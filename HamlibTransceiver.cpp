#include "HamlibTransceiver.hpp"

#include <cstring>

#include <QByteArray>
#include <QString>
#include <QStandardPaths>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QDebug>

#include "moc_HamlibTransceiver.cpp"

namespace
{
  // Unfortunately bandwidth is conflated  with mode, this is probably
  // because Icom do  the same. So we have to  care about bandwidth if
  // we want  to set  mode otherwise we  will end up  setting unwanted
  // bandwidths every time we change mode.  The best we can do via the
  // Hamlib API is to request the  normal option for the mode and hope
  // that an appropriate filter is selected.  Also ensure that mode is
  // only set is absolutely necessary.  On Icoms (and probably others)
  // the filter is  selected by number without checking  the actual BW
  // so unless the  "normal" defaults are set on the  rig we won't get
  // desirable results.
  //
  // As  an ultimate  workaround make  sure  the user  always has  the
  // option to skip mode setting altogether.

  // reroute Hamlib diagnostic messages to Qt
  int debug_callback (enum rig_debug_level_e level, rig_ptr_t /* arg */, char const * format, va_list ap)
  {
    QString message;
    static char const fmt[] = "Hamlib: %s";
    message = message.vsprintf (format, ap).trimmed ();

    switch (level)
      {
      case RIG_DEBUG_BUG:
        qFatal (fmt, message.toLocal8Bit ().data ());
        break;

      case RIG_DEBUG_ERR:
        qCritical (fmt, message.toLocal8Bit ().data ());
        break;

      case RIG_DEBUG_WARN:
        qWarning (fmt, message.toLocal8Bit ().data ());
        break;

      default:
        qDebug (fmt, message.toLocal8Bit ().data ());
        break;
      }

    return 0;
  }

  // callback function that receives transceiver capabilities from the
  // hamlib libraries
  int rigCallback (rig_caps const * caps, void * callback_data)
  {
    TransceiverFactory::Transceivers * rigs = reinterpret_cast<TransceiverFactory::Transceivers *> (callback_data);

    QString key;
    if (RIG_MODEL_DUMMY == caps->rig_model)
      {
        key = TransceiverFactory::basic_transceiver_name_;
      }
    else
      {
        key = QString::fromLatin1 (caps->mfg_name).trimmed ()
          + ' '+ QString::fromLatin1 (caps->model_name).trimmed ()
          // + ' '+ QString::fromLatin1 (caps->version).trimmed ()
          // + " (" + QString::fromLatin1 (rig_strstatus (caps->status)).trimmed () + ')'
          ;
      }

    auto port_type = TransceiverFactory::Capabilities::none;
    switch (caps->port_type)
      {
      case RIG_PORT_SERIAL:
        port_type = TransceiverFactory::Capabilities::serial;
        break;

      case RIG_PORT_NETWORK:
        port_type = TransceiverFactory::Capabilities::network;
        break;

      case RIG_PORT_USB:
        port_type = TransceiverFactory::Capabilities::usb;
        break;

      default: break;
      }
    (*rigs)[key] = TransceiverFactory::Capabilities (caps->rig_model
                                                     , port_type
                                                     , RIG_MODEL_DUMMY != caps->rig_model
                                                     && (RIG_PTT_RIG == caps->ptt_type
                                                         || RIG_PTT_RIG_MICDATA == caps->ptt_type)
                                                     , RIG_PTT_RIG_MICDATA == caps->ptt_type);

    return 1;			// keep them coming
  }

  // int frequency_change_callback (RIG * /* rig */, vfo_t vfo, freq_t f, rig_ptr_t arg)
  // {
  //   (void)vfo;			// unused in release build

  //   Q_ASSERT (vfo == RIG_VFO_CURR); // G4WJS: at the time of writing only current VFO is signalled by hamlib

  //   HamlibTransceiver * transceiver (reinterpret_cast<HamlibTransceiver *> (arg));
  //   Q_EMIT transceiver->frequency_change (f, Transceiver::A);
  //   return RIG_OK;
  // }

  class hamlib_tx_vfo_fixup final
  {
  public:
    hamlib_tx_vfo_fixup (RIG * rig, vfo_t tx_vfo)
      : rig_ {rig}
    {
      original_vfo_ = rig_->state.tx_vfo;
      rig_->state.tx_vfo = tx_vfo;
    }

    ~hamlib_tx_vfo_fixup ()
    {
      rig_->state.tx_vfo = original_vfo_;
    }

  private:
    RIG * rig_;
    vfo_t original_vfo_;
  };
}

freq_t HamlibTransceiver::dummy_frequency_;
rmode_t HamlibTransceiver::dummy_mode_ {RIG_MODE_NONE};

void HamlibTransceiver::register_transceivers (TransceiverFactory::Transceivers * registry)
{
  rig_set_debug_callback (debug_callback, nullptr);

#if WSJT_HAMLIB_TRACE
#if WSJT_HAMLIB_VERBOSE_TRACE
  rig_set_debug (RIG_DEBUG_TRACE);
#else
  rig_set_debug (RIG_DEBUG_VERBOSE);
#endif
#elif defined (NDEBUG)
  rig_set_debug (RIG_DEBUG_ERR);
#else
  rig_set_debug (RIG_DEBUG_WARN);
#endif

  rig_load_all_backends ();
  rig_list_foreach (rigCallback, registry);
}

void HamlibTransceiver::RIGDeleter::cleanup (RIG * rig)
{
  if (rig)
    {
      // rig->state.obj = 0;
      rig_cleanup (rig);
    }
}

HamlibTransceiver::HamlibTransceiver (TransceiverFactory::PTTMethod ptt_type, QString const& ptt_port)
  : PollingTransceiver {0}
  , rig_ {rig_init (RIG_MODEL_DUMMY)}
  , back_ptt_port_ {false}
  , is_dummy_ {true}
  , reversed_ {false}
  , mode_query_works_ {true}
  , split_query_works_ {true}
  , tickle_hamlib_ {false}
  , get_vfo_works_ {true}
{
  if (!rig_)
    {
      throw error {tr ("Hamlib initialisation error")};
    }

  switch (ptt_type)
    {
    case TransceiverFactory::PTT_method_VOX:
      set_conf ("ptt_type", "None");
      break;

    case TransceiverFactory::PTT_method_CAT:
      // Use the default PTT_TYPE for the rig (defined in the Hamlib
      // rig back-end capabilities).
      break;

    case TransceiverFactory::PTT_method_DTR:
    case TransceiverFactory::PTT_method_RTS:
      if (!ptt_port.isEmpty ())
        {
#if defined (WIN32)
          set_conf ("ptt_pathname", ("\\\\.\\" + ptt_port).toLatin1 ().data ());
#else
          set_conf ("ptt_pathname", ptt_port.toLatin1 ().data ());
#endif
        }

      if (TransceiverFactory::PTT_method_DTR == ptt_type)
        {
          set_conf ("ptt_type", "DTR");
        }
      else
        {
          set_conf ("ptt_type", "RTS");
        }
    }
}

HamlibTransceiver::HamlibTransceiver (int model_number, TransceiverFactory::ParameterPack const& params)
  : PollingTransceiver {params.poll_interval}
  , rig_ {rig_init (model_number)}
  , back_ptt_port_ {TransceiverFactory::TX_audio_source_rear == params.audio_source}
  , is_dummy_ {RIG_MODEL_DUMMY == model_number}
  , reversed_ {false}
  , mode_query_works_ {rig_ && rig_->caps->get_mode}
  , split_query_works_ {rig_ && rig_->caps->get_split_vfo}
  , tickle_hamlib_ {false}
  , get_vfo_works_ {true}
{
  if (!rig_)
    {
      throw error {tr ("Hamlib initialisation error")};
    }

  // rig_->state.obj = this;

  {
    //
    // user defined Hamlib settings
    //
    auto settings_file_name = QStandardPaths::locate (
#if QT_VERSION >= 0x050500
                                                 QStandardPaths::AppConfigLocation
#else
                                                 QStandardPaths::ConfigLocation
#endif
                                                 , "hamlib_settings.json");
    if (!settings_file_name.isEmpty ())
      {
	QFile settings_file {settings_file_name};
	if (settings_file.open (QFile::ReadOnly))
	  {
	    QJsonParseError status;
	    auto settings_doc = QJsonDocument::fromJson (settings_file.readAll (), &status);
	    if (status.error)
	      {
		throw error {tr ("Hamlib settings file error: %1 at character offset %2")
		    .arg (status.errorString ()).arg (status.offset)};
	      }
	    if (!settings_doc.isObject ())
	      {
		throw error {tr ("Hamlib settings file error: top level must be a JSON object")};
	      }
	    auto const& settings = settings_doc.object ();

	    //
	    // configuration settings
	    //
	    auto const& config = settings["config"];
	    if (!config.isUndefined ())
	      {
		if (!config.isObject ())
		  {
		    throw error {tr ("Hamlib settings file error: config must be a JSON object")};
		  }
		auto const& config_list = config.toObject ();
		for (auto item = config_list.constBegin (); item != config_list.constEnd (); ++item)
		  {
		    set_conf (item.key ().toLocal8Bit ().constData ()
			      , (*item).toVariant ().toString ().toLocal8Bit ().constData ());
		  }
	      }
	  }
      }
  }

  if (RIG_MODEL_DUMMY != model_number)
    {
      switch (rig_->caps->port_type)
        {
        case RIG_PORT_SERIAL:
          if (!params.serial_port.isEmpty ())
            {
              set_conf ("rig_pathname", params.serial_port.toLatin1 ().data ());
            }
          set_conf ("serial_speed", QByteArray::number (params.baud).data ());
          set_conf ("data_bits", TransceiverFactory::seven_data_bits == params.data_bits ? "7" : "8");
          set_conf ("stop_bits", TransceiverFactory::one_stop_bit == params.stop_bits ? "1" : "2");

          switch (params.handshake)
            {
            case TransceiverFactory::handshake_none: set_conf ("serial_handshake", "None"); break;
            case TransceiverFactory::handshake_XonXoff: set_conf ("serial_handshake", "XONXOFF"); break;
            case TransceiverFactory::handshake_hardware: set_conf ("serial_handshake", "Hardware"); break;
            }

          if (params.force_dtr)
            {
              set_conf ("dtr_state", params.dtr_high ? "ON" : "OFF");
            }
          if (params.force_rts)
            {
              if (TransceiverFactory::handshake_hardware != params.handshake)
                {
                  set_conf ("rts_state", params.rts_high ? "ON" : "OFF");
                }
            }
          break;

        case RIG_PORT_NETWORK:
          if (!params.network_port.isEmpty ())
            {
              set_conf ("rig_pathname", params.network_port.toLatin1 ().data ());
            }
          break;

        case RIG_PORT_USB:
          if (!params.usb_port.isEmpty ())
            {
              set_conf ("rig_pathname", params.usb_port.toLatin1 ().data ());
            }
          break;

        default:
          throw error {tr ("Unsupported CAT type")};
          break;
        }
    }

  switch (params.ptt_type)
    {
    case TransceiverFactory::PTT_method_VOX:
      set_conf ("ptt_type", "None");
      break;

    case TransceiverFactory::PTT_method_CAT:
      // Use the default PTT_TYPE for the rig (defined in the Hamlib
      // rig back-end capabilities).
      break;

    case TransceiverFactory::PTT_method_DTR:
    case TransceiverFactory::PTT_method_RTS:
      if (!params.ptt_port.isEmpty ()
          && params.ptt_port != "None"
          && (RIG_MODEL_DUMMY == model_number
              || params.ptt_port != params.serial_port))
        {
#if defined (WIN32)
          set_conf ("ptt_pathname", ("\\\\.\\" + params.ptt_port).toLatin1 ().data ());
#else
          set_conf ("ptt_pathname", params.ptt_port.toLatin1 ().data ());
#endif
        }

      if (TransceiverFactory::PTT_method_DTR == params.ptt_type)
        {
          set_conf ("ptt_type", "DTR");
        }
      else
        {
          set_conf ("ptt_type", "RTS");
        }
    }

  // Make Icom CAT split commands less glitchy
  set_conf ("no_xchg", "1");

  // would be nice to get events but not supported on Windows and also not on a lot of rigs
  // rig_set_freq_callback (rig_.data (), &frequency_change_callback, this);
}

HamlibTransceiver::~HamlibTransceiver ()
{
}

void HamlibTransceiver::error_check (int ret_code, QString const& doing) const
{
  if (RIG_OK != ret_code)
    {
      TRACE_CAT_POLL ("error:" << rigerror (ret_code));
      throw error {tr ("Hamlib error: %1 while %2").arg (rigerror (ret_code)).arg (doing)};
    }
}

void HamlibTransceiver::do_start ()
{
  TRACE_CAT (QString::fromLatin1 (rig_->caps->mfg_name).trimmed () << QString::fromLatin1 (rig_->caps->model_name).trimmed ());

  error_check (rig_open (rig_.data ()), tr ("opening connection to rig"));

  // the Net rigctl back end promises all functions work but we must
  // test get_vfo as it determines our strategy for Icom rigs
  vfo_t vfo;
  int rc = rig_get_vfo (rig_.data (), &vfo);
  if (-RIG_ENAVAIL == rc || -RIG_ENIMPL == rc)
    {
      get_vfo_works_ = false;
    }
  else
    {
      error_check (rc, "getting current VFO");
    }

  if (!is_dummy_ && rig_->caps->set_split_vfo) // if split is possible
                                               // do some extra setup
    {
      freq_t f1;
      freq_t f2;
      rmode_t m {RIG_MODE_USB};
      rmode_t mb;
      pbwidth_t w {RIG_PASSBAND_NORMAL};
      pbwidth_t wb;
      if ((!get_vfo_works_ || !rig_->caps->get_vfo)
          && (rig_->caps->set_vfo || rig_has_vfo_op (rig_.data (), RIG_OP_TOGGLE)))
        {
          // Icom have deficient CAT protocol with no way of reading which
          // VFO is selected or if SPLIT is selected so we have to simply
          // assume it is as when we started by setting at open time right
          // here. We also gather/set other initial state.
          error_check (rig_get_freq (rig_.data (), RIG_VFO_CURR, &f1), tr ("getting current frequency"));
          TRACE_CAT ("current frequency =" << f1);

          error_check (rig_get_mode (rig_.data (), RIG_VFO_CURR, &m, &w), tr ("getting current mode"));
          TRACE_CAT ("current mode =" << rig_strrmode (m) << "bw =" << w);

          if (!rig_->caps->set_vfo)
            {
              TRACE_CAT ("rig_vfo_op TOGGLE");
              error_check (rig_vfo_op (rig_.data (), RIG_VFO_CURR, RIG_OP_TOGGLE), tr ("exchanging VFOs"));
            }
          else
            {
              TRACE_CAT ("rig_set_vfo to other VFO");
              error_check (rig_set_vfo (rig_.data (), rig_->state.vfo_list & RIG_VFO_B ? RIG_VFO_B : RIG_VFO_SUB), tr ("setting current VFO"));
            }

          error_check (rig_get_freq (rig_.data (), RIG_VFO_CURR, &f2), tr ("getting other VFO frequency"));
          TRACE_CAT ("rig_get_freq other frequency =" << f2);

          error_check (rig_get_mode (rig_.data (), RIG_VFO_CURR, &mb, &wb), tr ("getting other VFO mode"));
          TRACE_CAT ("rig_get_mode other mode =" << rig_strrmode (mb) << "bw =" << wb);

          update_other_frequency (f2);

          if (!rig_->caps->set_vfo)
            {
              TRACE_CAT ("rig_vfo_op TOGGLE");
              error_check (rig_vfo_op (rig_.data (), RIG_VFO_CURR, RIG_OP_TOGGLE), tr ("exchanging VFOs"));
            }
          else
            {
              TRACE_CAT ("rig_set_vfo A/MAIN");
              error_check (rig_set_vfo (rig_.data (), rig_->state.vfo_list & RIG_VFO_A ? RIG_VFO_A : RIG_VFO_MAIN), tr ("setting current VFO"));
            }

          if (f1 != f2 || m != mb || w != wb)	// we must have started with MAIN/A
            {
              update_rx_frequency (f1);
            }
          else
            {
              error_check (rig_get_freq (rig_.data (), RIG_VFO_CURR, &f1), tr ("getting frequency"));
              TRACE_CAT ("rig_get_freq frequency =" << f1);

              error_check (rig_get_mode (rig_.data (), RIG_VFO_CURR, &m, &w), tr ("getting mode"));
              TRACE_CAT ("rig_get_mode mode =" << rig_strrmode (m) << "bw =" << w);

              update_rx_frequency (f1);
            }

          // TRACE_CAT ("rig_set_split_vfo split off");
          // error_check (rig_set_split_vfo (rig_.data (), RIG_VFO_CURR, RIG_SPLIT_OFF, RIG_VFO_CURR), tr ("setting split off"));
          // update_split (false);
        }
      else
        {
          vfo_t v {RIG_VFO_A};  // assume RX always on VFO A/MAIN

          if (get_vfo_works_ && rig_->caps->get_vfo)
            {
              error_check (rig_get_vfo (rig_.data (), &v), tr ("getting current VFO")); // has side effect of establishing current VFO inside hamlib
              TRACE_CAT ("rig_get_vfo current VFO = " << rig_strvfo (v));
            }

          reversed_ = RIG_VFO_B == v;

          if (mode_query_works_ && !(rig_->caps->targetable_vfo & (RIG_TARGETABLE_MODE | RIG_TARGETABLE_PURE)))
            {
              if (RIG_OK == rig_get_mode (rig_.data (), RIG_VFO_CURR, &m, &w))
                {
                  TRACE_CAT ("rig_get_mode current mode =" << rig_strrmode (m) << "bw =" << w);
                }
              else
                {
                  mode_query_works_ = false;
                  // Some rigs (HDSDR) don't have a working way of
                  // reporting MODE so we give up on mode queries -
                  // sets will still cause an error
                  TRACE_CAT_POLL ("rig_get_mode can't do on this rig");
                }
            }
        }
      update_mode (map_mode (m));
    }

  tickle_hamlib_ = true;

  if (is_dummy_ && dummy_frequency_)
    {
      // return to where last dummy instance was
      // TODO: this is going to break down if multiple dummy rigs are used
      rig_set_freq (rig_.data (), RIG_VFO_CURR, dummy_frequency_);
      update_rx_frequency (dummy_frequency_);
      if (RIG_MODE_NONE != dummy_mode_)
        {
          rig_set_mode (rig_.data (), RIG_VFO_CURR, dummy_mode_, RIG_PASSBAND_NORMAL);
          update_mode (map_mode (dummy_mode_));
        }
    }

  poll ();

  TRACE_CAT ("exit" << state () << "reversed =" << reversed_);
}

void HamlibTransceiver::do_stop ()
{
  if (is_dummy_)
    {
      rig_get_freq (rig_.data (), RIG_VFO_CURR, &dummy_frequency_);
      if (mode_query_works_)
        {
          pbwidth_t width;
          rig_get_mode (rig_.data (), RIG_VFO_CURR, &dummy_mode_, &width);
        }
    }
  if (rig_)
    {
      rig_close (rig_.data ());
    }

  TRACE_CAT ("state:" << state () << "reversed =" << reversed_);
}

auto HamlibTransceiver::get_vfos () const -> std::tuple<vfo_t, vfo_t>
{
  if (get_vfo_works_ && rig_->caps->get_vfo)
    {
      vfo_t v;
      error_check (rig_get_vfo (rig_.data (), &v), tr ("getting current VFO")); // has side effect of establishing current VFO inside hamlib
      TRACE_CAT ("rig_get_vfo VFO = " << rig_strvfo (v));

      reversed_ = RIG_VFO_B == v;
    }
  else if (rig_->caps->set_vfo && rig_->caps->set_split_vfo)
    {
      // use VFO A/MAIN for main frequency and B/SUB for Tx
      // frequency if split since these type of radios can only
      // support this way around

      TRACE_CAT ("rig_set_vfo VFO = A/MAIN");
      error_check (rig_set_vfo (rig_.data (), rig_->state.vfo_list & RIG_VFO_A ? RIG_VFO_A : RIG_VFO_MAIN), tr ("setting current VFO"));
    }
  // else only toggle available but both VFOs should be substitutable 

  auto rx_vfo = rig_->state.vfo_list & RIG_VFO_A ? RIG_VFO_A : RIG_VFO_MAIN;
  auto tx_vfo = !is_dummy_ && state ().split ()
    ? (rig_->state.vfo_list & RIG_VFO_B ? RIG_VFO_B : RIG_VFO_SUB)
    : rx_vfo;
  if (reversed_)
    {
      TRACE_CAT ("reversing VFOs");
      std::swap (rx_vfo, tx_vfo);
    }

  TRACE_CAT ("RX VFO = " << rig_strvfo (rx_vfo) << " TX VFO = " << rig_strvfo (tx_vfo));
  return std::make_tuple (rx_vfo, tx_vfo);
}

void HamlibTransceiver::do_frequency (Frequency f, MODE m)
{
  TRACE_CAT (f << "mode:" << m << "reversed:" << reversed_);

  // for the 1st time as a band change may cause a recalled mode to be
  // set
  error_check (rig_set_freq (rig_.data (), RIG_VFO_CURR, f), tr ("setting frequency"));

  if (mode_query_works_ && UNK != m)
    {
      do_mode (m, false);

      // for the 2nd time because a mode change may have caused a
      // frequency change
      error_check (rig_set_freq (rig_.data (), RIG_VFO_CURR, f), tr ("setting frequency"));

      // for the second time because some rigs change mode according
      // to frequency such as the TS-2000 auto mode setting
      do_mode (m, false);
    }

  update_rx_frequency (f);
}

void HamlibTransceiver::do_tx_frequency (Frequency tx, bool rationalise_mode)
{
  TRACE_CAT (tx << "rationalise mode:" << rationalise_mode << "reversed:" << reversed_);

  if (!is_dummy_)               // split is meaning less if you can't
                                // see it
    {
      auto split = tx ? RIG_SPLIT_ON : RIG_SPLIT_OFF;
      update_split (tx);
      auto vfos = get_vfos ();
      // auto rx_vfo = std::get<0> (vfos); // or use RIG_VFO_CURR
      auto tx_vfo = std::get<1> (vfos);

      if (tx)
        {
          // Doing set split for the 1st of two times, this one
          // ensures that the internal Hamlib state is correct
          // otherwise rig_set_split_freq() will target the wrong VFO
          // on some rigs

          if (tickle_hamlib_)
            {
              // This potentially causes issues with the Elecraft K3
              // which will block setting split mode when it deems
              // cross mode split operation not possible. There's not
              // much we can do since the Hamlib Library needs this
              // call at least once to establish the Tx VFO. Best we
              // can do is only do this once per session.
              TRACE_CAT ("rig_set_split_vfo split =" << split);
              auto rc = rig_set_split_vfo (rig_.data (), RIG_VFO_CURR, split, tx_vfo);
              if (tx || (-RIG_ENAVAIL != rc && -RIG_ENIMPL != rc))
                {
                  // On rigs that can't have split controlled only throw an
                  // exception when an error other than command not accepted
                  // is returned when trying to leave split mode. This allows
                  // fake split mode and non-split mode to work without error
                  // on such rigs without having to know anything about the
                  // specific rig.
                  error_check (rc, tr ("setting/unsetting split mode"));
                }

              tickle_hamlib_ = false;
            }

          hamlib_tx_vfo_fixup fixup (rig_.data (), tx_vfo);
          // do this before setting the mode because changing band may
          // recall the last mode used on the target band
          error_check (rig_set_split_freq (rig_.data (), RIG_VFO_CURR, tx), tr ("setting split TX frequency"));

          if (rationalise_mode)
            {
              rmode_t current_mode;
              pbwidth_t current_width;

              error_check (rig_get_split_mode (rig_.data (), RIG_VFO_CURR, &current_mode, &current_width), tr ("getting mode of split TX VFO"));
              TRACE_CAT ("rig_get_split_mode mode = " << rig_strrmode (current_mode) << "bw =" << current_width);

              auto new_mode = map_mode (state ().mode ());
              if (new_mode != current_mode)
                {
                  TRACE_CAT ("rig_set_split_mode mode = " << rig_strrmode (new_mode));
                  error_check (rig_set_split_mode (rig_.data (), RIG_VFO_CURR, new_mode, RIG_PASSBAND_NORMAL), tr ("setting split TX VFO mode"));

                  // do this again as setting the mode may change the frequency
                  error_check (rig_set_split_freq (rig_.data (), RIG_VFO_CURR, tx), tr ("setting split TX frequency"));
                }
            }
        }

      // Enable split last since some rigs (Kenwood for one) come out
      // of split when you switch RX VFO (to set split mode above for
      // example). Also the Elecraft K3 will refuse to go to split
      // with certain VFO A/B mode combinations.
      TRACE_CAT ("rig_set_split_vfo split =" << split);
      auto rc = rig_set_split_vfo (rig_.data (), RIG_VFO_CURR, split, tx_vfo);
      if (tx || (-RIG_ENAVAIL != rc && -RIG_ENIMPL != rc))
        {
          // On rigs that can't have split controlled only throw an
          // exception when an error other than command not accepted
          // is returned when trying to leave split mode. This allows
          // fake split mode and non-split mode to work without error
          // on such rigs without having to know anything about the
          // specific rig.
          error_check (rc, tr ("setting/unsetting split mode"));
        }

      update_other_frequency (tx);
    }
}

void HamlibTransceiver::do_mode (MODE mode, bool rationalise)
{
  TRACE_CAT (mode << "rationalise:" << rationalise);

  auto vfos = get_vfos ();
  // auto rx_vfo = std::get<0> (vfos);
  auto tx_vfo = std::get<1> (vfos);

  rmode_t current_mode;
  pbwidth_t current_width;

  error_check (rig_get_mode (rig_.data (), RIG_VFO_CURR, &current_mode, &current_width), tr ("getting current VFO mode"));
  TRACE_CAT ("rig_get_mode mode = " << rig_strrmode (current_mode) << "bw =" << current_width);

  auto new_mode = map_mode (mode);
  if (new_mode != current_mode)
    {
      TRACE_CAT ("rig_set_mode mode = " << rig_strrmode (new_mode));
      error_check (rig_set_mode (rig_.data (), RIG_VFO_CURR, new_mode, RIG_PASSBAND_NORMAL), tr ("setting current VFO mode"));
    }
      
  if (!is_dummy_ && state ().split () && rationalise)
    {
      error_check (rig_get_split_mode (rig_.data (), RIG_VFO_CURR, &current_mode, &current_width), tr ("getting split TX VFO mode"));
      TRACE_CAT ("rig_get_split_mode mode = " << rig_strrmode (current_mode) << "bw =" << current_width);

      if (new_mode != current_mode)
        {
          TRACE_CAT ("rig_set_split_mode mode = " << rig_strrmode (new_mode));
          hamlib_tx_vfo_fixup fixup (rig_.data (), tx_vfo);
          error_check (rig_set_split_mode (rig_.data (), RIG_VFO_CURR, new_mode, RIG_PASSBAND_NORMAL), tr ("setting split TX VFO mode"));
        }
    }
  update_mode (mode);
}

void HamlibTransceiver::poll ()
{
#if !WSJT_TRACE_CAT_POLLS
#if defined (NDEBUG)
  rig_set_debug (RIG_DEBUG_ERR);
#else
  rig_set_debug (RIG_DEBUG_WARN);
#endif
#endif

  freq_t f;
  rmode_t m;
  pbwidth_t w;
  split_t s;

  if (get_vfo_works_ && rig_->caps->get_vfo)
    {
      vfo_t v;
      error_check (rig_get_vfo (rig_.data (), &v), tr ("getting current VFO")); // has side effect of establishing current VFO inside hamlib
      TRACE_CAT_POLL ("VFO =" << rig_strvfo (v));
      reversed_ = RIG_VFO_B == v;
    }

  error_check (rig_get_freq (rig_.data (), RIG_VFO_CURR, &f), tr ("getting current VFO frequency"));
  TRACE_CAT_POLL ("rig_get_freq frequency =" << f);
  update_rx_frequency (f);

  if (!is_dummy_ && state ().split () && (rig_->caps->targetable_vfo & (RIG_TARGETABLE_FREQ | RIG_TARGETABLE_PURE)))
    {
      // only read "other" VFO if in split, this allows rigs like
      // FlexRadio to work in Kenwood TS-2000 mode despite them
      // not having a FB; command

      // we can only probe current VFO unless rig supports reading
      // the other one directly because we can't glitch the Rx
      error_check (rig_get_freq (rig_.data ()
                                 , reversed_
                                 ? (rig_->state.vfo_list & RIG_VFO_A ? RIG_VFO_A : RIG_VFO_MAIN)
                                 : (rig_->state.vfo_list & RIG_VFO_B ? RIG_VFO_B : RIG_VFO_SUB)
                                 , &f), tr ("getting current VFO frequency"));
      TRACE_CAT_POLL ("rig_get_freq other VFO =" << f);
      update_other_frequency (f);
    }

  if (mode_query_works_)
    {
      // We have to ignore errors here because Yaesu FTdx... rigs can
      // report the wrong mode when transmitting split with different
      // modes per VFO. This is unfortunate because that is exactly
      // what you need to do to get 4kHz Rx b.w and modulation into
      // the rig through the data socket or USB. I.e.  USB for Rx and
      // DATA-USB for Tx.
      auto rc = rig_get_mode (rig_.data (), RIG_VFO_CURR, &m, &w);
      if (RIG_OK == rc)
        {
          TRACE_CAT_POLL ("rig_get_mode mode =" << rig_strrmode (m) << "bw =" << w);
          update_mode (map_mode (m));
        }
      else
        {
          TRACE_CAT_POLL ("rig_get_mode mode failed with rc:" << rc << "ignoring");
        }
    }

  if (!is_dummy_ && rig_->caps->get_split_vfo && split_query_works_)
    {
      vfo_t v {RIG_VFO_NONE};		// so we can tell if it doesn't get updated :(
      auto rc = rig_get_split_vfo (rig_.data (), RIG_VFO_CURR, &s, &v);
      if (-RIG_OK == rc && RIG_SPLIT_ON == s)
        {
          TRACE_CAT_POLL ("rig_get_split_vfo split = " << s << " VFO = " << rig_strvfo (v));
          update_split (true);
          // if (RIG_VFO_A == v)
          // 	{
          // 	  reversed_ = true;	// not sure if this helps us here
          // 	}
        }
      else if (-RIG_OK == rc)	// not split
        {
          TRACE_CAT_POLL ("rig_get_split_vfo split = " << s << " VFO = " << rig_strvfo (v));
          update_split (false);
        }
      else
        {
          // Some rigs (Icom) don't have a way of reporting SPLIT
          // mode
          TRACE_CAT_POLL ("rig_get_split_vfo can't do on this rig");
          // just report how we see it based on prior commands
          split_query_works_ = false;
        }
    }

  if (RIG_PTT_NONE != rig_->state.pttport.type.ptt && rig_->caps->get_ptt)
    {
      ptt_t p;
      auto rc = rig_get_ptt (rig_.data (), RIG_VFO_CURR, &p);
      if (-RIG_ENAVAIL != rc && -RIG_ENIMPL != rc) // may fail if
        // Net rig ctl and target doesn't
        // support command
        {
          error_check (rc, tr ("getting PTT state"));
          TRACE_CAT_POLL ("rig_get_ptt PTT =" << p);
          update_PTT (!(RIG_PTT_OFF == p));
        }
    }

#if !WSJT_TRACE_CAT_POLLS
#if WSJT_HAMLIB_TRACE
#if WSJT_HAMLIB_VERBOSE_TRACE
  rig_set_debug (RIG_DEBUG_TRACE);
#else
  rig_set_debug (RIG_DEBUG_VERBOSE);
#endif
#elif defined (NDEBUG)
  rig_set_debug (RIG_DEBUG_ERR);
#else
  rig_set_debug (RIG_DEBUG_WARN);
#endif
#endif
}

void HamlibTransceiver::do_ptt (bool on)
{
  TRACE_CAT (on << state () << "reversed =" << reversed_);
  if (on)
    {
      if (RIG_PTT_NONE != rig_->state.pttport.type.ptt)
        {
          TRACE_CAT ("rig_set_ptt PTT = true");
          error_check (rig_set_ptt (rig_.data (), RIG_VFO_CURR
                                    , RIG_PTT_RIG_MICDATA == rig_->caps->ptt_type && back_ptt_port_
                                    ? RIG_PTT_ON_DATA : RIG_PTT_ON), tr ("setting PTT on"));
        }
    }
  else
    {
      if (RIG_PTT_NONE != rig_->state.pttport.type.ptt)
        {
          TRACE_CAT ("rig_set_ptt PTT = false");
          error_check (rig_set_ptt (rig_.data (), RIG_VFO_CURR, RIG_PTT_OFF), tr ("setting PTT off"));
        }
    }

  update_PTT (on);
}

void HamlibTransceiver::set_conf (char const * item, char const * value)
{
  token_t token = rig_token_lookup (rig_.data (), item);
  if (RIG_CONF_END != token)	// only set if valid for rig model
    {
      error_check (rig_set_conf (rig_.data (), token, value), tr ("setting a configuration item"));
    }
}

QByteArray HamlibTransceiver::get_conf (char const * item)
{
  token_t token = rig_token_lookup (rig_.data (), item);
  QByteArray value {128, '\0'};
  if (RIG_CONF_END != token)	// only get if valid for rig model
    {
      error_check (rig_get_conf (rig_.data (), token, value.data ()), tr ("getting a configuration item"));
    }
  return value;
}

auto HamlibTransceiver::map_mode (rmode_t m) const -> MODE
{
  switch (m)
    {
    case RIG_MODE_AM:
    case RIG_MODE_SAM:
    case RIG_MODE_AMS:
    case RIG_MODE_DSB:
      return AM;

    case RIG_MODE_CW:
      return CW;

    case RIG_MODE_CWR:
      return CW_R;

    case RIG_MODE_USB:
    case RIG_MODE_ECSSUSB:
    case RIG_MODE_SAH:
    case RIG_MODE_FAX:
      return USB;

    case RIG_MODE_LSB:
    case RIG_MODE_ECSSLSB:
    case RIG_MODE_SAL:
      return LSB;

    case RIG_MODE_RTTY:
      return FSK;

    case RIG_MODE_RTTYR:
      return FSK_R;

    case RIG_MODE_PKTLSB:
      return DIG_L;

    case RIG_MODE_PKTUSB:
      return DIG_U;

    case RIG_MODE_FM:
    case RIG_MODE_WFM:
      return FM;

    case RIG_MODE_PKTFM:
      return DIG_FM;

    default:
      return UNK;
    }
}

rmode_t HamlibTransceiver::map_mode (MODE mode) const
{
  switch (mode)
    {
    case AM: return RIG_MODE_AM;
    case CW: return RIG_MODE_CW;
    case CW_R: return RIG_MODE_CWR;
    case USB: return RIG_MODE_USB;
    case LSB: return RIG_MODE_LSB;
    case FSK: return RIG_MODE_RTTY;
    case FSK_R: return RIG_MODE_RTTYR;
    case DIG_L: return RIG_MODE_PKTLSB;
    case DIG_U: return RIG_MODE_PKTUSB;
    case FM: return RIG_MODE_FM;
    case DIG_FM: return RIG_MODE_PKTFM;
    default: break;
    }
  return RIG_MODE_USB;	// quieten compiler grumble
}
