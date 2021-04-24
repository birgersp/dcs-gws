$srcDir = "gws"
$buildDir = "build"
$versionFile = "version.txt"
$projectName = "gws"
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
$files = @(
	"unit-types\unit-types.lua",
	"gws\class.lua",
	"gws\unitspec.lua",
	"gws\vector2.lua",
	"gws\vector3.lua",
	"gws\coordinate.lua",
	"gws\groupcommand.lua",
	"gws\groupintel.lua",
	"gws\map.lua",
	"gws\informedgroup.lua",
	"gws\intel.lua",
	"gws\reinforcer.lua",
	"gws\setupbase.lua",
	"gws\setup.lua",
	"gws\task.lua",
	"gws\taskforce.lua",
	"gws\taskgroup.lua",
	"gws\tasksequence.lua",
	"gws\unitcluster.lua",
	"gws\util.lua",
	"gws\waypoint.lua"
)
$outFileSB = [System.Text.StringBuilder]::new()
$examplesSB = [System.Text.StringBuilder]::new()
$experimentsSB = [System.Text.StringBuilder]::new()

[void]$outFileSB.Append("$($outFileWarning)`n")
[void]$outFileSB.Append("-- Version $($version)`n")
[void]$outFileSB.Append("-- Build $($date)`n")
[void]$experimentsSB.Append("$($outFileWarning)`n")
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
	Add-Src $filename $outFileSB
	[void]$experimentsSB.Append("dofile([[$($rootDir)\$($filename)]])`n")
	[void]$examplesSB.Append("dofile([[$($rootDir)\$($filename)]])`n")
}
[void]$experimentsSB.Append("dofile([[$($rootDir)\tests\experiment.lua]])`n")

$buildFilename = "$($projectName)-$($version).lua"
Write-File $buildDir $buildFilename $outFileSB.ToString()
Write-File $buildTestDir $experimentFile $experimentsSB.ToString()
Write-File $buildTestDir $examplesFile $examplesSB.ToString()
