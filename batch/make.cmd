@echo off

set sources=^
 autogft\class.lua^
 autogft\unitspec.lua^
 autogft\vector2.lua^
 autogft\vector3.lua^
 autogft\coordinate.lua^
 autogft\groupcommand.lua^
 autogft\groupintel.lua^
 autogft\iocev.lua^
 autogft\map.lua^
 autogft\observerintel.lua^
 autogft\reinforcer.lua^
 autogft\setup.lua^
 autogft\task.lua^
 autogft\taskforce.lua^
 autogft\taskgroup.lua^
 autogft\tasksequence.lua^
 autogft\unitcluster.lua^
 autogft\util.lua^
 autogft\waypoint.lua^
 unit-types\unit-types.lua

set output_dir=build
set load_all_file=tests\load-all.lua

set /p version=<version.txt
set build=%output_dir%\autogft-%version%.lua
set comment_prefix=--

set current_dir=%cd%
cd ..
set root_dir=%cd%

echo Time is %time%
if not exist %output_dir% md %output_dir%
echo Cleaning contents of "%output_dir%"
del /Q %output_dir%
rem set input=%sources%
rem set output=%build%
rem call:make
set input=%sources%
set output=%build%
call:make

cd %current_dir%
goto:eof

:make

	echo -- Auto-generated, do not edit>%load_all_file%

	echo Writing to %output%
	
	break>%output%
	setlocal EnableDelayedExpansion
	set first=1
	for %%a in (%input%) do (

		echo dofile^([[%root_dir%\%%a]]^)>>%load_all_file%

		echo Appending %%a
		if !first!==0 (
			echo.>> %output%
			echo.>> %output%
			echo.>> %output%
		)
	
		echo %comment_prefix%>>%output% %%a
		echo.>> %output%
		type %%a>>%output%
		
		set first=0
	)
	
	echo Done
goto:eof
