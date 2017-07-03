@echo off &setlocal enableextensions disabledelayedexpansion
set "@dialog=1"           || :gui_choices_wait 
set "@timers=1"           || :measure_run      
set "MOD_DIR=MOD"         || :work_folder      
goto :Batch_Main                               
```js
  // AveYo: manual filters to suppliment the autogenerated ones by the No_Bling JS function - moved on top, for convenience    
  var NULL_VPCF='particles/error/null.vpcf', ADD_HAT={}, REM_HAT={}, ADD_HERO={}, REM_HERO={}, EXCLUDE={}, KEEP={};
  // :WARNING! Don't touch before understanding the No_Bling function; comments with !!! means critical - expect glitches if removed
```
title No-Bling DOTA mod builder by AveYo - version 1.0 &call :set_window 0 7 120 40 ||:i Bg Fg Cols Lines                     
setlocal
call set "ps_colors=%c:"=\"%%l:"=\"%%r:"=\"%%s:"=\"%"    ||:ex: powershell -c "%ps_colors%; : fc Hello; : _c ' fancy '; : cf. World" 
:: this method can be way faster for drawing many colors in one go, but is way slower than repeated :colors calls with single color
endlocal &set "ps_colors=%ps_colors%"                                                                                            

