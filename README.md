# User and Group Management TUI tool 
## About this tool
This is TUI a tool that i created using `dialog` utility in bash so that you can manage users and groups on your linux machine without using the CLI.This tool is capable of doing the following:
1. **Add User**: you can add a user by specifying their old username, password, home directory, UID, GID of the primary group and the new username.
2. **Modify User**: you can modify an existing user by specifying their new username, password, home directory, UID and GID of the primary group.
3. **Delete User**: you can delete an existing user.
4. **List Users**: you can list all users on your system.
5. **Add Group**: you can add a group by specifying the groupname, GID and a list of users to add to the group (comma-seperated).
6. **Modify Group**: you can modify an existing group by specifying old groupname, GID, a list of users to overwrite or append to the existing user list of the group (comma-seperated) and the new groupname.
7. **Delete Group**: you can delete an existing group.
8. **List Groups**: you can list all groups on your system.
9. **Disable User**: you can lock an existing user account.
10. **Enable User**: you can unlock an existing user account.
11. **Change Password**: you can change the password of an existing user.

> [!NOTE]
> Most of these parameters are optional and when left blank the user or group will be created using default settings but you are required to enter the `username` (or `old username` in **Modify User** menu) and `groupname` (or `old groupname` in **Modify Group** menu).  


## Installation:
Usually `dialog` is available in most modern linux distros but if it is not installed, you can use your distro's package manager to install it:
### Ubuntu / Debian / Linux Mint:
```bash
sudo apt update
sudo apt install dialog
```
### CentOS / RHEL / Fedora:
```bash
sudo dnf install dialog
```
### Arch:
```bash
sudo pacman -S dialog
```
Once installed, clone this repo and give the tool execute permission and make sure to run the script with root privileges or `sudo`
```bash
git clone https://github.com/adhammamdouh272/User_and_Group_Management_TUI.git
cd User_and_Group_Management_TUI
chmod +x tool.sh
sudo ./tool.sh
```

## Usage:
- You can navigate the menus using your ***arrow keys*** and ***Enter*** to confirm your choice.
- In some menus (like **Add User**) you will need to press ***Tab*** to shift between entering values and selecting `OK` or `Cancel` button.
- In **List Users** or **List Groups** menus, the menus has a simlair interface to `less` command so you can for example press ***/*** to open a serach look for pattern.
- In **Add Group**  and **Modify Group** menus, make sure to enter the user list comma-seperated with no spaces  
> [!WARNING]
> When entering a user list in **Add Group**  and **Modify Group** menus, make sure to enter the user list comma-seperated with no spaces so something like `alice,bob,smith` is valid while something like `alice, bob , smith` is invalid and will result in an error.


