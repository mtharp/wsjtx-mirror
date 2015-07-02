#include "fastgraph.h"
#include "commons.h"
#include <QSettings>
#include "fastplot.h"
#include "ui_fastgraph.h"
#include "moc_fastgraph.cpp"

#define NSMAX2 1366

FastGraph::FastGraph(QSettings * settings, QWidget *parent) :
  QDialog {parent, Qt::Window | Qt::WindowTitleHint |
           Qt::WindowCloseButtonHint |
           Qt::WindowMinimizeButtonHint},
  m_settings (settings),
  ui(new Ui::FastGraph)
{
  ui->setupUi(this);
  installEventFilter(parent);                   //Installing the filter
  ui->fastPlot->setCursor(Qt::CrossCursor);

//Restore user's settings
  m_settings->beginGroup("FastGraph");
  restoreGeometry (m_settings->value ("geometry", saveGeometry ()).toByteArray ());
  ui->fastPlot->setPlotZero(m_settings->value("PlotZero", 0).toInt());
  ui->fastPlot->setPlotGain(m_settings->value("PlotGain", 0).toInt());
  ui->zeroSlider->setValue(ui->fastPlot->m_plotZero);
  ui->gainSlider->setValue(ui->fastPlot->m_plotGain);
  ui->fastPlot->setGreenZero(m_settings->value("GreenZero", 0).toInt());
  ui->fastPlot->setGreenGain(m_settings->value("GreenGain", 0).toInt());
  ui->greenZeroSlider->setValue(ui->fastPlot->m_greenZero);
  ui->greenGainSlider->setValue(ui->fastPlot->m_greenGain);
  m_settings->endGroup();
}

FastGraph::~FastGraph()
{
  saveSettings();
  delete ui;
}

void FastGraph::closeEvent (QCloseEvent * e)
{
  saveSettings ();
  QDialog::closeEvent (e);
}

void FastGraph::saveSettings()
{
//Save user's settings
  m_settings->beginGroup("FastGraph");
  m_settings->setValue ("geometry", saveGeometry ());
  m_settings->setValue("PlotZero",ui->fastPlot->m_plotZero);
  m_settings->setValue("PlotGain",ui->fastPlot->m_plotGain);
  m_settings->setValue("GreenZero",ui->fastPlot->m_greenZero);
  m_settings->setValue("GreenGain",ui->fastPlot->m_greenGain);
  m_settings->endGroup();
}

void FastGraph::plotSpec()
{
  ui->fastPlot->draw();
}

void FastGraph::on_gainSlider_valueChanged(int value)
{
  ui->fastPlot->setPlotGain(value);
  ui->fastPlot->draw();
}

void FastGraph::on_zeroSlider_valueChanged(int value)
{
  ui->fastPlot->setPlotZero(value);
  ui->fastPlot->draw();
}

void FastGraph::on_greenGainSlider_valueChanged(int value)
{
  ui->fastPlot->setGreenGain(value);
  ui->fastPlot->draw();
}

void FastGraph::on_greenZeroSlider_valueChanged(int value)
{
  ui->fastPlot->setGreenZero(value);
  ui->fastPlot->draw();
}
