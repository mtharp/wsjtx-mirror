// Interface to WSPRnet website
//
// by Edson Pereira - PY2SDR

#include "wsprnet.h"

WSPRNet::WSPRNet(QObject *parent) :
    QObject(parent)
{
  wsprNetUrl = "http://wsprnet.org/post?";
  //wsprNetUrl = "http://127.0.0.1/post.php?";
  networkManager = new QNetworkAccessManager(this);
  connect(networkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(networkReply(QNetworkReply*)));

  uploadTimer = new QTimer(this);
  connect( uploadTimer, SIGNAL(timeout()), this, SLOT(work()));
}

void WSPRNet::upload(QString call, QString grid, QString rfreq, QString tfreq, QString tpct, QString dbm, QString version, QString fileName)
{
    m_call = call;
    m_grid = grid;
    m_rfreq = rfreq;
    m_tfreq = tfreq;
    m_tpct = tpct;
    m_dbm = dbm;
    m_vers = version;
    m_file = fileName;

    // Open the wsprd.out file
    QFile wsprdOutFile(fileName);
    if (!wsprdOutFile.open(QIODevice::ReadOnly | QIODevice::Text) || wsprdOutFile.size() == 0) {
        urlQueue.enqueue( wsprNetUrl + urlEncodeNoSpot());
        m_uploadType = 1;
        uploadTimer->start(50);
        return;
    }

    // Read the contents
    while (!wsprdOutFile.atEnd()) {
        QHash<QString,QString> query;
        if ( decodeLine(wsprdOutFile.readLine(), query) ) {
           urlQueue.enqueue( wsprNetUrl + urlEncodeSpot(query));
           m_uploadType = 2;
           uploadTimer->start(50);
        }
    }
    m_urlQueueSize = urlQueue.size();
}

void WSPRNet::networkReply(QNetworkReply *reply)
{
    QString serverResponse = reply->readAll();
    QString response;
    if( m_uploadType == 2) {
        if (serverResponse.contains(QRegExp("spot\\(s\\) added"))) {
            response = "Uploading Spot " + QString::number(m_urlQueueSize - urlQueue.size()) + "/"+ QString::number(m_urlQueueSize);
            emit uploadStatus(response);
        } else {
            emit uploadStatus("Upload Failed");
            urlQueue.clear();
            uploadTimer->stop();
        }
    }

    if (urlQueue.isEmpty()) {
        emit uploadStatus("done");
        QFile::remove(m_file);
        uploadTimer->stop();
    }

    //qDebug() << serverResponse;
}

bool WSPRNet::decodeLine(QString line, QHash<QString,QString> &query)
{
    //qDebug() << line;
    // 130223 2256 7    -21 -0.3  14.097090  DU1MGA PK04 37          0    40    0
    // Date   Time Sync dBm  DT   Freq       Msg
    // 1      2    3     4   5     6         -------7------          8     9    10
    QRegExp rx("^(\\d+)\\s+(\\d+)\\s+(\\d+)\\s+([+-]?\\d+)\\s+([+-]?\\d+\\.\\d+)\\s+(\\d+\\.\\d+)\\s+(.*)\\s+([+-]?\\d+)\\s+([+-]?\\d+)\\s+([+-]?\\d+)");
    if (rx.indexIn(line) != -1) {
        int msgType = 0;
        QString msg = rx.cap(7);
        msg.remove(QRegExp("\\s+$"));
        msg.remove(QRegExp("^\\s+"));
        QString call, grid, dbm;

        // Prevent reporting data ouside of the current frequency band
        float f = fabs(m_rfreq.toFloat() - rx.cap(6).toFloat());
        qDebug() << "Freq Delta = " << f;
        if (f > 0.0002)
            return false;

        QRegExp msgRx;

        // Check for Message Type 1
        msgRx.setPattern("^([A-Z0-9]{3,6})\\s+([A-Z]{2}\\d{2})\\s+(\\d+)");
        if (msgRx.indexIn(msg) != -1) {
            //qDebug() << "Type 1" << msgRx.cap(1) << msgRx.cap(2) << msgRx.cap(3);
            msgType = 1;
            call = msgRx.cap(1);
            grid = msgRx.cap(2);
            dbm = msgRx.cap(3);
        }

        // Check for Message Type 2
        msgRx.setPattern("^([A-Z0-9/]+)\\s+(\\d+)");
        if (msgRx.indexIn(msg) != -1) {
            //qDebug() << "Type 2" << msgRx.cap(1) << msgRx.cap(2);
            msgType = 2;
            call = msgRx.cap(1);
            grid = "";
            dbm = msgRx.cap(2);
        }

        // Check for Message Type 3
        msgRx.setPattern("^<([A-Z0-9/]+)>\\s+([A-Z]{2}\\d{2}[A-Z]{2})\\s+(\\d+)");
        if (msgRx.indexIn(msg) != -1) {
            //qDebug() << "Type 3" << msgRx.cap(1) << msgRx.cap(2) << msgRx.cap(3);
            msgType = 3;
            call = msgRx.cap(1);
            grid = msgRx.cap(2);
            dbm = msgRx.cap(3);
        }

        // Unknown message format
        if (!msgType) {
            return false;
        }

        query["function"] = "wspr";
        query["rcall"] = m_call;
        query["rgrid"] = m_grid;
        query["rqrg"] = m_rfreq;
        query["date"] = rx.cap(1);
        query["time"] = rx.cap(2);
        query["sig"] = rx.cap(4);
        query["dt"] = rx.cap(5);
        query["drift"] = rx.cap(10);
        query["tqrg"] = rx.cap(6);
        query["tcall"] = call;
        query["tgrid"] = grid;
        query["dbm"] = dbm;
        query["version"] = m_vers;

    } else {
        return false;
    }
    return true;
}

QString WSPRNet::urlEncodeNoSpot()
{
    QString queryString;

    queryString += "function=wsprstat&";
    queryString += "rcall=" + m_call + "&";
    queryString += "rgrid=" + m_grid + "&";
    queryString += "rqrg=" + m_rfreq + "&";
    queryString += "tpct=" + m_tpct + "&";
    queryString += "tqrg=" + m_tfreq + "&";
    queryString += "dbm=" + m_dbm + "&";
    queryString += "version=" +  m_vers;

    qDebug() << queryString;

    return queryString;;
}

QString WSPRNet::urlEncodeSpot(QHash<QString,QString> query)
{
    QString queryString;

    queryString += "function=" + query["function"] + "&";
    queryString += "rcall=" + query["rcall"] + "&";
    queryString += "rgrid=" + query["rgrid"] + "&";
    queryString += "rqrg=" + query["rqrg"] + "&";
    queryString += "date=" + query["date"] + "&";
    queryString += "time=" + query["time"] + "&";
    queryString += "sig=" + query["sig"] + "&";
    queryString += "dt=" + query["dt"] + "&";
    queryString += "drift=" + query["drift"] + "&";
    queryString += "tqrg=" + query["tqrg"] + "&";
    queryString += "tcall=" + query["tcall"] + "&";
    queryString += "tgrid=" + query["tgrid"] + "&";
    queryString += "dbm=" + query["dbm"] + "&";
    queryString += "version=" + query["version"];

    qDebug() << queryString;

    return queryString;
}

void WSPRNet::work()
{
    if (!urlQueue.isEmpty()) {
        QUrl url(urlQueue.dequeue());
        QNetworkRequest request(url);
        networkManager->get(request);
    } else {
        uploadTimer->stop();
    }
}



