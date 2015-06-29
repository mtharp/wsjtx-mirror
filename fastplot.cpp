#include "fastplot.h"
#include "commons.h"
#include <math.h>
#include <QDebug>
#include "moc_fastplot.cpp"

#define MAX_SCREENSIZE 2048


FPlotter::FPlotter(QWidget *parent) :                  //FPlotter Constructor
  QFrame(parent)
{
  setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Expanding);
  setFocusPolicy(Qt::StrongFocus);
  setAttribute(Qt::WA_PaintOnScreen,false);
  setAutoFillBackground(false);
  setAttribute(Qt::WA_OpaquePaintEvent, false);
  setAttribute(Qt::WA_NoSystemBackground, true);

  m_StartFreq = -200;
  m_fftBinWidth=12000.0/32768.0;
  m_hdivs = HORZ_DIVS;
  m_2DPixmap = QPixmap(0,0);
  m_ScalePixmap = QPixmap(0,0);
  m_OverlayPixmap = QPixmap(0,0);
  m_Size = QSize(0,0);
  m_line = 0;
  m_dBStepSize=10;
}

FPlotter::~FPlotter() { }                                      // Destructor

QSize FPlotter::minimumSizeHint() const
{
  return QSize(50, 50);
}

QSize FPlotter::sizeHint() const
{
  return QSize(180, 180);
}

void FPlotter::resizeEvent(QResizeEvent* )                    //resizeEvent()
{
  if(!size().isValid()) return;
  if( m_Size != size() ) {  //if changed, resize pixmaps to new screensize
    m_Size = size();
    m_w = m_Size.width();
    m_h = m_Size.height();
    m_h1=30;
    m_h2=m_h-m_h1;
    m_2DPixmap = QPixmap(m_Size.width(), m_h2);
    m_2DPixmap.fill(Qt::black);
    m_OverlayPixmap = QPixmap(m_Size.width(), m_h2);
    m_OverlayPixmap.fill(Qt::black);
    m_2DPixmap.fill(Qt::black);
    m_ScalePixmap = QPixmap(m_w,30);
    m_ScalePixmap.fill(Qt::white);
  }
  DrawOverlay();
  draw();
}

void FPlotter::paintEvent(QPaintEvent *)                    // paintEvent()
{
  QPainter painter(this);
  painter.drawPixmap(0,0,m_ScalePixmap);
  painter.drawPixmap(0,m_h1,m_2DPixmap);
}

void FPlotter::draw()                           //draw()
{
  int i,j,y;
  float blue[4096],red[4096];
  float gain = pow(10.0,(m_plotGain/20.0));

  if(m_2DPixmap.size().width()==0) return;
  QPainter painter2D(&m_2DPixmap);
  QRect tmp(0,0,m_w,m_h2);
  painter2D.fillRect(tmp,Qt::black);

  QPoint LineBuf[MAX_SCREENSIZE];
  QPen penBlue(QColor(0,255,255),1);
  QPen penRed(Qt::red,1);


// check i0 value! ...
  painter2D.setPen(penBlue);
  j=0;
  int i0=0;
  for(i=0; i<m_w; i++) {
    y = 0.9*m_h2 - gain*(m_h/10.0)*(blue[i0+i]-1.0) - 0.01*m_h2*m_plotZero;
    LineBuf[j].setX(i);
    LineBuf[j].setY(y);
    j++;
  }
  painter2D.drawPolyline(LineBuf,j);

  painter2D.setPen(penRed);
  j=0;
  for(int i=0; i<m_w; i++) {
    y = 0.9*m_h2 - gain*(m_h/10.0)*(red[i0+i]-1.0) - 0.01*m_h2*m_plotZero;
    LineBuf[j].setX(i);
    LineBuf[j].setY(y);
    j++;
  }
  painter2D.drawPolyline(LineBuf,j);
  update();                              //trigger a new paintEvent
}

void FPlotter::DrawOverlay()                                 //DrawOverlay()
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


  painter.setPen(QPen(Qt::white, 1,Qt::DotLine));

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

  float pixPerHdiv = 50; //###

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

}

void FPlotter::MakeFrequencyStrs()                       //MakeFrequencyStrs
{
  float freq;
  for(int i=0; i<=m_hdivs; i++) {
    freq=m_StartFreq + i*m_freqPerDiv;
    m_HDivText[i].setNum((int)freq);
  }
}

int FPlotter::XfromFreq(float f)                               //XfromFreq()
{
//  int x = (int) m_w * (f - m_StartFreq)/m_fSpan;
  int x=100;
  if(x<0 ) return 0;
  if(x>m_w) return m_w;
  return x;
}

float FPlotter::FreqfromX(int x)                               //FreqfromX()
{
//  return float(m_StartFreq + x*m_fftBinWidth*m_binsPerPixel);
}

void FPlotter::SetRunningState(bool running)              //SetRunningState()
{
//  m_Running = running;
}

void FPlotter::setPlotZero(int plotZero)                  //setPlotZero()
{
  m_plotZero=plotZero;
}

int FPlotter::getPlotZero()                               //getPlotZero()
{
  return m_plotZero;
}

void FPlotter::setPlotGain(int plotGain)                  //setPlotGain()
{
  m_plotGain=plotGain;
}

int FPlotter::getPlotGain()                               //getPlotGain()
{
  return m_plotGain;
}

int FPlotter::plotWidth(){return m_2DPixmap.width();}

void FPlotter::UpdateOverlay() {DrawOverlay();}
