#ifndef WIDEGRAPH_H
#define WIDEGRAPH_H
#include <QDialog>

namespace Ui {
  class WideGraph;
}

class WideGraph : public QDialog
{
  Q_OBJECT

public:
  explicit WideGraph(QWidget *parent = 0);
  ~WideGraph();

  void   plotSpec();
  void   saveSettings();

private slots:
  void on_smoothSpinBox_valueChanged(int n);
  void on_cbBlue_toggled(bool checked);
  void on_gainSlider_valueChanged(int value);
  void on_zeroSlider_valueChanged(int value);

private:

  Ui::WideGraph *ui;
};

#endif // WIDEGRAPH_H
