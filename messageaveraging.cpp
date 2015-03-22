#include <QSettings>
#include "messageaveraging.h"
#include "ui_messageaveraging.h"

MessageAveraging::MessageAveraging(QSettings * settings, QWidget *parent) :
  QWidget(parent),
  settings_ {settings},
  ui(new Ui::MessageAveraging)
{
  ui->setupUi(this);
  QList<QCheckBox*> cb;
  cb.append(ui->cb1);
  cb.append(ui->cb2);
  cb.append(ui->cb3);
  cb.append(ui->cb4);
  cb.append(ui->cb5);
  cb.append(ui->cb6);
  cb.append(ui->cb7);
  cb.append(ui->cb8);
  cb.append(ui->cb9);
  cb.append(ui->cb10);
  QList<QLineEdit*> t;
  t.append(ui->lineEdit_1);
  t.append(ui->lineEdit_2);
  t.append(ui->lineEdit_3);
  t.append(ui->lineEdit_4);
  t.append(ui->lineEdit_5);
  t.append(ui->lineEdit_6);
  t.append(ui->lineEdit_7);
  t.append(ui->lineEdit_8);
  t.append(ui->lineEdit_9);
  t.append(ui->lineEdit_10);
  for(int i=0; i<10; i++) {
    t[i]->setText("");
  }
  read_settings ();
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
  emit clearAverage();
}

