# Put this at the end of your script to add a small amount of hapiness to your life!
$star = @"
        .
       ,O,
      ,OOO,
'oooooOOOOOooooo'
  `OOOOOOOOOOO`
    `OOOOOOO`
    OOOO'OOOO
   OOO'   'OOO
  O'         'O
"@
$heart = @"
							  ,d88b.d88b,
							  88888888888
							  `Y8888888Y'
							    `Y888Y'
							      `Y'
"@

$hurray = @"

=========================================================================

888    888 888     888 8888888b.  8888888b.         d8888 Y88b   d88P 888 
888    888 888     888 888   Y88b 888   Y88b       d88888  Y88b d88P  888 
888    888 888     888 888    888 888    888      d88P888   Y88o88P   888 
8888888888 888     888 888   d88P 888   d88P     d88P 888    Y888P    888 
888    888 888     888 8888888P"  8888888P"     d88P  888     888     888 
888    888 888     888 888 T88b   888 T88b     d88P   888     888     Y8P 
888    888 Y88b. .d88P 888  T88b  888  T88b   d8888888888     888      "  
888    888  "Y88888P"  888   T88b 888   T88b d88P     888     888     888 

=========================================================================

"@
# The Colors Man (tm)
$rainbowColors = @(
    "DarkBlue", 
    "DarkCyan", 
    "DarkRed", 
    "DarkMagenta", 
    "DarkYellow", 
    "Blue", 
    "Green", 
    "Cyan", 
    "Red", 
    "Magenta", 
    "Yellow"
)

# Give em' a show
Write-Host $star -ForegroundColor Yellow

$hurray.Split("`n") | ForEach-Object -Begin {
    $index = 0
} -Process {
    Write-Host $_ -ForegroundColor $rainbowColors[$index % $rainbowColors.Length]
    $index++
}

Write-Host $heart -ForegroundColor DarkRed