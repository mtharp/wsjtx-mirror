#include <QSettings>
#include "messageaveraging.h"
#include "ui_messageaveraging.h"
#include "commons.h"

MessageAveraging::MessageAveraging(QSettings * settings, QWidget *parent) :
  QWidget(parent),
  settings_ {settings},
  ui(new Ui::MessageAveraging)
{
  ui->setupUi(this);
  read_settings ();
  on_pbClrAll_clicked();
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
  emit msgAvgDecode();
}

void MessageAveraging::on_pbClrAll_clicked()
{
  m_k=0;
  emit clearAverage();
}

void MessageAveraging::displayAvg(QString t)
{
  ui->msgAvgTextBrowser->setText(t);
}


void MessageAveraging::on_pbCompress_clicked()
{

}
