function Resolve-ProfileParameter {
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [Parameter(ValueFromPipelineByPropertyName)] [ValidateSet('Public','Private','Domain','Any')]
        [System.String[]] $Profile
    )
    process {
        $dedupedProfiles = Remove-DuplicateMembers -Members $Profile;
        
        if ($dedupedProfiles -contains 'Any') {
            ## If we have any specified, expand and return this
            return @('Domain','Private','Public');
        }
        else {
            ## Otherwise return the deduped profiles
            return $dedupedProfiles;
        }
        
    } #end process
} #end function Resolve-ProfileParameter
