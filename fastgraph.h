#ifndef FASTGRAPH_H
#define FASTGRAPH_H
#include <QDialog>

namespace Ui {
  class FastGraph;
}

class QSettings;

class FastGraph : public QDialog
{
  Q_OBJECT

protected:
  void closeEvent (QCloseEvent *) override;

public:
  explicit FastGraph(QSettings *, QWidget *parent = 0);
  ~FastGraph();

  void   plotSpec();
  void   saveSettings();

private slots:
  void on_smoothSpinBox_valueChanged(int n);
  void on_cbBlue_toggled(bool checked);
  void on_gainSlider_valueChanged(int value);
  void on_zeroSlider_valueChanged(int value);  
  void on_binsPerPixelSpinBox_valueChanged(int n);

private:
  QSettings * m_settings;

  Ui::FastGraph *ui;
};

#endif // FASTGRAPH_H
