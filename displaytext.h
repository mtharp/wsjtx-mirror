#ifndef DISPLAYTEXT_H
#define DISPLAYTEXT_H

#include <QTextBrowser>

class DisplayText : public QTextBrowser
{
    Q_OBJECT
public:
    explicit DisplayText(QWidget *parent = 0);
};

#endif // DISPLAYTEXT_H
