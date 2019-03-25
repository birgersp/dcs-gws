set current_dir=%cd%
cd ..
del /Q docs\*
call luadocumentor.bat autogft
cd %current_dir%
