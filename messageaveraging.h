#ifndef MESSAGEAVERAGING_H
#define MESSAGEAVERAGING_H

#include <QWidget>
#include <QDebug>

namespace Ui {
class MessageAveraging;
}

class MessageAveraging : public QWidget
{
  Q_OBJECT

public:
  explicit MessageAveraging(QWidget *parent = 0);
  ~MessageAveraging();

private slots:
  void on_pbDecode_clicked();
  void on_pbClrAvg_clicked();

private:
  Ui::MessageAveraging *ui;
};

#endif // MESSAGEAVERAGING_H
