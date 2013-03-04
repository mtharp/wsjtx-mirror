#ifndef WSPRNET_H
#define WSPRNET_H

#include <QObject>
#include <QtNetwork>

class WSPRNet : public QObject
{
Q_OBJECT
public:
    explicit WSPRNet(QObject *parent = 0);
    void upload(QString call, QString grid, QString fileName);

signals:
    void wsprNetResponse(QString);

public slots:
    void networkReply( QNetworkReply * );

private:
    QNetworkAccessManager *networkManager;
    QString wsprNetUrl;
};

#endif // WSPRNET_H
