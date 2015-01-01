#include "commons.h"
#include "widegraph.h"
#include "ui_widegraph.h"

#define NSMAX 1366

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

//Restore user's settings
  QString inifile(QApplication::applicationDirPath());
  inifile += "/emecho.ini";
  QSettings settings(inifile, QSettings::IniFormat);

  settings.beginGroup("WideGraph");
  ui->widePlot->setPlotZero(settings.value("PlotZero", 0).toInt());
  ui->widePlot->setPlotGain(settings.value("PlotGain", 0).toInt());
  ui->zeroSlider->setValue(ui->widePlot->getPlotZero());
  ui->gainSlider->setValue(ui->widePlot->getPlotGain());
  ui->smoothSpinBox->setValue(settings.value("Smooth",0).toInt());
  ui->widePlot->m_blue=settings.value("BlueCurve",false).toBool();
  ui->cbBlue->setChecked(ui->widePlot->m_blue);
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
  inifile += "/emecho.ini";
  QSettings settings(inifile, QSettings::IniFormat);

  settings.beginGroup("WideGraph");
  settings.setValue("PlotZero",ui->widePlot->m_plotZero);
  settings.setValue("PlotGain",ui->widePlot->m_plotGain);
  settings.setValue("Smooth",ui->widePlot->m_smooth);
  settings.setValue("BlueCurve",ui->widePlot->m_blue);
  settings.endGroup();
}

void WideGraph::plotSpec()
{
  ui->widePlot->draw();
}

void WideGraph::on_smoothSpinBox_valueChanged(int n)
{
  ui->widePlot->setSmooth(n);
  ui->widePlot->draw();
}

void WideGraph::on_cbBlue_toggled(bool checked)
{
  ui->widePlot->m_blue=checked;
  ui->widePlot->draw();
}

void WideGraph::on_gainSlider_valueChanged(int value)
{
  ui->widePlot->setPlotGain(value);
  ui->widePlot->draw();
}

void WideGraph::on_zeroSlider_valueChanged(int value)
{
  ui->widePlot->setPlotZero(value);
  ui->widePlot->draw();
}
