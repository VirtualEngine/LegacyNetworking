function Get-LegacyNetAdapter {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Management.ManagementObject])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.String] $Name,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.SwitchParameter] $Physical
    )

    $filters = @();;
    if ($PSBoundParameters.ContainsKey('Name')) {
        $filters += 'NetConnectionID = "{0}"' -f $Name;
    }
    if ($PSBoundParameters.ContainsKey('Physical')) {
        $filters += 'PhysicalAdapter = "{0}"' -f $Physical.ToString();
    }
    
    Write-Verbose -Message ($localized.QueryingWmiObjectClass -f 'Win32_NetworkAdapter');
    $wmiFilters = $filters -join ' AND ';
    if ([System.String]::IsNullOrEmpty($wmiFilters)) {
        return Get-WmiObject -Class Win32_NetworkAdapter;    
    }
    else {
        Write-Verbose -Message ($localized.ApplyingWmiQueryFilter -f $wmiFilters);
        return Get-WmiObject -Class Win32_NetworkAdapter -Filter $wmiFilters;
    }

} #end function Get-NetworkAdapter
