[void](New-Item -ItemType Directory -Path build\docs -Force)
Remove-Item .\build\docs\api\*
Write-Host "Building docs"
ldcapp inDir=gws outDir=docs\api
