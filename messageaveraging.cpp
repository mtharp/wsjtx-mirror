#include "messageaveraging.h"
#include "ui_messageaveraging.h"

MessageAveraging::MessageAveraging(QWidget *parent) :
  QWidget(parent),
  ui(new Ui::MessageAveraging)
{
  ui->setupUi(this);
}

MessageAveraging::~MessageAveraging()
{
  delete ui;
}

void MessageAveraging::on_pbDecode_clicked()
{
  qDebug() << "Decode";
}

void MessageAveraging::on_pbClrAvg_clicked()
{
  qDebug() << "Clear Avg";
}
