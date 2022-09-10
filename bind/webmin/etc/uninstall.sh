#!/bin/sh
printf "Are you sure you want to uninstall Webmin? (y/n) : "
read answer
printf "\n"
if [ "$answer" = "y" ]; then
	echo "Removing Webmin package .."
	rm -f /usr/share/webmin/authentic-theme/manifest-*
	dpkg --remove --force-depends webmin
	systemctlcmd=`which systemctl 2>/dev/null`
	if [ -x "$systemctlcmd" ]; then
		$systemctlcmd stop webmin >/dev/null 2>&1 </dev/null
		rm -f /lib/systemd/system/webmin.service
		$systemctlcmd daemon-reload
	fi
	echo ".. done"
fi
