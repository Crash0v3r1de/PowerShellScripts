#######################################################################################
# Script Author - Nate Faulds <nb.faulds@gmail.com>  with help of PDQ's Kris Powell   #
# Purpose - I have customers who use PGP and their documents will always fail to      #
#    autosave to Office365/Sharepoint since the files are not a readable format.      #
#  This script automaticaly disables autosave for all users to O365 and SharePoint    #
#             This DOES NOT effect AutoRecovery and local AutoSave                    #
#        Side note: PDQ Deploy is a fantastic piece of software for admins            #
#######################################################################################

function ProcessAllUsers{
####################################################################
# This function code snippet was pulled from                       #
# https://www.pdq.com/blog/modifying-the-registry-users-powershell #
#  This is a fantastic snippet so no reason to write from scratch  #
####################################################################

$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
$ProfileList = gp 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object {$_.PSChildName -match $PatternSID} | 
    Select  @{name="SID";expression={$_.PSChildName}}, 
            @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}}, 
            @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}}
$LoadedHives = gci Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} | Select @{name="SID";expression={$_.PSChildName}}
$UnloadedHives = Compare-Object $ProfileList.SID $LoadedHives.SID | Select @{name="SID";expression={$_.InputObject}}, UserHive, Username
Foreach ($item in $ProfileList) {
    IF ($item.SID -in $UnloadedHives.SID) {
        reg load HKU\$($Item.SID) $($Item.UserHive) | Out-Null
    }
    $wordFound = CheckOfficePresent $Item.SID # If Word is missing nothing else will be there
    if($wordFound){
    Set-ItemProperty registry::HKEY_USERS\$($Item.SID)\Software\Microsoft\Office\16.0\word -Name AutoSaveByDefaultUserChoice -Value 2
    Set-ItemProperty registry::HKEY_USERS\$($Item.SID)\Software\Microsoft\Office\16.0\excel -Name AutoSaveByDefaultUserChoice -Value 2
    Set-ItemProperty registry::HKEY_USERS\$($Item.SID)\Software\Microsoft\Office\16.0\powerpoint -Name AutoSaveByDefaultUserChoice -Value 2
    }      
    IF ($item.SID -in $UnloadedHives.SID) {
        [gc]::Collect()
        reg unload HKU\$($Item.SID) | Out-Null
    }
}

}
function CheckOfficePresent([string]$regPath){
$found = Get-ItemProperty -Path registry::HKEY_USERS\$regPath\Software\Microsoft\Office\16.0\word -Name WordName
if($found){ return 1}
else{ return 0}  # location is null/missing
}

ProcessAllUsers