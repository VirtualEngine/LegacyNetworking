ConvertFrom-StringData -StringData @'
    CheckingArrayMembers           = Checking array for '{0}' members.
    MembershipCountMismatch        = Array membership count is not correct. Expected '{0}' members, actual '{1}' members.
    MemberNotInDesiredState        = Array member '{0}' is not in the desired state.
    RemovingDuplicateMember        = Removing duplicate array member '{0}' definition.
    MembershipInDesiredState       = Array membership is in the desired state.
    MembershipNotDesiredState      = Array membership is NOT in the desired state.
    ExecutingNetsh                 = Executing: 'NETSH.EXE {0}'.
    QueryingWmiObjectClass         = Querying WMI oject class '{0}'.
    ApplyingWmiQueryFilter         = Applying WMI query filter '{0}'.
    
    GettingGatewayAddress          = Getting the default gateway address for network adapter '{0}'.
    SettingGatewayAddress          = Setting default gateway address '{0}' for network adapter '{1}'.
    GettingDnsServerAddress        = Getting DNS server addresses for network adapter '{0}'.
    SettingDnsServerAddress        = Setting DNS server addresses '{0}' for network adapter '{1}'.
    GettingIPAddress               = Getting the IP address for network adapter '{0}'.
    SettingIPAddress               = Setting IP address '{0}' for network adapter '{1}'.
    IPAddressDoesNotMatch          = IPAddress does not match desired state. Expected '{0}', actual '{1}'.
    ResourcePropertyMismatch       = Property '{0}' does not match the desired state; expected '{1}', actual '{2}'.
    ResourceInDesiredState         = Resource '{0}' is in the desired state.
    ResourceNotInDesiredState      = Resource '{0}' is NOT in the desired state.
'@
