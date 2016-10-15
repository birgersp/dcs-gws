@echo off

set output_dir=build
set sources=autogft\core.lua unit-types\unittypes.lua
set sources_standalone=%sources% mist\mist_4_3_74.lua
set include=example\example.lua unit-types\unittypes.lua
set build=%output_dir%\autogft.lua
set build_standalone=%output_dir%\autogft-standalone.lua

set comment_prefix=--

echo Time is %time%
if not exist %output_dir% md %output_dir%
rem set input=%sources%
rem set output=%build%
rem call:make
set input=%sources_standalone%
set output=%build_standalone%
call:make

for %%a in (%include%) do (
	echo Including %%a
	copy %%a %output_dir%
)

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
