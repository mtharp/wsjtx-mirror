#ifndef MESSAGE_SERVER_HPP__
#define MESSAGE_SERVER_HPP__

#include <QObject>
#include <QTime>
#include <QDateTime>
#include <QString>
#include <QByteArray>
#include <QHostAddress>

#include "Radio.hpp"

#include "pimpl_h.hpp"

//
// MessageServer - a reference implementation of a message server
//                  matching the MessageClient class at the other end
//                  of the wire
//
// This class is fully functioning and suitable for use in C++
// applications that use the Qt framework. Other applications should
// use this classes' implementation as a reference implementation.
//
class MessageServer
  : public QObject
{
  Q_OBJECT;

public:
  using port_type = quint16;
  using Frequency = Radio::Frequency;

  MessageServer (QObject * parent = nullptr);

  // start or restart the server, if the multicast_group_address
  // argument is given it is assumed to be a multicast group address
  // which the server will join
  Q_SLOT void start (port_type port, QHostAddress const& multicast_group_address = QHostAddress {});

  // ask the client with identification 'id' to make the same action
  // as a double click on the decode would
  //
  // note that the client is not obliged to take any action and only
  // takes any action if the decode is present and is a CQ or QRZ message
  Q_SLOT void reply (QString const& id, QTime time, qint32 snr, float delta_time, quint32 delta_frequency
                     , QString const& mode, QString const& message);

  // ask the client with identification 'id' to replay all decodes
  Q_SLOT void replay (QString const& id);

  // ask the client with identification 'id' to halt transmitting immediately
  Q_SLOT void halt_tx (QString const& id);

  // ask the client with identification 'id' to set the free text message
  Q_SLOT void free_text (QString const& id, QString const& text);

  // the following signals are emitted when a client broadcasts the
  // matching message
  Q_SIGNAL void client_opened (QString const& id);
  Q_SIGNAL void status_update (QString const& id, Frequency, QString const& mode, QString const& dx_call
                               , QString const& report, QString const& tx_mode, bool transmitting);
  Q_SIGNAL void client_closed (QString const& id);
  Q_SIGNAL void decode (bool is_new, QString const& id, QTime time, qint32 snr, float delta_time
                        , quint32 delta_frequency, QString const& mode, QString const& message);
  Q_SIGNAL void qso_logged (QString const& id, QDateTime time, QString const& dx_call, QString const& dx_grid
                            , Frequency dial_frequency, QString const& mode, QString const& report_sent
                            , QString const& report_received, QString const& tx_power, QString const& comments
                            , QString const& name);
  Q_SIGNAL void clear_decodes (QString const& id);

  // this signal is emitted when a network error occurs
  Q_SIGNAL void error (QString const&) const;

private:
  class impl;
  pimpl<impl> m_;
};

#endif
