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

function Remove-DuplicateMembers {
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param (
        [System.String[]] $Members
    )
    process {

        Set-StrictMode -Version Latest

        $destIndex = 0;
        for([int] $sourceIndex = 0 ; $sourceIndex -lt $Members.Count; $sourceIndex++)
        {
            $matchFound = $false;
            for([int] $matchIndex = 0; $matchIndex -lt $destIndex; $matchIndex++)
            {
                if($Members[$sourceIndex] -eq $Members[$matchIndex])
                {
                    # A duplicate is found. Discard the duplicate.
                    Write-Verbose -Message ($localized.RemovingDuplicateMember -f $Members[$sourceIndex]);
                    $matchFound = $true;
                    continue;
                }
            }

            if(!$matchFound)
            {
                $Members[$destIndex++] = $Members[$sourceIndex].ToLowerInvariant();
            }
        }

        # Create the output array.
        $destination = New-Object -TypeName System.String[] -ArgumentList $destIndex;

        # Copy only distinct elements from the original array to the destination array.
        [System.Array]::Copy($Members, $destination, $destIndex);

        return $destination;
        
    } #end process

} #end function RemoveDuplicateMembers
