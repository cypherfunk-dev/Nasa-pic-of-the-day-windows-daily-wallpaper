# Setting directory to the user folder
Set-Location "$env:USERPROFILE"

# Create image directory if not exist
if (!(Test-Path "apod" -PathType Container)) {
    New-Item -ItemType Directory -Name  "apod"
}

# .ps1 path
$rutaApod = Join-Path $env:USERPROFILE "apod\apod.ps1"

$apodScript = @'

# Define the NASA API URL
$url = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"

# Querying the api
$response = Invoke-RestMethod -Uri $url -Method Get

# Image name variable
$imgDir = "$($env:USERPROFILE)\$("apod")\$($response.date).jpg"

# Looking if image is already downloaded
if (!(Test-Path -Path $imgDir -PathType Leaf )) {    

# Get the URL of the image
# response.url for Standard Quality
# response.hdurl for High Quality

$imageUrl = $response.hdurl

# Downloading image
Invoke-WebRequest -Uri $imageUrl -OutFile $imgDir
}

# Set the image as the desktop wallpaper
Add-Type -TypeDefinition @"
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
"@

$wallpaper = $imgDir  # absolute path to the image file
[Wallpaper]::SetWallpaper("$wallpaper")
#If there's new pic, print data about it
if($response){
clear
$pictitle = $response.title
$picdate = $response.date
$picdescription = $response.explanation
Write-Host "Astronomy Picture of the Day - NASA"  -ForegroundColor DarkBlue -Backgroundcolor Gray
Write-Host "Title:"$pictitle  -ForegroundColor Yellow
Write-Host "Date:"$picdate "`n" "`n" -ForegroundColor Green
Write-Host $picdescription"`n" "`n" -ForegroundColor Cyan
Write-Host "Developed by https://github.com/andrescarlos-gm"
Read-Host -Prompt "Press any key to continue" 
}
'@

# Creating Powershell script file
$apodScript | Out-File -FilePath $rutaApod -Encoding ASCII

# Image name variable
$imgDir = "$($env:USERPROFILE)\$("apod")\$(Get-Date -Format "dd-MM-yyyy").jpg"

# Looking if image is already downloaded
if (!(Test-Path -Path $imgDir -PathType Leaf) ) {
    powershell -ExecutionPolicy Bypass -File $rutaApod
}

# Bat Path
$rutaBat = Join-Path $env:USERPROFILE "apod\task.bat"

# Bat script content
$contenidoBat = @"
powershell.exe -ExecutionPolicy Bypass -File $rutaApod
"@

# Creating Bat
$contenidoBat | Out-File -FilePath $rutaBat -Encoding ASCII

# Verify if task exists
if (!(Get-ScheduledTask -TaskName 'NASA-pic')) {
    # Creating PS1
    $contenidoPs1 = @'
    $scriptDir = "$env:USERPROFILE\apod"
    
    $taskTrigger = @( 
        New-ScheduledTaskTrigger -AtLogOn
        New-ScheduledTaskTrigger -Daily -At 3am
    )
    $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd 

    $user = $env:USERNAME

    $batScriptPath = Join-Path $scriptDir "\task.bat"

    $taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "/c `"$batScriptPath`""

    # Programmed task register
    Register-ScheduledTask -TaskName 'NASA-pic' -Trigger $taskTrigger -User $user -Action $taskAction -Settings $taskSettings -asJob -RunLevel Highest
'@

    $rutaTask = Join-Path $env:USERPROFILE "apod\Task.ps1"

    $contenidoPs1 | Out-File -FilePath $rutaTask -Encoding ASCII
    
    while (!(Test-Path $rutaTask -PathType Leaf )) {
    Start-Sleep -Seconds 1
    }

    # Running task script as admin
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $rutaTask" -Verb RunAs -Wait

    # Removing script once task is created  
    if (Get-ScheduledTask -TaskName 'NASA-pic'){
        Remove-Item $rutaTask
    } 
} else {
    powershell -ExecutionPolicy Bypass -File $rutaApod
}