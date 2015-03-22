#ifndef MESSAGEAVERAGING_H
#define MESSAGEAVERAGING_H

#include <QWidget>
#include <QDebug>

class QSettings;

namespace Ui {
class MessageAveraging;
}

class MessageAveraging : public QWidget
{
  Q_OBJECT

public:
  explicit MessageAveraging(QSettings * settings, QWidget *parent = 0);
  ~MessageAveraging();

signals:
  void clearAverage() const;
  void msgAvgDecode() const;

protected:
  void closeEvent (QCloseEvent *) override;

private slots:
  void on_pbDecode_clicked();
  void on_pbClrAvg_clicked();

private:
  void read_settings ();
  void write_settings ();
  QSettings * settings_;
  Ui::MessageAveraging *ui;
};

#endif // MESSAGEAVERAGING_H
