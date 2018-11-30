@ECHO OFF
SET notepad="C:\Program Files\Notepad++\notepad++.exe" -multiInst -notabbar -nosession -noPlugin

START /WAIT /B CMD /C %notepad% %*