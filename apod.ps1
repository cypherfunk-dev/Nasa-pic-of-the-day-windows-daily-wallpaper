# Set the directory to the User folder
Set-Location "$env:USERPROFILE"

# Create image Directory if not exist
if (!(Test-Path "apod" -PathType Container)) {
    New-Item -ItemType Directory -Name  "apod"
}

# Image name variable
$imgDir = "$("apod")\$(Get-Date -Format "dd-MM-yyyy").jpg"

# Looking if image is already downloaded
if ( Test-Path -Path $imgDir -PathType Leaf ) {    
} else{
# Define the NASA API URL
$url = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"

# Get the Astronomy Picture of the Day
$response = Invoke-RestMethod -Uri $url -Method Get

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
[Wallpaper]::SetWallpaper("$env:USERPROFILE\$wallpaper")


# .ps1 route
$rutaScriptEnApod = Join-Path $env:USERPROFILE "apod\apod.ps1"

# creating ps1 file
$contenidoScript | Out-File -FilePath $rutaScriptEnApod -Encoding ASCII

# Bat script content
$contenidoBat = @"
start /MIN /B powershell -ExecutionPolicy Bypass -File "$rutaScriptEnApod"
"@

$rutaBat = Join-Path $env:USERPROFILE "apod\task.bat"

# Creating Bat
$contenidoBat | Out-File -FilePath $rutaBat -Encoding ASCII

# Verify if task exists
if (!(Get-ScheduledTask -TaskName 'NASA-pic')) {

# Creating PS1
$contenidoPs1 = @'
# Directorio donde se encuentra el script
$scriptDir = "$env:USERPROFILE\apod"

# Configuración de los desencadenadores de la tarea
$taskTrigger = @( 
    New-ScheduledTaskTrigger -AtLogOn
)

# Configuración de las condiciones de la tarea (ninguna opción de energía marcada)
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd

# Obtener el nombre del usuario actual
$user = $env:USERNAME

$batScriptPath = Join-Path $scriptDir "\task.bat"

# Configuración de la acción de la tarea
$taskAction = New-ScheduledTaskAction -Execute 'cmd.exe' -Argument "/c `"$batScriptPath`""

# Registro de la tarea programada
try{
Register-ScheduledTask -TaskName 'NASA-pic' -Trigger $taskTrigger -User $user -Action $taskAction -Settings $taskSettings -asJob -RunLevel Highest
} catch {
    Write-Host "Error al crear la tarea programada"
    Read-Host "Presiona Enter para salir"

}
'@
$rutaTask = Join-Path $env:USERPROFILE "apod\Task.ps1"

$contenidoPs1 | Out-File -FilePath $rutaTask -Encoding ASCII

# Abrir el script como administrador
try{
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $rutaTask" -Verb RunAs -Wait
} catch{
    Write-Host "Hubo un error al ejecutar"
}
}
