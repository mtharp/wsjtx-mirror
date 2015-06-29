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

#define VERT_DIVS 7	//specify grid screen divisions
#define HORZ_DIVS 20

class FPlotter : public QFrame
{
  Q_OBJECT
public:
  explicit FPlotter(QWidget *parent = 0);
  ~FPlotter();

  QSize minimumSizeHint() const;
  QSize sizeHint() const;
  QColor  m_ColorTbl[256];
  qint32  m_w;
  qint32  m_plotZero;
  qint32  m_plotGain;

  void draw();		                                    //Update the Fast plot
  void SetRunningState(bool running);
  void setPlotZero(int plotZero);
  int  getPlotZero();
  void setPlotGain(int plotGain);
  int  getPlotGain();
  int  plotWidth();
  void UpdateOverlay();
  void DrawOverlay();

//  void SetPercent2DScreen(int percent){m_Percent2DScreen=percent;}

protected:
  //re-implemented widget event handlers
  void paintEvent(QPaintEvent *event);
  void resizeEvent(QResizeEvent* event);

private:

  void MakeFrequencyStrs();
  int XfromFreq(float f);
  float FreqfromX(int x);
  qint64 RoundFreq(qint64 freq, int resolution);

  QPixmap m_2DPixmap;
  QPixmap m_ScalePixmap;
  QPixmap m_OverlayPixmap;
  QSize   m_Size;
  QString m_HDivText[483];

  double  m_fftBinWidth;

  qint64  m_StartFreq;

  qint32  m_dBStepSize;
  qint32  m_hdivs;
  qint32  m_line;
  qint32  m_freqPerDiv;
  qint32  m_h;
  qint32  m_h1;
  qint32  m_h2;
};

#endif // FPLOTTER_H
