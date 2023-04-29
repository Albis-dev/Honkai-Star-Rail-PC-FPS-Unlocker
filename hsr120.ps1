# Check if the script is running with administrator privileges
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    # If not running as administrator, create a new PowerShell process with administrator privileges
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command ""& { $(Get-Command -CommandType Application -Name PowerShell).Path } -NoProfile -ExecutionPolicy Bypass -File '$(Get-Location)\$(Get-Item -Path ".\" -Name *).Name'""" -Verb RunAs
    exit
}

# Define the registry key path and value name
$registryPath = "HKCU:\Software\Cognosphere\Star Rail"
$valueName = "GraphicsSettings_Model_h2986158309"

try {
    # Read the existing binary value from the registry
    $binValue = Get-ItemPropertyValue -Path $registryPath -Name $valueName

    # Convert the binary value to a JSON string, removing the null terminator (0x00)
    $jsonString = [System.Text.Encoding]::UTF8.GetString($binValue).TrimEnd([char]0x00)

    # Convert the JSON string to a PowerShell object
    $jsonObject = ConvertFrom-Json -InputObject $jsonString

    # Output the parsed value before the update
    Write-Host "Parsed value before update:"
    Write-Output $jsonObject

    # Update the "FPS" value in the PowerShell object
    $jsonObject.FPS = 120

    # Output the parsed value after the update
    Write-Host "Parsed value after update:"
    Write-Output $jsonObject

    # Convert the PowerShell object back to a JSON string
    $updatedJsonString = ConvertTo-Json -InputObject $jsonObject

    # Convert the JSON string back to a binary value, adding the null terminator (0x00)
    $updatedBinValue = [System.Text.Encoding]::UTF8.GetBytes($updatedJsonString + [char]0x00)

    # Update the registry key with the new binary value
    Set-ItemProperty -Path $registryPath -Name $valueName -Value $updatedBinValue

    # Display the "Done!" message
    Write-Host "Done!"
}
catch {
    Write-Host "An error occurred:"
    Write-Host $_.Exception.Message
}

# Keep the window open
Write-Host "Press any key to exit..."
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
