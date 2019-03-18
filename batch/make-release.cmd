@echo off

set /p version=<version.txt

set examples_dir=examples
set examples=^
 basic.lua^
 linked-bases.lua^
 miscellaneous.lua^
 random-units.lua^
 scanning.lua^
 staging.lua^
 using-roads.lua
set example_mission="%HOMEPATH%\Saved Games\DCS\Missions\autogft-example.miz"
set build_dir=build
set examples_destination=%build_dir%\examples
set archive_dir=build-zip
set archive_file=%archive_dir%\autogft-%version%.zip
set include=unit-types.txt

call make.cmd
call make-docs.cmd

set current_dir=%cd%
cd ..

for %%a in (%include%) do (
	echo Including %%a
	copy %%a %build_dir%
)

if not exist %examples_destination% md %examples_destination%
for %%a in (%examples%) do (
	echo Including %examples_dir%\%%a
	copy %examples_dir%\%%a %examples_destination%
)

copy README.md %build_dir%\README.txt
copy %example_mission% %build_dir%\example-%version%.miz

md %build_dir%\docs
copy docs %build_dir%\docs

if exist %archive_dir% (
	if exist %archive_file% del %archive_file%
) else md %archive_dir%
cd %build_dir%
7z a ..\%archive_file% *.* docs\ examples\
cd %current_dir%