$directories = @("C:\ProgramData\*", "C:\Users\Public\*")

# Initialize a flag to track if any files were found
$fileFound = $false

# Iterate through the directories
foreach ($directory in $directories) {
    # Check if the directory exists
    if (Test-Path -Path $directory) {
        # Get all files in the directory with .exe or .dll extensions
        $files = Get-ChildItem -Path $directory -include "*.exe", "*.dll"
        
        # Iterate through the files
        foreach ($file in $files) {
            # Calculate the file hash
            $fileHash = Get-FileHash -Path $file.FullName -Algorithm SHA256 | Select-Object -ExpandProperty Hash
            
            # Output the full path and file hash
            Write-Output "File Path: $($file.FullName)"
            Write-Output "File Hash: $fileHash"
            
            # Set the flag indicating that files were found
            $fileFound = $true
        }
    }
}

# If no files were found, output "SAFE"
if (-not $fileFound) {
    Write-Output "SAFE"
}
