#ifndef DEVSETUP_H
#define DEVSETUP_H

#include <QDialog>
#include "ui_devsetup.h"

class DevSetup : public QDialog
{
  Q_OBJECT
public:
  DevSetup(QWidget *parent=0);
  ~DevSetup();

  void initDlg();
  qint32  m_idInt;
  qint32  m_pttPort;
  qint32  m_nDevIn;
  qint32  m_nDevOut;
  qint32  m_inDevList[100];
  qint32  m_outDevList[100];
  qint32  m_paInDevice;
  qint32  m_paOutDevice;
  qint32  m_BFO;

  bool    m_restartSoundIn;
  bool    m_restartSoundOut;
  bool    m_grid6;

  QString m_myCall;
  QString m_myGrid;
  QString m_saveDir;
  QString m_azelDir;
  QString m_dxccPfx;

public slots:
  void accept();

private slots:
  void on_myCallEntry_editingFinished();
  void on_myGridEntry_editingFinished();
  void on_cbGrid6_toggled(bool b);

  void on_bfoLineEdit_editingFinished();

private:
  Ui::DialogSndCard ui;
};

#endif // DEVSETUP_H
