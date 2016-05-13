data localized {
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        GettingDnsServerAddress = Getting DNS server addresses for network adapter '{0}'.
        SettingDnsServerAddress = Setting DNS server addresses '{0}' for network adapter '{1}'.
        ResourcePropertyMismatch = Property '{0}' does not match the desired state; expected '{1}', actual '{2}'.
        ResourceInDesiredState = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState = Resource '{0}' is NOT in the desired state.
'@
}

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)]
        [System.String[]] $Address,

        [Parameter(Mandatory)]
        [System.String] $InterfaceAlias,

        [Parameter()] [ValidateSet('IPv4')]
        [System.String] $AddressFamily = 'IPv4'
    )
    
    Write-Verbose -Message ($localized.GettingDnsServerAddress -f $InterfaceAlias);
    $configuration = Get-LegacyNetAdapterConfiguration -Name $InterfaceAlias;

    $targetResource = @{
        Address = $configuration.DNSServerSearchOrder;
        InterfaceAlias = $InterfaceAlias;
        AddressFamily = $AddressFamily;
    }

    return $targetResource;

} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [System.String[]] $Address,

        [Parameter(Mandatory)]
        [System.String] $InterfaceAlias,

        [Parameter()] [ValidateSet('IPv4')]
        [System.String] $AddressFamily = 'IPv4'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;
    $inDesiredState = $true;

    foreach ($server in $Address) {
        if ($targetResource.Address -notcontains $server) {
            Write-Verbose -Message ($localized.ResourcePropertyMismatch -f 'Address', $server, ($targetResource.Address -join ','));
            $inDesiredState = $false;    
        }
    }

    foreach ($server in $targetResource.Address) {
        if ($Address -notcontains $server) {
            Write-Verbose -Message ($localized.ResourcePropertyMismatch -f 'Address', $server, ($Address -join ','));
            $inDesiredState = $false;
        }
    }

    if ($inDesiredState) {
        Write-Verbose -Message ($localized.ResourceInDesiredState -f $InterfaceAlias);
        return $true;
    }
    else {
        Write-Verbose -Message ($localized.ResourceNotInDesiredState -f $InterfaceAlias);
        return $false;
    }

} #end Test-TargetResource

function Set-TargetResource {
    param (
        [Parameter(Mandatory)]
        [System.String[]] $Address,

        [Parameter(Mandatory)]
        [System.String] $InterfaceAlias,

        [Parameter()] [ValidateSet('IPv4')]
        [System.String] $AddressFamily = 'IPv4'
    )
    
    $configuration = Get-LegacyNetAdapterConfiguration -Name $InterfaceAlias;   
    Write-Verbose -Message ($localized.SettingDnsServerAddress -f ($Address -join ','), $InterfaceAlias);
    [ref] $null = $configuration.SetDNSServerSearchOrder($Address);

} #end Set-TargetResource

## Import the private functions into this module's scope
Get-ChildItem -Path $PSScriptRoot\..\..\Lib -Filter '*.ps1' | ForEach-Object {
    . $_.FullName;
}

Export-ModuleMember -Function *-TargetResource;
