The LegacyNetworking module contains cmdlets and DSC resources for managing Windows 7 and Server 2008 R2 machines.
These resources can be used to manage basic settings networking settings with down-level operating systems.

###Included Cmdlets
* **Get-LegacyNetAdapater**
* **Get-LegacyNetAdapaterConfiguration**
* **Get-LegacyNetFirewallRule**: Retrieves existing firewall rule(s)
* **New-LegacyNetFirewallRule**: Creates a new firewall rule 
* **Remove-LegacyNetFirewallRule**: Removes an existing firewall rule
* **Set-LegacyNetFirewallRule**: Updates an existing firewall rule

###Included Resources
* **vDefaultGatewayAddress**: Configures the default gateway of a network adapter
* **vDNSServerAddress**: Configures the DNS server address(es) a network adapter.
* **vFirewall**: Manages a local firewall rule.
* **vIPAddress**: Manages local IP address assigned to a network adapter.

vDefaultGatewayAddress
======================
Configures the default gateway of a network adapter.
### Syntax
```powershell
vDefaultGatewayAddress [String] #ResourceName
{
    Address = [string]
    InterfaceAlias = [string]
    [ AddressFamily = [string] { IPv4 } ]
}
```

vDNSServerAddress
=================
Configures the DNS server address(es) a network adapter.
### Syntax
```powershell
vDNSServerAddress [String] #ResourceName
{
    Address = [string[]]
    InterfaceAlias = [string]
    [ AddressFamily = [string] { IPv4 } ]
}
```

vFirewall
=========
Manages a local firewall rule.
### SYNTAX
```powershell
vFirewall [String] #ResourceName
{
    DisplayName = [string]
    Action = [string] { Allow | Block | Bypass }
    Direction = [string] { Inbound | Outbound }
    Profile = [string[]] { Domain | Private | Public | Any }
    [ Description = [string] ]
    [ Enabled = [string] { False | True } ]
    [ Ensure = [string] { Absent | Present } ]
    [ LocalPort = [string[]] ]
    [ Program = [string] ]
    [ Protocol = [string] ]
    [ RemotePort = [string[]] ]
    [ Service = [string] ]
}
```

vFirewall
=========
Manages local IP address assigned to a network adapter.
### SYNTAX
```powershell
vIPAddress [String] #ResourceName
{
    InterfaceAlias = [string]
    IPAddress = [string]
    SubnetMask = [uint32]
    [ AddressFamily = [string] { IPv4 } ]
}
```