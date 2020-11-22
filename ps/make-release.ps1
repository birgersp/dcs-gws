$examplesDir = "examples"
$archiveDir = "build-zip"
$versionFile = "version.txt"
$buildDir = "build"

$version = Get-Content -Path $versionFile
$archiveFile = "autogft-$($version).zip"
$examplesDestination = "$($buildDir)\examples"
$exampleMission="~\Saved Games\DCS\Missions\autogft-example.miz"

& .\ps\make.ps1
& .\ps\make-docs.ps1

$rootDir = Get-Location
$examplesDirFull = "$($rootDir)\$($examplesDir)"

[void]$outFileSB.Append("$($outFileWarning)`n")
[void]$outFileSB.Append("-- Version $($version)`n")
[void]$outFileSB.Append("-- Build $($date)`n")
[void]$experimentsSB.Append($outFileWarning)
[void]$examplesSB.Append($outFileWarning)

# Create examples dest dir
[void](New-Item -ItemType Directory -Path $examplesDestination -Force)

# Copy examples
$exampleFiles = Get-ChildItem $examplesDirFull *.lua
for ($i=0; $i -lt $exampleFiles.Count; $i++) {
	$filename = "$($examplesDir)\$($exampleFiles[$i])"
	Write-Host "Including $($filename)"
	Copy-Item $filename $examplesDestination -Force
	# Write-Host $filename
}

# Copy README
Copy-Item README.md $buildDir\README.txt -Force
Copy-Item $exampleMission $buildDir\example-$version.miz

# Create zip dir
[void](New-Item -ItemType Directory -Path $archiveDir -Force)
if (Test-Path $archiveDir\$archiveFile) {
	Remove-Item $archiveDir\$archiveFile
}
7z a .\$archiveDir\$archiveFile .\$buildDir\* .\$buildDir\docs\ .\$buildDir\examples\
