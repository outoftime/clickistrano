#! /bin/sh

GEMS_BIN=/var/lib/gems/1.8/bin
CLICKISTRANO_ROOT=/home/deploy/clickistrano
USER=deploy
GROUP=deploy
PORT=3000
PIDFILE=/var/run/clickistrano.pid

case "$1" in
  start)
    echo -n "Starting clickistrano"
    cd $CLICKISTRANO_ROOT
    $GEMS_BIN/thin start -R config.ru -d -u $USER -g $USER -p $PORT -P $PIDFILE
    echo "."
    ;;
  stop)
    echo -n "Stopping clickistrano"
    cd $CLICKISTRANO_ROOT
    $GEMS_BIN/thin stop -P $PIDFILE
    rm $PIDFILE
    echo "."
    ;;

  *)
    echo "Usage: /sbin/service clickistrano {start|stop}"
    exit 1
esac

exit 0
