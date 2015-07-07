#include "LettersSpinBox.hpp"

#include <QString>

#include "moc_LettersSpinBox.cpp"

QString LettersSpinBox::textFromValue (int value) const
{
  QString text;

  if(value < 10) {
    do {
      auto digit = value % 26;
      value /= 26;
      text = QChar {lowercase_ ? 'a' + digit : 'A' + digit} + text;
    } while (value);
  } else {
    if(value==11) text="5";
    if(value==12) text="10";
    if(value==13) text="15";
    if(value==14) text="30";
  }
  return text;
}

int LettersSpinBox::valueFromText (QString const& text) const
{
  int value {0};
  for (int index = text.size (); index > 0; --index)
    {
      value = value * 26 + text[index - 1].toLatin1 () - (lowercase_ ? 'a' : 'A');
    };
  return value;
}
