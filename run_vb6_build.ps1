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

$user = [Security.Principal.WindowsIdentity]::GetCurrent().Name

Write-Host "Running vb6 /make ${vbpprojectpath} /outdir ${outdir} /out ${buildLogFile} as ${user}"

# Run VB6 /make with the given arguments
try {

    VB6 /make $vbpprojectpath /outdir $outdir #/out $buildLogFile 

    if (Test-Path "c:\actions-runner\_work\MyVBApp\MyVBApp\DummyApp.exe"){
        Write-Host "Cool app is build"
        return 0
    }
    else{
        Write-Host "Sadly nothing is build"
    }
}
catch { 
    # Write-Error "Error running VB6 /make for some reason!!!"
    Write-Error $_.ScriptStackTrace
    return 2
}

#need to wait here a bit , as the file might not be ready ( powershell is soooo quick in Get-Content function :-D )
Start-Sleep -Milliseconds 1000

if(!(Test-Path $buildLogFile)){
    Write-Host "Build log does not exists"
    exit 0
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
