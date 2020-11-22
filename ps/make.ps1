$srcDir = "autogft"
$buildDir = "build"
$versionFile = "version.txt"
$projectName = "autogft"
$buildTestDir = "build-test"
$experimentFile = "load-experiment.lua"
$examplesFile = "load-examples.lua"

function Write-File {
	param (
		$DirName,
		$FileName,
		$Data
	)
	$outFile = "$DirName\$FileName"
	[void](New-Item -ItemType Directory -Path $DirName -Force)
	Write-Host "Writing to $($outFile)"
	Set-Content $outFile $Data
}

$date = Get-Date
$rootDir = Get-Location
$srcDirFull = "$($rootDir)\$($srcDir)"
$outFileWarning = "-- Auto-generated, do not edit"

$version = Get-Content -Path $versionFile
Write-Host "Building version $($version) $date"
$files = Get-ChildItem $srcDir *.lua
$outFileSB = [System.Text.StringBuilder]::new()
$examplesSB = [System.Text.StringBuilder]::new()
$experimentsSB = [System.Text.StringBuilder]::new()

[void]$outFileSB.Append("$($outFileWarning)`n")
[void]$outFileSB.Append("-- Version $($version)`n")
[void]$outFileSB.Append("-- Build $($date)`n")
[void]$experimentsSB.Append($outFileWarning)
[void]$examplesSB.Append($outFileWarning)

function Add-Src {
	param (
		[string]$fileName,
		[System.Text.StringBuilder]$destination
	)
	Write-Host "Including $filename"
	$data = Get-Content -Path "$filename" -Raw
	[void]$destination.Append("`n")
	[void]$destination.Append("-- $($fileName)`n")
	[void]$destination.Append("$($data)")
}

Add-Src "unit-types\unit-types.lua" $outFileSB

for ($i=0; $i -lt $files.Count; $i++) {
	$filename = $files[$i]
	Add-Src $srcDir\$filename $outFileSB
	[void]$experimentsSB.Append("dofile($($srcDirFull)\$($filename))`n")
	[void]$examplesSB.Append("dofile($($srcDirFull)\$($filename))`n")
}

$buildFilename = "$($projectName)-$($version).lua"
Write-File $buildDir $buildFilename $outFileSB.ToString()
Write-File $buildTestDir $experimentFile $experimentsSB.ToString()
Write-File $buildTestDir $examplesFile $examplesSB.ToString()
