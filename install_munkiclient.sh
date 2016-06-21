#!/bin/bash

#  Install Munki Client, point it at your munki repo, and run updates
#  Coded by Jack-Daniyel Strong, J-D Strong Consulting, Inc. & Strong Solutions
#  Written 2015.07.28, Last Modified 2015.07.28 by Jack-Daniyel Strong

# IP Address or FQDN for your Munki Repo
MUNKISERVER="10.211.55.13"

# IP Address or FQDN for your Apple Software Update Server
# Set to Blank to use Apple's Servers
SUSSERVER=""

# Audible Notifications
NOTIFY=1   # set to 0 to not have audible notification

### TOUCH NOTHING BELOW THIS LINE ###
##### Begin Declare Variables Used by Script #####
 
DEFAULTS="/usr/bin/defaults"
INSTALLER="/usr/sbin/installer"
REMOVE="/bin/rm"
LAUNCHCTL="/bin/launchctl"
CURL="/usr/bin/curl"
OPEN="/usr/bin/open"

# Declare directory variables.
PREFS_DIR="/Library/Preferences"
MANAGEDINSTALLS="${PREFS_DIR}/ManagedInstalls"

##### End Declare Variables Used by Script #####

if [ $(whoami) != 'root' ]; then
       echo "Must be root to run $0"
        exit 1;
fi

##### Let us set some Preferences #####
 
# Tell Munki to where its repo is.
$DEFAULTS write $MANAGEDINSTALLS SoftwareRepoURL "http://${MUNKISERVER}/munki_repo/"

# Tell Munki to Install Apple Software Updates.
$DEFAULTS write $MANAGEDINSTALLS InstallAppleSoftwareUpdates -bool True

# Tell Munki of Location for Apple Software Updates.
if [[ $SUSSERVER ]]; then
	$DEFAULTS write $MANAGEDINSTALLS SoftwareUpdateServerURL "http://${SUSSERVER}:8088/index.sucatalog"
fi

# Tell Munki to Not Tell the User in the event it gets left behind.
$DEFAULTS write $MANAGEDINSTALLS SuppressUserNotification -bool True
$DEFAULTS write $MANAGEDINSTALLS DaysBetweenNotifications -int 1000

##### End Preferences Setting #####

##### Install the latest Munki Package #####
#Download
$CURL https://github.com/munki/munki/releases/download/v2.7.1/munkitools-2.7.1.2764.pkg > /tmp/munki2.pkg 
#Install
$INSTALLER -target / -pkg /tmp/munki2.pkg 
#Cleanup
$REMOVE -rf /tmp/__MACOSX /tmp/munki2.pkg
#Start Daemons
$LAUNCHCTL load /Library/LaunchDaemons/com.googlecode.munki.*
#Kickoff update run
/usr/local/munki/managedsoftwareupdate

# Nondestructive Notification - Customer's settings are preserved.
if [[ $NOTIFY ]]; then
	MuteState=$(osascript -e 'output muted of (get volume settings)')
	OldVolume=$(osascript -e 'output volume of (get volume settings)')
	OldAVolume=$(osascript -e 'output alert volume of (get volume settings)')

	osascript -e 'set volume output muted false'
	osascript -e 'set volume output volume 100'
	osascript -e 'set volume alert volume 100'

	osascript -e 'beep 3' # get attention
	say -v Alex 'Run Updates is Finished Installing'

	# CleanUp
	osascript -e "set volume output muted ${MuteState}"
	osascript -e "set volume output volume $OldVolume"
	osascript -e "set volume alert volume $OldAVolume"
fi

#Open Managed Software Center
$OPEN '/Applications/Managed Software Center.app'
 
exit 0;
