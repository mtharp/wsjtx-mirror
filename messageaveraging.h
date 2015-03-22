#ifndef MESSAGEAVERAGING_H
#define MESSAGEAVERAGING_H

#include <QWidget>
#include <QDebug>
#include <QCheckBox>
#include <QList>
#include <QLineEdit>

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

  void addItem(QString t);

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
  QList<QCheckBox*> m_cb;
  QList<QLineEdit*> m_t;

  qint32 m_k;

  Ui::MessageAveraging *ui;
};

#endif // MESSAGEAVERAGING_H
