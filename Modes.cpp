#include "Modes.hpp"

#include <QString>
#include <QVariant>

#include "moc_Modes.cpp"

namespace
{
  char const * const mode_names[] =
  {
    "",
    "JT65",
    "JT9",
    "JT4",
    "WSPR",
    "Echo",
    "ISCAT",
    "JTMSK"
  };
}

Modes::Modes (QObject * parent)
  : QAbstractListModel {parent}
{
}

char const * Modes::name (Mode m)
{
  return mode_names[static_cast<int> (m)];
}

auto Modes::value (QString const& s) -> Mode
{
  auto end = mode_names + sizeof (mode_names) / sizeof (mode_names[0]);
  auto p = std::find_if (mode_names, end
                         , [&s] (char const * const name) {
                           return name == s;
                         });
  return p != end ? static_cast<Mode> (p - mode_names) : NULL_MODE;
}

QVariant Modes::data (QModelIndex const& index, int role) const
{
  QVariant item;

  if (index.isValid ())
    {
      auto const& row = index.row ();
      switch (role)
        {
        case Qt::ToolTipRole:
        case Qt::AccessibleDescriptionRole:
          item = tr ("Mode");
          break;

        case Qt::EditRole:
          item = static_cast<Mode> (row);
          break;

        case Qt::DisplayRole:
        case Qt::AccessibleTextRole:
          item = mode_names[row];
          break;

        case Qt::TextAlignmentRole:
          item = Qt::AlignHCenter + Qt::AlignVCenter;
          break;
        }
    }

  return item;
}

QVariant Modes::headerData (int section, Qt::Orientation orientation, int role) const
{
  QVariant result;

  if (Qt::DisplayRole == role && Qt::Horizontal == orientation)
    {
      result = tr ("Mode");
    }
  else
    {
      result = QAbstractListModel::headerData (section, orientation, role);
    }

  return result;
}

#if !defined (QT_NO_DEBUG_STREAM)
ENUM_QDEBUG_OPS_IMPL (Modes, Mode);
#endif

ENUM_QDATASTREAM_OPS_IMPL (Modes, Mode);
ENUM_CONVERSION_OPS_IMPL (Modes, Mode);
