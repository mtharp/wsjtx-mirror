#include "plotter.h"
#include "commons.h"
#include <math.h>
#include <QDebug>

#define MAX_SCREENSIZE 2048


CPlotter::CPlotter(QWidget *parent) :                  //CPlotter Constructor
  QFrame(parent)
{
  setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
  setFocusPolicy(Qt::StrongFocus);
  setAttribute(Qt::WA_PaintOnScreen,false);
  setAutoFillBackground(false);
  setAttribute(Qt::WA_OpaquePaintEvent, false);
  setAttribute(Qt::WA_NoSystemBackground, true);

  m_StartFreq = -200;
  m_fftBinWidth=48000.0/131072.0;
  m_fSpan=1000.0;
  m_hdivs = HORZ_DIVS;
  m_Running = false;
  m_paintEventBusy=false;
  m_2DPixmap = QPixmap(0,0);
  m_ScalePixmap = QPixmap(0,0);
  m_OverlayPixmap = QPixmap(0,0);
  m_Size = QSize(0,0);
  m_TxFreq = 1500;
  m_line = 0;
  m_dBStepSize=10;
  m_Percent2DScreen = 89;	//percent of screen used for 2D display
}

CPlotter::~CPlotter() { }                                      // Destructor

QSize CPlotter::minimumSizeHint() const
{
  return QSize(50, 50);
}

QSize CPlotter::sizeHint() const
{
  return QSize(180, 180);
}

void CPlotter::resizeEvent(QResizeEvent* )                    //resizeEvent()
{
  if(!size().isValid()) return;
  if( m_Size != size() ) {  //if changed, resize pixmaps to new screensize
    m_Size = size();
    m_w = m_Size.width();
    m_h = m_Size.height();
    m_h1 = (100-m_Percent2DScreen)*(m_Size.height())/100;
    m_h2 = (m_Percent2DScreen)*(m_Size.height())/100;

    m_2DPixmap = QPixmap(m_Size.width(), m_h2);
    m_2DPixmap.fill(Qt::black);
    m_OverlayPixmap = QPixmap(m_Size.width(), m_h2);
    m_OverlayPixmap.fill(Qt::black);

    m_2DPixmap.fill(Qt::black);
    m_ScalePixmap = QPixmap(m_w,30);
    m_ScalePixmap.fill(Qt::white);

    m_fSpan=m_w*m_fftBinWidth;
    m_StartFreq=50 * int((-0.5*m_fSpan)/50.0 - 0.5);
//    qDebug() << "D" << m_fSpan << m_StartFreq;
  }
  DrawOverlay();
  draw();
}

void CPlotter::paintEvent(QPaintEvent *)                    // paintEvent()
{
  if(m_paintEventBusy) return;
  m_paintEventBusy=true;
  QPainter painter(this);
  painter.drawPixmap(0,0,m_ScalePixmap);
  painter.drawPixmap(0,m_h1,m_2DPixmap);
  m_paintEventBusy=false;
}

void CPlotter::draw()                                       //draw()
{
  int i,j,y;
  float blue[2000],red[2000];
  double gain = pow(10.0,(m_plotGain/20.0));

  QPainter painter2D(&m_2DPixmap);
  QRect tmp(0,0,m_w,m_h2);
  painter2D.fillRect(tmp,Qt::black);
  QPoint LineBuf[MAX_SCREENSIZE];
//  QPen penBlue(Qt::blue,1);
  QPen penBlue(QColor(0,255,255),1);
  QPen penRed(Qt::red,1);
  j=0;
  int i0=1000 + int(m_StartFreq/m_fftBinWidth);
  for(i=0; i<2000; i++) {
    blue[i]=datcom_.blue[i];
    red[i]=datcom_.red[i];
  }

  if(m_smooth>0) {
    for(i=0; i<m_smooth; i++) {
      int n2000=2000;
      smo121_(blue,&n2000);
      smo121_(red,&n2000);
    }
  }

  painter2D.setPen(penBlue);
  j=0;
  for(i=0; i<m_w; i++) {
    y = m_h2 - gain*(m_h/10.0)*blue[i0+i] - 5 - m_plotZero;
    LineBuf[j].setX(i);
    LineBuf[j].setY(y);
    j++;
  }
  painter2D.drawPolyline(LineBuf,j);

  painter2D.setPen(penRed);
  j=0;
  for(int i=0; i<m_w; i++) {
    y = m_h2 - gain*(m_h/10.0)*red[i0+i] - 5 - m_plotZero;
    LineBuf[j].setX(i);
    LineBuf[j].setY(y);
    j++;
  }
  painter2D.drawPolyline(LineBuf,j);
  update();                              //trigger a new paintEvent
}

void CPlotter::DrawOverlay()                                 //DrawOverlay()
{
  if(m_OverlayPixmap.isNull() or m_2DPixmap.isNull()) return;
//  int w = m_WaterfallPixmap.width();
  int x,y;

  QRect rect;
  QPainter painter(&m_OverlayPixmap);
  painter.initFrom(this);
  QLinearGradient gradient(0, 0, 0 ,m_h2);  //fill background with gradient
  gradient.setColorAt(1, Qt::black);
  gradient.setColorAt(0, Qt::darkBlue);
  painter.setBrush(gradient);
  painter.drawRect(0, 0, m_w, m_h2);
  painter.setBrush(Qt::SolidPattern);

  m_fSpan = m_w*m_fftBinWidth;
  m_freqPerDiv=20;
  if(m_fSpan>250) m_freqPerDiv=50;
  float pixPerHdiv = m_freqPerDiv/m_fftBinWidth;
  float pixPerVdiv = float(m_h2)/float(VERT_DIVS);

  m_hdivs = m_w*m_fftBinWidth/m_freqPerDiv + 0.9999;

  painter.setPen(QPen(Qt::white, 1,Qt::DotLine));
  for( int i=1; i<m_hdivs; i++)                   //draw vertical grids
  {
    x=int(i*pixPerHdiv);
    painter.drawLine(x,0,x,m_h2);
  }

  for( int i=1; i<VERT_DIVS; i++)                 //draw horizontal grids
  {
    y = (int)( (float)i*pixPerVdiv );
    painter.drawLine(0,y,m_w,y);
  }

  QRect rect0;
  QPainter painter0(&m_ScalePixmap);
  painter0.initFrom(this);

  //create Font to use for scales
  QFont Font("Arial");
  Font.setPointSize(12);
  QFontMetrics metrics(Font);
  Font.setWeight(QFont::Normal);
  painter0.setFont(Font);
  painter0.setPen(Qt::black);

  m_ScalePixmap.fill(Qt::white);
  painter0.drawRect(0, 0, m_w, 30);

//draw tick marks on upper scale
  for( int i=1; i<m_hdivs; i++) {         //major ticks
    x = (int)( (float)i*pixPerHdiv );
    painter0.drawLine(x,18,x,30);
  }
  int minor=5;
  if(m_freqPerDiv==200) minor=4;
  for( int i=1; i<minor*m_hdivs; i++) {   //minor ticks
    x = i*pixPerHdiv/minor;
    painter0.drawLine(x,24,x,30);
  }

//draw frequency values
  MakeFrequencyStrs();
  for( int i=0; i<=m_hdivs; i++) {
    if(0==i) {
      //left justify the leftmost text
      x = (int)( (float)i*pixPerHdiv);
      rect0.setRect(x,0, (int)pixPerHdiv, 20);
      painter0.drawText(rect0, Qt::AlignLeft|Qt::AlignVCenter,
                       m_HDivText[i]);
    }
    else if(m_hdivs == i) {
      //right justify the rightmost text
      x = (int)( (float)i*pixPerHdiv - pixPerHdiv);
      rect0.setRect(x,0, (int)pixPerHdiv, 20);
      painter0.drawText(rect0, Qt::AlignRight|Qt::AlignVCenter,
                       m_HDivText[i]);
    } else {
      //center justify the rest of the text
      x = (int)( (float)i*pixPerHdiv - pixPerHdiv/2);
      rect0.setRect(x,0, (int)pixPerHdiv, 20);
      painter0.drawText(rect0, Qt::AlignHCenter|Qt::AlignVCenter,
                       m_HDivText[i]);
    }
  }

  QPen pen1(Qt::red, 3);                         //Mark Tx Freq with red tick
  painter0.setPen(pen1);
  x = XfromFreq(m_TxFreq);
  painter0.drawLine(x,17,x,30);

}

void CPlotter::MakeFrequencyStrs()                       //MakeFrequencyStrs
{
  float freq;
  for(int i=0; i<=m_hdivs; i++) {
    freq=m_StartFreq + i*m_freqPerDiv;
    m_HDivText[i].setNum((int)freq);
  }
}

int CPlotter::XfromFreq(float f)                               //XfromFreq()
{
  int x = (int) m_w * (f - m_StartFreq)/m_fSpan;
  if(x<0 ) return 0;
  if(x>m_w) return m_w;
  return x;
}

float CPlotter::FreqfromX(int x)                               //FreqfromX()
{
  return float(m_StartFreq + x*m_fftBinWidth);
}

void CPlotter::SetRunningState(bool running)              //SetRunningState()
{
  m_Running = running;
}

void CPlotter::setPlotZero(int plotZero)                  //setPlotZero()
{
  m_plotZero=plotZero;
}

int CPlotter::getPlotZero()                               //getPlotZero()
{
  return m_plotZero;
}

void CPlotter::setPlotGain(int plotGain)                  //setPlotGain()
{
  m_plotGain=plotGain;
}

int CPlotter::getPlotGain()                               //getPlotGain()
{
  return m_plotGain;
}

void CPlotter::setSmooth(int n)                               //setSmooth()
{
  m_smooth=n;
}

int CPlotter::getSmooth()                                    //getSmooth()
{
  return m_smooth;
}
int CPlotter::plotWidth(){return m_2DPixmap.width();}
void CPlotter::UpdateOverlay() {DrawOverlay();}
