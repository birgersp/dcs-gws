@echo off

if not exist batch/%~nx0 (
	echo Error: This script must run from project root dir
	exit /b 2
)

set sources=^
 unit-types.lua^
 autogft\class.lua^
 autogft\unitspec.lua^
 autogft\vector2.lua^
 autogft\vector3.lua^
 autogft\coordinate.lua^
 autogft\groupcommand.lua^
 autogft\groupintel.lua^
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
 autogft\waypoint.lua

set examples=^
 examples\basic.lua^
 examples\miscellaneous.lua^
 examples\scanning.lua^
 examples\staging.lua^
 examples\using-roads.lua

set build_dir=build
set build_test_dir=build-test
set experiment_file=%build_test_dir%\load-experiment.lua
set examples_file=%build_test_dir%\load-examples.lua

set /p version=<version.txt
set build_file=%build_dir%\autogft-%version%.lua
set comment_prefix=--

set root_dir=%cd%

echo Time is %time%
if not exist %build_dir% md %build_dir%
echo Cleaning contents of "%build_dir%"
del /Q %build_dir%
if not exist %build_test_dir% md %build_test_dir%
set output="%build_file%"

set auto_generated_msg=-- Auto-generated, do not edit

echo %auto_generated_msg%>%experiment_file%
echo %auto_generated_msg%>%examples_file%
echo if not finished then>>%experiment_file%
echo if not finished then>>%examples_file%

echo Writing to %output%
break>%output%

setlocal EnableDelayedExpansion
set first=1
for %%a in (%sources%) do (

	echo dofile^([[%root_dir%\%%a]]^)>>%experiment_file%
	echo dofile^([[%root_dir%\%%a]]^)>>%examples_file%

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

echo dofile^([[%root_dir%\tests\experiment.lua]]^)>>%experiment_file%
echo if not keep_looping then finished=true end>>%experiment_file%
echo end>>%experiment_file%

for %%a in (%examples%) do (
	echo dofile^([[%root_dir%\%%a]]^)>>%examples_file%
)

echo finished=true>>%examples_file%
echo end>>%examples_file%

echo Done

cd %root_dir%
