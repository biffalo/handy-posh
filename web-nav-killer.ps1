#this script removes persistence objects and binaries for the "Web Companion/WebNavigator" adware#
#removes scheduled task#
Unregister-ScheduledTask -TaskName "WC ScheduledTask" -Confirm:$false
Unregister-ScheduledTask -TaskName "BB Updater Scheduler" -Confirm:$false
#remove folder for each user on system#
#Get all users profiles
$users = Get-ChildItem "C:\Users" -Directory 
#Iterate through each user and yeet
foreach ($user in $users) {
    #construct the path for the folders to delete
    $folder1 = "$($user.FullName)\AppData\Roaming\BBWC"
    $folder2 = "$($user.FullName)\AppData\Roaming\Browser Extension"
    $folder3 = "$($user.FullName)\AppData\Local\WebNavigatorBrowser"
    $folder4 = "$($user.FullName)\AppData\Local\BlazeMedia"
    # check if the folder exist and then remove them
    if (Test-Path $folder1) {
        Remove-Item $folder1 -Recurse -Force
    }
    if (Test-Path $folder2) {
        Remove-Item $folder2 -Recurse -Force
    }
    if (Test-Path $folder3) {
        Remove-Item $folder3 -Recurse -Force
    }
    if (Test-Path $folder4) {
        Remove-Item $folder4 -Recurse -Force
    }
}