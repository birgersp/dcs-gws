set example_mission="C:\Users\birge\Saved Games\DCS\Missions\autogft-example.miz"
set build_dir=build
set archive_dir=build-zip
set archive_file=%archive_dir%\autogft.zip

call make.cmd
call make-docs.cmd

copy README.md %build_dir%\README.txt

copy %example_mission% %build_dir%\example.miz

md %build_dir%\docs
copy docs %build_dir%\docs

if exist %archive_dir% (
	if exist %archive_file% del %archive_file%
) else md %archive_dir%
7z a ..\%archive_file% *.*