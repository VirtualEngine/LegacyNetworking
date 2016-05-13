function Remove-LegacyNetFirewallRule {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)] [ValidateNotNullOrEmpty()]
        [Alias('Name')] [System.String] $DisplayName,
        
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)] [ValidateSet('Public','Private','Domain','Any')]
        [System.String[]] $Profile
    )
    begin {
        
        if ($PSBoundParameters.ContainsKey('Profile')) {
            $PSBoundParameters['Profile'] = Resolve-ProfileParameter -Profile $Profile;
        }
        
    } #end begin
    process {
        
        $netshNameString = 'Name="{0}"' -f $DisplayName;
        $netshProfileString = 'Profile={0}' -f ($Profile -join ',');
        $netshCommands = @('advfirewall', 'firewall', 'delete', 'rule', $netshNameString, $netshProfileString);
       
        $shouldProcessMessage = 'NETSH.EXE {0}' -f ($netshCommands -join ' ');
        #Write-Verbose ("Executing 'NETSH.EXE {0}'." -f ($netshCommands -join ' '));
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
            Get-LegacyNetFirewallRule @PSBoundParameters;
        }
    
    } #end process
} #end function Remove-FirewallRule
