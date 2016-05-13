function New-LegacyNetFirewallRule {
    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [Alias('Name')] [System.String] $DisplayName,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateSet('Public','Private','Domain','Any')]
        [System.String[]] $Profile,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateSet('Inbound','Outbound')]
        [System.String] $Direction,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateSet('Allow','Block','Bypass')]
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
            @{ Name = 'Protocol'; NetshParameter = 'protocol'; Type = [System.String]; }
            @{ Name = 'Direction'; NetshParameter = 'dir'; Type = [System.String]; CustomMap = @{ Inbound = 'in'; Outbound = 'out'; }; }
            @{ Name = 'Description'; NetshParameter = 'desc'; Type = [System.String]; }
            @{ Name = 'Enabled'; NetshParameter = 'enable'; Type = [System.Boolean]; CustomMap = @{ True = 'yes'; False = 'no'; }; }
            @{ Name = 'LocalPort'; NetshParameter = 'localport'; Type = [System.String[]]; }
            @{ Name = 'RemotePort'; NetshParameter = 'remoteport'; Type = [System.String[]]; }
            @{ Name = 'Program'; NetshParameter = 'program'; Type = [System.String]; }
            @{ Name = 'Service'; NetshParameter = 'service'; Type = [System.String]; }
            @{ Name = 'Action'; NetshParameter = 'action'; Type = [System.String]; }
        )
        
        if ($PSBoundParameters.ContainsKey('Profile')) {
            $PSBoundParameters['Profile'] = Resolve-ProfileParameter -Profile $Profile;
        }
        
    } #end begin
    process {
        
        $netshNameString = 'Name="{0}"' -f $DisplayName;
        $netshProfileString = 'Profile={0}' -f ($Profile -join ',');
        $netshCommands = @('advfirewall', 'firewall', 'add', 'rule', $netshNameString, $netshProfileString);
        
        $parameterNames = @(
            'Protocol',
            'Description',
            'Enabled',
            'Direction',
            'LocalPort',
            'RemotePort',
            'Program',
            'Service',
            'Action'
        );
        
        $specificNetshCommands = @();
        foreach ($parameterName in $PSBoundParameters.Keys) {
            foreach ($mapping in $map) {
                if ($parameterName -eq $mapping.Name) {
                    $parameterValue = $PSBoundParameters[$parameterName];
                    if ($mapping.CustomMap) {
                        $specificNetshCommands += '{0}="{1}"' -f $mapping.NetshParameter, $mapping.CustomMap[$parameterValue.ToString()];
                    }
                    else {
                        $specificNetshCommands += '{0}="{1}"' -f $mapping.NetshParameter, ($parameterValue -join ',');
                    }
                }
            }
        }
        
        if ($specificNetshCommands.Count -eq 0) {
            throw ("Nothing to set.");
        }
        else {
            $netshCommands += $specificNetshCommands;
        }
        
        $shouldProcessMessage = 'NETSH.EXE {0}' -f ($netshCommands -join ' ');
        if ($PSCmdlet.ShouldProcess($shouldProcessMessage)) {
            $netshOutput = & netsh.exe $netshCommands;
            if ($LASTEXITCODE -ne 0) {
                $errorMessage = $netshOutput -split "`r`n";
                if ([System.String]::IsNullOrEmpty($errorMessage[1])) {
                    ## The requested operation requires elevation (Run as administrator).
                    throw ($errorMessage[0]);
                }
                else {
                    throw ($errorMessage[1]);
                }
            }
            Write-Verbose -Message (($netshOutput -join ' ').Trim());
            Get-LegacyNetFirewallRule -DisplayName $DisplayName -Profile $Profile;
        }
        
    } #end process
} #end function New-FirewallRule
