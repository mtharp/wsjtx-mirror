#include "messageaveraging.h"
#include "ui_messageaveraging.h"

MessageAveraging::MessageAveraging(QWidget *parent) :
  QWidget(parent),
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
  cb.append(ui->cb11);
  cb.append(ui->cb12);
  cb.append(ui->cb13);
  cb.append(ui->cb14);
  cb.append(ui->cb15);
  for(int i=0; i<15; i++) {
    cb[i]->setText("     ");
  }
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
