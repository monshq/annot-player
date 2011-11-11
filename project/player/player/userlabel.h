#ifndef USERLABEL_H
#define USERLABEL_H

// userlabel.h
// 8/1/2011

#include <QLabel>

class UserLabel : public QLabel
{
  Q_OBJECT

  typedef UserLabel Self;
  typedef QLabel Base;

public:
  explicit UserLabel(QWidget *parent = 0);

signals:
  void showUserPanelRequested();

protected:
  virtual void mouseDoubleClickEvent(QMouseEvent *event);
};

#endif // USERLABEL_H