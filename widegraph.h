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
  void on_zeroSpinBox_valueChanged(int arg1);
  void on_gainSpinBox_valueChanged(int arg1);
  void on_smoothSpinBox_valueChanged(int n);

private:

  Ui::WideGraph *ui;
};

#endif // WIDEGRAPH_H
