#sets .one files to open in notepad for each user#
$users = Get-ChildItem Registry::HKU
foreach ($user in $users) {
        $key = "Registry::\$($user.Name)\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.one\OpenWithList"
            Set-ItemProperty -Path $key -Name "a" -Value "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App" -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $key -Name "b" -Value "Microsoft.WindowsNotepad_8wekyb3d8bbwe!App" -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $key -Name "MRUList" -Value "ba" -Force -ErrorAction SilentlyContinue
        }
foreach ($user in $users) {
        $key = "Registry::\$($user.Name)\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.one\UserChoice"
            Get-Item -Path $key | Remove-Item -Force -Verbose
            }
foreach ($user in $users) {
        $key = "Registry::\$($user.Name)\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.one\OpenWithProgids"
            Get-Item -Path $key | Remove-Item -Force -Verbose
            }
