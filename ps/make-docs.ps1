[void](New-Item -ItemType Directory -Path build\docs\api -Force)
Remove-Item .\build\docs\api\*
Write-Host "Building docs"
ldcapp inDir=gws outDir=docs\api
