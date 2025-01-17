#!/bin/bash

# Version 2.0 First Run Admin
# Creator : Sylvain La Gravière
# Twitter : @darkomen78
# Mail : darkomen@me.com

# Supprime les LaunchAgents
rm -f ~/Library/LaunchAgents/com.infernobox.firstrun*
# Emplacement du dossiers IT
ITFOLDER="/Applications/Utilities/IT"

if [ "$USER" = "adminit" ]; then
	WALLPAPERFILE="$ITFOLDER/wallpaper.jpg"
elif [ "$USER" = "adminuser" ]; then
	WALLPAPERFILE="/Users/Shared/login.png"
else
	exit 0
fi
# Emplacement des fichiers partagés
LOGINWALL="/Users/Shared/login.png"
USERPICFILE="/Users/Shared/admin.tif"
# Configuration HomePage Safari
SAFARIHOMEPAGE='http://munki'

# Menu Rapide Utilisateur (YES ou NO )
SWITCHUSER='YES'

FULLOSVERSION=$(sw_vers -productVersion)

osascript -e 'display notification "Configuration de la session administrateur en cours..." with title "First Run Admin"'
sleep 5

# Liste des apps à mettre dans le Dock
DOCKAPPS=('Safari.app' 'Firefox.app' 'Google Chrome.app' 'Utilities/Console.app' 'Utilities/Terminal.app' 'Utilities/Activity Monitor.app' 'Utilities/Migration Assistant.app' 'Utilities/Keychain Access.app' 'Utilities/Disk Utility.app' 'System Preferences.app' 'Managed Software Center.app')

# Tweak System

# Active le menu permutation rapide d’utilisateur
defaults write NSGlobalDomain MultipleSessionEnabled -bool $SWITCHUSER

# Délais pour le sauveur d’écran en secondes
defaults -currentHost write com.apple.screensaver idleTime 600
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 5

# Désactive la réouverture des applications après l’exctinction
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# Supprimer l'icone TimeMachine de la barre de menu
defaults -currentHost write com.apple.systemuiserver dontAutoLoad -array-add "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"
defaults -currentHost write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" "/System/Library/CoreServices/Menu Extras/AirPort.menu" "/System/Library/CoreServices/Menu Extras/Battery.menu" "/System/Library/CoreServices/Menu Extras/Clock.menu" "/System/Library/CoreServices/Menu Extras/TextInput.menu"

# Afficher la durée et non le pourcentage de batterie
defaults write com.apple.menuextra.battery ShowPercent -string "NO"
defaults write com.apple.menuextra.battery ShowTime -string "YES"

# Toujours montrer les barres de défilements
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Agrandir les dialogues de sauvegarde
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Agrandir les dialogues d'impression
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Sauvegarder par défaut sur le disque local (et non iCloud)
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Désactiver le message d'alerte à la première ouverte d'une application
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Désactiver le Crash Reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Tweak Souris - Trackpad

# Désactiver le "défilement naturel"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Désactiver la "pression maintenue" pour les lettres accentuées
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Tweak Finder

# Les fenêtres du Finder affiche le dossier utilisateur par défaut
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Activer toutes les icones sur le bureau
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Afficher toutes les extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Afficher la barre d'état
defaults write com.apple.finder ShowStatusBar -bool true

# La recherche ce fait dans le dossier courant par défaut
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Désactiver l'avertissement lors du changement d'une extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Empêche la création de .DS_Store sur les volumes réseaux
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Affiche le dossier Bibliothèque de l'utilisateur
chflags nohidden ~/Library

# Affiche les onglets “General”, “Ouvrir avec”, et “Permissions” dans les fenêtres d'info
defaults write com.apple.finder FXInfoPanesExpanded -dict \
General -bool true \
OpenWith -bool true \
Privileges -bool true

# Aligne par défaut les icones sur une grille
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# Utiliser la vue en colonne
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

#####################################
### Tweak Dock et Mission control ###
#####################################
# Désactiver le Dashboard
# defaults write com.apple.dashboard mcx-disabled -bool true
# Les applications masquées sont transparentes
defaults write com.apple.dock showhidden -bool true
# Ne pas réarranger les espaces automatiquement
defaults write com.apple.dock mru-spaces -bool false
# Affiche l'indicateur d'application ouverte
defaults write com.apple.dock show-process-indicators -bool true
# Vide tout le dock
/usr/bin/defaults write com.apple.dock 'persistent-apps' -array " "
# Ajout des Applications dans le Dock
ROOTAPPS="/Applications/"
for ADDAPP in "${DOCKAPPS[@]}"
do
	if [ -d "$ROOTAPPS$ADDAPP" ]; then
		/usr/bin/defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$ROOTAPPS$ADDAPP</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
	fi
done
# Ajout des autres éléments dans le Dokc
# Dossiers, alias, documents
# Options : displayas = 0 pile, 1 dossier / showas = 0 auto, 1 éventail, 2 grille, 3 liste
/usr/bin/defaults write com.apple.dock 'persistent-others' -array-add '<dict><key>tile-data</key><dict><key>arrangement</key><integer>0</integer><key>displayas</key><integer>0</integer><key>file-data</key><dict><key>_CFURLString</key><string>/Users/Shared/Serveurs/</string><key>_CFURLStringType</key><integer>0</integer></dict><key>preferreditemsize</key><integer>-1</integer><key>showas</key><integer>0</integer></dict><key>tile-type</key><string>directory-tile</string></dict>'
/usr/bin/defaults write com.apple.dock 'persistent-others' -array-add '<dict><key>tile-data</key><dict><key>arrangement</key><integer>0</integer><key>displayas</key><integer>0</integer><key>file-data</key><dict><key>_CFURLString</key><string>'"$ITFOLDER"'</string><key>_CFURLStringType</key><integer>0</integer></dict><key>preferreditemsize</key><integer>-1</integer><key>showas</key><integer>0</integer></dict><key>tile-type</key><string>directory-tile</string></dict>'

# Désactiver le Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Les applications masquées sont transparentes
defaults write com.apple.dock showhidden -bool true

# Ne pas réarranger les espaces automatiquement
defaults write com.apple.dock mru-spaces -bool false

# Tweak Time Machine

# Désactiver la demande automatique de TimeMachine
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Tweak Safari

# Page de démarrage Google
defaults write com.apple.Safari HomePage -string "$SAFARIHOMEPAGE"

# Ne pas ouvrir les fichiers téléchargés automatiquement
defaults write com.apple.Safari AutoOpenSafeDownloads -bool true

# Activer le menu developpeur
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Tweak Mail

# Le raccourcis command + entrée permet d'envoyer le mail
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"

# Simplifie le copier coller d'adresse
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Tweak Moniteur d'activité

# Affiche tous les processus
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Tweak Gatekeeper

# Autoriser n'importe où
spctl --master-disable

# Désactiver la réactivation automatique (30 jours)
sudo defaults write /Library/Preferences/com.apple.security GKAutoRearm -bool NO

# Tweak première ouverture de session
defaults write ~/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE
defaults write ~/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "$FULLOSVERSION"
defaults write ~/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none

# Changement de l’image

dscl . delete /Users/$USER Picture
dscl . delete /Users/$USER JPEGPhoto
dscl . append $HOME Picture $USERPICFILE

# Changement du fond d'écran
python $ITFOLDER/set_desktops.py --path $WALLPAPERFILE

# Relance du Dock et du Finder pour prise en compte des nouveaux réglages
killall Dock
killall Finder
sleep 3

# Changement du fond de login El Capitan
LOGINFILE="/Library/Caches/com.apple.desktop.admin.png"
if [ -f $LOGINFILE ]; then
	rm -f $LOGINFILE
fi
cp $LOGINWALL $LOGINFILE

####################################
####################################
####################################
##### ADMIN SETTINGS SCRIPT END #####
####################################
osascript <<EOD
tell application "System Events"
log out
end tell
EOD

exit 0
