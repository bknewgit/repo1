#!/bin/sh
##Script to self heal NTP service

#Check the OS Type
OS=`uname -a | awk '{print $1}'`

################################################################
####Beginning of Function Definitions

#self heal for Linux NTP
NTP_Linux()
{
	RELEASE=`cat /etc/redhat-release | awk '{print $7}' | awk -F "." '{print $1}'`
	echo "Restarting NTPD services and sleeping for 10 seconds on : `hostname`"
	if [ "${RELEASE}"  == "7" ]; then
		systemctl stop ntpd
		/usr/sbin/ntpdate -s us.pool.ntp.org
		systemctl start ntpd 
		sleep 10
		systemctl status ntpd 
	else
		/sbin/service ntpd stop 
		/usr/sbin/ntpdate -s us.pool.ntp.org
		/sbin/service ntpd start
		sleep 10
		/sbin/service ntpd status
	fi
}

#self heal for SunOS NTP
NTP_SunOS()
{
	echo "Restarting NTPD services and sleeping for 10 seconds on : `hostname`"
	/usr/sbin/svcadm disable ntp
        /usr/sbin/ntpdate -s us.pool.ntp.org
	/usr/sbin/svcadm enable ntp
	sleep 10
	ps -ef | grep xntpd | grep -v grep
}

#self heal for AIX NTP
NTP_AIX()
{
	echo "Restarting NTPD services and sleeping for 10 seconds on : `hostname`"
	/usr/bin/stopsrc -s xntpd
        /usr/sbin/ntpdate -s us.pool.ntp.org
	/usr/bin/startsrc -s xntpd
	sleep 10
	ps -ef | grep xntpd | grep -v grep
}

#End of Function Definitions
################################################################

#Main routine
LogFile="/home/users/nagios/SelfHeal/logs/`hostname`-`date +%m%d%Y%H%M`-NTP.log"

echo "#################### S E L F - H E A L I N G In Progress ######################" | tee ${LogFile}
echo "Current Date : `date`"
case "${OS}" in
        "Linux")
		NTP_Linux | tee -a ${LogFile}
                ;;
        "SunOS")
		NTP_SunOS | tee -a ${LogFile}
                ;;
        "AIX")
		NTP_AIX | tee -a ${LogFile}
                ;;
esac

echo "Date after fix : `date`"
echo "#################### S E L F - H E A L I N G Completed #######################" | tee -a ${LogFile}
