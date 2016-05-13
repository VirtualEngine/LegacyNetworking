function Get-LegacyNetAdapterConfiguration {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([System.Management.ManagementObject])]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [System.String] $Name,
        
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Default')]
        [System.Management.Automation.SwitchParameter] $Physical,
        
        [Parameter(ValueFromPipeline, ParameterSetName = 'InputObject')]
        [System.Management.ManagementObject] $InputObject
    )
    
    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        $InputObject = Get-LegacyNetAdapter @PSBoundParameters;
    }
    
    if ($InputObject) {
        
        foreach ($networkAdapter in $InputObject) {
            
            Write-Verbose -Message ($localized.QueryingWmiObjectClass -f 'Win32_NetworkAdapterConfiguration');
            $wmiFilter = 'Index = "{0}"' -f $networkAdapter.DeviceID;
            Write-Verbose -Message ($localized.ApplyingWmiQueryFilter -f $wmiFilter);
            Write-Output -InputObject (Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter $wmiFilter);
            
        } #end foreach network adapter
        
    } #end if network adapters

} #end function Get-NetworkAdapter
