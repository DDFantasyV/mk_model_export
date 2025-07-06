@echo off
setlocal enabledelayedexpansion

for %%i in ("%~dp0.") do set "parent_dir=%%~fi"
set "inputFolder=%parent_dir%\input"
set "outputFolder=%parent_dir%\output"
set "fixFolder=%parent_dir%\fix"
set "resultFolder=%parent_dir%\result"

rd /s /q "%resultFolder%"

md "%outputFolder%"
md "%fixFolder%"
md "%resultFolder%"


set /p "newname=Warship Part Name(e.g. FSB031_Flandre_1952_Bow):"

echo Step 1: Running Geometrypack_old
%parent_dir%\geometrypack_old\geometrypack.exe --verbose --tree %inputFolder% %outputFolder%


echo Step 2: Running Geometrypack
%parent_dir%\geometrypack\geometrypack.exe --verbose --tree --update-content %outputFolder% %fixFolder%


echo Step 3: Processing Model Files
move /y "%inputFolder%\*" "%resultFolder%" >nul
move /y "%fixFolder%\output\input\*" "%resultFolder%" >nul

for %%e in (temp_model primitives) do (
    for /f "delims=" %%f in ('dir /s /b %resultFolder%\*.%%e 2^>nul') do (
        del /f /q "%%f"
    )
)


echo Step 4: Editing *.visual Files
set "temp_file=%resultFolder%\%~nx0.tmp"

for /r "%resultFolder%" %%F in (*.visual) do (
    set "filename=%%~nF"
)

(
    for /f "usebackq delims=" %%a in ("%resultFolder%\%filename%.visual") do (
        set "line=%%a"
        set "line=!line:shape</node>=</node>!"
        set "line=!line:%filename%=%newname%!"
        echo !line!
    )
) > "%temp_file%"

move /y "%temp_file%" "%resultFolder%\%filename%.visual" >nul


echo Step 5: Renaming Files and Creating lods Folder
ren "%resultFolder%\%filename%.visual" "%newname%.visual"
ren "%resultFolder%\%filename%.geometry" "%newname%.geometry"

set "lodsFolder=%resultFolder%\lods"
md "%lodsFolder%"
copy "%resultFolder%\%newname%.visual" "%lodsFolder%\%newname%_lod1.visual" >nul
copy "%resultFolder%\%newname%.visual" "%lodsFolder%\%newname%_lod2.visual" >nul
copy "%resultFolder%\%newname%.visual" "%lodsFolder%\%newname%_lod3.visual" >nul

echo Step 6: Cleaning Temp Folders and Files
rd /s /q "%outputFolder%"
rd /s /q "%fixFolder%"

echo Finished!
pause
