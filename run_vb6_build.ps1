# Get the arguments
$vbpprojectpath = $args[0]
$outdir = $args[1]
$logdir = $args[2]

# Get the current directory
if (!$logdir){
    $curdir = Get-Location
}
else{
    $curdir = $logdir
}
$date = Get-Date -Format "yyyyMMddHHmmss"

$regexSuccess = "Build of .* succeeded."

#in case we got relative path to the project ,let's expand
$fullProjectPath = [System.IO.Path]::GetFullPath($vbpprojectpath)

#get projectName for build log file name construction
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($fullProjectPath)

#base path for build log file , then should come date suffix
$buildLogFile = "${curdir}\build_${projectName}_${date}.log"

Write-Host "Running script for building VB project"

$currentDir = Get-Location

Write-Host $vbpprojectpath
Write-Host $buildLogFile 
Write-Host $currentDir

# Run VB6 /make with the given arguments
try {
    VB6 /make $vbpprojectpath /outdir $outdir #/out $buildLogFile 
    VB6 /?

}
catch { 
    # Write-Error "Error running VB6 /make for some reason!!!"
    Write-Error $_.ScriptStackTrace
    return 2
}

#need to wait here a bit , as the file might not be ready ( powershell is soooo quick in Get-Content function :-D )
Start-Sleep -Milliseconds 1000

if(!(Test-Path $buildLogFile)){
    return 3
}

$log = Get-Content $buildLogFile | Select-Object -Unique  

if (Test-Path $buildLogFile) {
    # Remove-Item $buildLogFile -verbose
}

if ($log -match $regexSuccess){
    Write-Output "Build success"
    return 0
}
else  {
    Write-Error $log
    return 1
}
