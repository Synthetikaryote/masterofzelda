7za a -r -tzip masterofzelda.love *.* -xr!*.love -xr!*.bat -xr!*.exe
copy /b "C:\tools\love\love.exe"+masterofzelda.love masterofzelda.exe
masterofzelda
"C:\tools\love\love.exe" masterofzelda.love
pause