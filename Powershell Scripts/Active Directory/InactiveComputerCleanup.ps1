<#

.SYNOPSIS
   This script finds and manages inactive AD computer accounts.

.DESCRIPTION
    This script enables you to manage stale Active Directory computer objects.

.PARAMETER UserName
    The user account which will be used to connect to the Active Directory database to query and manage objects. Provide in DOMAIN\USER format.

.PARAMETER Password
    The password for the user account connecting to Active Directory.

.PARAMETER CleanupMode
    Specifies how stale objects should be managed.
    - Disable   Disables the object.
    - Delete    Deletes the object completely.

.PARAMETER SearchBase
    Specifies at which scope the search will take place. This can be an OU or the root directory in the format of its distinguished name.

.PARAMETER DaysInactive
    An integer that specifies the amount in days that a computer has not been seen on the network.

.PARAMETER DisablePrompts
    When set to true, safety prompts are removed and the script will manage accounts set by the cleanup mode.

#>

#---------------------------------------------------[Script Parameters]------------------------------------------------

Param (
    [Parameter(Mandatory = $true)][string]$UserName,
    [Parameter(Mandatory = $true)][securestring]$Password,
    [Parameter(Mandatory = $false)][String][ValidateSet('Disable', 'Delete', 'ScanOnly')]$CleanupMode = "ScanOnly",
    [Parameter(Mandatory = $false)][String]$SearchBase = "OU=COMPUTERS,OU=SRV,OU=TEST,DC=domain,DC=com",
    [Parameter(Mandatory = $false)][int]$DaysInactive = 45,
    [Parameter(Mandatory = $false)][boolean]$DisablePrompts = $True
)

#---------------------------------------------------[Initialisations]--------------------------------------------------

Import-Module ActiveDirectory

#---------------------------------------------------[Declarations]-----------------------------------------------------

$Credential = New-Object System.Management.Automation.PSCredential ("$UserName", $Password)
$Date = ((get-date).AddDays(-$DaysInactive))
$ReportName = "AD_Computer_Cleanup_Report"
$ReportPath = "C:\temp\" + "$ReportName" + "_" + (get-date).ToString("dd_MM_yyyy") + ".csv"
$To = "my.email@outlook.com"
$SMTPServer = "my.smtp.server@domain.com"
$Subject = "Inactive AD computers report."
$From = "Some.EmailAddress@domain.com"

#---------------------------------------------------[Functions]--------------------------------------------------------

function Get-InactiveComputers {

    param()

    Begin { 
        Write-Host "Searching for inactive computer accounts in the directory $SearchBase" -ForegroundColor Green
    }

    Process {
        Try {
            $params = @{
                Credential = $Credential
                SearchBase = $SearchBase
                Properties = 'Name', 'LastLogonDate'
                Filter = {LastLogonDate -lt $Date -and Enabled -eq $True}
            }
            $global:InactiveComputers = Get-ADComputer @params
        }
        Catch {
            Write-Host -ForegroundColor Red "Error: $($_.Exception)"
            Break
        }
    }

    End {
        Write-Host -ForegroundColor Green 'Completed Successfully.'
        Write-Host ' '
        Return $InactiveComputers
    }
}
function Remove-InactiveComputers {
    param()
    Begin { 
        Write-Host "Removing inactive computer accounts in $SearchBase" -ForegroundColor Green
    }

    Process {
        Try {
            foreach ($Object in $InactiveComputers){
                Remove-ADComputer -Identity $Object -Credential $Credential -Confirm:$False -WhatIf
            }
        }
        Catch {
            Write-Host -ForegroundColor Red "Error: $($_.Exception)"
            Break
        }
    }

    End {
        If ($?) {
            Write-Host -ForegroundColor Green 'Completed Successfully.'
            Write-Host ' '
        } 
    }
}
function New-ADComputerReport {
    param(
        [string]$SMTPServer,
        [string]$Subject,
        [string]$To,
        [string]$From,
        [boolean]$SendEmail
    )

    Begin{
        Write-Host "Generating AD computer report in location $($ReportPath)"
    }

    Process {
        Try {
            If ($ReportPath -notlike '*.csv') {
                Write-Host "Error: Report path not valid. Ensure you specify a valid path and filename with .csv extension." -ForegroundColor Red
            }
            If (!(Test-Path C:\Temp)){
                New-Item -ItemType Directory -Path "C:\" -Name "Temp"
            }

            $Global:InactiveComputers | Export-CSV $ReportPath

            Send-MailMessage -SmtpServer $SMTPServer -Subject $Subject -To $To -From $From -Attachments $ReportPath

        }
        Catch {
            Write-Host -BackgroundColor Red "Error: $($_.Exception)"
            Break
        }
    }
}

#---------------------------------------------------[Execution]--------------------------------------------------------

Get-InactiveComputers

Write-Host "Found $($InactiveComputers.count) inactive computers in the directory $($SearchBase)." -ForegroundColor Green

If ($DisablePrompts -eq $false){
    Write-Host "Continue with cleanup using $($CleanupMode) mode?." -ForegroundColor Green
    Read-Host "Press Enter to continue."
    
}

If ($CleanupMode -eq "Disable"){
    Disable-InactiveComputers
}
elseif (($CleanupMode -eq "Delete") -and ($InactiveComputers.count -gt 0)){
    Write-Host "Removing computer objects is a destructive operation that cannot be undone." -ForegroundColor Yellow
    Read-Host "Press 'Enter' to continue with this operation."
    Remove-InactiveComputers
}
elseif (($CleanupMode -eq "ScanOnly") -and ($InactiveComputers.count -gt 0)) {
    Return $InactiveComputers | Select-Object Name, LastLogonDate, DistinguishedName | Format-Table
}

New-ADComputerReport -SMTPServer $SMTPServer -Subject $Subject -To $To -From $From 
