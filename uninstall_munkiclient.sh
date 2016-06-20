#!/bin/bash

#  Install Munki Client, point it at your munki repo, and run updates
#  Coded by Jack-Daniyel Strong, J-D Strong Consulting, Inc. & Strong Solutions
#  Written 2015.07.28, Last Modified 2015.10.19 by Jack-Daniyel Strong

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
PKGUTIL="/usr/sbin/pkgutil"

# Declare directory variables.
PREFS_DIR="/Library/Preferences"
MANAGEDINSTALLS="${PREFS_DIR}/ManagedInstalls"

##### End Declare Variables Used by Script #####

if [ $(whoami) != 'root' ]; then
       echo "Must be root to run $0"
        exit 1;
fi

##### Let us set some Preferences #####

 launchctl unload /Library/LaunchDaemons/com.googlecode.munki.*

$REMOVE -rf "/Applications/Utilities/Managed Software Update.app"
#Munki 2 only:
$REMOVE -rf "/Applications/Managed Software Center.app"

$REMOVE -f /Library/LaunchDaemons/com.googlecode.munki.*
$REMOVE -f /Library/LaunchAgents/com.googlecode.munki.*
$REMOVE -rf "/Library/Managed Installs"
$REMOVE -rf /usr/local/munki
$REMOVE /etc/paths.d/munki

$PKGUTIL --forget com.googlecode.munki.admin
$PKGUTIL --forget com.googlecode.munki.app
$PKGUTIL --forget com.googlecode.munki.core
$PKGUTIL --forget com.googlecode.munki.launchd

# reset App Store to pull updates from default Apple servers
$DEFAULTS delete $PREFS_DIR/com.apple.SoftwareUpdate CatalogURL

# Nondestructive Notification - Customer's settings are preserved.
if [[ $NOTIFY ]]; then
	MuteState=$(osascript -e 'output muted of (get volume settings)')
	OldVolume=$(osascript -e 'output volume of (get volume settings)')
	OldAVolume=$(osascript -e 'output alert volume of (get volume settings)')

	osascript -e 'set volume output muted false'
	osascript -e 'set volume output volume 100'
	osascript -e 'set volume alert volume 100'

	osascript -e 'beep 3' # get attention
	say -v Alex 'Run Updates Client has been removed'

	# CleanUp
	osascript -e "set volume output muted ${MuteState}"
	osascript -e "set volume output volume $OldVolume"
	osascript -e "set volume alert volume $OldAVolume"
fi


exit 0;