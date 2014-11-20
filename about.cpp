#include "about.h"
#include "ui_about.h"

CAboutDlg::CAboutDlg(QWidget *parent, QString Revision) :
  QDialog(parent),
  m_Revision(Revision),
  ui(new Ui::CAboutDlg)
{
  ui->setupUi(this);
  ui->labelTxt->clear();
  m_Str  = "<html><h2>" + m_Revision + "</h2>\n\n";
  m_Str += "Copyright 2014 by Joe Taylor, K1JT. <br><br>";
  ui->labelTxt->setText(m_Str);
}

CAboutDlg::~CAboutDlg()
{
  delete ui;
}
