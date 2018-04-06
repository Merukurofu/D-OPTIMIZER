@set @v=3 /*
@echo off &set "arg1=%1" &set "arg2=%2" &color 07 &title DOTA primary mm language override by AveYo v%@v:/*=%
echo.
echo      ---------------------------------------------------------------------
echo     :     DOTA primary MM language override with distinct UI language     :
echo     :---------------------------------------------------------------------:
echo     : Can have Steam in German, Dota in Russian and MM queue for SChinese :
echo     :                                                                     :
echo     : WARNING! Steam must be closed so that launch options could be added :
echo      ---------------------------------------------------------------------
timeout /t 10
echo.
:: Detect default steam language to use as UI suggestion
call :reg_query "HKCU\SOFTWARE\Valve\Steam" "Language" steam_language
if defined steam_language set "ui_language=%STEAM_LANGUAGE%"
if not defined ui_language set "ui_language=english"
:: Change default MM suggestion below:
set "mm_language=schinese"
:: Allow overriding both via command line arguments
if defined arg1 set "mm_language=%~1"
if defined arg2 set "ui_language=%~2"
:: Set available languages
set "lang=brazilian bulgarian czech danish dutch english finnish french german greek hungarian italian japanese korean koreana"
set "lang=%lang% norwegian polish portuguese romanian russian schinese spanish swedish tchinese thai turkish ukrainian"
set "mm_override=" & set "ui_override=" & set "mm_lang_found=" & set "ui_lang_found="
:: Prompt and process MM language choice
if not defined arg1 echo Will override primary MM language with: %mm_language%
if not defined arg1 set/p "mm_override=Enter new choice, or press Enter to use %mm_language%: "
if defined mm_override set "mm_language=%mm_override%"
for /f "delims=" %%a in ('cscript //E:JScript //nologo "%~f0" LOCase %mm_language%') do set "mm_language=%%a"
for %%s in (%lang%) do if /i "%%s"=="%mm_language%" set "mm_lang_found=y"
if not defined mm_lang_found call :end ! Can't use '%mm_override%' MM language
if /i "%mm_language%"=="english" ( set "primary=English" ) else set "primary=%mm_language%"
echo.
:: Prompt and process UI language choice
if not defined arg2 echo Will override UI language with: %ui_language%
if not defined arg2 set/p "ui_override=Enter new choice, or press Enter to use %ui_language%: "
if defined ui_override set "ui_language=%ui_override%"
for /f "delims=" %%a in ('cscript //E:JScript //nologo "%~f0" LOCase %ui_language%') do set "ui_language=%%a"
for %%s in (%lang%) do if /i "%%s"=="%ui_language%" set "ui_lang_found=y"
if not defined ui_lang_found call :end ! Can't use '%ui_override%' UI language
if /i "%ui_language%"=="english" ( set "secondary=English" ) else set "secondary=%ui_language%"
echo.
:: Set mod directory and launch options
set "mod_language=%ui_language%"
set "mod_options=-language %ui_language%,-textlanguage %mm_language%,+cl_language %ui_language%"
if /i "%ui_language%"=="english" set "mod_language=english%%"
if /i "%ui_language%"=="english" set "mod_options=-language english%%,-textlanguage %mm_language%,+cl_language english"
:: Kill Dota and Steam
taskkill /im dota2.exe /t /f >nul 2>nul 
taskkill /im Steam.exe /t /f >nul 2>nul & timeout /t 1 >nul & del /f /q "%STEAMPATH%\.crash" >nul 2>nul & timeout /t 1 >nul
echo Adding localization redirection for MM: %mm_language% and UI: %ui_language% &rem stun bars still remain in primary mm language
call :set_steam
call :set_dota
set "panorama_src=%DOTA%\dota\panorama\localization"
set "panorama_dst=%DOTA%\dota_%mod_language%\panorama\localization"
set "core_resource_src=%DOTA%\core\resource"
set "resource_src=%DOTA%\dota\resource"
set "resource_dst=%DOTA%\dota_%mod_language%\resource"
:: Process Panorama localization
echo Creating "dota_%mm_language%.txt" in %panorama_dst%
( del /f/s/q "%panorama_dst%" & rmdir /s/q "%panorama_dst%" & mkdir "%panorama_dst%" ) >nul 2>nul
copy /y "%panorama_src%\dota_%ui_language%.txt" "%panorama_dst%\dota_%mm_language%.txt" >nul 2>nul
:: Process Resource localization
( del /f/s/q "%resource_dst%" & rmdir /s/q "%resource_dst%" & mkdir "%resource_dst%" ) >nul 2>nul
set "files_dota=items dota gameui chat broadcastfacts hero_chat_wheel"
for %%B in (%files_dota%) do copy /y "%resource_src%\%%B_%ui_language%.txt" "%resource_dst%\%%B_%mm_language%.txt" >nul 2>nul
set "files_core=valve vgui keybindings"
for %%B in (%files_core%) do copy /y "%core_resource_src%\%%B_%ui_language%.txt" "%resource_dst%\%%B_%mm_language%.txt" >nul 2>nul
:: Adjust "Language" "English" in Resource localization files
pushd "%resource_dst%"
cscript //E:JScript //nologo "%~f0" Dota_ResValue "Language" "%primary%" 
:: Add launch options to change mm language but keep user interface in selected ui language (english by default)
echo Adding launch options: %mod_options:,= %
if not defined STEAMDATA echo ERROR! User profile not found, cannot add options & goto :done
pushd "%STEAMDATA%\config" & copy /y localconfig.vdf localconfig.vdf.bak >nul
cscript //E:JScript //nologo "%~f0"  Dota_LOptions "localconfig.vdf" "-language x,-textlanguage x,+cl_language x" -remove
cscript //E:JScript //nologo "%~f0"  Dota_LOptions "localconfig.vdf" "%mod_options%" -add
:done
:: [Optional] Restart Steam with fast options
rem set l1=-silent -console -forceservice -windowed -nobigpicture -nointro -vrdisable -single_core -no-dwrite -tcp
rem set l2=-inhibitbootstrap -nobootstrapperupdate -nodircheck -norepairfiles -noverifyfiles -nocrashmonitor -noassert
rem start "Steam" "%STEAMPATH%\Steam.exe" %l1% %l2%
:: Done!
call :end Done
exit/b

::----------------------------------------------------------------------------------------------------------------------------------
:: Utility functions
::----------------------------------------------------------------------------------------------------------------------------------
:set_steam outputs %STEAMPATH% %STEAMDATA% %STEAMID%
set "STEAMPATH=D:\Steam"                                                            &rem AveYo:" Override detection here if needed "
if not exist "%STEAMPATH%\Steam.exe" call :reg_query "HKCU\SOFTWARE\Valve\Steam" "SteamPath" STEAMPATH
set "STEAMDATA=" & if defined STEAMPATH for %%# in ("%STEAMPATH:/=\%") do set "STEAMPATH=%%~dpnx#"    &rem  / pathsep on Windows lul
if not exist "%STEAMPATH%\Steam.exe" call :end ! Cannot find SteamPath in registry
call :reg_query "HKCU\SOFTWARE\Valve\Steam\ActiveProcess" "ActiveUser" ACTIVEUSER & set/a "STEAMID=ACTIVEUSER" >nul 2>nul
if exist "%STEAMPATH%\userdata\%STEAMID%\config\localconfig.vdf" set "STEAMDATA=%STEAMPATH%\userdata\%STEAMID%"
if not defined STEAMDATA for /f "delims=" %%# in ('dir "%STEAMPATH%\userdata" /b/o:d/t:w/s 2^>nul') do set "ACTIVEUSER=%%~dp#"
if not defined STEAMDATA for /f "delims=\" %%# in ("%ACTIVEUSER:*\userdata\=%") do set "STEAMID=%%#"
if exist "%STEAMPATH%\userdata\%STEAMID%\config\localconfig.vdf" set "STEAMDATA=%STEAMPATH%\userdata\%STEAMID%"
exit/b

:set_dota outputs %STEAMAPPS% %DOTA% %CONTENT%
set "DOTA=D:\Games\steamapps\common\dota 2 beta\game"                               &rem AveYo:" Override detection here if needed "
if exist "%DOTA%\dota\maps\dota.vpk" set "STEAMAPPS=%DOTA:\common\dota 2 beta=%" & exit/b
set "libfilter=LibraryFolders { TimeNextStatsReport ContentStatsID }"
if not exist "%STEAMPATH%\SteamApps\libraryfolders.vdf" call :end ! Cannot find "%STEAMPATH%\SteamApps\libraryfolders.vdf"
for /f usebackq^ delims^=^"^ tokens^=4 %%s in (`findstr /v "%libfilter%" "%STEAMPATH%\SteamApps\libraryfolders.vdf"`) do (
 if exist "%%s\steamapps\appmanifest_570.acf" if exist "%%s\steamapps\common\dota 2 beta\game\dota\maps\dota.vpk" set "libfs=%%s" )
set "STEAMAPPS=%STEAMPATH%\steamapps" & if defined libfs set "STEAMAPPS=%libfs:\\=\%\steamapps"
if not exist "%STEAMAPPS%\common\dota 2 beta\game\dota\maps\dota.vpk" call :end ! Cannot find "%STEAMAPPS%\common\dota 2 beta\game"
set "DOTA=%STEAMAPPS%\common\dota 2 beta\game" & set "CONTENT=%STEAMAPPS%\common\dota 2 beta\content"
exit/b

:reg_query %1:KeyName %2:ValueName %3:OutputVariable %4:other_options[example: "/t REG_DWORD"]
setlocal & for /f "skip=2 delims=" %%s in ('reg query "%~1" /v "%~2" /z 2^>nul') do set "rq=%%s" & call set "rv=%%rq:*)    =%%"
endlocal & call set "%~3=%rv%" & exit/b                          &rem AveYo - Usage:" call :reg_query "HKCU\MyKey" "MyValue" MyVar "

:end %1:Message[Delayed termination with status message - prefix with ! to signal failure]
echo. & if "%~1"=="!" ( color 0c & echo ERROR! %* & pause & exit ) else echo INFO: %* & pause & exit

rem End of batch code */
//----------------------------------------------------------------------------------------------------------------------------------
// Utility JS functions - callable independently
//----------------------------------------------------------------------------------------------------------------------------------
//apps=getKeYpath(parsed,"UserLocalConfigStore/Software/Valve/Steam/Apps");
function getKeYpath(obj,kp){
  var test=kp.split("/");
  var out=obj;
  for (var i=0;i<test.length;i++) {
    for (var KeY in out) {
      if (out.hasOwnProperty(KeY) && (KeY+"").toLowerCase()==(test[i]+"").toLowerCase()) {out=out[KeY]; /*w.echo("found "+KeY);*/}
    }
  }
  return out;
}
Dota_LOptions=function(fn, options, _flag){
  // fn:localconfig.vdf    options:separated by ,    _flag: -read=print -remove=delete -add=default if ommited
  var regs={}, lo=options.split(","), i=0,n=lo.length;
  for (i=0;i<n;i++){
    regs[lo[i]]=new RegExp('(' + lo[i].split(" ")[0].replace(/([-+])/,"\\$1")+((lo[i].indexOf(' ')==-1) ? ')' : ' [\\w%]+)'),'gi');
  }
  var flag=_flag || '-add', file=path.normalize(fn), data=fs.readFileSync(file, DEF_ENCODING);
  var vdf=ValveDataFormat(), parsed=vdf.parse(data), apps=getKeYpath(parsed,"UserLocalConfigStore/Software/Valve/Steam/Apps");
  var dota=apps[vdf.nr('570')];                              // added getKeYpath function to fix inconsistent key case used by Valve
  if (flag == '-read'){ w.echo(dota["LaunchOptions"]); return; }                           // print existing launch options and exit
  if (typeof dota["LaunchOptions"] === 'undefined' || dota["LaunchOptions"] === ''){
    dota["LaunchOptions"]=(flag != '-remove') ? lo.join(" ") : "";                             // no launch options defined, add all
  } else {
    for (i=0;i<n;i++){
      if (lo[i] !== ''){
        if (regs[lo[i]].test(dota["LaunchOptions"])){
          if (flag == '-remove') dota["LaunchOptions"]=dota["LaunchOptions"].replace(regs[lo[i]], '');// found existing, delete 1by1
          else dota["LaunchOptions"]=dota["LaunchOptions"].replace(regs[lo[i]], lo[i]);              // found existing, replace 1by1
        } else {
          if (flag != '-remove') dota["LaunchOptions"]+=' '+lo[i];                                   // not found existing, add 1by1
        }
      }
    }
  }
  dota["LaunchOptions"]=dota["LaunchOptions"].replace(/\s\s+/g, ' ');                     // replace multiple spaces between options
  fs.writeFileSync(fn, vdf.stringify(parsed,true), DEF_ENCODING);                    // update fn if flag is -add -remove or ommited
};
Dota_ResValue=function(file, res, value){
  var data='', magic='\"lang\"', fpath=fso.GetFolder(fso.GetAbsolutePathName("."));
  var find_res=new RegExp('^([ \t]*\"'+res+'\"[ \t]+\")(.*)(\"[ \t]*$[\n\r]+)','gmi');
  WSH.Echo('Patching "'+res+'" to "'+value+'" in '+fpath);
  var files=new Enumerator(fpath.Files); files.moveFirst();  
  while (!files.atEnd()) {
  	var fn=files.item().name; WSH.Stdout.Write('.'); //WSH.Echo(fn); // get file names and write ... progress
    data=fs.readFileSync(fn, 'utf-16'); // read resource file
		data=data.replace(find_res,'$1'+value+'$3'); // mod res with value
    fs.writeFileSync(fn, data, 'utf-16'); files.moveNext(); // save file and load another
	}
  WSH.Echo(' Done!');
}
WriteLocal=function(fn,s){ fs.writeFileSync(fn, s.replace(/>/g,"\r\n").replace(/\'/g,"\""), "unicode"); };
LOCase=function(s){ w.echo(s.toLowerCase()); };

//----------------------------------------------------------------------------------------------------------------------------------
// ValveDataFormat hybrid js parser by AveYo, 2016                                                VDF test on 20.1 MB items_game.txt
// loosely based on vdf-parser by Rossen Popov, 2014-2016                                                           node.js  cscript
// featuring auto-renaming duplicate keys, saving comments, grabbing lame one-line "key" { "k" "v" }        parse:  1.329s   9.285s
// greatly improved cscript performance - it's not that bad overall but still lags behind node.js       stringify:  0.922s   3.439s
//----------------------------------------------------------------------------------------------------------------------------------
function ValveDataFormat(){
  var jscript=(typeof ScriptEngine == 'function' && ScriptEngine() == 'JScript'); if (!jscript){ var w={}; w.echo=console.log; }
  var order=!jscript, dups=false, comments=false, newline='\n', empty=(jscript) ? '' : undefined;
  return {
    parse: function(txt, flag){
      var obj={}, stack=[obj], expect_bracket=false, i=0; comments=flag || false;
      if (/\r\n/.test(txt)){newline='\r\n';} else newline='\n';
      var m, regex =/[^"\r\n]*(\/\/.*)|"([^"]*)"[ \t]+"([^"]*\\"[^"]*\\"[^"]*|[^"]*)"|"([^"]*)"|({)|(})/g;                       //"
      while ((m=regex.exec(txt)) !== null){
        //lf='\n'; w.echo(' cmnt:'+m[1]+lf+' key:'+m[2]+lf+' val:'+m[3]+lf+' add:'+m[4]+lf+' open:'+m[5]+lf+' close:'+m[6]+lf);
        if (comments && m[1] !== empty){
          i++;key='\x10'+i; stack[stack.length-1][key]=m[1];                                      // AveYo: optionally save comments
        } else if (m[4] !== empty){
          key=m[4]; if (expect_bracket){ w.echo('VDF.parse: invalid bracket near '+m[0]); return this.stringify(obj,true); }
          if (order && key == ''+~~key){key='\x11'+key;}              // AveYo: prepend nr. keys with \x11 to keep order in node.js
          if (typeof stack[stack.length-1][key] === 'undefined'){
            stack[stack.length-1][key]={};
          } else {
            i++;key+= '\x12'+i; stack[stack.length-1][key]={}; dups=true;             // AveYo: rename duplicate key obj with \x12+i
          }
          stack.push(stack[stack.length-1][key]); expect_bracket=true;
        } else if (m[2] !== empty){
          key=m[2]; if (expect_bracket){ w.echo('VDF.parse: invalid bracket near '+m[0]); return this.stringify(obj,true); }
          if (order && key == ''+~~key) key='\x11'+key;                // AveYo: prepend nr. keys with \x11 to keep order in node.js
          if (typeof stack[stack.length-1][key] !== 'undefined'){ i++;key+= '\x12'+i; dups=true; }//AveYo: rename duplicate k-v pair
          stack[stack.length-1][key]=m[3]||'';
        } else if (m[5] !== empty){
          expect_bracket=false; continue; // one level deeper
        } else if (m[6] !== empty){
          stack.pop(); continue; // one level back
        }
      }
      if (stack.length != 1){ w.echo('VDF.parse: open parentheses somewhere'); return this.stringify(obj,true); }
      return obj; // stack[0];
    },
    stringify: function(obj, pretty, nl){
      if (typeof obj != 'object'){ w.echo('VDF.stringify: Input not an object'); return obj; }
      pretty=( typeof pretty == 'boolean' && pretty) ? true : false; nl=nl || newline || '\n';
      return this.dump(obj, pretty, nl, 0);
    },
    dump: function(obj, pretty, nl, level){
      if (typeof obj != 'object'){ w.echo('VDF.stringify: Key not string or object'); return obj; }
      var indent='\t', buf='', idt='', i=0;
      if (pretty){for (; i < level; i++) idt+= indent;}
      for (var key in obj){
        if (typeof obj[key] == 'object')  {
          buf+= idt+'"'+this.redup(key)+'"'+nl+idt+'{'+nl+this.dump(obj[key], pretty, nl, level+1)+idt+'}'+nl;
        } else {
          if (comments && key.indexOf('\x10') !== -1){ buf+= idt+obj[key]+nl; continue; }      // AveYo: restore comments (optional)
          buf+= idt+'"'+this.redup(key)+'"'+indent+indent+'"'+obj[key]+'"'+nl;
        }
      }
      return buf;
    },
    redup: function(key){
      if (order && key.indexOf('\x11') !== -1) key=key.split('\x11')[1];                    // AveYo: restore number keys in node.js
      if (dups && key.indexOf('\x12') !== -1) key=key.split('\x12')[0];                        // AveYo: restore duplicate key names
      return key;
    },
    nr: function(key){return (!jscript && key.indexOf('\x11') == -1) ? '\x11'+key : key;}   // AveYo: check number key: vdf.nr('nr')
  };
} // End of ValveDataFormat

//----------------------------------------------------------------------------------------------------------------------------------
// Hybrid JScript Engine by AveYo - can call specific functions as the first script argument
//----------------------------------------------------------------------------------------------------------------------------------
// start of JScript specific code
jscript=true; engine='JScript'; w=WScript; launcher=new ActiveXObject('WScript.Shell'); argc=w.Arguments.Count(); argv=[]; run='';
if (argc > 0){ run=w.Arguments(0); for (var i=1;i<argc;i++) argv.push( '"'+w.Arguments(i).replace(/[\\\/]+/g,'\\\\')+'"'); }
process={}; process.argv=[ScriptEngine(),w.ScriptFullName]; for (var j=0;j<argc;j++) process.argv[j+2]=w.Arguments(j);
path={}; path.join=function(f,n){return fso.BuildPath(f,n);}; path.normalize=function(f){return fso.GetAbsolutePathName(f);};
path.basename=function(f){return fso.GetFileName(f);}; path.dirname=function(f){return fso.GetParentFolderName(f);};path.sep='\\';
fs={}; fso=new ActiveXObject("Scripting.FileSystemObject"); ado=new ActiveXObject('ADODB.Stream'); DEF_ENCODING='Windows-1252';
FileExists=function(f){ return fso.FileExists(f); }; PathExists=function(f){ return fso.FolderExists(f); };
MakeDir=function(fn){
  if (fso.FolderExists(fn)) return; var pfn=fso.GetAbsolutePathName(fn), d=pfn.match(/[^\\\/]+/g), p='';
  for(var i=0,n=d.length; i<n; i++){ p+= d[i]+'\\'; if (!fso.FolderExists(p)) fso.CreateFolder(p); }
};
fs.readFileSync=function(fn, charset){
  var data=''; ado.Mode=3; ado.Type=2; ado.Charset=charset || 'Windows-1252'; ado.Open(); ado.LoadFromFile(fn);
  while (!ado.EOS) data+= ado.ReadText(131072); ado.Close(); return data;
};
fs.writeFileSync=function(fn, data, encoding){
  ado.Mode=3; ado.Type=2; ado.Charset=encoding || 'Windows-1252'; ado.Open();
  ado.WriteText(data); ado.SaveToFile(fn, 2); ado.Close(); return 0;
};
//----------------------------------------------------------------------------------------------------------------------------------
// Auto-run JS: if first script argument is a function name - call it, passing the next arguments
//----------------------------------------------------------------------------------------------------------------------------------
if (run && !(/[^A-Z0-9$_]/i.test(run))) new Function('if(typeof '+run+' == "function"){'+run+'('+argv+');}')();
//