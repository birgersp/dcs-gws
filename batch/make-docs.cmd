rem remove this once a new lua documentor is ready
echo Skipping doc generator
exit /b 2

set current_dir=%cd%
cd ..
del /Q docs\*
call luadocumentor.bat autogft
cd %current_dir%
