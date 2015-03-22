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
  qDebug() << "Decode";
  emit msgAvgDecode();
}

void MessageAveraging::on_pbClrAll_clicked()
{
  for(int i=0; i<10; i++) {
    m_t[i]->setText("");
    m_cb[i]->setChecked(false);
  }
  m_k=0;
  emit clearAverage();
}

void MessageAveraging::addItem(QString t)
{
  m_t[m_k]->setText(t);
  m_cb[m_k]->setChecked(true);
  if(m_k<9) m_k+=1;
}


void MessageAveraging::on_pbCompress_clicked()
{
  qDebug() << "Compress";
  for(int i=0; i<m_k; i++) {
    if(!m_cb[i]->isChecked()) {
      for(int j=i; j<=m_k; j++) {
        bool b=m_cb[j+1]->isChecked();
        if(b) {
          QString t=m_t[j+1]->text();
          qDebug() << "a" << i << j << m_k << t << b;
          m_t[i]->setText(t);
          m_cb[i]->setChecked(b);
          goto next_i;
        }
      }
    }
next_i: m_k-=1;
  }
}
