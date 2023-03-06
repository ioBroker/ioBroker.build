@echo off & setlocal EnableDelayedExpansion
if [%1]==[] goto:ERROR
set port=%1
set last=[]
for /f "tokens=1-5" %%a in ('netstat -ano') do (
  if [%%b] == [[::]:%port%] (
    if not [%%e]==[0] (
      if not !last! == [%%e] (
        for /f "skip=3 tokens=1-5" %%i in ('tasklist /FO TABLE /FI "PID eq %%e"') do (
          echo %port%;%%i;%%e
        )
      )
      set last=[%%e]
    )
  )

  if [%%b] == [127.0.0.1:%port%] (
    if not [%%e]==[0] (
      if not !last! == [%%e] (
        for /f "skip=3 tokens=1-5" %%i in ('tasklist /FO TABLE /FI "PID eq %%e"') do (
          echo %port%;%%i;%%e
        )
      )
      set last=[%%e]
    )
  )
)

goto:eof 
:ERROR
echo ERROR - No port given
