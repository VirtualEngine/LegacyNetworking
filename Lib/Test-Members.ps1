<#

    The MIT License (MIT)

    Copyright (c) 2015 Microsoft Corporation.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.

#>

function Test-Members {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        ## Existing array members
        [AllowNull()]
        [System.String[]] $ExistingMembers,
        
        ## Explicit array members
        [AllowNull()]
        [System.String[]] $Members
    )
    process {
        Write-Verbose -Message ($localized.CheckingArrayMembers -f $ExistingMembers.Count);
        if ($PSBoundParameters.ContainsKey('Members')) {
            if ($null -eq $Members) {
                $Members = @();    
            }
            $Members = [System.String[]] @(Remove-DuplicateMembers -Members $Members);
            if ($ExistingMembers.Count -ne $Members.Count)
            {
                Write-Verbose -Message ($localized.MembershipCountMismatch -f $Members.Count, $ExistingMembers.Count);
                Write-Verbose -Message ("1: $($members.Count) $($ExistingMembers.Count)")                
                return $false;
            }

            foreach ($member in $Members)
            {
                if ($member -notin $ExistingMembers)
                {
                    Write-Verbose -Message ($localized.MemberNotInDesiredState -f $member);;
                    Write-Verbose -Message ("2: $member")
                    return $false;
                }
            }
        } #end if $Members

        Write-Verbose -Message $localized.MembershipInDesiredState;
        return $true;
        
    } #end process

} #end function Test-Membership
