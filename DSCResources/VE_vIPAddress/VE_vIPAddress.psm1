data localized {
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        GettingIPAddress = Getting the IP address for network adapter '{0}'.
        SettingIPAddress = Setting IP address '{0}' for network adapter '{1}'.
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
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String] $InterfaceAlias,

        [Parameter(Mandatory)]
        [UInt32] $SubnetMask,

        [Parameter()] [ValidateSet('IPv4')]
        [String] $AddressFamily = 'IPv4'
    )
        
    Write-Verbose -Message ($localized.GettingIPAddress -f $InterfaceAlias);
    $configuration = Get-LegacyNetAdapterConfiguration -Name $InterfaceAlias;

    $IPAddresses = @();
    for ($i = 0; $i -lt $configuration.IPAddress.Count; $i++) { 
        if ($configuration.IPAddress[$i] -match '\.') {
            $IPAddresses += $configuration.IPAddress[$i];
            $subnetCIDR = ConvertTo-CIDR -SubnetMask $configuration.IPSubnet[$i];
        }
    }

    $targetResource = @{
        IPAddress = $IPAddresses -join ',';
        InterfaceAlias = $InterfaceAlias;
        SubnetMask = $subnetCIDR;
        AddressFamily = $AddressFamily;
    }

    return $targetResource;

} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)]
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String] $InterfaceAlias,

        [Parameter(Mandatory)]
        [UInt32] $SubnetMask,

        [Parameter()] [ValidateSet('IPv4')]
        [String] $AddressFamily = 'IPv4'
    )

    $targetResource = Get-TargetResource @PSBoundParameters;
    $inDesiredState = $true;

    if ($targetResource.IPAddress -notcontains $IPAddress) {
        Write-Verbose -Message ($localized.ResourcePropertyMismatch -f 'IPAddress', $IPAddress, $targetResource.IPAddress);
        $inDesiredState = $false;   
    }
    elseif ($targetResource.SubnetMask -ne $SubnetMask) {
        Write-Verbose -Message ($localized.ResourcePropertyMismatch -f 'SubnetMask', $SubnetMask, $targetResource.SubnetMask);
        $inDesiredState = $false;   
    }

    if ($inDesiredState) {
        Write-Verbose -Message ($localized.ResourceInDesiredState -f $InterfaceAlias);
        return $true;
    }
    else {
        Write-Verbose -Message ($localized.ResourceNotInDesiredState -f $InterfaceAlias);
        return $false;
    }

} #end function Test-TargetResource

function Set-TargetResource {
    param (
        [Parameter(Mandatory)]
        [String] $IPAddress,

        [Parameter(Mandatory)]
        [String] $InterfaceAlias,

        [Parameter(Mandatory)]
        [UInt32] $SubnetMask,

        [Parameter()] [ValidateSet('IPv4')]
        [String] $AddressFamily = 'IPv4'
    )

    $configuration = Get-LegacyNetAdapterConfiguration -Name $InterfaceAlias;
    $subnetMaskString = ConvertFrom-CIDR -CIDR $SubnetMask;
    $ipAddressString = '{0}/{1}' -f $IPAddress, $subnetMaskString;
    Write-Verbose -Message ($localized.SettingIPAddress -f $ipAddressString, $InterfaceAlias);
    [ref] $null = $configuration.EnableStatic($IPAddress, $subnetMaskString);

} #end function Set-TargetResource

## Import the private functions into this module's scope
Get-ChildItem -Path $PSScriptRoot\..\..\Lib -Filter '*.ps1' | ForEach-Object {
    . $_.FullName;
}

Export-ModuleMember -Function *-TargetResource;
