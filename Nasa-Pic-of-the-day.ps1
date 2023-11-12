# Set the directory to the User folder
Set-Location "$env:USERPROFILE"

# Create image Directory if not exist

if (!(Test-Path "NASA - Picture of the Day" -PathType Container)){
    New-Item -ItemType Directory -Name  "NASA - Picture of the Day"
    Write-Host "La carpeta ha sido creada"
} else {
    Write-Host "La carpeta ya existe"
}

# Image name variable
$imgDir = "$("NASA - Picture of the Day")\$(Get-Date -Format "dd-MM-yyyy").jpg"

# Looking if image is already downloaded
if ( Test-Path -Path $imgDir -PathType Leaf ){
    Write-Host "El archivo ya esta descargado"
    Exit
}

# Define the NASA API URL
$url = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"

# Get the Astronomy Picture of the Day
$response = Invoke-RestMethod -Uri $url -Method Get

# Get the URL of the image
$imageUrl = $response.hdurl

# Downloading image
Invoke-WebRequest -Uri $imageUrl -OutFile $imgDir
Write-Host "Imagen descargada"

# Set the image as the desktop wallpaper
Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public class Wallpaper {
    public const uint SPI_SETDESKWALLPAPER = 0x0014;
    public const uint SPIF_UPDATEINIFILE = 0x01;
    public const uint SPIF_SENDWININICHANGE = 0x02;
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    private static extern int SystemParametersInfo (uint uAction, uint uParam, string lpvParam, uint fuWinIni);
    public static void SetWallpaper (string path) {
        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, path, SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE);
    }
}
'@

$wallpaper = $imgDir  # absolute path to the image file
[Wallpaper]::SetWallpaper($wallpaper)

# Create a scheduled task to run the script every day, at every startup or at logon
$taskTriggers = @( 
    New-ScheduledTaskTrigger -Daily -At 00:01
    New-ScheduledTaskTrigger -AtStartup
    New-ScheduledTaskTrigger -AtLogon
    )
$taskAction = New-ScheduledTaskAction -Execute $(Invoke-Expression -Command $PSCommandPath)


Register-ScheduledTask -TaskName 'NASA-pic' -Trigger $taskTriggers -Action $taskAction -User "NT AUTHORITY\SYSTEM"