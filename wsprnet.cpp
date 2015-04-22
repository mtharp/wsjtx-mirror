// Interface to WSPRnet website
//
// by Edson Pereira - PY2SDR

#include "wsprnet.h"

// Some hardwired, but tunable parameters
const int PARAM_WORK_INTERVAL_MSEC = 200.0;  // time interval between work calls
const int PARAM_WORK_TIMEOUT_SEC = 90.0;  // timeout for uploading of all spots
const int PARAM_SEND_INTERVAL_SEC = 2.0;  // wait time between spot requests

// Derived parameters
const int PARAM_SEND_NO_CALLS =
    int(1000.0*PARAM_SEND_INTERVAL_SEC/PARAM_WORK_INTERVAL_MSEC);
const int PARAM_TIMEOUT_NO_CALLS =
    int(1000.0*PARAM_WORK_TIMEOUT_SEC/PARAM_WORK_INTERVAL_MSEC);

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

void WSPRNet::upload(QString call, QString grid, QString rfreq, QString tfreq,
                     QString mode, QString tpct, QString dbm, QString version,
                     QString fileName)
{
    m_call = call;
    m_grid = grid;
    m_rfreq = rfreq;
    m_tfreq = tfreq;
    m_mode = mode;
    m_tpct = tpct;
    m_dbm = dbm;
    m_vers = version;
    m_file = fileName;

//    qDebug() << "mode: " << m_mode;

    // Initialize the counters, lists, queues
    m_workCalls = 0;
    urlQueue.clear( );
    replyList.clear( );

    // Open the wsprd.out file
    QFile wsprdOutFile(fileName);
    if (!wsprdOutFile.open(QIODevice::ReadOnly | QIODevice::Text) ||
            wsprdOutFile.size() == 0) {
        urlQueue.enqueue( wsprNetUrl + urlEncodeNoSpot());
        m_uploadType = 1;
        m_urlQueueSize = 1;
        uploadTimer->start(PARAM_WORK_INTERVAL_MSEC);
        return;
    }

    // Read the contents
    while (!wsprdOutFile.atEnd()) {
        QHash<QString,QString> query;
        if ( decodeLine(wsprdOutFile.readLine(), query) ) {
           // Prevent reporting data ouside of the current frequency band
           float f = fabs(m_rfreq.toFloat() - query["tqrg"].toFloat());
           if (f > 0.0002)
                continue;
           urlQueue.enqueue( wsprNetUrl + urlEncodeSpot(query));
           m_uploadType = 2;
        }
    }
    m_urlQueueSize = urlQueue.size();
    uploadTimer->start(PARAM_WORK_INTERVAL_MSEC);
}

void WSPRNet::networkReply(QNetworkReply *reply)
{
    QString serverResponse = reply->readAll();

    qDebug() << "Server response:\n" << serverResponse;

    // Check for network errors
    if ((reply->error( )) != QNetworkReply::NoError) {
        qDebug() << "Network Error:" <<  reply->error( );
        emit uploadStatus("Network Error");
    } else if (m_uploadType == 2) {
        // Check for the expected reply from the server
        if (!serverResponse.contains(QRegExp("spot\\(s\\) added"))) {
          qDebug() << "Server did not return expected response";
          emit uploadStatus("Unexpected server response");
        }
    }

    // Update the list of pending replies
    replyList.removeAll(reply);

    // Clean up to avoid a memory leak
    reply->deleteLater( );
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
        query["date"] = rx.cap(1);
        query["time"] = rx.cap(2);
        query["sig"] = rx.cap(4);
        query["dt"] = rx.cap(5);
        query["drift"] = rx.cap(8);
        query["tqrg"] = rx.cap(6);
        query["tcall"] = call;
        query["tgrid"] = grid;
        query["dbm"] = dbm;
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
    if(m_mode=="WSPR-2") queryString += "mode=2";
    if(m_mode=="WSPR-15") queryString += "mode=15";

    qDebug() << queryString;

    return queryString;;
}

QString WSPRNet::urlEncodeSpot(QHash<QString,QString> query)
{
    QString queryString;

    queryString += "function=" + query["function"] + "&";
    queryString += "rcall=" + m_call + "&";
    queryString += "rgrid=" + m_grid + "&";
    queryString += "rqrg=" + m_rfreq + "&";
    queryString += "date=" + query["date"] + "&";
    queryString += "time=" + query["time"] + "&";
    queryString += "sig=" + query["sig"] + "&";
    queryString += "dt=" + query["dt"] + "&";
    queryString += "drift=" + query["drift"] + "&";
    queryString += "tqrg=" + query["tqrg"] + "&";
    queryString += "tcall=" + query["tcall"] + "&";
    queryString += "tgrid=" + query["tgrid"] + "&";
    queryString += "dbm=" + query["dbm"] + "&";
    queryString += "version=" + m_vers;

    qDebug() << queryString;

    return queryString;
}

void WSPRNet::work()
{
    // Minor change to the basic strategy of operation by KD6EKQ. When
    // requests are sent to the wsprnet.org server, the reply object that
    // is returned by networkManager->get(request) is placed on a QList
    // (named replyList). When a request finishes normally, it then gets
    // removed from replyList in the networkReply( ) method. The timeout
    // code below will abort any requests that have not finished after
    // waiting some (configurable) time period.

    // Increment the call counter

    m_workCalls++;

    // First check the URL queue for spot requests that have yet to be sent

    if (!urlQueue.isEmpty()) {
        // Pace the sending of our requests (go easy on the wsprnet.org server)
        if ((m_workCalls % PARAM_SEND_NO_CALLS) != 0) return;
        // Send the next request
        QUrl url(urlQueue.dequeue());
        QNetworkRequest request(url);
        QNetworkReply *reply = networkManager->get(request);
        // Append the reply object to the list of pending replies
        replyList.append(reply);
        // Update the message in the status bar
        QString status = "Uploading Spot " + 
            QString::number(m_urlQueueSize - urlQueue.size()) +
            "/" + QString::number(m_urlQueueSize);
        emit uploadStatus(status);
        return;
    }

    // Check the list of pending replies

    if (replyList.isEmpty()) {
        // All replies were received, signal main that the upload has finished
        emit uploadStatus("done");
        QFile::remove(m_file);
        uploadTimer->stop();
        return;
    }

    // Pending reply list is non-empty, check if the timeout period has elapsed

    if (m_workCalls >= PARAM_TIMEOUT_NO_CALLS) {
        // Timeout period has elapsed, abort requests that are still running
        qDebug() << "Timeout, len(replyList) = " << replyList.size();
        // Make a copy of the replyList (possible race condition with replyList)
        QList<QNetworkReply *> replyListCopy;
        for (int j = 0; j < replyList.size(); ++j)
            replyListCopy.append((replyList.at(j)));
        // Explicitly abort any requests that are still running
        for (int j = 0; j < replyListCopy.size(); ++j) {
            if (replyListCopy.at(j)->isRunning( )) {
                // After an abort, the networkReply( ) method should get called
                replyListCopy.at(j)->abort( );
            }
        }
        emit uploadStatus("done");  // signal main that the upload has finished
        QFile::remove(m_file);
        uploadTimer->stop();
        return;
    } else {
        // Update the message in the status bar
        if ((m_workCalls % PARAM_SEND_NO_CALLS) == 0)
            emit uploadStatus("Waiting for wsprnet.org");
    }

}

// End of wsprnet.cpp
