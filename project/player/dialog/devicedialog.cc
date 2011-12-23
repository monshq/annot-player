// devicedialog.cc
// 12/2/2011

#include "devicedialog.h"
#include "uistyle.h"
#include "tr.h"
#include "stylesheet.h"
#include "defines.h"
#include "logger.h"
#include "core/gui/toolbutton.h"
#include "core/gui/combobox.h"
#ifdef Q_WS_WIN
  #include "win/qtwin/qtwin.h"
#endif // Q_WS_WIN
#ifdef Q_OS_UNIX
  #include "unix/qtunix/qtunix.h"
#endif // Q_OS_UNIX
#ifdef USE_MODULE_IOUTIL
  #include "module/ioutil/ioutil.h"
#endif // USE_MODULE_IOUTIL
#include <QtGui>

#define DEBUG "devicedialog"
#include "module/debug/debug.h"

#define COMBOBOX_MINWIDTH      100

using namespace Logger;

// - Helpers -

QStringList
DeviceDialog::devices()
{
#ifdef Q_WS_WIN
  return QtWin::getLogicalDrivesWithType(QtWin::CdRomDrive);
#elif defined (Q_OS_UNIX)
  return QtUnix::getDevicesWithType(QtUnix::CdRom);
#else
  Q_ASSERT(0); // unimplemented
  return QStringList();
#endif // Q_WS_WIN | Q_OS_UNIX
}

// - Constructions -

DeviceDialog::DeviceDialog(QWidget *parent)
  : Base(parent)
{
#ifdef Q_WS_MAC
  setWindowFlags(windowFlags() | Qt::FramelessWindowHint);
#endif // Q_WS_MAC
  setWindowTitle(TR(T_TITLE_OPENDEVICE));
  UiStyle::globalInstance()->setWindowStyle(this);
  setContentsMargins(0, 0, 0, 0);

  // Widgets

  //messageLabel_ = new QLabel; {
  //  messageLabel_->setStyleSheet(SS_LABEL);
  //  messageLabel_->setToolTip(TR(T_MESSAGE));
  //  messageLabel_->setAlignment(Qt::AlignCenter);
  //}

  pathComboBox_ = new Core::Gui::ComboBox; {
    UiStyle::globalInstance()->setComboBoxStyle(pathComboBox_);
    pathComboBox_->setEditable(true);
    pathComboBox_->setMinimumWidth(COMBOBOX_MINWIDTH);
    pathComboBox_->setToolTip(TR(T_PATH));
  }
  //connect(pathComboBox_, SIGNAL(activated(int)), SLOT(setMoveStyle(int)));

#define MAKE_RADIOBUTTON(_button, _text) \
  _button = new QRadioButton; { \
    _button->setStyleSheet(SS_RADIOBUTTON_TEXT); \
    _button->setText(_text); \
    _button->setToolTip(_text); \
  }

  MAKE_RADIOBUTTON(autoRadioButton_, tr("auto"))
  MAKE_RADIOBUTTON(dvdRadioButton_, "DVD")
  MAKE_RADIOBUTTON(cdRadioButton_, "CD")
#undef MAKE_RADIOBUTTON

#define MAKE_TOOLBUTTON(_button, _text, _tip, _slot) \
   _button = new Core::Gui::ToolButton; { \
    _button->setStyleSheet(SS_TOOLBUTTON_TEXT); \
    _button->setToolButtonStyle(Qt::ToolButtonTextOnly); \
    _button->setText(QString("[ %1 ]").arg(_text)); \
    _button->setToolTip(_tip); \
    connect(_button, SIGNAL(clicked()), _slot); \
  }

  MAKE_TOOLBUTTON(okButton_, TR(T_OPEN), TR(T_TOOLTIP_OPENDEVICE), SLOT(ok()))
  QToolButton *MAKE_TOOLBUTTON(cancelButton, TR(T_CANCEL), TR(T_CANCEL), SLOT(cancel()))
  QToolButton *MAKE_TOOLBUTTON(refreshButton, TR(T_REFRESH), TR(T_REFRESH), SLOT(refresh()))
#undef MAKE_TOOLBUTTON

  // Layouts
  QVBoxLayout *rows = new QVBoxLayout; {
    QHBoxLayout *buttons = new QHBoxLayout,
                *path = new QHBoxLayout;

    //rows->addWidget(messageLabel_);
    rows->addLayout(path);
    rows->addLayout(buttons);

    path->addWidget(pathComboBox_);
    path->addStretch();
    path->addWidget(autoRadioButton_);
    path->addWidget(dvdRadioButton_);
    path->addWidget(cdRadioButton_);

    buttons->addWidget(okButton_);
    buttons->addWidget(refreshButton);
    buttons->addWidget(cancelButton);
  } setLayout(rows);

  // Connections
  connect(pathComboBox_, SIGNAL(currentIndexChanged(int)), SLOT(invalidateButtons()));
  connect(pathComboBox_, SIGNAL(editTextChanged(QString)), SLOT(invalidateButtons()));

  // Post behaviors
  autoRadioButton_->setChecked(true);
  okButton_->setFocus();
}

// - Properties -

//void
//DeviceDialog::setMessage(const QString &text)
//{ messageLabel_->setText(text); }

QString
DeviceDialog::currentPath() const
{ return pathComboBox_->currentText(); }
// - Slots -

void
DeviceDialog::cancel()
{ hide(); }

void
DeviceDialog::ok()
{
  hide();

  // TODO: validate exsistent of path here
  QString path = currentPath();
  if (!QFileInfo(path).exists()) {
    warn(TR(T_ERROR_BAD_FILEPATH) + ": " + path);
    return;
  }

  bool isAudioCD;
#if USE_MODULE_IOUTIL
  if (autoRadioButton_->isChecked())
    isAudioCD = IOUtil::isAudioCD(path);
  else
#endif // USE_MODULE_IOUTIL
  isAudioCD = cdRadioButton_->isChecked();
  emit deviceSelected(path, isAudioCD);
}

void
DeviceDialog::refresh()
{
  //invalidateMessage();
  invalidateComboBox();
  invalidateButtons();
}

void
DeviceDialog::invalidateComboBox()
{
  pathComboBox_->clear();
  QStringList items = devices();
  foreach (QString path, items)
    pathComboBox_->addItem(path);

  if (pathComboBox_->count())
    pathComboBox_->setCurrentIndex(0);
}

// - Events -

void
DeviceDialog::setVisible(bool visible)
{
  if (visible)
    refresh();
  Base::setVisible(visible);
}

void
DeviceDialog::invalidateButtons()
{
  QString path = currentPath();
  bool t = QFileInfo(path).exists();
  okButton_->setEnabled(t);
}

// EOF