#!/bin/bash

# Panda Helper V1
# Copyright (c) James Gillman [jronaldgillman@gmail.com], gitlab: @safetypanda
# Released under the GNU General Public License version 3+
# Refer to LICENSE file for license information.

#############################################
##        C O N F I G U R A T I O N        ##
#############################################

editor="vi"
#editor="nano"
#editor="emacs"

updateCommand="apt upgrade"
#updateCommand="dnf upgrade"
#updateCommand="yum upgrade"
#updateCommand="pacman -Syu"

#logViewer="less"
logViewer="vi"
#logViewer="cat"
#logViewer="more"

##                 ##
# DISCORD BOTS INFO #
##                 ##

#Moogle-Bot
botName1='MoogleBot'
botFileName1='moogle_bot.rb'
botLocation1='/home/MoogleBot/mooglebot/'
botLogFile1='/home/MoogleBot/mooglebot/logs.txt'

#ExampleBot
# botName2='ExampleBot'
# botFileName2='examplebot.bot'
# botLocation2='/home/example/'
# botLogFile2='/home/MoogleBot/mooglebot/logs.txt'

##           ##
# SERVER INFO #
##           ##

#Offsite Server
server1Name="CHANGE THIS"
server1Login="CHANGE THIS"

#ExampleServer
#server2Name=Example-Server
#server2Login=USERNAME@EXAMPLESERVER

#############################################
##          M E N U   C O N F I G          ##
#############################################

##                               ##
# SERVER CHOICE, ADD SERVERS HERE #
##                               ##
function server_choice
{
    dialog --backtitle "Panda Helper" --title 'INFO!' --infobox "Note: If you aren't using SSH Keys you will have to enter your login password every server/bot command unless you are using locally!" 5 50; sleep 3
    
    serverChoice=$(dialog --output-fd 1 --backtitle "Panda Helper" \
    --title "[Server Choice]" \
    --nocancel \
    --menu "For administering computer you are on use 'This Computer'. Otherwise, select your server:" 15 40 3 \
    1 "This Computer" \
    2 "Remote-Bertha" \
    3 "Quit Program")
    #2 "Example-Bot" \ #Make sure you put it before Quit Program, with a different number, and add 1 to the number after 15 40

    case $serverChoice in     
        1)
            serverChoice='NULL'
            serverName=$HOSTNAME
            ;;
        2) 
            serverChoice=$server1Login
            serverName=$server1Name
            ;; 
        #2) #Change Case number obviously
        #   serverChoice=$server1Login
        #   serverName=$server1Name
        #   ;;
        #    
        3)
            exit_helper
            ;;
        esac
}

##                         ##
# BOT CHOICE, ADD BOTS HERE #
##                         ##
function bot_choice
{
    botChoice=$(dialog --output-fd 1 \
    --backtitle "Panda Helper | Will Connect To: $serverName" \
    --title "[Bot Choice]" \
    --nocancel \
    --menu "Select Discord Bot:" 15 40 2 \
    1 "$botName1" \
    2 "Return to Main Menu")
    #2 "Example-Bot" \ #Make sure you put it before Quit Program, with a different number, and add 1 to the number after 15 40

    case $botChoice in #Look At Example Spot to add a bot case 
        1) 
            dBotName=$botName1
            dBotFileName=$botFileName1
            dBotLocation=$botLocation1
            dBotLogFile=$botLogFile1

            bot_menu 
            ;;  
        #2) #Change Case number obviously
        #   serverChoice=$server1Login
        #   serverName=$server1Name
        #   ;;
        #     
        2)
            return
            ;;
    esac
}

##                   ##
# Main Menu Selection #
##                   ##
function main_menu()
{
while true
do

menuChoice=$(dialog --output-fd 1 \
--clear --backtitle "Panda Helper | Will Connect To: $serverName" \
--title "[MAIN-MENU]" \
--nocancel \
--menu "What do you want to do?" 15 40 6 \
1 "Bot Menu" \
2 "Update Server" \
3 "Reboot Server" \
4 "Server Terminal" \
5 "Exit Helper" \
6 "About and License")


case $menuChoice in
    1)
        bot_choice
        ;;
    2)   
        update_server        
        ;;
    3)
        reboot_server
        ;;
    4)
        ssh_server
        ;;
    5) 
        exit_helper
        ;;
    6) 
        about
        ;;
esac
done
}


##        ##
# BOT MENU #
##        ##
function bot_menu
{
    menuChoice=$(dialog --output-fd 1 \
    --clear --backtitle "Panda Helper | Will Connect To: $serverName | Bot Selection: $dBotName" \
    --title "[BOT-MENU]" \
    --nocancel \
    --menu "What do you want to do?" 15 40 7 \
    1 "View Logs [If Bot Makes Them]" \
    2 "Edit Bot Code" \
    3 "Update Bot" \
    4 "Start Bot" \
    5 "Kill Bot" \
    6 "Reboot Bot" \
    7 "Return to Main Menu")

    case $menuChoice in
        1) 
            read_logs
            ;;
        2)
            edit_bot
            ;;
        3)
            update_bot
            ;;
        4)
            start_bot
            ;;
        5)
            kill_bot
            ;;
        6)
            reboot_bot
            ;;   
        7)
            return
            ;;
    esac
}

#############################################
##            M A I N   C O D E            ##
#############################################

##        ##
# COMMANDS #
##        ## 

function read_logs()
{
    command="$logviewer $dBotLogFile"

    if [ $serverChoice != 'NULL' ]
    then
        ssh -t $serverChoice $command
    else
        $command
    fi
}

function edit_bot
{
    fullBotLocation=$dBotLocation
    fullBotLocation+=$dBotFileName
    
    command="$editor $fullBotLocation"

    if [ $serverChoice != 'NULL' ]
    then
        ssh -t $serverChoice $command
    else
        sudo $command
    fi
}


function reboot_server
{
    dialog --backtitle "Panda Helper | Will Connect To: $serverName" --infobox "Rebooting..." 10 30; sleep 2
    if [ $serverChoice != 'NULL' ]
    then
        ssh -t $serverChoice reboot
    else
        sudo reboot
    fi
}

function exit_helper
{
    dialog --backtitle "Panda Helper" --infobox "Closing Helper" 10 30; sleep 2 
    exit 0
}

function reboot_bot
{  
    dialog --backtitle "Panda Helper | Will Connect To: $serverName | Bot Selection: $dBotName" --infobox "Rebooting Bot" 10 30; sleep 2
    
    fullBotLocation=$dBotLocation
    fullBotLocation+=$dBotFileName

    determine_file_type

    killCommand="killall $fileType $fullBotLocation"
    startCommand="nohup $fileType $fullBotLocation &"

    if [ $serverChoice != 'NULL' ]
    then
        ssh $serverChoice "$killCommand; $startCommand"
    else
       sudo "$killCommand; $startCommand"
    fi
}

function stop_bot
{
    dialog --backtitle "Panda Helper | Will Connect To: $serverName | Bot Selection: $dBotName" --infobox "Killing Bot" 10 30; sleep 2

    fullBotLocation=$dBotLocation
    fullBotLocation+=$dBotFileName
    
    determine_file_type

    killCommand="killall $fileType $fullBotLocation"
    
    if [ $serverChoice != 'NULL' ]
    then
        ssh -t $serverChoice "$killCommand"
    else
       sudo $killCommand
    fi
}

function start_bot
{
    dialog --backtitle "Panda Helper | Will Connect To: $serverName | Bot Selection: $dBotName" --infobox "Starting Bot" 10 30; sleep 2

    determine_file_type

    fullBotLocation=$dBotLocation
    fullBotLocation+=$dBotFileName

    startCommand="nohup $fileType $fullBotLocation &"

    echo "$fileType"


    echo "$startCommand"

    if [ $serverChoice != 'NULL' ]
    then
        ssh -n $serverChoice "$startCommand; exit"
    else
       sudo $startCommand
    fi
}

function update_server
{
     dialog --backtitle "Panda Helper | Will Connect To: $serverName" --infobox "Updating Server, Please be patient!" 10 30; sleep 2

    if [ $serverChoice != 'NULL' ]
    then
        ssh -t $updateCommand
    else
       sudo $updateCommand
    fi
}

function update_bot
{
    dialog --backtitle "Panda Helper | Will Connect To: $serverName | Bot Selection: $dBotName"
    dialog --title 'Updating Bot' --msgbox "You may have to give your username and password, depending on repository choice" 10 70
    
    command="git pull"

    if [ $serverChoice != 'NULL' ]
    then
        ssh -t $serverChoice "cd $dBotLocation; $command"
    else
        cd $dBotLocation
        $command
    fi
}

function ssh_server
{
    if [ $serverChoice != 'NULL' ]
    then
        ssh $serverChoice
    else
        dialog --title 'SSH ISSUE' --msgbox "You're already on your computer... No need to SSH" 10 70
    fi
}

function determine_file_type
{
    if [[ $dBotFileName == *".rb"* ]];
    then   
        fileType='ruby'
    fi

    if [[ $dBotFileName == *".py"* ]];
    then   
        fileType='python3'
    fi

    if [[ $dBotFileName == *".js"* ]];
    then   
        fileType='node'
    fi
}

function about()
{
    dialog --title 'About License' --scrollbar --msgbox "Panda Helper (C) 2019 James Gillman \n\n\
This program comes with ABSOLUTELY NO WARRANTY; \n\
This is free software, and you are welcome to redistribute it \n\
under certain conditions. Refer to included GNU License!" \
10 70
}

##                         ##
# IT'S TIME TO R-R-R-R-RUN! #
##                         ##
server_choice 
main_menu

clear