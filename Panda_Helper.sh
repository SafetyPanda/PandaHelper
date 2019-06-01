#!/bin/bash

# Panda's Lazy Discord Bot Helper
# Copyright (c) James Gillman [jronaldgillman@gmail.com], gitlab: @safetypanda
# Released under the GNU General Public License version 3+
# Refer to LICENSE file for license information.



INPUT=/tmp/menu.sh.$$ #Store menu option selected by user
trap "rm $INPUT; exit" SIGHUP SIGINT SIGTERM

function read_logs()
{
    dialog --title "text" --fselect /path/to/dir height width
FILE=$(dialog --stdout --title "Please choose a file" --fselect $HOME/ 14 48)

    dialog --title "LOG DATA" \
       --tailboxbg $FILE 20 70 \
}

function reboot_server(server)
{
    dialog --backtitle "Panda's Lazy Discord Bot Helper" --infobox "Rebooting..." 10 30; sleep 2
    [-f $INPUT ] && rm $INPUT
    reboot
}

function exit_helper(server)
{
    dialog --backtitle "Panda's Lazy Discord Bot Helper" --infobox "Closing Helper" 10 30; sleep 2 
    break
}

function exit_before_helper
{
    dialog --backtitle "Panda's Lazy Discord Bot Helper" --infobox "Closing Helper" 10 30; sleep 2 
    exit 0
}

function reboot_bot(server)
{
    dialog --backtitle "Panda's Lazy Discord Bot Helper" --infobox "Closing Helper" 10 30; sleep 2
    echo reboot
}

function update_server(server)
{
    dialog --backtitle "Panda's Lazy Discord Bot Helper" --infobox "Updating Server, Please be patient!" 10 30; sleep 2
    apt upgrade -y
}

function update_bot()
{
    echo help
}

function about()
{
    dialog --title 'About and License' --msgbox "Panda's Lazy Discord Bot Helper (C) 2019 James Gillman \n\n\
This program comes with ABSOLUTELY NO WARRANTY; \n\
This is free software, and you are welcome to redistribute it \n\
under certain conditions. Refer to included GNU License!" \
    10 70
}

##             ##
# SERVER CHOICE #
##             ##
function server_choice
{
    server = $(dialog --backtitle "Panda's Lazy Discord Bot Helper" \
    --title "[Server Choice]" \
    --ok-label "CONNECT" --cancel-label "EXIT"
    --menu "Select server:" 0 0 0 "${serverList[@]}")

    case $serverChoice:$? in
        *:0) 
            clear
            ssh $serverChoice
            ;; 
        "":*) exit_before_helper;;

}

##              ##
# Menu Selection #
##              ##
function main_menu(server)
{
while true
do

dialog --clear --backtitle "Panda's Lazy Discord Bot Helper" \
--title "[LAZY MENU]" \
--menu "What do you want to do?" 15 40 7 1 "View Logs" \
2 "Reboot Bot" 3 "Reboot Server" 4 "Update Server" \
5 "Update Bot" 6 "Exit Helper" 7 "About and License" 2>"${INPUT}"

menuChoice=$(<"${INPUT}")

case $menuChoice in
    1) 
        read_logs(server)
        ;;
    2) killall ruby ;;
    3) 
        reboot_server(server)
        ;;
    4)
        update_server(server)
        ;;
    6) 
        exit_helper(server)
        ;;
    7) 
        about(server)
        ;;
esac

done

[ -f $INPUT ] && rm $INPUT

}

##
# RUNNING
##

serverChoice 
mainMenu

clear