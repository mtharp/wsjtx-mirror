///////////////////////////////////////////////////////////////////////////
// Some code in this file and accompanying files is based on work by
// Moe Wheatley, AE4Y, released under the "Simplified BSD License".
// For more details see the accompanying file LICENSE_WHEATLEY.TXT
///////////////////////////////////////////////////////////////////////////

#ifndef FPLOTTER_H
#define FPLOTTER_H

#include <QtWidgets>
#include <QFrame>
#include <QImage>
#include <cstring>

class FPlotter : public QFrame
{
  Q_OBJECT
public:
  explicit FPlotter(QWidget *parent = 0);
  ~FPlotter();

  QSize minimumSizeHint() const;
  QSize sizeHint() const;

  qint32  m_w;
  qint32  m_plotZero;
  qint32  m_plotGain;
  qint32  m_greenGain;
  qint32  m_greenZero;

  void draw();		                                    //Update the Fast plot
  void SetRunningState(bool running);
  void setPlotZero(int plotZero);
  int  getPlotZero();
  void setPlotGain(int plotGain);
  int  getPlotGain();
  void setGreenGain(int n);
  void setGreenZero(int n);
  int  plotWidth();
  void UpdateOverlay();
  void DrawOverlay();

protected:
  //re-implemented widget event handlers
  void paintEvent(QPaintEvent *event);
  void resizeEvent(QResizeEvent* event);

private:

  void MakeTimeStrs();
  int XfromTime(float t);
  float TimefromX(int x);
  qint64 RoundFreq(qint64 freq, int resolution);

  QPixmap m_horizPixmap;
  QPixmap m_ScalePixmap;
  QPixmap m_OverlayPixmap;
  QSize   m_Size;
  QString m_HDivText[483];

  double  m_pixPerSecond;

  qint32  m_dBStepSize;
  qint32  m_hdivs;
  qint32  m_line;
  qint32  m_freqPerDiv;
  qint32  m_h;
  qint32  m_h1;
  qint32  m_h2;
  qint32  m_jh0;

  bool m_Running;
};

extern float fast_green[703];
extern float fast_s[44992];                                    //44992=64*703
extern int   fast_jh;
extern QVector<QColor> g_ColorTbl;


#endif // FPLOTTER_H
