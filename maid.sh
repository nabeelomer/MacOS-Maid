#!/bin/bash
SECONDS=0

#Check if running as root and if not elevate
amiroot=$(sudo -n uptime 2>&1| grep -c "load")
if [ "$amiroot" -eq 0 ]
then
    printf "Maid Requires Root Access. Enter Your Password:\n"
    sudo -v
    printf "\n"
fi

#Delete Saved SSIDs For Security
#Be Sure To Set Home And Work SSID for ease of use.
printf "Deleting saved wireless networks.\n"
homessid="Get Off My LAN"
workssid="----"
IFS=$'\n'
for ssid in $(networksetup -listpreferredwirelessnetworks en0 | grep -v "Preferred networks on en0:" | grep -v $homessid | grep -v $workssid | sed "s/[\	]//g")
do
    networksetup -removepreferredwirelessnetwork en0 "$ssid" >> maid.log
done

#Install Updates.
# printf "Installing needed updates.\n"
# softwareupdate -i -a > /dev/null 2>&1

#Taking out the trash.
printf "Emptying the trash.\n"
sudo rm -rfv /Volumes/*/.Trashes >> maid.log
sudo rm -rfv ~/.Trash  >> maid.log

#Clean the logs.
printf "Emptying the system log files.\n"
sudo rm -rfv /private/var/log/*  >> maid.log
sudo rm -rfv /Library/Logs/DiagnosticReports/* >> maid.log

printf "Deleting the quicklook files.\n"
sudo rm -rf /private/var/folders/ >> maid.log

#Cleaning Up Homebrew.
printf "Cleaning up Homebrew.\n"
brew cleanup --force -s >> maid.log
brew cask cleanup >> maid.log
rm -rfv /Library/Caches/Homebrew/* >> maid.log
brew tap --repair >> maid.log

#Cleaning Up Ruby.
printf "Cleanup up Ruby.\n"
gem cleanup >> maid.log

#Cleaning Up Docker.
#You May Not Want To Do This.
# printf "Removing all Docker containers.\n"
# docker rmi -f "$(docker images -q --filter 'dangling=true')" > /dev/null 2>&1

#Purging Memory.
printf "Purging memory.\n"
sudo purge >> maid.log

#Removing Known SSH Hosts
# printf "Removing known ssh hosts.\n"
# sudo rm -f /Users/"$(whoami)"/.ssh/known_hosts > /dev/null 2>&1

#Securly Erasing Data.
# printf "Securely erasing free space (This will take a while). \n"
# diskutil secureErase freespace 0 "$( df -h / | tail -n 1 | awk '{print $1}')" > /dev/null 2>&1

#Brew Upgrades
printf "Running Brew upgrades"
brew upgrade >> maid.log

#Finishing Up.
timed="$((SECONDS / 3600)) Hours $(((SECONDS / 60) % 60)) Minutes $((SECONDS % 60)) seconds"

printf "Maid Service Took %s this time. See 'maid.log' for details.\n" "$timed"
