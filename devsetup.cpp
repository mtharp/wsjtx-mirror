#include "devsetup.h"
#include "mainwindow.h"
#include <QDebug>
#include <portaudio.h>

#define MAXDEVICES 100

//----------------------------------------------------------- DevSetup()
DevSetup::DevSetup(QWidget *parent) :	QDialog(parent)
{
  ui.setupUi(this);	//setup the dialog form
  m_restartSoundIn=false;
  m_restartSoundOut=false;
}

DevSetup::~DevSetup()
{
}

void DevSetup::initDlg()
{
  int k,id;
  int valid_devices=0;
  int minChan[MAXDEVICES];
  int maxChan[MAXDEVICES];
  int minSpeed[MAXDEVICES];
  int maxSpeed[MAXDEVICES];
  char hostAPI_DeviceName[MAXDEVICES][50];
  char s[60];
  int numDevices=Pa_GetDeviceCount();
  getDev(&numDevices,hostAPI_DeviceName,minChan,maxChan,minSpeed,maxSpeed);
  k=0;
  for(id=0; id<numDevices; id++)  {
    if(48000 >= minSpeed[id] && 48000 <= maxSpeed[id]) {
      m_inDevList[k]=id;
      k++;
      sprintf(s,"%2d   %d  %-49s",id,maxChan[id],hostAPI_DeviceName[id]);
      QString t(s);
      ui.comboBoxSndIn->addItem(t);
      valid_devices++;
    }
  }

  const PaDeviceInfo *pdi;
  int nchout;
  char *p,*p1;
  char p2[50];
  char pa_device_name[128];
  char pa_device_hostapi[128];

  k=0;
  for(id=0; id<numDevices; id++ )  {
    pdi=Pa_GetDeviceInfo(id);
    nchout=pdi->maxOutputChannels;
    if(nchout>=2) {
      m_outDevList[k]=id;
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

      sprintf(p2,"%2d   %-8s  %-39s",id,p1,pa_device_name);
      QString t(p2);
      ui.comboBoxSndOut->addItem(t);
    }
  }

  ui.myCallEntry->setText(m_myCall);
  ui.myGridEntry->setText(m_myGrid);
  ui.idIntSpinBox->setValue(m_idInt);
  ui.pttComboBox->setCurrentIndex(m_pttPort);
  ui.saveDirEntry->setText(m_saveDir);
  ui.dxccEntry->setText(m_dxccPfx);
  ui.timeoutSpinBox->setValue(m_timeout);
  ui.fCalSpinBox->setValue(m_fCal);
  ui.faddEntry->setText(QString::number(m_fAdd,'f',3));
  ui.comboBoxSndIn->setCurrentIndex(m_nDevIn);
  ui.comboBoxSndOut->setCurrentIndex(m_nDevOut);
  ui.cbInitIQplus->setChecked(m_initIQplus);
  ui.mult570SpinBox->setValue(m_mult570);
  ui.cal570SpinBox->setValue(m_cal570);
  sscanf(m_colors.toAscii(),"%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x%2x",
         &r,&g,&b,&r0,&g0,&b0,&r1,&g1,&b1,&r2,&g2,&b2,&r3,&g3,&b3);
  updateColorLabels();
  ui.sbBackgroundRed->setValue(r);
  ui.sbBackgroundGreen->setValue(g);
  ui.sbBackgroundBlue->setValue(b);
  ui.sbRed0->setValue(r0);
  ui.sbRed1->setValue(r1);
  ui.sbRed2->setValue(r2);
  ui.sbRed3->setValue(r3);
  ui.sbGreen0->setValue(g0);
  ui.sbGreen1->setValue(g1);
  ui.sbGreen2->setValue(g2);
  ui.sbGreen3->setValue(g3);
  ui.sbBlue0->setValue(b0);
  ui.sbBlue1->setValue(b1);
  ui.sbBlue2->setValue(b2);
  ui.sbBlue3->setValue(b3);

  m_paInDevice=m_inDevList[m_nDevIn];
  m_paOutDevice=m_outDevList[m_nDevOut];

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
  m_dxccPfx=ui.dxccEntry->text();
  m_timeout=ui.timeoutSpinBox->value();
  m_fCal=ui.fCalSpinBox->value();
  m_fAdd=ui.faddEntry->text().toDouble();
  m_nDevIn=ui.comboBoxSndIn->currentIndex();
  m_paInDevice=m_inDevList[m_nDevIn];
  m_nDevOut=ui.comboBoxSndOut->currentIndex();
  m_paOutDevice=m_outDevList[m_nDevOut];
  m_initIQplus=ui.cbInitIQplus->isChecked();
  m_mult570=ui.mult570SpinBox->value();
  m_cal570=ui.cal570SpinBox->value();

  QDialog::accept();
}

void DevSetup::on_cal570SpinBox_valueChanged(double ppm)
{
  m_cal570=ppm;
}

void DevSetup::on_mult570SpinBox_valueChanged(int mult)
{
  m_mult570=mult;
}

void DevSetup::updateColorLabels()
{
  QString t;
  int r=ui.sbBackgroundRed->value();
  int g=ui.sbBackgroundGreen->value();
  int b=ui.sbBackgroundBlue->value();
  int r0=ui.sbRed0->value();
  int r1=ui.sbRed1->value();
  int r2=ui.sbRed2->value();
  int r3=ui.sbRed3->value();
  int g0=ui.sbGreen0->value();
  int g1=ui.sbGreen1->value();
  int g2=ui.sbGreen2->value();
  int g3=ui.sbGreen3->value();
  int b0=ui.sbBlue0->value();
  int b1=ui.sbBlue1->value();
  int b2=ui.sbBlue2->value();
  int b3=ui.sbBlue3->value();

  t.sprintf("QLabel{background-color: #%2.2x%2.2x%2.2x;"
            "color: #%2.2x%2.2x%2.2x}",r,g,b,r0,g0,b0);
  ui.lab0->setStyleSheet(t);
  t.sprintf("QLabel{background-color: #%2.2x%2.2x%2.2x;"
            "color: #%2.2x%2.2x%2.2x}",r,g,b,r1,g1,b1);
  ui.lab1->setStyleSheet(t);
  t.sprintf("QLabel{background-color: #%2.2x%2.2x%2.2x;"
            "color: #%2.2x%2.2x%2.2x}",r,g,b,r2,g2,b2);
  ui.lab2->setStyleSheet(t);
  t.sprintf("QLabel{background-color: #%2.2x%2.2x%2.2x;"
            "color: #%2.2x%2.2x%2.2x}",r,g,b,r3,g3,b3);
  ui.lab3->setStyleSheet(t);

  m_colors.sprintf("%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x"
            "%2.2x%2.2x%2.2x",r,g,b,r0,g0,b0,r1,g1,b1,r2,g2,b2,r3,g3,b3);
}

void DevSetup::on_sbBackgroundRed_valueChanged(int r)
{
  updateColorLabels();
}

void DevSetup::on_sbBackgroundGreen_valueChanged(int g)
{
  updateColorLabels();
}

void DevSetup::on_sbBackgroundBlue_valueChanged(int b)
{
  updateColorLabels();
}


void DevSetup::on_sbRed0_valueChanged(int arg1)
{
  updateColorLabels();
}

void DevSetup::on_sbGreen0_valueChanged(int arg1)
{
  updateColorLabels();
}

void DevSetup::on_sbBlue0_valueChanged(int arg1)
{
  updateColorLabels();
}

void DevSetup::on_sbRed1_valueChanged(int arg1)
{
   updateColorLabels();
}

void DevSetup::on_sbGreen1_valueChanged(int arg1)
{
  updateColorLabels();
}

void DevSetup::on_sbBlue1_valueChanged(int arg1)
{
   updateColorLabels();
}

void DevSetup::on_sbRed2_valueChanged(int arg1)
{
   updateColorLabels();
}

void DevSetup::on_sbGreen2_valueChanged(int arg1)
{
   updateColorLabels();
}

void DevSetup::on_sbBlue2_valueChanged(int arg1)
{
   updateColorLabels();
}

void DevSetup::on_sbRed3_valueChanged(int arg1)
{
  updateColorLabels();
}

void DevSetup::on_sbGreen3_valueChanged(int arg1)
{
  updateColorLabels();
}

void DevSetup::on_sbBlue3_valueChanged(int arg1)
{
  updateColorLabels();
}

void DevSetup::on_pushButton_5_clicked()
{
  QColor color = QColorDialog::getColor(Qt::green, this);
  if (color.isValid()) {
  }
}
