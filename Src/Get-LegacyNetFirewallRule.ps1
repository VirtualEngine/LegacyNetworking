function Get-LegacyNetFirewallRule {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        #[Parameter(ParameterSetName = 'Port', ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [Alias('Name')] [System.String] $DisplayName,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateSet('Public','Private','Domain','Any')]
        [System.String[]] $Profile,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateSet('Inbound','Outbound')]
        [System.String] $Direction,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateSet('Allow','Block','Bypass')]
        [System.String] $Action,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Port')] [ValidateNotNullOrEmpty()]
        [System.String] $Protocol,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Description,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.Boolean] $Enabled,
        
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Port')]
        [System.String[]] $LocalPort,
        
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Port')]
        [System.String[]] $RemotePort,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Program,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [System.String] $Service
    )
    begin {
        
        $map = @(
            @{ Name = 'Protocol'; Regex = '^Protocol:'; Type = [System.String]; }
            @{ Name = 'Description'; Regex = '^Description:'; Type = [System.String]; }
            @{ Name = 'Enabled'; Regex = '^Enabled:'; Type = [System.Boolean]; CustomMap = @{ Yes = $true; No = $false; }; }
            @{ Name = 'Direction'; Regex = '^Direction:'; Type = [System.String]; CustomMap = @{ In = 'Inbound'; Out = 'Outbound'; }; }
            @{ Name = 'Profile'; Regex = '^Profiles:'; Type = [System.String[]]; }
            @{ Name = 'DisplayGroup'; Regex = '^Grouping:'; Type = [System.String]; } ## Read-only
            @{ Name = 'LocalPort'; Regex = '^LocalPort:'; Type = [System.String[]]; }
            @{ Name = 'RemotePort'; Regex = '^RemotePort:'; Type = [System.String[]]; }
            @{ Name = 'Program'; Regex = '^Program:'; Type = [System.String]; }
            @{ Name = 'Service'; Regex = '^Service:'; Type = [System.String]; }
            @{ Name = 'Action'; Regex = '^Action:'; Type = [System.String]; }
        )
        
        if ($PSBoundParameters.ContainsKey('Profile')) {
            $PSBoundParameters['Profile'] = Resolve-ProfileParameter -Profile $Profile;
        }
        
    } #end begin
    end {
        
        $firewallRule = $null;
        
        if ($DisplayName.Contains('*')) {
            ## Retrieve all rules for parsing later
            Write-Verbose -Message ('Performing wildcard match');
            $firewallRules = Get-NetshFirewallRule;
            $isWilcardMatch = $true;
        }
        else {
            ## Retrieve by explicit name match
            $firewallRules = Get-NetshFirewallRule @PSBoundParameters;
            $isWilcardMatch = $false;
        }
        
        foreach ($string in $firewallRules) {
            
            ## Do we have a new rule or reached the end?
            if (($string -match '^Rule Name:') -or ($string -match 'Ok.')) {
                
                $isMatch = $true;
                
                if ($null -ne $firewallRule) {
                    
                    ## Perform wilcard match
                    if ($isWilcardMatch) {
                        if ($firewallRule.Name -notlike $DisplayName) {
                            continue;
                        }
                    }
                    else {
                        if ($firewallRule.Name -ne $DisplayName) {
                            continue;
                        }
                    }
                    
                    ## Now compare all specified attributes..
                    foreach ($parameterName in $PSBoundParameters.Keys) {
                        if ($firewallRule[$parameterName] -is [System.String[]]) {
                            $existingMembers = $firewallRule[$parameterName];
                            $expectedMembers = $PSBoundParameters[$parameterName];
                            if (-not (Test-Members -ExistingMembers $existingMembers -Members $expectedMembers -Verbose:$false)) {
                                Write-Debug ("Expected: {0}, Actual: {1}" -f ($expectedMembers -join ' '), ($existingMembers -join ' '))
                                ## Required as continue only breaks out of the current foreach loop
                                $isMatch = $false;
                                continue;
                            }
                        }
                        elseif ($null -ne $firewallRule[$parameterName]) {
                            if ($firewallRule[$parameterName] -ne $PSBoundParameters[$parameterName]) {
                                Write-Debug ("Expected: {0}, Actual: {1}" -f ($PSBoundParameters[$parameterName] -join ' '), ($firewallRule[$parameterName] -join ' '))
                                ## Required as continue only breaks out of the current foreach loop
                                $isMatch = $false;
                                continue;
                            }
                        }
                    }
                                        
                    if ($isMatch) {
                        ## Output existing object (only if we have one!)..
                        Write-Output -InputObject ([PSCustomObject] $firewallRule);
                    }
                }
                
                $firewallRule = [Ordered] @{
                    Name = ($string -replace '^Rule Name:').Trim()
                    LocalPort = @('Any');
                    RemotePort = @('Any');
                };
            
        }
            else {
                
                foreach ($mapping in $map) {
                    if ($string -match $mapping.Regex) {
                        $firewallRuleValue = ($string -replace $mapping.Regex).Trim();
                        if ($mapping.CustomMap) {
                            $firewallRule[$mapping.Name] = $mapping.CustomMap[$firewallRuleValue];
                        }
                        elseif ($mapping.Type.ToString() -eq 'System.String[]') {
                            $firewallRule[$mapping.Name] = $firewallRuleValue.Split(',');
                        }
                        else {
                            $firewallRule[$mapping.Name] = $firewallRuleValue -as $mapping.Type;
                        }
                    }
                } # end foreach mapping
            }
            
        } #end foreach string
        
    } #end end
} #end function Get-FirewallRule
