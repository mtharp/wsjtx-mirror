#include "MetaDataRegistry.hpp"

#include <QMetaType>
#include <QItemEditorFactory>
#include <QStandardItemEditorCreator>

#include "Radio.hpp"
#include "FrequencyList.hpp"
#include "AudioDevice.hpp"
#include "Configuration.hpp"
#include "StationList.hpp"
#include "Transceiver.hpp"
#include "TransceiverFactory.hpp"
#include "WFPalette.hpp"

#include "FrequencyLineEdit.hpp"

void register_types ()
{
  // Default custom item view delegates
  auto factory = new QItemEditorFactory;

  // Radio namespace
  auto frequency_type_id = qRegisterMetaType<Radio::Frequency> ("Frequency");
  factory->registerEditor (frequency_type_id, new QStandardItemEditorCreator<FrequencyLineEdit> ());
  auto frequency_delta_type_id = qRegisterMetaType<Radio::FrequencyDelta> ("FrequencyDelta");
  factory->registerEditor (frequency_delta_type_id, new QStandardItemEditorCreator<FrequencyDeltaLineEdit> ());

  // Frequency list model
  qRegisterMetaType<FrequencyList::Item> ("Item");
  qRegisterMetaTypeStreamOperators<FrequencyList::Item> ("Item");
  qRegisterMetaType<FrequencyList::FrequencyItems> ("FrequencyItems");
  qRegisterMetaTypeStreamOperators<FrequencyList::FrequencyItems> ("FrequencyItems");

  // Audio device
  qRegisterMetaType<AudioDevice::Channel> ("AudioDevice::Channel");

  // Configuration
  qRegisterMetaType<Configuration::DataMode> ("Configuration::DataMode");
  qRegisterMetaTypeStreamOperators<Configuration::DataMode> ("Configuration::DataMode");
  qRegisterMetaType<Configuration::Type2MsgGen> ("Configuration::Type2MsgGen");
  qRegisterMetaTypeStreamOperators<Configuration::Type2MsgGen> ("Configuration::Type2MsgGen");

  // Station details
  qRegisterMetaType<StationList::Station> ("Station");
  qRegisterMetaTypeStreamOperators<StationList::Station> ("Station");
  qRegisterMetaType<StationList::Stations> ("Stations");
  qRegisterMetaTypeStreamOperators<StationList::Stations> ("Stations");

  // Transceiver
  qRegisterMetaType<Transceiver::TransceiverState> ("Transceiver::TransceiverState");
  qRegisterMetaType<Transceiver::MODE> ("Transceiver::MODE");

  // Transceiver factory
  qRegisterMetaType<TransceiverFactory::DataBits> ("TransceiverFactory::DataBits");
  qRegisterMetaTypeStreamOperators<TransceiverFactory::DataBits> ("TransceiverFactory::DataBits");
  qRegisterMetaType<TransceiverFactory::StopBits> ("TransceiverFactory::StopBits");
  qRegisterMetaTypeStreamOperators<TransceiverFactory::StopBits> ("TransceiverFactory::StopBits");
  qRegisterMetaType<TransceiverFactory::Handshake> ("TransceiverFactory::Handshake");
  qRegisterMetaTypeStreamOperators<TransceiverFactory::Handshake> ("TransceiverFactory::Handshake");
  qRegisterMetaType<TransceiverFactory::PTTMethod> ("TransceiverFactory::PTTMethod");
  qRegisterMetaTypeStreamOperators<TransceiverFactory::PTTMethod> ("TransceiverFactory::PTTMethod");
  qRegisterMetaType<TransceiverFactory::TXAudioSource> ("TransceiverFactory::TXAudioSource");
  qRegisterMetaTypeStreamOperators<TransceiverFactory::TXAudioSource> ("TransceiverFactory::TXAudioSource");
  qRegisterMetaType<TransceiverFactory::SplitMode> ("TransceiverFactory::SplitMode");
  qRegisterMetaTypeStreamOperators<TransceiverFactory::SplitMode> ("TransceiverFactory::SplitMode");

  // Waterfall palette
  qRegisterMetaTypeStreamOperators<WFPalette::Colours> ("Colours");

  QItemEditorFactory::setDefaultFactory (factory);
}
