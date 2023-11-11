# Define the NASA API URL
$url = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"

# Get the Astronomy Picture of the Day
$response = Invoke-RestMethod -Uri $url -Method Get

# Get the URL of the image
$imageUrl = $response.hdurl

# Set the directory to the User folder
Set-Location "$env:USERPROFILE"

# Create Script Directory
$usrDir = New-Item -ItemType Directory -Name  "NASA - Picture of the Day"

# Create variable with the image name
$imgDir = "$($usrDir.FullName)\$(Get-Date -Format "dd-MM-yyyy").jpg"

# Download the image
Invoke-WebRequest -Uri $imageUrl -OutFile $imgDir

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

# Create a scheduled task to run the script every day
# To do