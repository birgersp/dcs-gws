@echo off

set archive_dir=build-zip
set archive_file=%archive_dir%\autogft.zip

call make.cmd

if exist %archive_dir% (
	if exist %archive_file% del %archive_file%
) else md %archive_dir%

cd build
7z a ..\%archive_file% *.*