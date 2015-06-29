#include "fastgraph.h"
#include "commons.h"
#include <QSettings>
#include "fastplot.h"
#include "ui_fastgraph.h"
#include "moc_fastgraph.cpp"

#define NSMAX2 1366

FastGraph::FastGraph(QSettings * settings, QWidget *parent) :
  QDialog {parent, Qt::Window | Qt::WindowTitleHint | Qt::WindowCloseButtonHint | Qt::WindowMinimizeButtonHint},
  m_settings (settings),
  ui(new Ui::FastGraph)
{
  ui->setupUi(this);
  installEventFilter(parent);                   //Installing the filter
  ui->fastPlot->setCursor(Qt::CrossCursor);
  setMaximumWidth(2048);
  setMaximumHeight(880);
  ui->fastPlot->setMaximumHeight(800);

//Restore user's settings
  m_settings->beginGroup("FastGraph");
  restoreGeometry (m_settings->value ("geometry", saveGeometry ()).toByteArray ());
  ui->fastPlot->setPlotZero(m_settings->value("PlotZero", 0).toInt());
  ui->fastPlot->setPlotGain(m_settings->value("PlotGain", 0).toInt());
  ui->zeroSlider->setValue(ui->fastPlot->getPlotZero());
  ui->gainSlider->setValue(ui->fastPlot->getPlotGain());
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
