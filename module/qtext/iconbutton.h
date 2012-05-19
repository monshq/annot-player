#ifndef _QTEXT_ICONBUTTON_H
#define _QTEXT_ICONBUTTON_H

// qtext/iconbutton.h
// 5/16/2012

#include "module/qtext/toolbutton.h"

QT_FORWARD_DECLARE_CLASS(QPropertyAnimation)
QT_FORWARD_DECLARE_CLASS(QTimer)

namespace QtExt {

class IconButton : public ToolButton
{
  Q_OBJECT
  Q_PROPERTY(int radius READ radius WRITE setRadius)
  Q_PROPERTY(int minimumRadius READ minimumRadius WRITE setMinimumRadius)
  Q_PROPERTY(int maximumRadius READ maximumRadius WRITE setMaximumRadius)
  Q_DISABLE_COPY(IconButton)
  typedef IconButton Self;
  typedef ToolButton Base;

  int radius_, minimumRadius_, maximumRadius_;
  QPropertyAnimation *radiusAni_;

  QTimer *leaveTimer_;

public:
  explicit IconButton(QWidget *parent = 0);

  // - Properties -
public:
  int radius() const { return radius_; }
  int minimumRadius() const { return minimumRadius_; }
  int maximumRadius() const { return maximumRadius_; }
public slots:
  void setRadius(int value);
  void setMinimumRadius(int value) { minimumRadius_ = value; }
  void setMaximumRadius(int value) { maximumRadius_ = value; }

  // - Events -
protected:
  void enterEvent(QEvent *event);
  void leaveEvent(QEvent *event);
  void changeEvent(QEvent *event);

protected slots:
  void enter();
  void leave();
};

} // namespace QtExt

#endif // _QTEXT_ICONBUTTON_H
