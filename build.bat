
@echo off
chcp 65001

if "%1" == "copy" (
    goto :end
)

call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x86

REM cd /d D:\repo\pvztoolkit
cd /d %~dp0

set INCLUDE=.\fltk\include;%INCLUDE%
set LIB=.\fltk\lib;%LIB%

set INCLUDE=.\zlib\include;%INCLUDE%
set LIB=.\zlib\lib;%LIB%

set INCLUDE=.\lua\include;%INCLUDE%
set LIB=.\lua\lib;%LIB%

if "%1" == "server" (
    goto :server
)


if NOT "%1" == "debug" (
    goto :release
)

:server
cl.exe /LD .\server\server.cpp ws2_32.lib /std:c++20 /EHsc /Feout\server.dll /Fo./out/
goto :end

:debug
if exist .\out\pvztoolkitd.exe del .\out\pvztoolkitd.exe

nmake -f makefile.debug

if not exist .\out\pvztoolkitd.exe goto :end

mt.exe -nologo ^
-manifest ".\res\ptk.manifest" ^
-outputresource:".\out\pvztoolkitd.exe;#1"
goto :end

:release
echo "release build"
nmake -f makefile.release clean
nmake -f makefile.release

if not exist .\out\pvztoolkit.exe goto :end

mt.exe -nologo ^
-manifest ".\res\ptk.manifest" ^
-outputresource:".\out\pvztoolkit.exe;#1"

goto :end

file="PvZ_Toolkit_v1.20.3.exe"
rm $file.hash
echo $file >> $file.hash
echo "MD5" >> $file.hash
md5sum $file | cut -d" " -f1 | tr [a-z] [A-Z] >> $file.hash
echo "SHA-1" >> $file.hash
sha1sum $file | cut -d" " -f1 | tr [a-z] [A-Z] >> $file.hash
echo "SHA-256" >> $file.hash
sha256sum $file | cut -d" " -f1 | tr [a-z] [A-Z] >> $file.hash
echo "SHA-512" >> $file.hash
sha512sum $file | cut -d" " -f1 | tr [a-z] [A-Z] >> $file.hash

gpg --armor --detach-sign $file
gpg --verify $file.asc $file

:end

copy /y bin\splash.png .\out
copy /y bin\lineup.yml .\out
copy /y bin\builds.yml .\out
copy /y bin\server.dll .\out

xcopy /y /i /e .\bin\script .\out\script
