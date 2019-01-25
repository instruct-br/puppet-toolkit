<#
Originally developed by Hashicorp.
Source: https://raw.githubusercontent.com/hashicorp/puppet-bootstrap/master/windows.ps1

.SYNOPSIS
    Installs Puppet on this machine.

.DESCRIPTION
    Downloads and installs the official Puppet MSI package.

    This script requires administrative privileges.

    You can run this script from an old-style cmd.exe prompt using the
    following:

      powershell.exe -ExecutionPolicy Unrestricted -NoLogo -NoProfile -Command "& '.\puppet-agent-installer.ps1'"

.PARAMETER MsiUrl
    This is the URL to the Puppet MSI file you want to install. This defaults
    to a version from Puppet.

.PARAMETER PuppetVersion
    This is the version of Puppet that you want to install. If you pass this it will override the version in the MsiUrl.
    This defaults to $null.
#>
param(
    [string]$MsiUrl = "https://downloads.puppet.com/windows/puppet5/puppet-agent-x64-latest.msi",
    [string]$PuppetVersion = $null
)

if ($PuppetVersion) {
    if ($PuppetVersion[0] -eq '6') {
        $MsiUrl = "https://downloads.puppet.com/windows/puppet6/puppet-agent-$($PuppetVersion)-x64.msi"
    } else {
        if ($PuppetVersion[0] -eq '5') {
            $MsiUrl = "https://downloads.puppet.com/windows/puppet5/puppet-agent-$($PuppetVersion)-x64.msi"
        } else {
            $MsiUrl = "https://downloads.puppet.com/windows/puppet-agent-$($PuppetVersion)-x64.msi"
        }
    }
    Write-Output "Puppet version $PuppetVersion specified, updated MsiUrl to `"$MsiUrl`""
}

$PuppetInstalled = $false
try {
    $ErrorActionPreference = "Stop";
    Get-Command puppet | Out-Null
    $PuppetInstalled = $true
    $PuppetVersion = &puppet "--version"
    Write-Output "Puppet $PuppetVersion is installed. This process does not ensure the exact version or at least version specified, but only that puppet is installed. Exiting..."
    Exit 0
} catch {
    Write-Output "Puppet is not installed, continuing..."
}

if (!($PuppetInstalled)) {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (! ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
        Write-Output -ForegroundColor Red "You must run this script as an administrator."
        Exit 1
    }

    # Install it - msiexec will download from the url
    $install_args = @("/qn", "/norestart", "/i", $MsiUrl)
    Write-Output "Installing Puppet. Running msiexec.exe $install_args"
    $process = Start-Process -FilePath msiexec.exe -ArgumentList $install_args -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Output "Installer failed."
        Exit 1
    }

    # Stop the service that it autostarts
    Write-Output "Stopping Puppet service that is running by default..."
    Start-Sleep -s 5
    Stop-Service -Name puppet

    Write-Output "Puppet successfully installed."
}
