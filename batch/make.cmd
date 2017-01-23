@echo off

set sources= ^
autogft\core.lua ^
autogft\class.lua ^
autogft\controlzone.lua ^
autogft\group.lua ^
autogft\groupcommand.lua ^
autogft\task.lua ^
autogft\taskforce.lua ^
autogft\unitcluster.lua ^
autogft\unitspec.lua ^
autogft\vector3.lua ^
autogft\waypoint.lua ^
unit-types\unit-types.lua

set /p version=<version.txt

set output_dir=build
set sources_standalone=%sources% mist\mist_4_3_74.lua

set build=%output_dir%\autogft-%version%.lua
set build_standalone=%output_dir%\autogft-%version%-standalone.lua
set comment_prefix=--

set current_dir=%cd%
cd ..
echo Time is %time%
if not exist %output_dir% md %output_dir%
echo Cleaning contents of "%output_dir%"
del /Q %output_dir%
rem set input=%sources%
rem set output=%build%
rem call:make
set input=%sources_standalone%
set output=%build_standalone%
call:make

cd %current_dir%
goto:eof

:make
	echo Writing to %output%
	
	break>%output%
	setlocal EnableDelayedExpansion
	set first=1
	for %%a in (%input%) do (
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
