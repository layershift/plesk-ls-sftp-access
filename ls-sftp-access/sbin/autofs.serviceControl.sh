#!/bin/bash

echo $1

case $1 in
    start)
        /bin/systemctl enable autofs.service
        /bin/systemctl start autofs.service
        exit $?
    ;;
    stop)
        /bin/systemctl disable autofs.service
        /bin/systemctl stop autofs.service
        exit $?
    ;;
    restart)
        /bin/systemctl stop autofs.service && /bin/systemctl start autofs.service
        exit $?
    ;;
    status)
        /bin/systemctl status autofs.service
        if [ $? -ge 1 ]; then exit 1; else exit 0; fi;
    ;;
    isinstalled|isconfigured)
        /bin/systemctl status autofs.service
        if [ $? -eq 4 ]; then
            echo "Service not installed"
            exit 1
        else
            echo "Service is installed"
            exit 0
        fi
    ;;
    *)
        echo "Use $0 start|stop|restart|status|isconfigured|isinstalled"
        exit 1
    ;;
esac;

exit 0