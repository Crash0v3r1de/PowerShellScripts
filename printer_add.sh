#!/bin/bash


## Driver install and printer adding script
## Made to download the driver from local server
## Install the driver
## Then add the printer and wipe tmp files
## Created 11/22/2019
## Created by Nate Faulds - nb.faulds@gmail.com
## Use case for local print server for a department that needs items added not via JAMF
## Added the echo color stuff so the script isn't blank, no validation for now but can add later

## Variables we can use
PRINTER_NAME="NAME_NO_SPACES"
PRINTR_LOC_INFO="loc_no_spaces"
PRINTER_IPP_ADDRESS="ipp://<change-ip>"
cGreen='\033[01;32m'
cNone='\033[00m'
cRed='\033[0;31m'


make_working_space()
{
echo -e "${cGreen}"
echo -e "Making our temporary workspace..."
echo -e "${cNone}"
mkdir ~/tmp # Make working temp space
cd ~/tmp # lets move to run commands in here just in case
}

download_file()
{
echo -e "${cGreen}"
echo -e "Downloading the driver package image..."
echo -e "${cNone}"
curl http://<server-address>/<file-location> -o ~/tmp/Brother_PrinterDrivers_ColorLaser_1_3_0.dmg # Download the driver
}

mount_and_install()
{
echo -e "${cGreen}"
echo -e "Mounting and installing the printer driver..."
echo -e "${cNone}"
hdiutil attach ~/tmp/Brother_PrinterDrivers_ColorLaser_1_3_0.dmg # Mount dmg image
cd /Volumes/Brother_PrinterDrivers_ColorLaser # Change directory to mounted image for .pkg install
installer -package Brother_PrinterDrivers_ColorLaser.pkg -target "/Volumes/Macintosh HD" # Install package
cd ~/
}

cleanup()
{
echo -e "${cGreen}"
echo -e "Unmounting driver image and removing our temporary workspace..."
echo -e "${cNone}"
hdiutil unmount "/Volumes/Brother_PrinterDrivers_ColorLaser" # unmount the image so we can remove the file
cd ~/ # back home
rm -R tmp # remove the tmp folder and it's contents
}

add_printer()
{
echo -e "${cGreen}"
echo -e "Adding network printer"
echo -e "${cNone}"
lpadmin -p $PRINTER_NAME -L $PRINTR_LOC_INFO -E -v $PRINTER_IPP_ADDRESS -P "/Library/Printers/PPDs/Contents/Resources/Brother HL-3180CDW.gz"
}

is_root()
{
if [ "$EUID" != 0 ]; then
echo -e "${cRed}"
echo -e "SCRIPT NOT RUNNING AS ROOT!"
echo -e "Please run -> sudo ${0##*/}"
echo -e "If non admin user, Please run -> sudo -U <admin/root username> ${0##*/}"
echo -e "${cNone}"
exit
fi
}

is_root
make_working_space
download_file
mount_and_install
add_printer
cleanup
