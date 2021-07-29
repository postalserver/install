#!/bin/bash
ROOT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
set -e

run() {
    eval $@
}

# Enter the root directory
cd $ROOT_DIR

# Run the right command
case "$1" in
    start)
        run "docker-compose -p postal up -d"
        ;;

    stop)
        run "docker-compose -p postal down"
        ;;

    initialize)
        run "docker-compose -p postal run runner postal initialize"
        ;;

    upgrade)
        run "docker-compose pull"
        run "docker-compose -p postal run runner postal upgrade"
        run "docker-compose -p postal up -d"
        ;;

    upgrade-db)
        run "docker-compose -p postal run runner postal upgrade"
        ;;

    console)
        run "docker-compose -p postal run runner postal console"
        ;;

    make-user)
        run "docker-compose -p postal run runner postal make-user"
        ;;

    default-dkim-record)
        run "docker-compose -p postal run runner postal default-dkim-record"
        ;;

    test-app-smtp)
        run "docker-compose -p postal run runner postal test-app-smtp"
        ;;

    *)
        echo "Usage: postal [command]"
        echo
        echo "Running postal:"
        echo
        echo -e " * \e[35mstart\e[0m - start Postal"
        echo -e " * \e[35mstop\e[0m - stop Postal"
        echo
        echo "Setup/upgrade tools:"
        echo
        echo -e " * \e[32minitialize\e[0m - create and load the DB schema"
        echo -e " * \e[32mupgrade\e[0m - upgrade the DB schema"
        echo
        echo "Other tools:"
        echo
        echo -e " * \e[34mversion\e[0m - show the current Postal version"
        echo -e " * \e[34mmake-user\e[0m - create a new global admin user"
        echo -e " * \e[34mdefault-dkim-record\e[0m - display the default DKIM record"
        echo -e " * \e[34mconsole\e[0m - open an interactive console"
        echo -e " * \e[34mtest-app-smtp\e[0m - send a test message through Postal"
        echo
esac
