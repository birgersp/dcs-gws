@echo off

set sources=bajas\bajas.lua mist\mist_4_3_74.lua
set output_dir=build
set output=%output_dir%\bajas-standalone.lua
set comment_prefix=--

echo Writing to %output%
echo.

if not exist %output_dir% md %output_dir%

break>%output%
setlocal EnableDelayedExpansion
set first=1
for %%a in (%sources%) do (
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

echo.
echo Done