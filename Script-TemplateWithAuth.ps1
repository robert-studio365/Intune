<#
.SYNOPSIS


.DESCRIPTION


.PARAMETER Param
    Param description.

.PARAMETER ShowProgress
    Show a progressbar displaying the current operation.

.EXAMPLE
    

.NOTES
    FileName:    <script name>.ps1
    Author:      Nickolaj Andersen
    Contact:     @NickolajA
    Created:     2017-07-25
    Updated:     2017-07-25
    
    Version history:
    1.0.0 - (2017-07-25) Script created

    Required modules:
    AzureAD (Install-Module -Name AzureAD)        
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [parameter(Mandatory=$true, HelpMessage="Specify the tenant name, e.g. domain.onmicrosoft.com.")]
    [ValidateNotNullOrEmpty()]
    [string]$TenantName,

    [parameter(Mandatory=$false, HelpMessage="Specify the Application ID of the app registration in Azure AD. When no parameter is manually passed, script will attempt to use well known Microsoft Intune PowerShell app registration.")]
    [ValidateNotNullOrEmpty()]
    [string]$ApplicationID = "d1ddf0e4-d672-4dae-b554-9d5bdfd93547"    
)
Begin {
    # Determine if the PSIntuneAuth module needs to be installed
    try {
        Write-Verbose -Message "Attempting to locate PSIntuneAuth module"
        $PSIntuneAuthModule = Get-InstalledModule -Name PSIntuneAuth -ErrorAction Stop -Verbose:$false
        if ($PSIntuneAuthModule -ne $null) {
            Write-Verbose -Message "Authentication module detected, checking for latest version"
            $LatestModuleVersion = (Find-Module -Name PSIntuneAuth -ErrorAction Stop -Verbose:$false).Version
            if ($LatestModuleVersion -gt $PSIntuneAuthModule.Version) {
                Write-Verbose -Message "Latest version of PSIntuneAuth module is not installed, attempting to install: $($LatestModuleVersion.ToString())"
                $UpdateModuleInvocation = Update-Module -Name PSIntuneAuth -Scope CurrentUser -Force -ErrorAction Stop -Confirm:$false -Verbose:$false
            }
        }
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to detect PSIntuneAuth module, attempting to install from PSGallery"
        try {
            Install-Module -Name PSIntuneAuth -Scope AllUsers -Force -ErrorAction Stop -Confirm:$false -Verbose:$false
            Write-Verbose -Message "Successfully installed PSIntuneAuth"
        }
        catch [System.Exception] {
            Write-Warning -Message "An error occurred while attempting to install PSIntuneAuth module. Error message: $($_.Exception.Message)" ; break
        }
    }

    # Check if token has expired and if, request a new
    Write-Verbose -Message "Checking for existing authentication token"
    if ($Global:AuthToken -ne $null) {
        $UTCDateTime = (Get-Date).ToUniversalTime()
        $TokenExpireMins = ($Global:AuthToken.ExpiresOn.datetime - $UTCDateTime).Minutes
        Write-Verbose -Message "Current authentication token expires in (minutes): $($TokenExpireMins)"
        if ($TokenExpireMins -le 0) {
            Write-Verbose -Message "Existing token found but has expired, requesting a new token"
            $Global:AuthToken = Get-MSIntuneAuthToken -TenantName $TenantName -ClientID $ApplicationID
        }
        else {
            Write-Verbose -Message "Existing authentication token has not expired, will not request a new token"
        }
    }
    else {
        Write-Verbose -Message "Authentication token does not exist, requesting a new token"
        $Global:AuthToken = Get-MSIntuneAuthToken -TenantName $TenantName -ClientID $ApplicationID
    }
}
Process {
    # Main code
}