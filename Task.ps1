# Verifica si la tarea ya existe
if (!(Get-ScheduledTask -TaskName 'NASA-pic')) {
    Write-Host "Se creará la tarea"

    # Directorio donde se encuentra el script
    $scriptDir = "$env:USERPROFILE\apod"

    # Configuración de los desencadenadores de la tarea
    $taskTriggers = @( 
        New-ScheduledTaskTrigger -AtLogon
    )
    # Configuración de la acción de la tarea
    $taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Unrestricted -Command `"& $scriptDir\apod.ps1 > `"$($env:USERPROFILE)\apod\log.txt`""

    # Registro de la tarea programada
    Register-ScheduledTask -TaskName 'NASA-pic' -Trigger $taskTriggers -Action $taskAction -User 'NT AUTHORITY\SYSTEM'  -RunLevel Highest –Force
    Write-Host "Tarea creada correctamente."
} else {
    Write-Host "La tarea ya está creada."
}
