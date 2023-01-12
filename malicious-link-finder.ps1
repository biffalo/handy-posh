#Malicious LNK Finder#
#Parses every LNK file in C:\users and spits out any where target is like rundll32/cmd/powershell#
# Set the root directory to search
$root = "C:\users"
$ErrorActionPreference= 'silentlycontinue'
# Get all the .LNK files in the root directory and its subdirectories, skipping legit powershell and cmd shortcuts#
$excluded = @("*Command Prompt.lnk", "*Windows PowerShell.lnk", "*Windows PowerShell (x86).lnk")
$lnkFiles = Get-ChildItem $root -Filter "*.lnk" -Recurse -Exclude $excluded

# Iterate through each .LNK file
foreach ($lnkFile in $lnkFiles)
{
    # Get the target of the .LNK file
    $target = (New-Object -ComObject WScript.Shell).CreateShortcut($lnkFile.FullName).TargetPath

    # Check if the target contains rundll
    if ($target -like "*rundll32*")
    {
        # Print the full path of the .LNK file and its target
        Write-Host "LNK PATH: $($lnkFile.FullName) -> LNK TARGET: $target"
    }
}

foreach ($lnkFile in $lnkFiles)
{
    # Get the target of the .LNK file#
    $target = (New-Object -ComObject WScript.Shell).CreateShortcut($lnkFile.FullName).TargetPath

    # Check if the target contains cmd.exe#
    if ($target -like "*cmd*")
    {
        # Print the full path of the .LNK file and its target#
        Write-Host "LNK PATH: $($lnkFile.FullName) -> LNK TARGET: $target"
    }
}
foreach ($lnkFile in $lnkFiles)
{
    # Get the target of the .LNK file#
    $target = (New-Object -ComObject WScript.Shell).CreateShortcut($lnkFile.FullName).TargetPath

    # Check if the target contains powershell.exe#
    if ($target -like "*powershell*")
    {
        # Print the full path of the .LNK file and its target#
        Write-Host "LNK PATH: $($lnkFile.FullName) -> LNK TARGET: $target"
    }
}
