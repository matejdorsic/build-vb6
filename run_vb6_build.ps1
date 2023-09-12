# Get the arguments
$vbpprojectpath = $args[0]
$outdir = $args[1]

# Get the current directory
$curdir = Get-Location
$date = Get-Date -Format "yyyyMMddHHmmss"

$regexSuccess = "Build of .* succeeded."

#in case we got relative path to the project ,let's expand
$fullProjectPath = [System.IO.Path]::GetFullPath($vbpprojectpath)

#get projectName for build log file name construction
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($fullProjectPath)

#base path for build log file , then should come date suffix
$buildLogFile = "${curdir}\build_${projectName}_${date}.log"

Write-Host $vbpprojectpath
Write-Host $buildLogFile 

# Run VB6 /make with the given arguments
VB6 /make $vbpprojectpath /outdir $outdir /out $buildLogFile

#need to wait here a bit , as the file might not be ready ( powershell is soooo quick in Get-Content function :-D )
Start-Sleep -Milliseconds 1000

$log = Get-Content $buildLogFile | Select-Object -Unique  

if (Test-Path $buildLogFile) {
    # Remove-Item $buildLogFile -verbose
}

if ($log -match $regexSuccess){
    Write-Host "Build success"
    return 0
}
else  {
    Write-Host $log
    return 1
}
