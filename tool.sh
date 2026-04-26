#!/bin/bash

#user_menu is a function that is used to generate both Add User and Modify User menus by passing the commands useradd or usermod respectively
user_menu() {
    local data_array=() 
    while [ True ]
    do
        dialog --clear
        command=$1
        local command_args=""
        if [[ $1 == "useradd" ]] then
            a=$(dialog --title "Add User" --output-separator ":" --stdout --insecure --mixedform "User Creation menu" 25 78 16 \
            "Username:" 0 0 "${data_array[0]}" 0 11 20 50 0 \
            "Password:" 3 0 "${data_array[1]}" 3 11 20 50 1 \
            "Home Directory:" 5 0 "${data_array[2]}" 5 17 20 100 0 \
            "Shell:" 7 0 "${data_array[3]}" 7 8 20 100 0 \
            "UID:" 9 0 "${data_array[4]}" 9 6 20 100 0 \
            "GID:" 11 0 "${data_array[5]}" 11 6 20 100 0 \
            )
        elif  [[ $1 == "usermod" ]] then
            a=$(dialog --title "Modify User" --output-separator ":" --stdout --insecure --mixedform "User Modification menu" 25 78 16 \
            "Old Username:" 0 0 "${data_array[0]}" 0 15 20 50 0 \
            "Password:" 3 0 "${data_array[1]}" 3 11 20 50 1 \
            "Home Directory:" 5 0 "${data_array[2]}" 5 17 20 100 0 \
            "Shell:" 7 0 "${data_array[3]}" 7 8 20 100 0 \
            "UID:" 9 0 "${data_array[4]}" 9 6 20 100 0 \
            "GID:" 11 0 "${data_array[5]}" 11 6 20 100 0 \
            "New Username:" 13 0 "${data_array[6]}" 13 15 20 100 0 \
            )   
        fi    

        stderr_var=$?
        mapfile -d ":" -t data_array < <(echo $a)

        # if Cancel is selected
        if [[ $stderr_var == 1 ]] then
            break
        #if Ok is selected    
        else
            # Check if username is empty
            if [ -z "${data_array[0]}" ]; then
                dialog --stdout --msgbox "You must enter a username" 15 60
                continue
            fi

            # Check if password is not empty
            if [ ! -z "${data_array[1]}" ]; then
                encrypted_pass=$(openssl passwd -6 ${data_array[1]})
                command_args+="-p $encrypted_pass "
            fi
            
            #Check if Home dir is not empty
            if [ ! -z "${data_array[2]}" ]; then
                command_args+="-d ${data_array[2]} "
            fi
            
            #Check if shell is not empty
            if [ ! -z "${data_array[3]}" ]; then
                command_args+="-s ${data_array[3]} "
            fi

            #Check if UID is not empty
            if [ ! -z "${data_array[4]}" ]; then
                command_args+="--uid ${data_array[4]} "
            fi

            #Check if GID is not empty
            if [ ! -z "${data_array[5]}" ]; then
                command_args+="--gid ${data_array[5]} "
            fi

            #Check if New Username exists (works only for Modify User)
            if [[ ! -z "${data_array[6]}" && $command == usermod ]]; then
                command_args+="-l ${data_array[6]} "
            fi

            #Execute the command with args specified and print any error to stdout
            result=$($command $command_args ${data_array[0]} 2>&1)
            echo "$command $command_args ${data_array[0]} 2>&1"
            #if no error occurred
            if [ -z "$result" ]; then
                if [[ $1 == "useradd" ]] then
                    dialog --title SUCCESS --stdout --msgbox "User ${data_array[0]} is created successfully" 5 70
                elif [[ $1 == "usermod" ]] then
                    dialog --title SUCCESS --stdout --msgbox "User ${data_array[0]} is modified successfully" 5 70
                fi    
                break
            
            else
                dialog --title ERROR --stdout --msgbox "$result" 5 70
                continue
            fi
        fi
    done
}

## group_menu is similar to user_men but for Add group and modify group
group_menu() {
    local data_array=() 
    while [ True ]
    do
        dialog --clear
        command=$1
        local command_args=""
        if [[ $1 == "groupadd" ]] then
            a=$(dialog --title "Add Group" --output-separator ":" --stdout --mixedform "Group Creation menu" 25 78 16 \
            "Group Name:" 0 0 "${data_array[0]}" 0 15 20 50 0 \
            "GID:" 3 0 "${data_array[1]}" 3 6 20 100 0 \
            "Users (comma-separated):" 5 0 "${data_array[2]}" 5 26 20 200 0\
            )
        elif  [[ $1 == "groupmod" ]] then
            a=$(dialog --title "Modify Group" --output-separator ":" --stdout --mixedform "Group Modification menu" 25 78 16 \
            "Old Group Name:" 0 0 "${data_array[0]}" 0 20 20 50 0 \
            "GID:" 3 0 "${data_array[1]}" 3 6 20 100 0 \
            "Users (comma-separated):" 5 0 "${data_array[2]}" 5 26 20 200 0\
            "New Group Name:" 7 0 "${data_array[3]}" 7 20 20 50 0 \
            )   
        fi    

        stderr_var=$?
        mapfile -d ":" -t data_array < <(echo $a)
        # if Cancel is selected
        if [[ $stderr_var == 1 ]] then
            break
        #if Ok is selected    
        else
            # Check if groupname is empty
            if [ -z "${data_array[0]}" ]; then
                dialog --stdout --msgbox "You must enter a groupname" 15 60
                continue
            fi

            # Check if GID is not empty
            if [ ! -z "${data_array[1]}" ]; then
                command_args+="--gid ${data_array[1]} "
            fi

            # Check if users is not empty
            if [ ! -z "${data_array[2]}" ]; then
                dialog --title "Modify Group" --stdout --yesno "Do you want to append these users to the group?" 5 70
                stderr_var=$?
                if [[ $stderr_var == 0 ]] then command_args+="-a " ; fi
                command_args+="--users ${data_array[2]} "
            fi

            # Check if new groupname is not empty (groupmod only)
            if [[ ! -z "${data_array[3]}" && $command == "groupmod" ]]; then
                command_args+="--new-name ${data_array[3]} "
            fi
            
            result=$($1 $command_args ${data_array[0]} 2>&1)
            
            if [ -z "$result" ]; then
                if [[ $1 == "groupadd" ]] then
                    dialog --title SUCCESS --stdout --msgbox "Group ${data_array[0]} is created successfully" 5 70
                elif [[ $1 == "groupmod" ]] then
                    dialog --title SUCCESS --stdout --msgbox "Group ${data_array[0]} is modified successfully" 5 70
                fi    
                break

            else
                dialog --title ERROR --stdout --msgbox "$result" 5 70
                continue
            fi
        fi
    done
}









while [ True ] 
do
    #Main Menu
    choice=$(dialog --stdout --erase-on-exit --title "Users Creation TUI Tool" --clear --menu "Main Menu" 25 78 16 \
    "Add User" "Add a user to the system." \
    "Modify User" "Modify an existing user." \
    "Delete User" "Delete an existing user" \
    "List Users" "List all users on the system." \
    "Add Group" "Add a user group to the system." \
    "Modify Group" "Modify a group and its list of members." \
    "Delete Group" "Delete an existing group" \
    "List Groups" "List all groups on the system." \
    "Disable User" "Lock the user account" \
    "Enable User" "Unlock the user account" \
    "Change Password" "Change password of a user") 

    case $choice in

        "Add User")
            user_menu useradd
            ;;

        "Modify User")
            user_menu usermod
            ;;

        "Delete User")
            a=$(dialog --stdout --title "Delete User" --inputbox "Enter the username that you want to remove" 8 80)
            if [[ $? == 0 ]] then
                id $a 1>/dev/null # Check if user exists
                if [[ $? != 0 || -z $a ]] then ## if user is does not exist or empty field
                    dialog --stdout --title ERROR --msgbox "User $a does not exist" 15 60
                else
                    result=$(userdel $a 2>&1)
                    if [[ $? == 0 ]] then
                        dialog --title SUCCESS --stdout --msgbox "User $a has been deleted" 5 70
                    else
                        dialog --title ERROR --stdout --msgbox "$result" 5 70
                    fi
                fi
            fi
            ;;

        "List Users")
            tmp_file=$(mktemp)
            cut -d ":" -f 1 /etc/passwd > $tmp_file
            dialog --title "All users on your system" --textbox $tmp_file 25 78
            rm $tmp_file
            ;;

        "Add Group")
            group_menu groupadd
            ;;

        "Modify Group")
            group_menu groupmod
            ;;    

        "Delete Group")
            a=$(dialog --stdout --title "Delete Group" --inputbox "Enter the groupname that you want to remove" 8 80)
            if [[ $? == 0 ]] then
                grep $a /etc/group 1> /dev/null
                if [[ $? != 0 || -z $a ]] then
                    dialog --stdout --title ERROR --msgbox "Group $a does not exist" 15 60
                else
                    result=$(groupdel $a 2>&1)
                    if [[ $? == 0 ]] then
                        dialog --title SUCCESS --stdout --msgbox "Group $a has been deleted" 5 70
                    else
                        dialog --title ERROR --stdout --msgbox "$result" 5 70
                    fi
                fi
            fi
            ;;

        "List Groups")
            tmp_file=$(mktemp)
            cut -d ":" -f 1 /etc/group > $tmp_file
            dialog --title "All groups on your system" --textbox $tmp_file 25 78
            rm $tmp_file
            ;;
        
        "Disable User")
            a=$(dialog --stdout --title "Disable User" --inputbox "Enter the username that you want to lock his/her account" 8 80)
            if [[ $? == 0 ]] then
                id $a 1>/dev/null 
                if [[ $? != 0 || -z $a ]] then
                    dialog --stdout --title ERROR --msgbox "User $a does not exist" 15 60
                else
                    result=$(usermod -L $a 2>&1)
                    if [[ $? == 0 ]] then
                        dialog --title SUCCESS --stdout --msgbox "User $a has been locked" 5 70
                    else
                        dialog --title ERROR --stdout --msgbox "$result" 5 70
                    fi
                fi
            fi
            ;;

        "Enable User")
            a=$(dialog --stdout --title "Enable User" --inputbox "Enter the username that you want to unlock his/her account" 8 80)
            if [[ $? == 0 ]] then
                id $a 1>/dev/null 
                if [[ $? != 0 || -z $a ]] then
                    dialog --stdout --title ERROR --msgbox "User $a does not exist" 5 60
                else
                    result=$(usermod -U $a 2>&1)
                    if [[ $? == 0 ]] then
                        dialog --title SUCCESS --stdout --msgbox "User $a has been unlocked" 5 70
                    else
                        dialog --title ERROR --stdout --msgbox "$result" 5 70
                    fi
                    
                fi
            fi
            ;;    

        "Change Password")
            a=$(dialog --stdout --title "Change Password" --inputbox "Enter the username that you want to change his/her password" 8 80)
            if [[ $? == 0 ]] then
                id $a 1>/dev/null 
                if [[ $? != 0 || -z $a ]] then
                    dialog --stdout --msgbox "User $a does not exist" 5 60
                else
                    b=$(dialog --stdout --insecure --title "Change Password" --passwordbox "Enter the new password:" 8 80)
                    if [[ $? != 0 ]] then continue; fi
                    c=$(dialog --stdout --insecure --title "Change Password" --passwordbox "Confirm the new password:" 8 80)
                    if [[ $? != 0 ]] then continue; fi
                    if [[ $b == $c ]] then
                        result=$(passwd $a 2>&1 < <(echo -e "$b\n$b"))
                        if [[ $? == 0 ]] then
                            dialog --title SUCCESS --stdout --msgbox "Password changed successfully" 5 70
                        else
                            dialog --title ERROR --stdout --msgbox "$result" 5 70
                        fi
                    else
                        dialog --title ERROR --stdout --msgbox "Passwords don't match please try again" 5 70
                    fi 
                fi
            fi
            ;;    

        *)     
            break  
            ;;

    esac
    
done
