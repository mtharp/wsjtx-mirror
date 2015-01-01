#include "astro.h"
#include "ui_astro.h"
#include <QDebug>
#include <QFile>
#include <QMessageBox>
#include <stdio.h>
#include "commons.h"

Astro::Astro(QWidget *parent) :
  QWidget(parent),
  ui(new Ui::Astro)
{
  ui->setupUi(this);
  ui->astroTextBrowser->setStyleSheet(
        "QTextBrowser { background-color : cyan; color : black; }");
  ui->astroTextBrowser->clear();
}

Astro::~Astro()
{
    delete ui;
}

void Astro::astroUpdate(QDateTime t, QString mygrid, double freq)
{
  static bool astroBusy=false;
  char cc[300];
  double azsun,elsun,azmoon,elmoon,azmoondx,elmoondx;
  double ramoon,decmoon,dgrd,poloffset,xnr;
  double doppler,techo,dop,dop00,width1;
  int ntsky;
  QString date = t.date().toString("yyyy MMM dd");
  QString utc = t.time().toString();
  int nyear=t.date().year();
  int month=t.date().month();
  int nday=t.date().day();
  int nhr=t.time().hour();
  int nmin=t.time().minute();
  int nsec=t.time().second();
  double sec=nsec + 0.001*t.time().msec();
  double uth=nhr + nmin/60.0 + sec/3600.0;
  int nfreq=freq+0.5;
  if(nfreq<1) nfreq=1;
  if(nfreq > 50000) nfreq=144;

  if(!astroBusy) {
    astroBusy=true;
    astrosub_(&nyear, &month, &nday, &uth, &nfreq, mygrid.toLatin1(),
            mygrid.toLatin1(), &azsun, &elsun, &azmoon, &elmoon,
            &azmoondx, &elmoondx, &ntsky, &dop, &dop00,&ramoon, &decmoon,
            &dgrd, &poloffset, &xnr, &techo, &width1, 6, 6);
    doppler=dop00;
    datcom_.dop=dop00;
    r4com_.techo=techo;
    r4com_.fspread=width1;
    r4com_.fsample=96000.0;
    r4com_.naz=int(azmoon+0.5);
    r4com_.nel=int(elmoon+0.5);
    if(nfreq<=1) {                            //Do this a better way!
      ntsky=0;
      doppler=0;
      nfreq=0;
    }
    astroBusy=false;
  }
  sprintf(cc,
          "Az:    %6.1f\n"
          "El:    %6.1f\n"
          "Dop: %8.1f\n"
          "Spread:%6.1f\n"
          "Techo: %6.2f\n"
          "Dec:   %6.1f\n"
          "Freq:  %6d\n"
          "Tsky:  %6d\n"
          "Dgrd:  %6.1f",
          azmoon,elmoon,doppler,width1,techo,decmoon,nfreq,ntsky,dgrd);
  ui->astroTextBrowser->setText(" "+ date + "\nUTC: " + utc + "\n" + cc);

//  QString fname=azelDir+"/azel.dat";
  QString fname="/wsjt/map65/azel.dat";
  QFile f(fname);
  if(!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
    QMessageBox mb;
    mb.setText("Cannot open " + fname);
    mb.exec();
    return;
  }
  int ndop=doppler;
  QTextStream out(&f);
  sprintf(cc,"%2.2d:%2.2d:%2.2d,%5.1f,%5.1f,Moon\n"
          "%2.2d:%2.2d:%2.2d,%5.1f,%5.1f,Sun\n"
          "%2.2d:%2.2d:%2.2d,%5.1f,%5.1f,Source\n"
          "%4d,%6d,Doppler\n"
          "%3d,%1d,fQSO\n"
          "%3d,%1d,fQSO2\n",
          nhr,nmin,nsec,azmoon,elmoon,
          nhr,nmin,nsec,azsun,elsun,
          nhr,nmin,nsec,0.0,0.0,
          nfreq,ndop,
          0,0,
          0,0);
  out << cc;
  f.close();
}

void Astro::setFontSize(int n)
{
  ui->astroTextBrowser->setFontPointSize(n);
}
