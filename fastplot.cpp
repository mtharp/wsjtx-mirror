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

  m_pixPerSecond= 12000.0/512.0;
  m_hdivs = 30;
  m_2DPixmap = QPixmap(0,0);
  m_ScalePixmap = QPixmap(0,0);
  m_OverlayPixmap = QPixmap(0,0);
  m_Size = QSize(0,0);
  m_line = 0;
  m_dBStepSize=10;
  m_jh0=0;
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
  int j,y;
  float gain = pow(10.0,(m_plotGain/20.0));

  if(m_2DPixmap.size().width()==0) return;
  QPainter painter2D(&m_2DPixmap);
  QRect tmp(0,0,m_w,m_h2);
  painter2D.fillRect(tmp,Qt::black);

  QPoint LineBuf[MAX_SCREENSIZE];
  QPen penGreen(Qt::green,1);


// Update the green curve
  painter2D.setPen(penGreen);
  j=0;
  for(int x=m_jh0; x<=fast_jh; x++) {
    y = 0.9*m_h - gain*(m_h/100.0)*fast_green[x] - m_plotZero;
    LineBuf[j].setX(x);
    LineBuf[j].setY(y);
//    qDebug() << "a" << j << fast_jh << fast_green[x] << x << y;
    j++;
  }
//  m_jh0=fast_jh;
  m_jh0=0;
  painter2D.drawPolyline(LineBuf,j);
  update();                              //trigger a new paintEvent
}

void FPlotter::DrawOverlay()                                 //DrawOverlay()
{
  if(m_OverlayPixmap.isNull() or m_2DPixmap.isNull()) return;
  int x;

  QRect rect;
  QPainter painter(&m_OverlayPixmap);
  painter.initFrom(this);
//  painter.setBrush(Qt::SolidPattern);
//  painter.setPen(QPen(Qt::white, 1,Qt::DotLine));

  QRect rect0;
  QPainter painter0(&m_ScalePixmap);
  painter0.initFrom(this);

  //create Font to use for scales
  QFont Font("Arial");
  Font.setPointSize(8);
  QFontMetrics metrics(Font);
  Font.setWeight(QFont::Normal);
  painter0.setFont(Font);
  painter0.setPen(Qt::white);
  m_ScalePixmap.fill(Qt::black);
  painter0.drawRect(0, 0, m_w, 20);
  painter0.drawLine(0,20,m_w,20);

//Draw ticks at 1-second intervals
  for( int i=0; i<=m_hdivs; i++) {
    x = (int)( (float)i*m_pixPerSecond );
    painter0.drawLine(x,16,x,20);
  }

//Write numbers on the time scale
  MakeTimeStrs();
  for( int i=0; i<=m_hdivs; i++) {
    if(0==i) {
      //left justify the leftmost text
      x = (int)( (float)i*m_pixPerSecond);
      rect0.setRect(x,0, (int)m_pixPerSecond, 20);
      painter0.drawText(rect0, Qt::AlignLeft|Qt::AlignVCenter,
                       m_HDivText[i]);
    }
    else if(m_hdivs == i) {
      //right justify the rightmost text
      x = (int)( (float)i*m_pixPerSecond - m_pixPerSecond);
      rect0.setRect(x,0, (int)m_pixPerSecond, 20);
      painter0.drawText(rect0, Qt::AlignRight|Qt::AlignVCenter,
                       m_HDivText[i]);
    } else {
      //center justify the rest of the text
      x = (int)( (float)i*m_pixPerSecond - m_pixPerSecond/2);
      rect0.setRect(x,0, (int)m_pixPerSecond, 20);
      painter0.drawText(rect0, Qt::AlignHCenter|Qt::AlignVCenter,
                       m_HDivText[i]);
    }
  }
}

void FPlotter::MakeTimeStrs()                       //MakeTimeStrs
{
  for(int i=0; i<=m_hdivs; i++) {
    m_HDivText[i].setNum(i);
  }
}

int FPlotter::XfromTime(float t)                               //XfromFreq()
{
  return int(t*m_pixPerSecond);
}

float FPlotter::TimefromX(int x)                               //FreqfromX()
{
  return float(x/m_pixPerSecond);
}

void FPlotter::SetRunningState(bool running)              //SetRunningState()
{
  m_Running = running;
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
