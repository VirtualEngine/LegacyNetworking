data localized {
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
        GettingFirewallRule = Getting legacy firewall rule '{0}'.
        CreatingFirewallRule = Creating legacy firewall rule '{0}'.
        UpdatingFirewallRule = Updating legacy firewall rule '{0}'.
        RemovingFirewallRule = Removing legacy firewall rule '{0}'.
        ResourcePropertyMismatch = Property '{0}' does not match the desired state; expected '{1}', actual '{2}'.
        ResourceInDesiredState = Resource '{0}' is in the desired state.
        ResourceNotInDesiredState = Resource '{0}' is NOT in the desired state.
        
        CheckingArrayMembers           = Checking array for '{0}' members.
        MembershipCountMismatch        = Array membership count is not correct. Expected '{0}' members, actual '{1}' members.
        MemberNotInDesiredState        = Array member '{0}' is not in the desired state.
        RemovingDuplicateMember        = Removing duplicate array member '{0}' definition.
        MembershipInDesiredState       = Array membership is in the desired state.
        MembershipNotDesiredState      = Array membership is NOT in the desired state.
'@
}

function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [Alias('Name')] [System.String] $DisplayName,
        
        [Parameter(Mandatory)]
        [System.String[]] $Profile,
        
        [Parameter(Mandatory)] [ValidateSet('Inbound','Outbound')]
        [System.String] $Direction,
        
        [Parameter(Mandatory)] [ValidateSet('Allow','Block','Bypass')]
        [System.String] $Action,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Protocol,
        
        [Parameter()] [AllowEmptyString()]
        [System.String] $Description,
        
        [Parameter()]
        [System.Boolean] $Enabled,
        
        [Parameter()] [AllowEmptyString()]
        [System.String[]] $LocalPort,
        
        [Parameter()] [AllowEmptyString()]
        [System.String[]] $RemotePort,
        
        [Parameter()] [AllowEmptyString()]
        [System.String] $Program,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Service,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )
    
    $Profile = Resolve-ProfileParameter -Profile $Profile;
    
    Write-Verbose -Message ($localized.GettingFirewallRule -f $DisplayName);
    $getLegacyNetFirewallRuleParams = @{
        DisplayName = $DisplayName;
        Profile = $Profile;
        Direction = $Direction;
        Action = $Action;
    }
    $firewallRule = Get-LegacyNetFirewallRule @getLegacyNetFirewallRuleParams; 

    $targetResource = @{
        DisplayName = $firewallRule.Name;
        Profile = $firewallRule.Profile -as [System.String[]];
        Direction = $firewallRule.Direction;
        Action = $firewallRule.Action;
        Protocol = $firewallRule.Protocol;
        Description = $firewallRule.Description;
        Enabled = $firewallRule.Enabled;
        LocalPort = $firewallRule.LocalPort;
        RemotePort = $firewallRule.RemotePort;
        Program = $firewallRule.Program;
        Service = $firewallRule.Service;
        Ensure = if ($firewallRule) { 'Present' } else { 'Absent' }
        DisplayGroup = $firewallRule.DisplayGroup;
    }

    return $targetResource;

} #end function Get-TargetResource

function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [Alias('Name')] [System.String] $DisplayName,
        
        [Parameter(Mandatory)]
        [System.String[]] $Profile,
        
        [Parameter(Mandatory)] [ValidateSet('Inbound','Outbound')]
        [System.String] $Direction,
        
        [Parameter(Mandatory)] [ValidateSet('Allow','Block','Bypass')]
        [System.String] $Action,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Protocol,
        
        [Parameter()] [AllowEmptyString()]
        [System.String] $Description,
        
        [Parameter()]
        [System.Boolean] $Enabled = $true,
        
        [Parameter()] [AllowEmptyString()]
        [System.String[]] $LocalPort,
        
        [Parameter()] [AllowEmptyString()]
        [System.String[]] $RemotePort,
        
        [Parameter()] [AllowEmptyString()]
        [System.String] $Program,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Service,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    ## Add ensure and enabled as they might not have been explicitly passed
    $PSBoundParameters['Ensure'] = $Ensure;
    $PSBoundParameters['Enabled'] = $Enabled;
    
    $Profile = Resolve-ProfileParameter -Profile $Profile;
    $PSBoundParameters['Profile'] = $Profile;
    
    $targetResource = Get-TargetResource @PSBoundParameters;
    $inDesiredState = $true;
    
    foreach ($propertyName in $PSBoundParameters.Keys) {
        
        if ($targetResource.ContainsKey($propertyName)) {
            $propertyValue = $PSBoundParameters[$propertyName];
            if ($propertyValue -is [System.String[]]) {
                $members = Test-Members -ExistingMembers $targetResource[$propertyName] -Members $propertyValue -Verbose:$false;
                if (-not $members) {
                    Write-Verbose -Message ($localized.ResourcePropertyMismatch -f $propertyName, ($propertyValue -join ','), ($targetResource[$propertyName] -join ','));
                    $inDesiredState = $false;    
                }
            }
            elseif ($propertyValue -ne $targetResource[$propertyName]) {
                Write-Verbose -Message ($localized.ResourcePropertyMismatch -f $propertyName, ($propertyValue -join ','), ($targetResource[$propertyName] -join ','));
                $inDesiredState = $false;   
            }
        }
    }

    if ($inDesiredState) {
        Write-Verbose -Message ($localized.ResourceInDesiredState -f $DisplayName);
        return $true;
    }
    else {
        Write-Verbose -Message ($localized.ResourceNotInDesiredState -f $DisplayName);
        return $false;
    }

} #end function Test-TargetResource

function Set-TargetResource {
    param (
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
        [Alias('Name')] [System.String] $DisplayName,
        
        [Parameter(Mandatory)]
        [System.String[]] $Profile,
        
        [Parameter(Mandatory)] [ValidateSet('Inbound','Outbound')]
        [System.String] $Direction,
        
        [Parameter(Mandatory)] [ValidateSet('Allow','Block','Bypass')]
        [System.String] $Action,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Protocol,
        
        [Parameter()] [AllowEmptyString()]
        [System.String] $Description,
        
        [Parameter()]
        [System.Boolean] $Enabled = $true,
        
        [Parameter()] [AllowEmptyString()]
        [System.String[]] $LocalPort,
        
        [Parameter()] [AllowEmptyString()]
        [System.String[]] $RemotePort,
        
        [Parameter()] [AllowEmptyString()]
        [System.String] $Program,
        
        [Parameter()] [ValidateNotNullOrEmpty()]
        [System.String] $Service,
        
        [Parameter()] [ValidateSet('Present','Absent')]
        [System.String] $Ensure = 'Present'
    )

    ## Add enabled as it might not have been explicitly passed
    $PSBoundParameters['Enabled'] = $Enabled;
    
    ## Remove Ensure as it can't be passed to *-LegacyNetFirewallRule
    [ref] $null = $PSBoundParameters.Remove('Ensure');
    
    $Profile = Resolve-ProfileParameter -Profile $Profile;
    $PSBoundParameters['Profile'] = $Profile;
    
    $targetResource = Get-TargetResource @PSBoundParameters -Ensure $Ensure;
    
    if (($Ensure -eq 'Present') -and ($targetResource.Ensure -eq 'Absent')) {
        ## Create
        Write-Verbose -Message ($localized.CreatingFirewallRule -f $DisplayName);
        [ref] $null = New-LegacyNetFirewallRule @PSBoundParameters;
    }
    elseif ($Ensure -eq 'Present') {
        ## Update
        Write-Verbose -Message ($localized.UpdatingFirewallRule -f $DisplayName);
        [ref] $null = Set-LegacyNetFirewallRule @PSBoundParameters; 
    }
    elseif (($Ensure -eq 'Absent') -and ($targetResource.Ensure -eq 'Present')) {
        ## Remove   
        Write-Verbose -Message ($localized.RemovingFirewallRule -f $DisplayName);
        [ref] $null = Remove-LegacyNetFirewallRule -DisplayName $DisplayName -Profile $Profile;
    }

} #end function Set-TargetResource

## Import the private functions into this module's scope
Get-ChildItem -Path $PSScriptRoot\..\..\Lib -Filter '*.ps1' | ForEach-Object {
    . $_.FullName;
}

Export-ModuleMember -Function *-TargetResource;
