@echo off 
@rem pushd "%~dp0../../redist/" 
call "ParaEngineClient.exe" single="false" mc="true" noupdate="true" dev="%~dp0../../_mod/" mod="ImagesTo3Dmodel" isDevEnv="true"  
@rem popd 
