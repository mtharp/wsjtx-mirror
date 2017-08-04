// -*- Mode: C++ -*-
#ifndef DISPLAYTEXT_H
#define DISPLAYTEXT_H

#include <QTextEdit>
#include <QFont>

#include "logbook/logbook.h"
#include "decodedtext.h"

class DisplayText
  : public QTextEdit
{
  Q_OBJECT
public:
  explicit DisplayText(QWidget *parent = 0);

  void setContentFont (QFont const&);
  void insertLineSpacer(QString const&);
  void displayDecodedText(DecodedText decodedText, QString myCall, bool displayDXCCEntity,
			  LogBook logBook, QColor color_CQ, QColor color_MyCall,
			  QColor color_DXCC, QColor color_NewCall);
  void displayTransmittedText(QString text, QString modeTx, qint32 txFreq,
			      QColor color_TxMsg, bool bFastMode);
  void displayQSY(QString text);

  Q_SIGNAL void selectCallsign (bool alt, bool ctrl);

  Q_SLOT void appendText (QString const& text, QColor bg = Qt::white);

protected:
  void mouseDoubleClickEvent(QMouseEvent *e);

private:
  QString appendDXCCWorkedB4(QString message, QString const& callsign, QColor * bg, LogBook logBook,
			     QColor color_CQ, QColor color_DXCC, QColor color_NewCall);

  QFont char_font_;
};

#endif // DISPLAYTEXT_H
