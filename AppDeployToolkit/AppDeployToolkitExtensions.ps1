<#
.SYNOPSIS

PSAppDeployToolkit - Provides the ability to extend and customise the toolkit by adding your own functions that can be re-used.

.DESCRIPTION

This script is a template that allows you to extend the toolkit with your own custom functions.

This script is dot-sourced by the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.

PSApppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2023 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham and Muhammad Mashwani).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.EXAMPLE

powershell.exe -File .\AppDeployToolkitHelp.ps1

.INPUTS

None

You cannot pipe objects to this script.

.OUTPUTS

None

This script does not generate any output.

.NOTES

.LINK

https://psappdeploytoolkit.com
#>


[CmdletBinding()]
Param (
)

##*===============================================
##* VARIABLE DECLARATION
##*===============================================

# Variables: Script
[string]$appDeployToolkitExtName = 'PSAppDeployToolkitExt'
[string]$appDeployExtScriptFriendlyName = 'App Deploy Toolkit Extensions'
[version]$appDeployExtScriptVersion = [version]'3.9.3'
[string]$appDeployExtScriptDate = '02/05/2023'
[hashtable]$appDeployExtScriptParameters = $PSBoundParameters

##*===============================================
##* FUNCTION LISTINGS
##*===============================================

function Set-SCCMAppDetectRegistryKey {
    <#
    .SYNOPSIS
    This Function Record a Value in the registry that can be used for Application Detection in SCCM
    .EXAMPLE
    Set-SCCMAppDetectRegistryKey -AppName 'Application' -Value '1'
    .PARAMETER AppName
    Application Name
    .PARAMETER Value
    Value of Registry Entry
    #>
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $AppDeployReg,
        [Parameter(Mandatory=$true)]
        [string]
        $AppName,
        [Parameter(Mandatory=$true)]
        [string]
        $Value
    )
    if ($PSBoundParameters['AppDeployReg']) {
        $AppDeployReg = $AppDeployReg
    }
    else {
        $AppDeployReg = "HKLM:\SOFTWARE\PSADT\Application Detection"
    }

    if (!(Test-Path $AppDeployReg)) {
        New-Item $AppDeployReg -Force | Out-Null
        Write-Log "Create $AppDeployReg"
    }

    New-ItemProperty $AppDeployReg -Name $AppName -Value $Value -Force | Out-Null
    Write-Log "Create $AppDeployReg\$AppName with a value of $Value"
}

function Remove-SCCMAppDetectRegistryKey {
    <#
    .SYNOPSIS
    This Function Remove a Value in the registry that can be used for Application Detection in SCCM
    .EXAMPLE
    Remove-SCCMAppDetectRegistryKey -AppName 'Application'
    .PARAMETER AppName
    Application Name
    #>
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $AppDeployReg,
        [Parameter(Mandatory=$true)]
        [string]
        $AppName
    )
    if ($PSBoundParameters['AppDeployReg']) {
        $AppDeployReg = $AppDeployReg
    }
    else {
        $AppDeployReg = "HKLM:\SOFTWARE\PSADT\Application Detection"
    }
    Remove-ItemProperty $AppDeployReg -Name $AppName -Force | Out-Null
    Write-Log "Remove $AppDeployReg\$AppName"
}

function Set-Host {
	<#
	.SYNOPSIS
	This Function add a entrie to the hosts file
	.EXAMPLE
	Set-Host -ip "192.168.x.x" -hostname "server.domain"
	.PARAMETER ip
	.PARAMETER hostname
	#>
	param (
		[Parameter(Mandatory=$false)]
		[string]
		$hostFile,
		[Parameter(Mandatory=$true)]
		[string]
		$ip,
		[Parameter(Mandatory=$true)]
		[string]
		$hostname
	)
	if ($PSBoundParameters['hostFile']) {
		$hostFile = $hostFile
	}
	else {
		$hostFile = "C:\Windows\System32\drivers\etc\hosts"
	}
	
	Remove-Host $hostFile $hostname
	$ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $hostFile
}

function Remove-Host {
	<#
	.SYNOPSIS
	This Function Remove a entrie from the hosts file
	.EXAMPLE
	Remove-Host -hostname "server.domain"
	.PARAMETER hostname
	#>
	param (
		[Parameter(Mandatory=$false)]
		[string]
		$hostFile,
		[Parameter(Mandatory=$true)]
		[string]
		$hostname
	)
	if ($PSBoundParameters['hostFile']) {
		$hostFile = $hostFile
	}
	else {
		$hostFile = "C:\Windows\System32\drivers\etc\hosts"
	}
	
	$c = Get-Content $hostFile
	$newLines = @()
	
	ForEach ($line in $c) {
		$bits = [regex]::Split($line, "\t+")
		
		if ($bits.count -eq 2) {
			if ($bits[1] -ne $hostname) {
				$newLines += $line
			}
		} else {
			$newLines += $line
		}
	}
	
	Clear-Content $hostFile
	
	ForEach ($line in $newLines) {
		$line | Out-File -encoding ASCII -append $hostFile
	}
}
	

##*===============================================
##* END FUNCTION LISTINGS
##*===============================================

##*===============================================
##* SCRIPT BODY
##*===============================================

If ($scriptParentPath) {
    Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] dot-source invoked by [$(((Get-Variable -Name MyInvocation).Value).ScriptName)]" -Source $appDeployToolkitExtName
}
Else {
    Write-Log -Message "Script [$($MyInvocation.MyCommand.Definition)] invoked directly" -Source $appDeployToolkitExtName
}

##*===============================================
##* END SCRIPT BODY
##*===============================================
