function ConvertFrom-CIDR {
    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Uint32] $CIDR
    )
    ## Convert CIDR to netmask
    $int64 = ([System.Convert]::ToInt64(('1'*$CIDR + '0'*(32-$CIDR)), 2));
    return '{0}.{1}.{2}.{3}' -f ([System.Math]::Truncate($int64 / 16777216)).ToString(),
        ([System.Math]::Truncate(($int64 % 16777216) / 65536)).ToString(),
        ([System.Math]::Truncate(($int64 % 65536) / 256)).ToString(),
        ([System.Math]::Truncate($int64 % 256)).ToString();

} #end function ConvertFrom-CIDR
