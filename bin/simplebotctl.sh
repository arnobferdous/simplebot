#!/bin/sh
#
# Control script designed to allow an easy command line interface
# to controlling any binary.  Written by Marc Slemko, 1997/08/23
# 
# The exit codes returned are:
#	0 - operation completed successfully
#	1 - 
#	2 - usage error
#	3 - binary could not be started
#	4 - binary could not be stopped
#	8 - configuration syntax error
#
# When multiple arguments are given, only the error from the _last_
# one is reported.  Run "*ctl help" for usage info
#
#
# |||||||||||||||||||| START CONFIGURATION SECTION  ||||||||||||||||||||
# --------------------                              --------------------
# 
# the name of your binary
NAME="SimpleBot Daemon"
#
# home directory
BINDIR=`dirname $0`
HOMEDIR=`dirname $BINDIR`
#
# the path to your binary, including options if necessary
BINARY="$BINDIR/simplebotd.pl"
#
# the path to your PID file
PIDFILE="$HOMEDIR/logs/pid.txt"
#
# grep string for status `ps -ef` calls
STATUSGREP="simplebotd"
#
# --------------------                              --------------------
# ||||||||||||||||||||   END CONFIGURATION SECTION  ||||||||||||||||||||

ERROR=0
ARGV="$@"
if [ "x$ARGV" = "x" ] ; then 
    ARGS="help"
fi

for ARG in $@ $ARGS
do
    # check for pidfile
    if [ -f $PIDFILE ] ; then
	PID=`cat $PIDFILE`
	if [ "x$PID" != "x" ] && kill -0 $PID 2>/dev/null ; then
	    STATUS="$NAME running (pid $PID)"
	    RUNNING=1
	else
	    STATUS="$NAME not running (pid $PID?)"
	    RUNNING=0
	fi
    else
	STATUS="$NAME not running (no pid file)"
	RUNNING=0
    fi

    case $ARG in
    start)
	if [ $RUNNING -eq 1 ]; then
	    echo "$ARG: $NAME already running (pid $PID)"
	    continue
	fi
	if $BINARY ; then
	    echo "$ARG: $NAME started"
	else
	    echo "$ARG: $NAME could not be started"
	    ERROR=3
	fi
	;;
    stop)
	if [ $RUNNING -eq 0 ]; then
	    echo "$ARG: $STATUS"
	    continue
	fi
	if kill $PID ; then
            while [ "x$PID" != "x" ] && kill -0 $PID 2>/dev/null ; do
                sleep 1;
            done
	    echo "$ARG: $NAME stopped"
	else
	    echo "$ARG: $NAME could not be stopped"
	    ERROR=4
	fi
	;;
    restart)
        $0 stop start
	;;
    status)
        echo "$STATUS"
	if [ $RUNNING -eq 1 ]; then
		echo ""
		ps -ef | grep "$STATUSGREP" | grep -v grep
		echo ""
	fi
	;;
    *)
	echo "usage: $0 (start|stop|restart|status|debug|help)"
	cat <<EOF

start      - start $NAME
stop       - stop $NAME and wait until process actually exits
restart    - calls stop, then start (hard restart)
status     - check whether service is currently running
help       - display this screen

EOF
	ERROR=2
    ;;

    esac

done

exit $ERROR

## ====================================================================
## The Apache Software License, Version 1.1
##
## Copyright (c) 2000 The Apache Software Foundation.  All rights
## reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
##
## 1. Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
##
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in
##    the documentation and/or other materials provided with the
##    distribution.
##
## 3. The end-user documentation included with the redistribution,
##    if any, must include the following acknowledgment:
##       "This product includes software developed by the
##        Apache Software Foundation (http://www.apache.org/)."
##    Alternately, this acknowledgment may appear in the software itself,
##    if and wherever such third-party acknowledgments normally appear.
##
## 4. The names "Apache" and "Apache Software Foundation" must
##    not be used to endorse or promote products derived from this
##    software without prior written permission. For written
##    permission, please contact apache@apache.org.
##
## 5. Products derived from this software may not be called "Apache",
##    nor may "Apache" appear in their name, without prior written
##    permission of the Apache Software Foundation.
##
## THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
## WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
## OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
## DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
## ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
## SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
## LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
## USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
## ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
## OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
## SUCH DAMAGE.
## ====================================================================
##
## This software consists of voluntary contributions made by many
## individuals on behalf of the Apache Software Foundation.  For more
## information on the Apache Software Foundation, please see
## <http://www.apache.org/>.
##
## Portions of this software are based upon public domain software
## originally written at the National Center for Supercomputing Applications,
## University of Illinois, Urbana-Champaign.
##
# 