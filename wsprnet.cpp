// Interface to WSPRnet website
//
// by Edson Pereira - PY2SDR

#include "wsprnet.h"

WSPRNet::WSPRNet(QObject *parent) :
    QObject(parent)
{
  wsprNetUrl = "http://wsprnet.org/meptspots.php";
  networkManager = new QNetworkAccessManager(this);
  connect( networkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(networkReply(QNetworkReply*)) );
}

void WSPRNet::upload( QString call, QString grid, QString fileName )
{
    // Open the wsprd.out file
    QFile wsprdOutFile(fileName);
    if (!wsprdOutFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Failed to open " + fileName;
    }

    // Read the contents
    QByteArray wsprdOutData;
    while (!wsprdOutFile.atEnd()) {
        wsprdOutData.append(wsprdOutFile.readLine());
    }

    // WSPRnet URL
    QUrl url(wsprNetUrl);
    QNetworkRequest request(url);

    QString boundary = "--------------------WSPRnet_Boundary_$";
    request.setHeader( QNetworkRequest::ContentTypeHeader, QString("multipart/form-data, boundary=" + boundary));

    QByteArray data(QString("--" + boundary + "\r\n").toAscii());
    data += "Content-Disposition: form-data; name=\"allmept\"; filename=\"" + wsprdOutFile.fileName() + "\"\r\n";
    data += "Content-Type: application/octet-stream\r\n\r\n";
    data += wsprdOutData + "\r\n";
    data += "--" + boundary + "\r\n";
    data += "Content-Disposition: form-data; name=\"call\"\r\n\r\n";
    data += call + "\r\n";
    data += "--" + boundary + "\r\n";
    data += "Content-Disposition: form-data; name=\"grid\"\r\n\r\n";
    data += grid + "\r\n";
    data += "--" + boundary + "\r\n";

    qDebug() << "Uploading spots to WSPRNet: " << url;
    networkManager->post( request, data );
}

void WSPRNet::networkReply( QNetworkReply *reply )
{
    QString serverResponse = reply->readAll();
    emit wsprNetResponse(serverResponse);
}



