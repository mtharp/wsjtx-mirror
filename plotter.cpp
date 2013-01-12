#include "plotter.h"
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

  m_StartFreq = 1000;
  m_fftBinWidth=1500.0/2048.0;
  m_fSpan=1000.0;
  m_hdivs = HORZ_DIVS;
  m_Running = false;
  m_paintEventBusy=false;
  m_WaterfallPixmap = QPixmap(0,0);
  m_2DPixmap = QPixmap(0,0);
  m_ScalePixmap = QPixmap(0,0);
  m_OverlayPixmap = QPixmap(0,0);
  m_Size = QSize(0,0);
  m_TxFreq = 1500;
  m_line = 0;
  m_fSample = 12000;
  m_nsps=15360;
  m_dBStepSize=10;
  m_Percent2DScreen = 30;	//percent of screen used for 2D display
  m_transmitted=false;
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
    m_WaterfallPixmap = QPixmap(m_Size.width(), m_h1);
    m_OverlayPixmap = QPixmap(m_Size.width(), m_h2);
    m_OverlayPixmap.fill(Qt::black);

    m_WaterfallPixmap.fill(Qt::black);
    m_2DPixmap.fill(Qt::black);
    m_ScalePixmap = QPixmap(m_w,30);
    m_ScalePixmap.fill(Qt::white);

    m_fSpan=m_w*m_fftBinWidth;
    m_StartFreq=100 * int((1500-0.5*m_fSpan)/100.0 + 0.5);
    if(m_nsps==65536) m_StartFreq=20 * int((1612.5-0.5*m_fSpan)/20.0 + 0.5);
  }
  DrawOverlay();
}

void CPlotter::paintEvent(QPaintEvent *)                    // paintEvent()
{
  if(m_paintEventBusy) return;
  m_paintEventBusy=true;
  QPainter painter(this);
  painter.drawPixmap(0,0,m_ScalePixmap);
  painter.drawPixmap(0,30,m_WaterfallPixmap);
  painter.drawPixmap(0,m_h1,m_2DPixmap);
  m_paintEventBusy=false;
}

void CPlotter::draw(float swide[])                                //draw()
{
  int j,y2;
  float y;

  double gain = pow(10.0,0.05*(m_plotGain+7));

//move current data down one line (must do this before attaching a QPainter object)
  m_WaterfallPixmap.scroll(0,1,0,0,m_w,m_h1);
  QPainter painter1(&m_WaterfallPixmap);
  m_2DPixmap = m_OverlayPixmap.copy(0,0,m_w,m_h2);
  QPainter painter2D(&m_2DPixmap);

  painter2D.setPen(Qt::green);

  QPoint LineBuf[MAX_SCREENSIZE];
  j=0;
  bool strong0=false;
  bool strong=false;
  int i0=(m_StartFreq-1000)/m_fftBinWidth;
  if(m_nsps==65536) i0=(m_StartFreq-1550)/m_fftBinWidth;

  for(int i=0; i<m_w; i++) {
    strong=false;
    if(swide[i0+i]<0) {
      strong=true;
      swide[i0+i]=-swide[i0+i];
    }
    y = 10.0*log10(swide[i0+i]);
    int y1 = 5.0*gain*y + 10*m_plotZero;
    if (y1<0) y1=0;
    if (y1>254) y1=254;
    if (swide[i0+i]>1.e29) y1=255;
    if(y1==255 and m_transmitted) {
      painter1.setPen(Qt::red);
    } else {
      painter1.setPen(m_ColorTbl[y1]);
    }
    painter1.drawPoint(i,0);
    y2=0;
    if(m_bCumulative) {
      y2=1.5*gain*10.0*log10(datcom_.savg[i0+i]) - 20;
    } else {
      y2 = 0.4*gain*y - 15;
    }
    y2=y2*float(m_h)/540.0;
    if(strong != strong0 or i==m_w-1) {
      painter2D.drawPolyline(LineBuf,j);
      j=0;
      strong0=strong;
      if(strong0) painter2D.setPen(Qt::red);
      if(!strong0) painter2D.setPen(Qt::green);
    }
    LineBuf[j].setX(i);
    LineBuf[j].setY(m_h-(y2+0.8*m_h));
    j++;
  }
  m_transmitted=false;

  if(swide[0]>1.0e29) m_line=0;
  m_line++;
  if(m_line == 13) {
    UTCstr();
    painter1.setPen(Qt::white);
    painter1.drawText(5,10,m_sutc);
  }
  update();                              //trigger a new paintEvent
}

void CPlotter::UTCstr()
{
  int ihr,imin;
  if(datcom_.ndiskdat != 0) {
    ihr=datcom_.nutc/100;
    imin=datcom_.nutc % 100;
  } else {
    qint64 ms = QDateTime::currentMSecsSinceEpoch() % 86400000;
    imin=ms/60000;
    ihr=imin/60;
    imin=imin % 60;
    imin=imin - (imin % (m_TRperiod/60));
  }
  sprintf(m_sutc,"%2.2d:%2.2d",ihr,imin);
}

void CPlotter::DrawOverlay()                                 //DrawOverlay()
{
  if(m_OverlayPixmap.isNull() or m_WaterfallPixmap.isNull() or
     m_dialFreq==0) return;
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
  int n=m_fSpan/10;
  m_freqPerDiv=10;
  if(n>25) m_freqPerDiv=50;
  if(n>70) m_freqPerDiv=100;
  if(n>140) m_freqPerDiv=200;
  if(n>310) m_freqPerDiv=500;
  float pixPerHdiv = m_freqPerDiv/m_fftBinWidth;
  float pixPerVdiv = float(m_h2)/float(VERT_DIVS);

  m_RFHz=int(1000000.0*m_dialFreq+m_StartFreq) % 1000;
//  qDebug() << "B" << m_StartFreq << m_dialFreq << m_RFHz;
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

  QPen pen0(Qt::green, 3);              //Mark decoding range with green line
  painter0.setPen(pen0);
  int x1,x2;
  if(m_nsps==8192) {
    x=XfromFreq(1500);
    x1=x - 100/m_fftBinWidth;
    x2=x + 100/m_fftBinWidth;
  } else {
    x=XfromFreq(1612.5);
    x1=x - 12.5/m_fftBinWidth;
    x2=x + 12.5/m_fftBinWidth;
  }
  pen0.setWidth(6);
  painter0.drawLine(x1,28,x2,28);

  QPen pen1(Qt::red, 3);                         //Mark Tx Freq with red tick
  painter0.setPen(pen1);
  x = XfromFreq(m_TxFreq);
  painter0.drawLine(x,17,x,30);

}

void CPlotter::MakeFrequencyStrs()                       //MakeFrequencyStrs
{
  float freq;
  for(int i=0; i<=m_hdivs; i++) {
    if(m_bRFscale) {
      freq=int(m_RFHz + i*m_freqPerDiv) % 1000;
    } else {
      freq=m_StartFreq + i*m_freqPerDiv;
    }
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

int CPlotter::plotWidth(){return m_WaterfallPixmap.width();}
void CPlotter::UpdateOverlay() {DrawOverlay();}
void CPlotter::setDataFromDisk(bool b) {m_dataFromDisk=b;}

void CPlotter::setTxFreq(int x, bool bf)                       //setTxFreq()
{
  if(bf) {
    m_TxFreq=x;         // x is freq in Hz
    m_xClick=XfromFreq(m_TxFreq);
  } else {
    if(x<0) x=0;      // x is pixel number
    if(x>m_Size.width()) x=m_Size.width();
    m_TxFreq = int(FreqfromX(x)+0.5);
    m_xClick=x;
  }
  DrawOverlay();
  update();
}

int CPlotter::TxFreq() {return m_TxFreq;}                        //TxFreq()

void CPlotter::mousePressEvent(QMouseEvent *event)       //mousePressEvent
{
  bool ctrl = (event->modifiers() & Qt::ControlModifier);
  if(ctrl) {
    int x=event->x();
    setTxFreq(x,false);
    emit freezeDecode1(1);                  //### ???
  }
}

void CPlotter::mouseDoubleClickEvent(QMouseEvent *event)  //mouse2click
{
  int x=event->x();
  setTxFreq(x,false);
  emit freezeDecode1(2);                  //### ???
}

void CPlotter::setPalette(QString palette)                      //setPalette()
{
  if(palette=="Linrad") {
    float twopi=6.2831853;
    float r,g,b,phi,x;
    for(int i=0; i<256; i++) {
      r=0.0;
      if(i>105 and i<=198) {
        phi=(twopi/4.0) * (i-105.0)/(198.0-105.0);
        r=sin(phi);
      } else if(i>=198) {
          r=1.0;
      }

      g=0.0;
      if(i>35 and i<198) {
        phi=(twopi/4.0) * (i-35.0)/(122.5-35.0);
        g=0.625*sin(phi);
      } else if(i>=198) {
        x=(i-186.0);
        g=-0.014 + 0.0144*x -0.00007*x*x +0.000002*x*x*x;
        if(g>1.0) g=1.0;
      }

      b=0.0;
      if(i<=117) {
        phi=(twopi/2.0) * i/117.0;
        b=0.4531*sin(phi);
      } else if(i>186) {
        x=(i-186.0);
        b=-0.014 + 0.0144*x -0.00007*x*x +0.000002*x*x*x;
        if(b>1.0) b=1.0;
      }
      m_ColorTbl[i].setRgb(int(255.0*r),int(255.0*g),int(255.0*b));
    }
    m_ColorTbl[255].setRgb(255,255,100);

  }

  if(palette=="CuteSDR") {
      for( int i=0; i<256; i++) {
      if( (i<43) )
        m_ColorTbl[i].setRgb( 0,0, 255*(i)/43);
      if( (i>=43) && (i<87) )
        m_ColorTbl[i].setRgb( 0, 255*(i-43)/43, 255 );
      if( (i>=87) && (i<120) )
        m_ColorTbl[i].setRgb( 0,255, 255-(255*(i-87)/32));
      if( (i>=120) && (i<154) )
        m_ColorTbl[i].setRgb( (255*(i-120)/33), 255, 0);
      if( (i>=154) && (i<217) )
        m_ColorTbl[i].setRgb( 255, 255 - (255*(i-154)/62), 0);
      if( (i>=217)  )
        m_ColorTbl[i].setRgb( 255, 0, 128*(i-217)/38);
    }
    m_ColorTbl[255].setRgb(255,255,100);
  }

  if(palette=="Blue") {
    FILE* fp=fopen("blue.dat","r");
    int n,r,g,b;
    float xr,xg,xb;
    for(int i=0; i<256; i++) {
      fscanf(fp,"%d%f%f%f",&n,&xr,&xg,&xb);
      r=255.0*xr + 0.5;
      g=255.0*xg + 0.5;
      b=255.0*xb + 0.5;
      m_ColorTbl[i].setRgb(r,g,b);
    }
  }

  if(palette=="AFMHot") {
    FILE* fp=fopen("afmhot.dat","r");
    int n,r,g,b;
    float xr,xg,xb;
    for(int i=0; i<256; i++) {
      fscanf(fp,"%d%f%f%f",&n,&xr,&xg,&xb);
      r=255.0*xr + 0.5;
      g=255.0*xg + 0.5;
      b=255.0*xb + 0.5;
      m_ColorTbl[i].setRgb(r,g,b);
    }
  }
}

void CPlotter::setNsps(int ntrperiod, int nsps)                                  //setNSpan()
{
  m_TRperiod=ntrperiod;
  m_nsps=nsps;
  m_fftBinWidth=4.0*1500.0/m_nsps;
  m_fSpan=m_w*m_fftBinWidth;
  m_StartFreq=100 * int((1500-0.5*m_fSpan)/100.0 + 0.5);
  if(m_nsps==65536) m_StartFreq=10 * int((1612.5-0.5*m_fSpan)/10.0 + 0.5);
  DrawOverlay();                         //Redraw scales and ticks
  update();                              //trigger a new paintEvent}
}
