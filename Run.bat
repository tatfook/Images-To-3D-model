@echo off 
@rem pushd "%~dp0../../_mod/ImagesTo3Dmodel/" 
call "ParaEngineClient.exe" single="false" mc="true" noupdate="true" dev="%~dp0" mod="ImagesTo3Dmodel" isDevEnv="true"  
@rem popd 
