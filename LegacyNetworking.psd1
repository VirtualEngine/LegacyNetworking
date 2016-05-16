@{
    RootModule = 'LegacyNetworking.psm1';
    ModuleVersion = '1.0.1';
    GUID = 'e6d3bd31-ae43-47ab-8a14-e3b8d85a2d2b';
    Author = 'Iain Brighton';
    CompanyName = 'Virtual Engine';
    Copyright = '(c) 2016 Virtual Engine Limited. All rights reserved.';
    Description = 'Module with resources for legacy (Windows 7 and Server 2008 R2) networking via WMI.';
    PowerShellVersion = '3.0';
    FunctionsToExport = @('Get-LegacyNetFirewallRule','New-LegacyNetFirewallRule','Remove-LegacyNetFirewallRule','Set-LegacyNetFirewallRule'
                            'Get-LegacyNetAdapter', 'Get-LegacyNetAdapterConfiguration');
    DscResourcesToExport = @('vDefaultGatewayAddress', 'vDNSServerAddress', 'vFirewall', 'vIPAddress');
    PrivateData = @{
        PSData = @{  # Private data to pass to the module specified in RootModule/ModuleToProcess
            Tags = @('VirtualEngine','Legacy','DSC','Networking','Firewall');
            LicenseUri = 'https://raw.githubusercontent.com/VirtualEngine/LegacyNetworking/master/LICENSE';
            ProjectUri = 'https://github.com/VirtualEngine/LegacyNetworking';
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}
