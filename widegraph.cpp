#include "widegraph.h"
#include "ui_widegraph.h"
#include "commons.h"

#define NSMAX 22000

WideGraph::WideGraph(QWidget *parent) :
  QDialog(parent),
  ui(new Ui::WideGraph)
{
  ui->setupUi(this);
  this->setWindowFlags(Qt::Dialog);
  this->installEventFilter(parent);                   //Installing the filter
  ui->widePlot->setCursor(Qt::CrossCursor);
  this->setMaximumWidth(2048);
  this->setMaximumHeight(880);
  ui->widePlot->setMaximumHeight(800);
  ui->widePlot->m_bRFscale=false;

  connect(ui->widePlot, SIGNAL(freezeDecode1(int)),this,
          SLOT(wideFreezeDecode(int)));

  //Restore user's settings
  QString inifile(QApplication::applicationDirPath());
  inifile += "/wsprx.ini";
  QSettings settings(inifile, QSettings::IniFormat);

  settings.beginGroup("WideGraph");
  ui->widePlot->setPlotZero(settings.value("PlotZero", 0).toInt());
  ui->widePlot->setPlotGain(settings.value("PlotGain", 0).toInt());
  ui->zeroSpinBox->setValue(ui->widePlot->getPlotZero());
  ui->gainSpinBox->setValue(ui->widePlot->getPlotGain());
  int w = settings.value("PlotWidth",1000).toInt();
  ui->widePlot->m_w=w;
  m_waterfallAvg = settings.value("WaterfallAvg",5).toInt();
  ui->waterfallAvgSpinBox->setValue(m_waterfallAvg);
  ui->widePlot->m_bRFscale=settings.value("RFscale",false).toBool();
  ui->cbRFscale->setChecked(ui->widePlot->m_bRFscale);
  ui->widePlot->m_bCumulative=settings.value("Cumulative",false).toBool();
  ui->cbCumulative->setChecked(ui->widePlot->m_bCumulative);
  m_qsoFreq=settings.value("QSOfreq",1010).toInt();
  ui->widePlot->setTxFreq(m_qsoFreq,true);
  settings.endGroup();
}

WideGraph::~WideGraph()
{
  saveSettings();
  delete ui;
}

void WideGraph::saveSettings()
{
  //Save user's settings
  QString inifile(QApplication::applicationDirPath());
  inifile += "/wsprx.ini";
  QSettings settings(inifile, QSettings::IniFormat);

  settings.beginGroup("WideGraph");
  settings.setValue("PlotZero",ui->widePlot->m_plotZero);
  settings.setValue("PlotGain",ui->widePlot->m_plotGain);
  settings.setValue("PlotWidth",ui->widePlot->plotWidth());
  settings.setValue("WaterfallAvg",ui->waterfallAvgSpinBox->value());
  settings.setValue("RFscale",ui->widePlot->m_bRFscale);
  settings.setValue("Cumulative",ui->widePlot->m_bCumulative);
  settings.setValue("QSOfreq",ui->widePlot->TxFreq());
  settings.endGroup();
}

void WideGraph::dataSink2(float s[], float df3, int ihsym, int ndiskdata)
{
  static float splot[NSMAX];
  static float swide[2048];
  int nbpp=1;
  static int n=0;

  //Average spectra over specified number, m_waterfallAvg
  if (n==0) {
    for (int i=0; i<NSMAX; i++)
      splot[i]=s[i];
  } else {
    for (int i=0; i<NSMAX; i++)
      splot[i] += s[i];
  }
  n++;

  if (n>=m_waterfallAvg) {
    for (int i=0; i<NSMAX; i++)
        splot[i] /= n;                       //Normalize the average
    n=0;
    int i=0;
    int jz=1000.0/df3;
    for (int j=0; j<jz; j++) {
      float sum=0;
      for (int k=0; k<nbpp; k++) {
        i++;
        sum += splot[i];
      }
      swide[j]=sum;
//      if(lstrong[1 + i/32]!=0) swide[j]=-smax;   //Tag strong signals
    }

// Time according to this computer
    qint64 ms = QDateTime::currentMSecsSinceEpoch() % 86400000;
    int ntr = (ms/1000) % m_TRperiod;
    if((ndiskdata && ihsym <= m_waterfallAvg) || (!ndiskdata && ntr<m_ntr0)) {
      for (int i=0; i<2048; i++) {
        swide[i] = 1.e30;
      }
    }
    m_ntr0=ntr;
    ui->widePlot->draw(swide);
  }
}

void WideGraph::on_waterfallAvgSpinBox_valueChanged(int n)
{
  m_waterfallAvg = n;
}

void WideGraph::on_zeroSpinBox_valueChanged(int value)
{
  ui->widePlot->setPlotZero(value);
}

void WideGraph::on_gainSpinBox_valueChanged(int value)
{
  ui->widePlot->setPlotGain(value);
}

void WideGraph::keyPressEvent(QKeyEvent *e)
{  
  switch(e->key())
  {
  int n;
  case Qt::Key_F11:
    n=11;
    if(e->modifiers() & Qt::ControlModifier) n+=100;
    emit f11f12(n);
    break;
  case Qt::Key_F12:
    n=12;
    if(e->modifiers() & Qt::ControlModifier) n+=100;
    emit f11f12(n);
    break;
  default:
    e->ignore();
  }
}

void WideGraph::wideFreezeDecode(int n)
{
  emit freezeDecode2(n);
}

void WideGraph::setPalette(QString palette)
{
  ui->widePlot->setPalette(palette);
}

void WideGraph::setDialFreq(double f)
{
  m_dialFreq=f;
}

double WideGraph::dialFreq()
{
  return m_dialFreq;
}

void WideGraph::setPeriod(int ntrperiod, int nsps)
{
  m_TRperiod=ntrperiod;
  m_nsps=nsps;
  ui->widePlot->setNsps(ntrperiod, nsps);
}

void WideGraph::setTxFreq(int n)
{
  ui->widePlot->setTxFreq(n,true);
}

int WideGraph::txFreq()
{
  return ui->widePlot->m_TxFreq;
}

void WideGraph::setTxed()
{
  ui->widePlot->m_transmitted=true;
}

void WideGraph::on_cbCumulative_toggled(bool b)
{
  ui->widePlot->m_bCumulative=b;
}

void WideGraph::on_cbRFscale_toggled(bool b)
{
  ui->widePlot->m_bRFscale=b;
}
