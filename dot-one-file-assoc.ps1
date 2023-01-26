#sets .one files to open in notepad for each user#
$users = Get-ChildItem Registry::HKU
foreach ($user in $users) {
        $key = "Registry::\$($user.Name)\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.one\OpenWithList"
            Set-ItemProperty -Path $key -Name "a" -Value "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App" -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $key -Name "b" -Value "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App" -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $key -Name "MRUList" -Value "ba" -Force -ErrorAction SilentlyContinue
        }
#remove existing user pref#
foreach ($user in $users) {
        $key = "Registry::\$($user.Name)\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.one\UserChoice"
            Remove-ItemProperty -Path $key -Name "ProgID" -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $key -Name "Hash" -Force -ErrorAction SilentlyContinue
            }
foreach ($user in $users) {
        $key = "Registry::\$($user.Name)\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.one\OpenWithProgids"
            Remove-ItemProperty -Path $key -Name "OneNote.Section.1" -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path $key -Name "Hash" -Force -ErrorAction SilentlyContinue
            }
#set machine default#
$oneKey = "HKLM:\SOFTWARE\Classes\.one"
Set-ItemProperty -Path $onekey -Name "(Default)" -Value "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App" -Force -ErrorAction SilentlyContinue
