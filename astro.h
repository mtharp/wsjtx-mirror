#ifndef ASTRO_H
#define ASTRO_H

#include <QWidget>
#include <QDateTime>

namespace Ui {
  class Astro;
}

class Astro : public QWidget
{
  Q_OBJECT

public:
  explicit Astro(QWidget *parent = 0);
  void astroUpdate(QDateTime t, QString mygrid, double freq);
  void setFontSize(int n);
  ~Astro();

private:
    Ui::Astro *ui;
};

extern "C" {
  void astrosub_(int* nyear, int* month, int* nday, double* uth, int* nfreq,
     const char* mygrid, const char* hisgrid, double* azsun,
     double* elsun, double* azmoon, double* elmoon, double* azmoondx,
     double* elmoondx, int* ntsky, float* dop, float* doppler00,
     double* ramoon, double* decmoon, double* dgrd, double* poloffset,
     double* xnr, float* techo, int len1, int len2);
}

#endif // ASTRO_H
