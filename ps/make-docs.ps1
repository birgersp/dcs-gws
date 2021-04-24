[void](New-Item -ItemType Directory -Path build\docs -Force)
Remove-Item .\build\docs\api\*
Write-Host "Building docs"
ldcapp inDir=autogft outDir=docs\api
