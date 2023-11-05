$fileId = "1Wuko3rkpL9TtOXTSIVmZ3tFHYFQs2sxf"
$exportUrl = "https://drive.google.com/uc?export=download&id=$fileId"

Invoke-WebRequest -Uri $exportUrl -OutFile "log_file.txt"

$inputFile = "log_file.txt"
$outputFile = "audit_rpt.txt"
$desktopPath = [Environment]::GetFolderPath("Desktop")

$blacklistPattern = "173.255.170.15"
$sqlInjectionPattern = "UNION|SELECT|' OR 1=1|DROP TABLE"

$outputLines = @()

$fileContent = Get-Content -Path $inputFile

if ($fileContent -ne $null) {
    $lineNumber = 1
    foreach ($line in $fileContent) {
        $lineFormatted = ""
        if ($line -match $blacklistPattern) {
            $lineFormatted = "Line: $lineNumber, bad IP found $blacklistPattern"
            $outputLines += $lineFormatted
        }
        if ($line -match $sqlInjectionPattern) {
            $lineFormatted = "Line: $lineNumber, SQL Injection attempt found $line"
            $outputLines += $lineFormatted
        }
        $lineNumber++
    }

    $outputLines | Out-File -FilePath $outputFile

    Move-Item -Path $outputFile -Destination (Join-Path -Path $PSScriptRoot -ChildPath $outputFile)
} else {
    Write-Host "The input file is empty or does not exist."
}

$zipPath = Join-Path -Path $desktopPath -ChildPath "processed_log.zip"
Compress-Archive -Path $inputFile, $outputFile -DestinationPath $zipPath