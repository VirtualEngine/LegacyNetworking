function ConvertTo-CIDR {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.String] $SubnetMask
    )

    $SubnetMask -split '\.' | ForEach-Object { $subnet = $subnet * 256 + [System.Convert]::ToInt64($_); }
    return [System.Convert]::ToString($subnet, 2).IndexOf('0');

} #end function ConvertTo-CIDR
