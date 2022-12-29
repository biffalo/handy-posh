# Set the root directory to search
$root = "C:\users"

# Get all the .LNK files in the root directory and its subdirectories
$lnkFiles = Get-ChildItem $root -Filter "*.lnk" -Recurse

# Iterate through each .LNK file
foreach ($lnkFile in $lnkFiles)
{
    # Get the target of the .LNK file
    $target = (New-Object -ComObject WScript.Shell).CreateShortcut($lnkFile.FullName).TargetPath

    # Check if the target contains rundll
    if ($target -like "*rundll32.exe*")
    {
        # Print the full path of the .LNK file and its target
        Write-Host "$($lnkFile.FullName) -> $target"
    }
}

foreach ($lnkFile in $lnkFiles)
{
    # Get the target of the .LNK file#
    $target = (New-Object -ComObject WScript.Shell).CreateShortcut($lnkFile.FullName).TargetPath

    # Check if the target contains cmd.exe#
    if ($target -like "*cmd.exe*")
    {
        # Print the full path of the .LNK file and its target#
        Write-Host "$($lnkFile.FullName) -> $target"
    }
}
foreach ($lnkFile in $lnkFiles)
{
    # Get the target of the .LNK file#
    $target = (New-Object -ComObject WScript.Shell).CreateShortcut($lnkFile.FullName).TargetPath

    # Check if the target contains powershell.exe#
    if ($target -like "*powershell.exe*")
    {
        # Print the full path of the .LNK file and its target#
        Write-Host "$($lnkFile.FullName) -> $target"
    }
}
