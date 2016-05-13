function Get-NetshFirewallRule {
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [Parameter(ValueFromPipeline)] [ValidateNotNullOrEmpty()]
        [System.String] $DisplayName,
        
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateSet('Public','Private','Domain')]
        [System.String[]] $Profile,
        
        [Parameter(ValueFromRemainingArguments)]
        [System.Object[]] $Arguments
    )
    process {

        if ($PSBoundParameters.ContainsKey('DisplayName') -and $PSBoundParameters.ContainsKey('Profile')) {
            $profileString = ([System.String[]] @(Remove-DuplicateMembers -Members $Profile)) -join ',';
            $netshMessage = 'advfirewall firewall show rule name="{0}" profile="{1}" verbose' -f $DisplayName, $profileString;
            Write-Verbose -Message ($localized.ExecutingNetsh -f $netshMessage);
            $netshOutput = & netsh advfirewall firewall show rule name="$DisplayName" profile="$profileString" verbose;
        }
        elseif ($PSBoundParameters.ContainsKey('DisplayName')) {
            $netshMessage = 'advfirewall firewall show rule name="{0}" verbose' -f $DisplayName;
            Write-Verbose -Message ($localized.ExecutingNetsh -f $netshMessage);
            $netshOutput = & netsh advfirewall firewall show rule name="$DisplayName" verbose;
        }
        elseif ($PSBoundParameters.ContainsKey('Profile')) {
            $profileString = ([System.String[]] @(Remove-DuplicateMembers -Members $Profile)) -join ',';
            $netshMessage = 'advfirewall firewall show rule name=all profile="{0}" verbose' -f $profileString;
            Write-Verbose -Message ($localized.ExecutingNetsh -f $netshMessage);
            $netshOutput = & netsh advfirewall firewall show rule name=all profile="$profileString" verbose;
        }
        else {
            $netshMessage = 'advfirewall firewall show rule name=all verbose';
            Write-Verbose -Message ($localized.ExecutingNetsh -f $netshMessage);
            $netshOutput = & netsh advfirewall firewall show rule name=all verbose;
        }
        return ($netshOutput -split "`r`n");
    
    } #end process
} #end function Get-NetshFirewallRule
