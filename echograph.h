#ifndef ECHOGRAPH_H
#define ECHOGRAPH_H
#include <QDialog>

namespace Ui {
  class EchoGraph;
}

class EchoGraph : public QDialog
{
  Q_OBJECT

public:
  explicit EchoGraph(QWidget *parent = 0);
  ~EchoGraph();

  void   plotSpec();
  void   saveSettings();

private slots:
  void on_smoothSpinBox_valueChanged(int n);
  void on_cbBlue_toggled(bool checked);
  void on_gainSlider_valueChanged(int value);
  void on_zeroSlider_valueChanged(int value);

private:

  Ui::EchoGraph *ui;
};

#endif // ECHOGRAPH_H
