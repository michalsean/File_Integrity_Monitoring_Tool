# FileCollector.ps1
# File Integrity Monitoring
# Reference: Malware Analysis Lectures

function Get-FileHashes {
    param (
        [Parameter(Mandatory=$true)]
        [string]$TargetPath
    )

    # 1. Cmdlets & Pipelines: Get items in target path
    # 2. Filtering: Only check common binary extensions e.g .exe
    $files = Get-ChildItem -Path $TargetPath -File | Where-Object { $_.Extension -match ".exe|.dll|.bat" }

    $results = foreach ($f in $files) {
        # 3. Cmdlet: Generate SHA256 Hash for integrity check
        $hashObj = Get-FileHash -Path $f.FullName -Algorithm SHA256
        
        # 4. Building structured data
        [PSCustomObject]@{
            FileName  = $f.Name
            FilePath  = $f.FullName
            Hash      = $hashObj.Hash
            LastModified = $f.LastWriteTime
        }
    }

    # 5. Output: Sorting mod time and converting to JSON for Py
    return $results | Sort-Object LastModified -Descending
}

# Parameters: Call function with target directory
$data = Get-FileHashes -TargetPath "C:\PATH\TO\DUMMY\FILES" #Path of Files

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$OutputFilePath = Join-Path -Path $ScriptDir -ChildPath "hashes.json" 
$data | ConvertTo-Json -Depth 10 | Out-File $OutputFilePath -Encoding utf8
Write-Host "Data saved to $OutputFilePath"
