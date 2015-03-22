#include <QSettings>
#include "messageaveraging.h"
#include "ui_messageaveraging.h"

MessageAveraging::MessageAveraging(QSettings * settings, QWidget *parent) :
  QWidget(parent),
  settings_ {settings},
  ui(new Ui::MessageAveraging)
{
  ui->setupUi(this);
  read_settings ();

  m_cb.append(ui->cb1);
  m_cb.append(ui->cb2);
  m_cb.append(ui->cb3);
  m_cb.append(ui->cb4);
  m_cb.append(ui->cb5);
  m_cb.append(ui->cb6);
  m_cb.append(ui->cb7);
  m_cb.append(ui->cb8);
  m_cb.append(ui->cb9);
  m_cb.append(ui->cb10);
  m_t.append(ui->lineEdit_1);
  m_t.append(ui->lineEdit_2);
  m_t.append(ui->lineEdit_3);
  m_t.append(ui->lineEdit_4);
  m_t.append(ui->lineEdit_5);
  m_t.append(ui->lineEdit_6);
  m_t.append(ui->lineEdit_7);
  m_t.append(ui->lineEdit_8);
  m_t.append(ui->lineEdit_9);
  m_t.append(ui->lineEdit_10);
  on_pbClrAvg_clicked();
}

MessageAveraging::~MessageAveraging()
{
  if (isVisible ()) write_settings ();
  delete ui;
}

void MessageAveraging::closeEvent (QCloseEvent * e)
{
  write_settings ();
  QWidget::closeEvent (e);
}
void MessageAveraging::read_settings ()
{
  settings_->beginGroup ("MessageAveraging");
  move (settings_->value ("window/pos", pos ()).toPoint ());
  settings_->endGroup ();
}

void MessageAveraging::write_settings ()
{
  settings_->beginGroup ("MessageAveraging");
  settings_->setValue ("window/pos", pos ());
  settings_->endGroup ();
}

void MessageAveraging::on_pbDecode_clicked()
{
  qDebug() << "Decode";
  emit msgAvgDecode();
}

void MessageAveraging::on_pbClrAvg_clicked()
{
  for(int i=0; i<10; i++) {
    m_t[i]->setText("");
  }
  m_k=0;
  emit clearAverage();
}

void MessageAveraging::addItem(QString t)
{
  m_t[m_k]->setText(t);
  if(m_k<9) m_k+=1;
}

