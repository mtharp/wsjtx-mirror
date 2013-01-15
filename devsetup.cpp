#include "devsetup.h"
#include "mainwindow.h"
#include <QDebug>
#include <portaudio.h>

#define MAXDEVICES 100

//----------------------------------------------------------- DevSetup()
DevSetup::DevSetup(QWidget *parent) :	QDialog(parent)
{
  ui.setupUi(this);	                              //setup the dialog form
  m_restartSoundIn=false;
  m_restartSoundOut=false;
}

DevSetup::~DevSetup()
{
}

void DevSetup::initDlg()
{
  int k,id;
  int numDevices=Pa_GetDeviceCount();

  const PaDeviceInfo *pdi;
  int nchin;
  int nchout;
  char *p,*p1;
  char p2[50];
  char pa_device_name[128];
  char pa_device_hostapi[128];

  k=0;
#ifdef WIN32
// Needs work to compile for Linux
  for(id=0; id<numDevices; id++ )  {
    pdi=Pa_GetDeviceInfo(id);
    nchin=pdi->maxInputChannels;
    if(nchin>0) {
      m_inDevList[k]=id;
      k++;
      sprintf((char*)(pa_device_name),"%s",pdi->name);
      sprintf((char*)(pa_device_hostapi),"%s",
              Pa_GetHostApiInfo(pdi->hostApi)->name);

      p1=(char*)"";
      p=strstr(pa_device_hostapi,"MME");
      if(p!=NULL) p1=(char*)"MME";
      p=strstr(pa_device_hostapi,"Direct");
      if(p!=NULL) p1=(char*)"DirectX";
      p=strstr(pa_device_hostapi,"WASAPI");
      if(p!=NULL) p1=(char*)"WASAPI";
      p=strstr(pa_device_hostapi,"ASIO");
      if(p!=NULL) p1=(char*)"ASIO";
      p=strstr(pa_device_hostapi,"WDM-KS");
      if(p!=NULL) p1=(char*)"WDM-KS";

      sprintf(p2,"%2d   %d   %-8s  %-39s",id,nchin,p1,pa_device_name);
      QString t(p2);
      ui.comboBoxSndIn->addItem(t);
    }
  }
#endif

  k=0;
  for(id=0; id<numDevices; id++ )  {
    pdi=Pa_GetDeviceInfo(id);
    nchout=pdi->maxOutputChannels;
    if(nchout>0) {
      m_outDevList[k]=id;
      k++;
      sprintf((char*)(pa_device_name),"%s",pdi->name);
      sprintf((char*)(pa_device_hostapi),"%s",
              Pa_GetHostApiInfo(pdi->hostApi)->name);

#ifdef WIN32
// Needs work to compile for Linux
      p1=(char*)"";
      p=strstr(pa_device_hostapi,"MME");

      if(p!=NULL) p1=(char*)"MME";
      p=strstr(pa_device_hostapi,"Direct");
      if(p!=NULL) p1=(char*)"DirectX";
      p=strstr(pa_device_hostapi,"WASAPI");
      if(p!=NULL) p1=(char*)"WASAPI";
      p=strstr(pa_device_hostapi,"ASIO");
      if(p!=NULL) p1=(char*)"ASIO";
      p=strstr(pa_device_hostapi,"WDM-KS");
      if(p!=NULL) p1=(char*)"WDM-KS";
      sprintf(p2,"%2d   %d   %-8s  %-39s",id,nchout,p1,pa_device_name);
      QString t(p2);
      ui.comboBoxSndOut->addItem(t);
#endif
    }
  }

  connect(&p4, SIGNAL(readyReadStandardOutput()),
                    this, SLOT(p4ReadFromStdout()));
  connect(&p4, SIGNAL(readyReadStandardError()),
          this, SLOT(p4ReadFromStderr()));
  connect(&p4, SIGNAL(error(QProcess::ProcessError)),
          this, SLOT(p4Error()));
  p4.start("rigctl -l");
  p4.waitForFinished(1000);

  ui.myCallEntry->setText(m_myCall);
  ui.myGridEntry->setText(m_myGrid);
  ui.idIntSpinBox->setValue(m_idInt);
  ui.pttComboBox->setCurrentIndex(m_pttPort);
  ui.saveDirEntry->setText(m_saveDir);
  ui.comboBoxSndIn->setCurrentIndex(m_nDevIn);
  ui.comboBoxSndOut->setCurrentIndex(m_nDevOut);
  m_paInDevice=m_inDevList[m_nDevIn];
  m_paOutDevice=m_outDevList[m_nDevOut];
  ui.cbGrid6->setChecked(m_grid6);
  ui.cbEnableCAT->setChecked(m_catEnabled);
  ui.catPortComboBox->setEnabled(m_catEnabled);
  ui.rigComboBox->setEnabled(m_catEnabled);
  ui.serialRateComboBox->setEnabled(m_catEnabled);
  ui.dataBitsComboBox->setEnabled(m_catEnabled);
  ui.stopBitsComboBox->setEnabled(m_catEnabled);
  ui.handshakeComboBox->setEnabled(m_catEnabled);

  ui.rigComboBox->setCurrentIndex(m_rigIndex);
  ui.catPortComboBox->setCurrentIndex(m_catPortIndex);
  ui.serialRateComboBox->setCurrentIndex(m_serialRateIndex);
  ui.dataBitsComboBox->setCurrentIndex(m_dataBitsIndex);
  ui.stopBitsComboBox->setCurrentIndex(m_stopBitsIndex);
  ui.handshakeComboBox->setCurrentIndex(m_handshakeIndex);

  QString t;
  t.sprintf("%d",m_BFO);
  ui.bfoLineEdit->setText(t);
}

//------------------------------------------------------- accept()
void DevSetup::accept()
{
  // Called when OK button is clicked.
  // Check to see whether SoundInThread must be restarted,
  // and save user parameters.

  if(m_nDevIn!=ui.comboBoxSndIn->currentIndex() or
     m_paInDevice!=m_inDevList[m_nDevIn]) m_restartSoundIn=true;

  if(m_nDevOut!=ui.comboBoxSndOut->currentIndex() or
     m_paOutDevice!=m_outDevList[m_nDevOut]) m_restartSoundOut=true;

  m_myCall=ui.myCallEntry->text();
  m_myGrid=ui.myGridEntry->text();
  m_idInt=ui.idIntSpinBox->value();
  m_pttPort=ui.pttComboBox->currentIndex();
  m_saveDir=ui.saveDirEntry->text();
  m_nDevIn=ui.comboBoxSndIn->currentIndex();
  m_paInDevice=m_inDevList[m_nDevIn];
  m_nDevOut=ui.comboBoxSndOut->currentIndex();
  m_paOutDevice=m_outDevList[m_nDevOut];
  m_rigIndex=ui.rigComboBox->currentIndex();
  m_serialRateIndex=ui.serialRateComboBox->currentIndex();
  m_dataBitsIndex=ui.dataBitsComboBox->currentIndex();
  m_stopBitsIndex=ui.stopBitsComboBox->currentIndex();
  m_handshakeIndex=ui.handshakeComboBox->currentIndex();

  QDialog::accept();
}

void DevSetup::on_myCallEntry_editingFinished()
{
  QString t=ui.myCallEntry->text();
  ui.myCallEntry->setText(t.toUpper());
}

void DevSetup::on_myGridEntry_editingFinished()
{
  QString t=ui.myGridEntry->text();
  t=t.mid(0,4).toUpper()+t.mid(4,2).toLower();
  ui.myGridEntry->setText(t);
}

void DevSetup::on_bfoLineEdit_editingFinished()
{
  m_BFO=ui.bfoLineEdit->text().toInt();
}

void DevSetup::on_cbGrid6_toggled(bool b)
{
  m_grid6=b;
}

void DevSetup::on_cbEnableCAT_toggled(bool b)
{
  m_catEnabled=b;
  ui.catPortComboBox->setEnabled(b);
  ui.rigComboBox->setEnabled(b);
  ui.serialRateComboBox->setEnabled(b);
  ui.dataBitsComboBox->setEnabled(b);
  ui.stopBitsComboBox->setEnabled(b);
  ui.handshakeComboBox->setEnabled(b);
}

void DevSetup::on_rigComboBox_activated(int n)
{
  m_rigIndex=n;
  m_rig=ui.rigComboBox->itemText(n).split(" ").at(0).toInt();
}

void DevSetup::on_catPortComboBox_activated(int index)
{
  m_catPortIndex=index;
  m_catPort=ui.catPortComboBox->itemText(index);
}

void DevSetup::on_serialRateComboBox_activated(int index)
{
  m_serialRateIndex=index;
  m_serialRate=ui.serialRateComboBox->itemText(index).toInt();
}

void DevSetup::on_dataBitsComboBox_activated(int index)
{
  m_dataBitsIndex=index;
  m_dataBits=ui.dataBitsComboBox->itemText(index).toInt();
}

void DevSetup::on_stopBitsComboBox_activated(int index)
{
  m_stopBitsIndex=index;
  m_stopBits=ui.stopBitsComboBox->itemText(index).toInt();
}

void DevSetup::on_handshakeComboBox_activated(int index)
{
  m_handshakeIndex=index;
  m_handshake=ui.handshakeComboBox->itemText(index);
}

void DevSetup::p4ReadFromStdout()                        //p4readFromStdout
{
  while(p4.canReadLine()) {
    QString t(p4.readLine());
    QString t1,t2,t3;
    if(t.mid(0,6)!=" Rig #") {
      t1=t.mid(0,6);
      t2=t.mid(8,22).trimmed();
      t3=t.mid(31,23).trimmed();
      t=t1 + "  " + t2 + "  " + t3;
//      qDebug() << t;
      ui.rigComboBox->addItem(t);
    }
  }
}

void DevSetup::p4ReadFromStderr()                        //p4readFromStderr
{
  QByteArray t=p4.readAllStandardError();
  if(t.length()>0) {
    msgBox(t);
  }
}

void DevSetup::p4Error()                                     //p4rror
{
  msgBox("Error running 'rigctl -l'.");
}

void DevSetup::msgBox(QString t)                             //msgBox
{
  msgBox0.setText(t);
  msgBox0.exec();
}

void DevSetup::on_idIntSpinBox_valueChanged(int n)
{
  m_idInt=n;
}
