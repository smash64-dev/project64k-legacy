copy %1 temp.z64
ucon64.exe --z64  temp.z64
xdelta3.exe -d -s temp.z64 "19XXTE Smashville Beta.xdelta" "19XXTE Smashville Beta.z64"
del temp.bak
del temp.z64