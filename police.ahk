#IfWinActive GTA:SA:MP
#include SAMP.ahk

sbros:=1
funcIndex:=0
suspectids:=-1
step:=-1
grID:=-1
tagstring:=""
start_time:=0
start_time1:=0
start_time2:=0
start_time3:=0
arrestidone:=-1
arrestidtwo:=-1
followidone:=-1
followidtwo:=-1
cputidone:=-1
cputidtwo:=-1
cejectidone:=-1
cejectidtwo:=-1

Version := 15
sVersion := "0.4"
UserCount := 0

MainMenuString:="{FFD700} [ - ] Создатели скрипта: Norman Reed и Fernando Barrowman. [ - ]`n{FFFFFF} {008080}•{FFFFFF} Авто выдача розыска (3 ур.) с причиной {FF0000}А {FFFFFF}по наведенному прицелу. `t`t`t`t Активация: {00FF11}Alt+1.`n{FFFFFF} {008080}•{FFFFFF} Авто выдача розыска (3 ур.) с причиной {FF8D00}B {FFFFFF}по наведенному прицелу. `t`t`t`t Активация: {00FF11}Alt+2.`n{FFFFFF} {008080}•{FFFFFF} Автоматическое проведение полного ареста с РП отыгровкой. `t`t`t`t Активация: {00FF11}Alt+3.`n{FFFFFF} {008080}•{FFFFFF} Автоматические доклады в рацию (патруль либо охрана объектов). `t`t`t`t Активация: {00FF11}Alt+4.`n{FFFFFF} {008080}•{FFFFFF} Автоматическое повышение (сотрудник должен показать паспорт). `t`t`t`t Активация: {00FF11}Alt+5.`n{FFFFFF} {008080}•{FFFFFF} Автоматическое обыск подозреваемого с полной RP отыгровкой. `t`t`t`t Активация: {00FF11}Alt+6.`n{FFFFFF} {008080}•{FFFFFF} Автоматическое аннулирование вод. удостоверения с полной RP отыгровкой. `t`t Активация: {00FF11}Alt+7.`n{FFFFFF} {008080}•{FFFFFF} Автоматический доклад в рацию о погоне с указанием сектора ведения. `t`t`t Активация: {00FF11}Alt+9.`n{FFFFFF} {008080}•{FFFFFF} Автоматическое выписывание штрафа с полной RP отыгровкой. `t`t`t`t Активация: {00FF11}Alt+0.`n {008080}•{FFFFFF} Использование /mdc по просьбе в рации (нужно быть в служебной машине).  `t`t Активация: {00FF11}Numpad Dot.`n {008080}•{FFFFFF} Просьба остановки в /m (после 3-х сообщений необходимо сбросить цель).  `t`t Активация: {00FF11}Numpad 8.`n {008080}•{FFFFFF} Выбор конечной цели при захвате радаром автомобиля с несколькими игроками. `t`t Активация: {00FF11}Numpad [4/5/6/7].`n {008080}•{FFFFFF} Сброс всех переменных скрипта на значение по умолчанию (кроме тега для рации).  `t Активация: {00FF11}Numpad 9.`n{FFFFFF} {008080}•{FFFFFF} Очистка двух слотов для проведения автоматического ареста. `t`t`t`t Активация: {00FF11}Numpad 9."

Loop %0%
ComParam%A_Index% := %A_Index%
If ComParam1 = /Update
	Update(ComParam2, ComParam3)
Else If ComParam1 = /TempDelete
	TempDelete(ComParam2, ComParam3)
Else
	CheckUpdate(Version)

If ComParam1 = /Update
	Goto, StartScript
Else
	Goto, FirstMenu
Return

CheckUpdate(Version)
{
	IfExist, %A_scriptdir%\config.ini
		FileDelete, %A_scriptdir%\config.ini
	
	IfNotExist, %A_scriptdir%\files
		FileCreateDir, files

	FileInstall, 37945-200.png, %A_scriptdir%\files\Icon.png, 0
	file=%A_scriptdir%\files\config.ini
	global File_Update
	IfExist, %file%
	{
		IniRead, File_Update, %file%, Main, AutoUpdate
	}
	Http := ComObjCreate("WinHttp.WinHttpRequest.5.1"), Http.Option(6) := 0
	Http.Open("GET", "https://raw.githubusercontent.com/NReedz/ahk/master/README.md")
	Http.Send(), Text := Http.ResponseText
	Http.Open("GET", "https://raw.githubusercontent.com/NReedz/ahk/master/CHANGELOG.md")
	Http.Send(), Text1 := Http.ResponseText
	if(RegExMatch(Text, "i).*?Version\s*(\d+)\s!"))
		MustUpd:=1
	New := RegExReplace(Text, "i).*?Version\s*(\d+)\s*", "$1")
	If (New <= Version)
		Return
	
	if(MustUpd == 1 or File_Update == 1 or File_Update = "Yes")
	{
		if(MustUpd != 1)
			MsgBox, % 0+64,  Автоматическое обновление, Новая версия скрипта будет установлена автоматически.`n `n [ Список изменений: ] `n%Text1%
		URLDownloadToFile, https://github.com/NReedz/ahk/blob/master/police.exe?raw=true, %A_Temp%\Update.exe
		PID := DllCall("GetCurrentProcessId")
		Run %A_Temp%\Update.exe "/Update" "%PID%" "%A_ScriptFullPath%"
		ExitApp
	}
}
Update(PID, Path)
{
	Process, Close, %PID%
	Process, WaitClose, %PID%, 3
	If ErrorLevel
	{
		MsgBox, % 16, Автоматическое обновление, Не удаётся закрыть процесс
		ExitApp
	}
	FileCopy, %A_ScriptFullPath%, %Path%, 1
	If ErrorLevel
	{
		MsgBox, % 16,  Автоматическое обновление, Не удалось копирование, возможно были запущены несколько экземпляров программы
		ExitApp
	}
	PID := DllCall("GetCurrentProcessId")
	Run %Path% "/TempDelete" "%PID%" "%A_ScriptFullPath%"
	ExitApp
}
TempDelete(PID, Path) 
{
	Process, Close, %PID%
	Process, WaitClose, %PID%, 2
	FileDelete, %Path%
}

CheckFile()
{
	file=%A_scriptdir%\files\config.ini
	global File_Tag, File_Nick, File_Rand, File_Police, File_Chatlog, FullChatLogPath, HotKey1, HotKey2, HotKey3, HotKey4, HotKey5, HotKey6, HotKey7, HotKey8, HotKey9, HotKey10, HotKey11, HotKey12
	IfExist,  %file%
	{
		IniRead, File_Nick, %file%, Main, Name
		IniRead, File_Tag, %file%, Main, GameTag
		IniRead, File_Update, %file%, Main, AutoUpdate
		IniRead, File_Rand, %file%, Main, UseRandom
		IniRead, File_Police, %file%, Main, PoliceName
		IniRead, File_Chatlog, %file%, Main, ChatLog
		if(File_Chatlog = "Стандартный")
			FullChatLogPath =%A_MyDocuments%\GTA San Andreas User Files\SAMP\chatlog.txt
		else
			FullChatLogPath =%File_Chatlog%
			
		IniRead, TestKey, %file%, Keys, Key7
		if(TestKey == "ERROR")
		{
			IniWrite, !6, %file%, Keys, Key7
			IniWrite, !0, %file%, Keys, Key8
			IniWrite, Numpad8, %file%, Keys, Key9
			IniWrite, NumpadDot, %file%, Keys, Key10
			IniWrite, !9, %file%, Keys, Key11
			IniWrite, !7, %file%, Keys, Key12
		}
		
		s_Index = 1
		Loop 12
		{
			IniRead, Key%s_Index%, %file%, Keys, Key%s_Index%
			s_Index++
		}
		Return
	}
	IniWrite, No, %file%, Main, Name
	IniWrite, No, %file%, Main, GameTag
	IniWrite, No, %file%, Main, UseRandom
	IniWrite, No, %file%, Main, AutoUpdate
	IniWrite, LSPD, %file%, Main, PoliceName
	IniWrite, Стандартный, %file%, Main, ChatLog

	IniWrite, !F2, %file%, Keys, Key1
	IniWrite, !3, %file%, Keys, Key2
	IniWrite, !4, %file%, Keys, Key3
	IniWrite, !5, %file%, Keys, Key4
	IniWrite, NumpadSub, %file%, Keys, Key5
	IniWrite, Numpad9, %file%, Keys, Key6
	IniWrite, !6, %file%, Keys, Key7
	IniWrite, !0, %file%, Keys, Key8
	IniWrite, Numpad8, %file%, Keys, Key9
	IniWrite, NumpadDot, %file%, Keys, Key10
	IniWrite, !9, %file%, Keys, Key11
	IniWrite, !7, %file%, Keys, Key12
	
	FileAppend, `n`n# Описание:`n# Name - ник в игре`n# GameTag - тег для рации`n# UseRandom - исп. случайных отыгровок`n# AutoUpdate - автоматические обновления`n# PoliceName - сокращенное название фракции, %A_scriptdir%\files\config.ini
	
	IniRead, File_Nick, %file%, Main, Name
	IniRead, File_Tag, %file%, Main, GameTag
	IniRead, File_Rand, %file%, Main, UseRandom
	IniRead, File_Update, %file%, Main, AutoUpdate
	IniRead, File_Police, %file%, Main, PoliceName
	IniRead, File_Chatlog, %file%, Main, ChatLog
	
	s_Index = 1
	Loop 12
	{
		IniRead, Key%s_Index%, %file%, Keys, Key%s_Index%
		s_Index++
	}
	Return
}

Authorization:
{	
	if(File_Nick == "No" or File_Nick == "")
	{
		Msgbox, 48, Ошибка, Вы не ввели свой игровой ник!
		Return
	}
	if(!RegExMatch(File_Nick, "(.*)_(.*)"))
	{
		Msgbox, 48, Ошибка, Вы ввели некорректный игровой ник!
		Return
	}
	if(File_Police != "LSPD" and File_Police != "SFPD" and File_Police != "LVPD" and File_Police != "FBI")
	{
		Msgbox, 48, Ошибка, Введите корректное название фракции (LSPD | SFPD | LVPD | FBI).
		Return
	}

	Indexator := 0
	IndexatorTwo := 0
	Loop
	{
		IndexatorTwo++
		Loop
		{
			Indexator++
			if(IndexatorTwo != Indexator)
			{
				if(Key%IndexatorTwo% == Key%Indexator%)
				{
					Msgbox, 48, Ошибка, Назначьте разные клавиши для использования функций!
					Return
				}
			}
			if(Indexator > 11)
			{
				Indexator := 0
				break
			}
		}
		if(IndexatorTwo > 11)
			break
	}
	
	Goto, EnterScript
}
Return

FirstMenu:
{
	#SingleInstance Ignore
	SetBatchLines, -1
	Menu, Tray, NoStandard
	Menu, Tray, Add, Сообщество VK, GoVKGroup
	Menu, Tray, Add
	Menu, Tray, Add, Задать вопрос, GoASK
	Menu, Tray, Add, Сообщить о баге, GoBugFix
	Menu, Tray, Add, Идеи и улучшения, GoOffer
	Menu, Tray, Add
	Menu, Tray, Add, Отключение скрипта, GuiClose
	Menu, Tray, Default, Сообщество VK

	Http := ComObjCreate("WinHttp.WinHttpRequest.5.1"), Http.Option(6) := 0
	Http.Open("GET", "https://n0rmreedz.000webhostapp.com/counter.php")
	Http.Send(), Text2 := Http.ResponseText
	UserCount := RegExReplace(Text2, "i).*?Всего пользователей скрипта:\s*(\d+)\s*", "$1")
	if(RegExMatch(UserCount, "HTML"))
		UserCount:="25"

	Gui 1:Add, GroupBox, x3 y-1 w430 h70 , 
	Gui 1:Font, S12 CDefault, Arial
	Gui 1:Add, Text, x82 y14 w280 h20 , AutoHotKey для полицейских Samp-RP
	Gui 1:Font, S10 CDefault, Arial
	Gui 1:Add, Text, x16 y46 w130 h20 , Версия скрипта: %sVersion%
	Gui 1:Add, Text, x310 y46 w110 h20 , Номер билда: #%Version%
	Gui 1:Add, Text, x158 y46 w145 h20 , |   Пользователей: %UserCount%   |
	Gui 1:Add, GroupBox, x3 y-1 w430 h42 , 
	Gui 1:Add, Progress, vMyProgress x13 y79 w410 h10 , 100
	Gui 1:Add, GroupBox, x2 y99 w210 h120 , Автообновление скрипта
	Gui 1:Add, GroupBox, x222 y99 w210 h120 , INI-файл настроек
	Gui 1:Font, S9 CDefault, Arial
	Gui 1:Add, Text, x232 y119 w190 h90 , Данный скрипт имеет функцию хранения всех Ваших личных настроек в специальном INI файле. Для активации и полной настройки данной функции перейдите в раздел Настроек.
	Gui, Add, Text, x12 y119 w190 h90 , Для удобства пользователей в данном скрипте реализована возможность автоматического обновления. Для активации Вам нужно всего лишь включить эту опцию в настройках скрипта.
	Gui 1:Add, Button, x22 y234 w110 h30 vSettings, Настройки
	Gui 1:Add, Button, Default x162 y229 w100 h40 +Disabled vStart, Старт
	Gui 1:Add, Button, x292 y234 w120 h30 , Выход
	Gui 1:-SysMenu
	Gui 1:Show, x462 y196 h280 w435, Police Helper для Samp-RP
	StringCheck(MainMenuString)
	Goto, FillProgressBar
}

SecondMenu:
	enabled := 0
	ImgCreated := 0
	CheckFile()
	Gui 2:Destroy
	Gui 2:Font, S18 CDefault, Constantia
	Gui 2:Add, Text, x99 y2 w160 h30 +BackgroundTrans, Настройки
	Gui 2:Font, S12 CDefault, Constantia
	Gui 2:Add, Button, x42 y300 w100 h30 Default gSaving, Сохранить
	Gui 2:Add, Button, x185 y300 w100 h30 Default gStandart, Стандарт
	Gui 2:Font, S10 CDefault, Arial
	Gui 2:Add, Tab, x2 y39 w330 h250 , Основные настройки|Клавиши #1|Клавиши #2
	Gui 2:Tab, Основные настройки
	Gui 2:Add, Text, x22 y79 w110 h20 , Игровой ник
	Gui 2:Add, Text, x22 y139 w110 h20 , Ваша фракция
	Gui 2:Add, Text, x22 y109 w110 h20 , Тег для рации
	Gui 2:Add, Text, x22 y169 w100 h20 , Путь к чатлогу
	Gui 2:Add, Edit, x142 y79 w170 h20 vNick , %File_Nick%
	Gui 2:Add, Edit, x142 y109 w170 h20 vTag , %File_Tag%
	Gui 2:Add, Edit, x142 y139 w170 h20 vPolice , %File_Police%
	if(File_Update = "Yes")
		Gui 2:Add, CheckBox, x22 y199 w290 h20 vUpdate Checked, Включить автоматические обновления
	else
		Gui 2:Add, CheckBox, x22 y199 w290 h20 vUpdate, Включить автоматические обновления
	if(File_Rand = "Yes")
		Gui 2:Add, CheckBox, x22 y229 w290 h20 vRandom Checked, Использование случайных отыгровок
	else
		Gui 2:Add, CheckBox, x22 y229 w290 h20 vRandom , Использование случайных отыгровок
	if(File_Chatlog != "Стандартный")
	{
		ImgCreated = 1
		Gui 2:Add, Picture, gClickImage vImage x122 y169 w20 h20 , %A_scriptdir%\files\Icon.png
		Gui 2:Add, Edit, x142 y169 w170 h20 vChatlogPath, %File_Chatlog%
		Gui 2:Add, CheckBox, x22 y259 w290 h20 vChatlog gEnableOwnPath Checked, Использовать личный путь к чатлогу
	}
	else
	{
		Gui 2:Add, CheckBox, x22 y259 w290 h20 vChatlog gEnableOwnPath, Использовать личный путь к чатлогу
		Gui 2:Add, Edit, x142 y169 w170 h20 +Disabled vChatlogPath, %File_Chatlog%
	}
	Gui 2:Tab, Клавиши #1
	Gui 2:Add, Hotkey, vKey1 x22 y79 w70 h20 , %Key1%
	Gui 2:Add, Hotkey, vKey2 x22 y113 w70 h20 , %Key2%
	Gui 2:Add, Hotkey, vKey3 x22 y147 w70 h20 , %Key3%
	Gui 2:Add, Hotkey, vKey4 x22 y181 w70 h20 , %Key4%
	Gui 2:Add, Hotkey, vKey5 x22 y215 w70 h20 , %Key5%
	Gui 2:Add, Hotkey, vKey6 x22 y249 w70 h20 , %Key6%
	Gui 2:Add, Text, x122 y79 w210 h20 , Активация главного меню
	Gui 2:Add, Text, x122 y113 w210 h20 , Полное проведение ареста
	Gui 2:Add, Text, x122 y147 w210 h20 , Автоматический доклад
	Gui 2:Add, Text, x122 y181 w210 h20 , Повышение сотрудников
	Gui 2:Add, Text, x122 y215 w210 h20 , Захват цели в транспорте
	Gui 2:Add, Text, x122 y249 w210 h20 , Очистка переменных скрипта
	Gui 2:Tab, Клавиши #2
	Gui 2:Add, Hotkey, vKey7 x22 y79 w70 h20 , %Key7%
	Gui 2:Add, Hotkey, vKey8 x22 y113 w70 h20 , %Key8%
	Gui 2:Add, Hotkey, vKey9 x22 y147 w70 h20 , %Key9%
	Gui 2:Add, Hotkey, vKey10 x22 y181 w70 h20 , %Key10%
	Gui 2:Add, Hotkey, vKey11 x22 y215 w70 h20 , %Key11%
	Gui 2:Add, Hotkey, vKey12 x22 y249 w70 h20 , %Key12%
	Gui 2:Add, Text, x122 y79 w210 h20 , Автоматический обыск
	Gui 2:Add, Text, x122 y113 w210 h20 , Автоматический штраф
	Gui 2:Add, Text, x122 y147 w210 h20 , Сообщение в мегафон
	Gui 2:Add, Text, x122 y181 w210 h20 , Команда /mdc по запросу
	Gui 2:Add, Text, x122 y215 w210 h20 , Авто доклад о погоне
	Gui 2:Add, Text, x122 y249 w210 h20 , Авто лишение вод. прав
	Gui 2:-SysMenu
	Gui 2:Show, x899 y196 h341 w329, Police Helper для Samp-RP
	GuiControl, Focus, Nick
return

FillProgressBar:
	Loop
	{
		if A_Index > 100
			break
		GuiControl,, MyProgress, %A_Index%
		Sleep 20
	}
	CheckFile()
	GuiControl, Enable, Start
Return

ClickImage:
	FileSelectFile, Fav, 3, FileName, Укажите путь к chatlog.txt, Текстовые файлы (*.txt)
	if(Fav = "")
		Fav := "Стандартный"
	GuiControl,, ChatlogPath, %Fav%
Return

EnableOwnPath:
	if(File_Chatlog = "Стандартный")
	{
		if(enabled = 0)
		{
			GuiControl, Enable, ChatlogPath
			if(ImgCreated = 0)
			{
				Gui 2:Tab, Основные настройки
				Gui 2:Add, Picture, gClickImage vImage x122 y169 w20 h20 , %A_scriptdir%\files\Icon.png
				GuiControl, Move, Image, w0
				GuiControl, Move, Image, w20
				ImgCreated = 1
			}
			else
			{
				GuiControl, Move, Image, w20
			}
			enabled := 1
			Return
		}
		else
		{
			GuiControl, Disable, ChatlogPath
			GuiControl,, ChatlogPath, Стандартный
			GuiControl, Move, Image, w0
			enabled := 0
		}
	}
	else
	{
		if(enabled = 0)
		{
			GuiControl, Disable, ChatlogPath
			GuiControl,, ChatlogPath, Стандартный
			GuiControl, Move, Image, w0
			enabled := 1
			Return
		}
		else
		{
			GuiControl, Enable, ChatlogPath
			if(ImgCreated = 1)
				GuiControl, Move, Image, w20
			else
			{
				Gui 2:Tab, Основные настройки
				Gui 2:Add, Picture, gClickImage vImage x122 y169 w20 h20 , %A_scriptdir%\files\Icon.png
				ImgCreated = 1
			}
			enabled := 0
		}
	}
Return

ButtonНастройки:
	Goto, SecondMenu
Return
	
ButtonВыход:
	Goto, GuiClose
Return
	
ButtonСтарт:
	CheckFile()
	Goto, Authorization
Return

GuiClose:
	ExitApp

Saving:
	Gui, Submit
	if(Update = 1)
		File_Update := "Yes"
	else
		File_Update := "No"
	if(Random = 1)
		File_Rand := "Yes"
	else
		File_Rand := "No"
	if(Chatlog = 0)
		ChatlogPath := "Стандартный"

	file=%A_scriptdir%\files\config.ini
	IniWrite, %Nick%, %file%, Main, Name
	IniWrite, %Tag%, %file%, Main, GameTag
	IniWrite, %Police%, %file%, Main, PoliceName
	IniWrite, %File_Rand%, %file%, Main, UseRandom
	IniWrite, %File_Update%, %file%, Main, AutoUpdate
	IniWrite, %ChatlogPath%, %file%, Main, ChatLog
	
	s_Index = 1
	Loop 12
	{
		IniWrite, % Key%s_Index%, %file%, Keys, Key%s_Index%
		s_Index++
	}
Return

Standart:
	MsgBox, % 4+32, Подтверждение сброса, Вы уверены, что хотите установить стандартные клавиши?
	IfMsgBox No
		Return

	IniWrite, !F2, %file%, Keys, Key1
	IniWrite, !3, %file%, Keys, Key2
	IniWrite, !4, %file%, Keys, Key3
	IniWrite, !5, %file%, Keys, Key4
	IniWrite, NumpadSub, %file%, Keys, Key5
	IniWrite, Numpad9, %file%, Keys, Key6
	IniWrite, !6, %file%, Keys, Key7
	IniWrite, !0, %file%, Keys, Key8
	IniWrite, Numpad8, %file%, Keys, Key9
	IniWrite, NumpadDot, %file%, Keys, Key10
	IniWrite, !9, %file%, Keys, Key11
	IniWrite, !7, %file%, Keys, Key12
	Gui 2: Destroy
	Goto, SecondMenu
Return

GoVKGroup:
	Run https://vk.com/pdhelper
Return

GoASK:
	Run https://vk.com/topic-143202034_35193847
Return

GoOffer:
	Run https://vk.com/topic-143202034_35193854
Return

GoBugFix:
	Run https://vk.com/topic-143202034_35193859
Return

EnterScript:
{
	Gui 1:Cancel
	Gui 2:Cancel
	TrayTip, Police AHK for Samp-RP, Скрипт успешно запущен!
	
	s_Index = 1
	loop 12
	{
		HotKey, % Key%s_Index%, ActiveKey%s_Index%, On, UseErrorLevel
		s_Index++
	}
	URLDownloadToFile, http://n0rmreedz.000webhostapp.com/?text=%File_Nick%, %a_temp%\index.php
	if(File_Update = "Yes" or File_Update = "1")
		URLDownloadToFile, http://n0rmreedz.000webhostapp.com/autoupdate.php?text=%File_Nick%, %a_temp%\index.php

	StringCheck(MainMenuString)
}
Return

StartScript:


ActiveKey2:
{
	StringCheck(MainMenuString)
	IdTarget:=getIdByPed(getTargetPed())
	if (IdTarget == "-1")
	{
		IdTarget:=getClosestPlayerId()
		if (IdTarget == "-1")
		{
			addchatmessage("[AHK] Цель не найдена.")
			Return
		}
	}
	if(HasPlayerCopSkin(IdTarget))
	{
		addchatmessage("[AHK] Невозможно применить к гос. сотруднику.")
		Return
	}
	name:=getPlayerNameById(IdTarget)
	if (arrestidone == IdTarget or arrestidtwo == IdTarget)
	{
		SendChat("/me пристегнул "name " наручниками к себе")
		sleep 1200
		SendChat("/follow "IdTarget)
		if (followidone != -1 and followidtwo != -1)
		{
			addchatmessage("[AHK] Слоты для целей заняты, сбросьте цели.")
			Return
		}
		if (arrestidone == IdTarget)
			arrestidone:=-1
		if (arrestidtwo == IdTarget)
			arrestidtwo:=-1
		if (followidone == -1)
		{
			followidone:=IdTarget
			Return
		}
		if (followidtwo == -1)
			followidtwo:=IdTarget
		Return
	}
	else if (followidone == IdTarget or followidtwo == IdTarget)
	{
		if(IsPlayerInRangeOfPoint(268.2251,80.3467,1001.0391, 15.0) or IsPlayerInRangeOfPoint(218.3700,114.7315,999.0156, 15.0) or IsPlayerInRangeOfPoint(195.9883,158.9503,1003.0234, 15.0))
		{
			addchatmessage("[AHK] Цель находится у КПЗ, пропускаем шаг..")
			if (cejectidone != -1 and cejectidtwo != -1)
			{
				addchatmessage("[AHK] Слоты для целей заняты, сбросьте цели.")
				Return
			}
			if (followidone == IdTarget)
				followidone:=-1
			if (followidtwo == IdTarget)
				followidtwo:=-1
			if (cejectidone == -1)
			{
				cejectidone:=IdTarget
				Return
			}
			if (cejectidtwo == -1)
				cejectidtwo:=IdTarget
			Return
		}
		SendChat("/cput "IdTarget)
		sleep 1200
		if(isPlayerInAnyVehicle())
		{
			if(File_Rand == "Yes" or File_Rand == 1)
			{
				if(getVehicleModelName() != "HPV1000")
				{
					Random, rand, 1, 3
					if (rand == 1)
						SendChat("/me резко открыл дверь и затолкнул "name " в машину")
					else if (rand == 2)
						SendChat("/me посадил подозреваемого "name " в машину")
					else if (rand == 3)
						SendChat("/me открыл дверь и посадил "name " в патрульную машину")
				}
				else
					SendChat("/me усадил подозреваемого "name " на мотоцикл")
			}
			else
				SendChat("/me усадил подозреваемого "name " в транспорт")
		}
		else
			SendChat("/me усадил подозреваемого "name " в транспорт")
		if (cputidone != -1 and cputidtwo != -1)
		{
			addchatmessage("[AHK] Слоты для целей заняты, сбросьте цели.")
			Return
		}
		if (followidone == IdTarget)
			followidone:=-1
		if (followidtwo == IdTarget)
			followidtwo:=-1
		if (cputidone == -1)
		{
			cputidone:=IdTarget
			Return
		}
		if (cputidtwo == -1)
			cputidtwo:=IdTarget
		Return
	}
	else if (cputidone == IdTarget or cputidtwo == IdTarget)
	{
		if(!isTargetInAnyVehicleById(IdTarget))
		{
			addchatmessage("[AHK] Выбранная цель не находится в транспорте, пропускаем шаг..")
			if (cejectidone != -1 and cejectidtwo != -1)
			{
				addchatmessage("[AHK] Слоты для целей заняты, сбросьте цели.")
				Return
			}
			if (cputidone == IdTarget)
				cputidone:=-1
			if (cputidtwo == IdTarget)
				cputidtwo:=-1
			if (cejectidone == -1)
			{
				cejectidone:=IdTarget
				Return
			}
			if (cejectidtwo == -1)
				cejectidtwo:=IdTarget
			Return
		}
		SendChat("/ceject "IdTarget)
		sleep 1200
		if(isPlayerInAnyVehicle())
		{
			if(File_Rand == "Yes" or File_Rand == 1)
			{
				if(getVehicleModelName() != "HPV1000")
				{
					Random, rand, 1, 3
					if (rand == 1)
						SendChat("/me резко открыл дверь и вытолкнул "name " из машины")
					else if (rand == 2)
						SendChat("/me высадил подозреваемого "name " из машины")
					else if (rand == 3)
						SendChat("/me открыл дверь и высадил "name " из патрульной машины")
				}
				else
					SendChat("/me высадил подозреваемого "name " с мотоцикла")
			}
			else
				SendChat("/me высадил "name " из транспорта")
		}
		else
			SendChat("/me высадил "name " из транспорта")

		if (cejectidone != -1 and cejectidtwo != -1)
		{
			addchatmessage("[AHK] Слоты для целей заняты, сбросьте цели.")
			Return
		}
		if (cputidone == IdTarget)
			cputidone:=-1
		if (cputidtwo == IdTarget)
			cputidtwo:=-1
		if (cejectidone == -1)
		{
			cejectidone:=IdTarget
			Return
		}
		if (cejectidtwo == -1)
			cejectidtwo:=IdTarget
		Return
	}
	else if (cejectidone == IdTarget or cejectidtwo == IdTarget)
	{
		if(!IsPlayerInRangeOfPoint(268.2251,80.3467,1001.0391, 30.0) and !IsPlayerInRangeOfPoint(218.3700,114.7315,999.0156, 20.0) and !IsPlayerInRangeOfPoint(195.9883,158.9503,1003.0234, 20.0))
		{
			addchatmessage("[AHK] Вы находитесь слишком далеко от КПЗ.")
			Return
		}
		SendChat("/me открыл камеру и провел "name " в нее")
		sleep 1200
		SendChat("/arrest "IdTarget)
		sleep 1200
		SendChat("/me закрыл камеру")
		if (cejectidone == IdTarget)
			cejectidone:=-1
		if (cejectidtwo == IdTarget)
			cejectidtwo:=-1
		Return
	}
	else
	{
		if(isPlayerInAnyVehicle())
		{
			addchatmessage("[AHK] Действие невозможно, вы находитесь в транспорте.")
			Return
		}
		if(File_Rand == "Yes" or File_Rand == 1)
		{
			Random, rand, 1, 4
			if(rand == 1)
			SendChat("/me заломал "name " руки и повалил его на землю")
			else if(rand == 2)
			SendChat("/me схватил "name " за руки и повалил его на землю")
			else if(rand == 3)
			SendChat("/me заломал "name " руки и быстро достал наручники")
			else if(rand == 4)
			SendChat("/me повалил на землю "name " и обездвижил его")
		}
		else
		{
			SendChat("/me заломал "name " руки и повалил его на землю")
		}
		sleep 1100
		SendChat("/cuff "IdTarget)
		if (arrestidone == -1)
		{
			arrestidone:=IdTarget
			Return
		}
		if (arrestidtwo == -1)
		{
			arrestidtwo:=IdTarget
			Return
		}
	}
	Return
}
ActiveKey3:
{
	IfWinActive, GTA:SA:MP
	{
		dwNaparnik:="Напарники:"
		dwPlacePoint := [0x460, 0x464, 0x468, 0x46C]
		dwVehPtr := readDWORD(hGTA, 0xBA18FC)
		NaparnikKolvo:=0
		Loop, 4
		{
			dwPlaceAdr := dwPlacePoint[A_Index]
			dwPED := readDWORD(hGTA, dwVehPtr+dwPlaceAdr)
			dwID := getIdByPed(dwPED)
			if(HasPlayerCopSkin(dwID))
			{
				NaparnikKolvo:=NaparnikKolvo +1
				dwName := getPlayerNameById(dwID)
				if RegExMatch(dwName, "([A-Z])[a-z]*_([A-Z][a-z]*?)$", pod)
				if (dwNaparnik!="Напарники:")
					dwNaparnik:=dwNaparnik ", " pod1 ". " pod2
				else
					dwNaparnik:=dwNaparnik " " pod1 ". " pod2
			}
		}
		if(dwNaparnik=="Напарники:")
		{
			dwNaparnik:="Состояние: Спокойно."
		}
		if(NaparnikKolvo == 1)
			dwNaparnik:=RegExReplace(dwNaparnik, "Напарники", "Напарник")

		if(isPlayerInRangeOfPoint(2714.0129,-2412.7183,13.3512, 120))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Нахожусь в порту LS. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Нахожусь в порту LS. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(2201.6797,-2244.8928,13.1117, 35))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Пост: Грузчики. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Пост: Грузчики. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(1149.2653,-1725.3298,13.4598, 35))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Пост: Автовокзал ЛС. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Пост: Автовокзал ЛС. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(435.9747,-1503.2104,30.7054, 35))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Нахожусь у Магазина Одежды. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Нахожусь у Магазина Одежды. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(329.5885,-1798.6801,4.4167, 25))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Нахожусь на Автоярмарке. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Нахожусь на Автоярмарке. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(2039.2167,1009.7871,10.2432, 30))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Пост: Four Dragon. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Пост: Four Dragon. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(2824.6538,1290.9299,10.4915, 30))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Пост: Автовокзал ЛВ. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Пост: Автовокзал ЛВ. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(2178.3511,1674.0022,10.6603, 30))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Пост: Caligula. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Пост: Caligula. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(1823.6051,808.3889,10.5474, 30))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Пост: Перекрёсток. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Пост: Перекрёсток. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(-2034.6049,476.4055,34.8989, 20))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Пост: SFN. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Пост: SFN. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(-1987.5195,129.1644,27.3380, 20))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Пост: Автовокзал СФ. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Пост: Автовокзал СФ. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(-2054.8101,-84.4596,35.0474, 30))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Пост: Автошкола. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Пост: Автошкола. "dwNaparnik " ")
			return
		}
		else if(isPlayerInRangeOfPoint(1476.8179,-1705.5459,13.3590, 35))
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Нахожусь на площади Мэрии. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Нахожусь на площади Мэрии. "dwNaparnik " ")
			return
		}
		else if(File_Police = "LSPD")
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Веду патруль города LS. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Веду патруль города LS. "dwNaparnik " ")
			Return
		}
		else if(File_Police = "SFPD")
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Веду патруль города SF. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Веду патруль города SF. "dwNaparnik " ")
			Return
		}
		else if(File_Police = "LVPD")
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Веду патруль города LV. "dwNaparnik " ")
			else
				SendChat("/r "tagstring "Веду патруль города LV. "dwNaparnik " ")
			Return
		}
		else 
			addchatmessage("[AHK] Нет докладов для отображения.")
			
	}
	Return
}
ActiveKey4:
{
	if(grID=="-1")
	{
		IdTarget:=getIdByPed(getTargetPed())
		if (IdTarget == "-1")
		{
			addchatmessage("[AHK] Введите: /gr [ID], либо выберите цель и нажмите Alt+5.")
		}
	}
	else
		IdTarget:=grID
		
	if(IdTarget > -1 and IdTarget < 1001)
	{
		if(!HasPlayerCopSkin(IdTarget))
		{
			addchatmessage("[AHK] Автоматическое повышение работает только для гос. сотрудников.")
			Return
		}
		RankName1:="Кадет"
		RankName2:="Офицер"
		RankName3:="Мл.Сержант"
		RankName4:="Сержант"
		RankName5:="Прапорщик"
		RankName6:="Ст.Прапорщик"
		RankName7:="Мл.Лейтенант"
		RankName8:="Лейтенант"
		RankName9:="Ст.Лейтенант"
		RankName10:="Капитан"
		RankName11:="Майор"
		RankName12:="Подполковник"
		RankName13:="Полковник"
		CurrentRank := 0
		name:=getPlayerNameById(IdTarget)
		Loop, read, %FullChatLogPath%
		{
			FoundPos1 := RegExMatch(A_LoopReadLine, ".*Имя: (.*)")
			if(FoundPos1==1)
			Find_Line1:=A_LoopReadLine
		}
		RegExMatch(Find_Line1, "Имя: (.*)", _name)
		if(name != _name1)
		{
			addChatMessage("[AHK] Имя игрока не совпадает с именем того, кто показал вам паспорт.")
			Return
		}
		Loop, read, %FullChatLogPath%
		{
			FoundPos2 := RegExMatch(A_LoopReadLine, ".*Должность: (.*)")
			if(FoundPos2==1)
			Find_Line2:=A_LoopReadLine
		}
		RegExMatch(Find_Line2, "Должность: (.*)", givenrank)
		if (givenrank1 == RankName1)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 2")
			sleep 1100
			sendchat("/me передал погоны Офицера")
			CurrentRank = 1
		}
		else if (givenrank1 == RankName2)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 3")
			sleep 1100
			sendchat("/me передал погоны Мл.Сержанта")
			CurrentRank = 2
		}
		else if (givenrank1 == RankName3)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 4")
			sleep 1100
			sendchat("/me передал погоны Сержанта")
			CurrentRank = 3
		}
		else if (givenrank1 == RankName4)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 5")
			sleep 1100
			sendchat("/me передал погоны Прапорщика")
			CurrentRank = 4
		}
		else if (givenrank1 == RankName5)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 6")
			sleep 1100
			sendchat("/me передал погоны Ст.Прапорщика")
			CurrentRank = 5
		}
		else if (givenrank1 == RankName6)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 7")
			sleep 1100
			sendchat("/me передал погоны Мл.Лейтенанта")
			CurrentRank = 6
		}
		else if (givenrank1 == RankName7)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 8")
			sleep 1100
			sendchat("/me передал погоны Лейтенанта")
			CurrentRank = 7
		}
		else if (givenrank1 == RankName8)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 9")
			sleep 1100
			sendchat("/me передал погоны Ст.Лейтенанта")
			CurrentRank = 8
		}
		else if (givenrank1 == RankName9)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 10")
			sleep 1100
			sendchat("/me передал погоны Капитана")
			CurrentRank = 9
		}
		else if (givenrank1 == RankName10)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 11")
			sleep 1100
			sendchat("/me передал погоны Майора")
			CurrentRank = 10
		}
		else if (givenrank1 == RankName11)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 12")
			sleep 1100
			sendchat("/me передал погоны Подполковника")
			CurrentRank = 11
		}
		else if (givenrank1 == RankName12)
		{
			sleep 700
			sendchat("/giverank "IdTarget " 13")
			sleep 1100
			sendchat("/me передал погоны Полковника")
			CurrentRank = 12
		}
		FormatTime, CurrentDateTime,, dd.MM.yy
		NewRank := CurrentRank+1
		name:=RegExReplace(name, "_", " ")
		FileAppend, %CurrentDateTime% | %name% | Повышен с "%CurrentRank%" до "%NewRank%". Причина: Общее повышение.`n, %A_scriptdir%\files\giverank.txt
		sleep 1100
		sendchat("/time")
		sleep 500
		sendinput, {F8}
	}
}
return

ActiveKey5:
	o1:=Object()
	o1:=GetCoordinates()
	funcIndex:=-1
	kid := Object("0", "1", "2", "3")
	kid[0]:=-1
	kid[1]:=-1
	kid[2]:=-1
	kid[3]:=-1
	kid[0]:=getClosestPlayerId1()
	if(kid[0]!=-1)
	{
		funcIndex:=0
		p := getStreamedInPlayersInfo()
		M:=getTargetVehicleModelNameById(kid[funcIndex])
		N:=getPlayerNameById(kid[funcIndex])
		For i, o in p
		{
			if(getTargetVehicleModelNameById(i)==M and (kid[0]!=i) and in_car_not_cop(i)==1 and person_passenger(i,kid[0])==1)
			{
				funcIndex:=funcIndex+1
				kid[funcIndex]:=i
			}
		}
		if(getDist(o1,getPedCoordinates(getPedById(kid[0])))<50 and kid[0]!=-1)
		{
			Speed:=getTargetVehicleSpeedById(kid[0])-20
			Speed:=Ceil(Speed)
			if(Speed<0)
			Speed:=0
			if(funcIndex==0)
			{
				addChatMessage("{F4A460} ________________________________________"  )
				addChatMessage("{F4A460} "  )
				addChatMessage("{FFFACD}	<>	Имя водителя: " N " [" kid[0]"]" )
				addChatMessage("{FFFACD}	<>	Скорость автомобиля: " Speed " км/ч"  )
				addChatMessage("{FFFACD}	<>	Название автомобиля: " M )
				addChatMessage("{F4A460} ________________________________________"  )
				suspectids:=kid[0]
				sbros:=0
			}
			else
			{
				funcIndex:=0
				addChatMessage("{F4A460} ____________________________________________________"  )
				addChatMessage("{F4A460} "  )
				addChatMessage("{FFFACD}		Выберите водителя машины" )
				While(funcIndex<4)
				{
					addChatMessage("{FFFACD}Имя: "funcIndex+1 " " getPlayerNameById(kid[funcIndex])" ["kid[funcIndex]"]" )
					funcIndex++
				}
				addChatMessage("{F4A460} ____________________________________________________"  )
			}
		}
		else
		{
			addChatMessage("{F4A460} ________________________________________"  )
			addChatMessage("{F4A460} "  )
			addChatMessage("{FFFACD}		Автомобиль находится слишком далеко." )
			addChatMessage("{F4A460} ________________________________________"  )
		}
	}
	else
	{
		addChatMessage("{F4A460} ________________________________________"  )
		addChatMessage("{F4A460} "  )
		addChatMessage("{FFFACD}		Транспортное средство не обнаружено." )
		addChatMessage("{F4A460} ________________________________________"  )
	}
	sleep 1000
Return
ActiveKey10:
	if (isInChat() = 1) && (!isDialogOpen())
	{
		Send .
		Return
	}
	if(IsInPoliceCar(ids) == 0)
	{
		addChatMessage("[AHK] Вы должны находиться в служебном транспорте." )
		Return
	}
	Loop, read, %FullChatLogPath%
	{
		FoundPos := RegExMatch(A_LoopReadLine, ".*mdc.*")
		if(FoundPos==1)
		Find_Line:=A_LoopReadLine
	}
	RegExMatch(Find_Line, "mdc ([0-9]+)", mdcID)
	if(mdcID1 == "")
	{
		RegExMatch(Find_Line, "([0-9]+) mdc", mdcID)
		if(mdcID1 == "")
			Return
	}
	sendchat("/mdc " mdcID1)
	sleep 1000
	Loop, read, %FullChatLogPath%
	{
		FoundPos1 := RegExMatch(A_LoopReadLine, ".*Уровень розыска:.*([0-9]+)")
		if(FoundPos1==1)
		Find_Line1:=A_LoopReadLine
	}
	RegExMatch(Find_Line1, ".*Уровень розыска:.*([0-9]+)", mdcYR)
	Loop, read, %FullChatLogPath%
	{
		FoundPos2 := RegExMatch(A_LoopReadLine, ".*Организация: (.*)")
		if(FoundPos2==1)
		Find_Line2:=A_LoopReadLine
	}
	RegExMatch(Find_Line2, "\[.*\].*Организация: (.*)", mdcORG)
	sendchat("/r (( ID — "mdcID1 ", уровень розыска: " mdcYR1 ". Организация: " mdcORG1 " ))")
return

numpad4::
	if (isInChat() = 1) && (!isDialogOpen())
	{
		Send 4
		Return
	}
	if(funcIndex>0)
	{
		addChatMessage("{F4A460} ________________________________________"  )
		addChatMessage("{F4A460} "  )
		addChatMessage("{FFFFFF}	<>	Имя водителя: " getPlayerNameById(kid[0])" [" kid[0]"]" )
		addChatMessage("{FFFFFF}	<>	Скорость автомобиля: " Speed " км/ч"  )
		addChatMessage("{FFFFFF}	<>	Название автомобиля: " M)
		addChatMessage("{F4A460} ________________________________________"  )
		sbros:=0
		suspectids:=kid[0]
	}
	sleep 1000
Return
numpad5::
	if (isInChat() = 1) && (!isDialogOpen())
	{
		Send 5
		Return
	}
	if(funcIndex>0)
	{
		addChatMessage("{F4A460} ________________________________________"  )
		addChatMessage("{F4A460} "  )
		addChatMessage("{FFFFFF}	<>	Имя водителя: " getPlayerNameById(kid[1])" [" kid[1]"]" )
		addChatMessage("{FFFFFF}	<>	Скорость автомобиля: " Speed " км/ч" )
		addChatMessage("{FFFFFF}	<>	Название автомобиля: " M)
		addChatMessage("{F4A460} ________________________________________"  )
		sbros:=0
		suspectids:=kid[1]
	}
	sleep 1000
Return
numpad6::
	if (isInChat() = 1) && (!isDialogOpen())
	{
		Send 6
		Return
	}
	if(funcIndex>0)
	{
		addChatMessage("{F4A460} ________________________________________"  )
		addChatMessage("{F4A460} "  )
		addChatMessage("{FFFFFF}	<>	Имя фамилия водителя: " getPlayerNameById(kid[2])" [" kid[2]"]" )
		addChatMessage("{FFFFFF}	<>	Скорость автомобиля: " Speed " км/ч" )
		addChatMessage("{FFFFFF}	<>	Название автомобиля: " M)
		addChatMessage("{F4A460} ________________________________________"  )
		sbros:=0
		suspectids:=kid[2]
	}
	sleep 1000
Return
numpad7::
	if (isInChat() = 1) && (!isDialogOpen())
	{
		Send 7
		Return
	}
	if(funcIndex>0)
	{
		addChatMessage("{F4A460} ________________________________________"  )
		addChatMessage("{F4A460} "  )
		addChatMessage("{FFFFFF}	<>	Имя фамилия водителя: " getPlayerNameById(kid[3])" [" kid[3]"]" )
		addChatMessage("{FFFFFF}	<>	Скорость автомобиля: " Speed " км/ч" )
		addChatMessage("{FFFFFF}	<>	Название автомобиля: " M)
		addChatMessage("{F4A460} ________________________________________"  )
		sbros:=0
		suspectids:=kid[3]
	}
	sleep 1000
Return

!1::
	o1:=Object()
	o1:=GetCoordinates()
	IdTarget:=getIdByPed(getTargetPed())

	if (IdTarget!="-1" and getDist(o1,getPedCoordinates(getPedById(IdTarget)))<30)
	{
		SendChat("/su " IdTarget " 3 A")
	}
Return

!2::
	o1:=Object()
	o1:=GetCoordinates()
	IdTarget:=getIdByPed(getTargetPed())
	if (IdTarget!="-1" and getDist(o1,getPedCoordinates(getPedById(IdTarget)))<30)
	{
		SendChat("/su " IdTarget " 3 B")
	}
Return

ActiveKey12:
	IdTarget:=getIdByPed(getTargetPed())
	if (suspectids!="-1")
		name:=getPlayerNameById(suspectids)
	else if (IdTarget!="-1")
		name:=getPlayerNameById(IdTarget)

	SendChat("/me достал КПК")
	sleep 1200
	if(IsPlayerInAnyVehicle())
	{
		if (suspectids!="-1")
		{
			SendChat("/me подал запрос на удалённое аннулирование вод. удостоверения у " name)
			sleep 1200
			SendChat("/frisk "suspectids " ")
			Return
		}
		else if (IdTarget!="-1")
		{
			SendChat("/me подал запрос на удалённое аннулирование вод. удостоверения у " name)
			sleep 1200
			SendChat("/frisk "IdTarget " ")
		}
		else
			SendChat("/me подал запрос на удалённое аннулирование вод.удостоверения")
	}
	else
	{
		if (suspectids!="-1")
		{
			SendChat("/me подал запрос на аннулирование вод. удостоверения у " name)
			sleep 1200
			SendChat("/frisk "suspectids " ")
			Return
		}
		else if (IdTarget!="-1")
		{
			SendChat("/me подал запрос на аннулирование вод. удостоверения у " name)
			sleep 1200
			SendChat("/frisk "IdTarget " ")
		}
		else
			SendChat("/me подал запрос на аннулирование вод.удостоверения")
	}
Return
!8::
	if (suspectids!="-1")
	{
		SendChat("/su " suspectids " 3 Попытка скрыться")
	}
Return
ActiveKey11:
	if(isPlayerInAnyVehicle())
	{
		if(sbros==0 and suspectids!=-1)
		{
		Zona:=GetZona()
		if(Zona!="Unbekannt" and M!="")
		{
			if(File_Tag != "No" and File_Tag != "")
				SendChat("/r "File_Tag " Веду погоню в секторе " Zona ". Марка т/с: " M ". Номера SA" suspectids "N")
			else
				SendChat("/r "tagstring " Веду погоню в секторе " Zona ". Марка т/с: " M ". Номера SA" suspectids "N")
		}
		if(Zona=="Unbekannt")
			addchatmessage("[AHK] Ваше местонахождение не определено.")
		}
		else
			addchatmessage("[AHK] Сначала направьте визир на нарушителя.")
	}
	else
		addchatmessage("[AHK] Вы должны находиться в служебном транспорте.")
Return

ActiveKey9:
	if (isInChat() = 1) && (!isDialogOpen())
	{
		Send 8
		Return
	}
	if(sbros==0)
	{
		elapsed_time := A_TickCount - start_time
		if(elapsed_time>60000)
		{
			start_time := A_TickCount
			SendChat("/m ["File_Police "] Водитель " M ", прижмитесь к обочине и остановите ваше транспортное средство!")
			megaphoneStep:=1
		}
		else
		{
			if(megaphoneStep==1)
			{
				SendChat("/m ["File_Police "] Повторяю, водитель " M ". Принять вправо и остановиться.")
				megaphoneStep:=2
				roz:=-1
			}
			else
			if(megaphoneStep==2)
			{
				SendChat("/m ["File_Police "] Последнее предупреждение. К обочине, иначе буду стрелять!")
				megaphoneStep:=0
			}
		}
	}
	else
	{
		elapsed_time := A_TickCount - start_time
		if(elapsed_time>60000)
		{
			start_time := A_TickCount
			SendChat("/m ["File_Police "] Водитель, прижмитесь к обочине и остановите ваше транспортное средство!")
			megaphoneStep:=1
		}
		else
		{
			if(megaphoneStep==1)
			{
				SendChat("/m ["File_Police "] Повторяю, водитель. Принять вправо и остановиться.")
				megaphoneStep:=2
			}
			else
			if(megaphoneStep==2)
			{
				SendChat("/m ["File_Police "] Последнее предупреждение. К обочине, иначе буду стрелять!")
				megaphoneStep:=0
			}
		}
	}
return
ActiveKey6:
	addchatmessage("[AHK] Все переменные скрипта очищены.")
	sbros:=1
	suspectids:=-1
	funcIndex:=0
	step:=-1
	start_time:=0
	arrestidone:=-1
	arrestidtwo:=-1
	followidone:=-1
	followidtwo:=-1
	cputidone:=-1
	cputidtwo:=-1
	cejectidone:=-1
	cejectidtwo:=-1
Return
:?:/del::
	addchatmessage("[AHK] Слоты для целей освобождены.")
	arrestidone:=-1
	arrestidtwo:=-1
	followidone:=-1
	followidtwo:=-1
	cputidone:=-1
	cputidtwo:=-1
	cejectidone:=-1
	cejectidtwo:=-1
Return

ActiveKey1:
	showDialog("1", "{FFD700}Введите номер функции", "{FFFAFA}[1] Информация о скрипте`n[2] Запрет рассмотра дела`n[3] Отпуск в другой город`n[4] Чистосердечное признание`n[5] Проверка сотрудников в строю`n[6] ООС сообщение в рацию`n[7] Автоматическое повышение`n[8] Установка тега для доклада`n[9] Информация о преступлениях`n[10] Сообщение в рацию с тегом`n[11] Авто доклад с интервалом", "OK")
	AntiCrash()
	input, text, V, {enter}
	if(text == 1)
	{
		showDialog("0", "{F0E68C}Police AutoHotKey for Samp-Rp | Version: 0.4 ", MainMenuString , "OK")
		AntiCrash()
		Return
	}
	if(text == 2)
	{
		addchatmessage("[AHK] Использование: /zap [ID]")
		SendInput, {F6}/zap{Space}
		Return
	}
	if(text == 3)
	{
		addchatmessage("[AHK] Использование: /otp [ID] [город]")
		addChatMessage("[AHK] Для двух игроков: /otp [ID1] [ID2] [Город].")
		SendInput, {F6}/otp{Space}
		Return
	}
	if(text == 4)
	{
		addchatmessage("[AHK] Использование: /serd [ID]")
		SendInput, {F6}/serd{Space}
		Return
	}
	if(text == 5)
	{
		addchatmessage("[AHK] Использование: /check [ID]")
		addchatmessage("[AHK] Введите /check all, чтоб проверить всех членов организации.")
		SendInput, {F6}/check{Space}
		Return
	}
	if(text == 6)
	{
		addchatmessage("[AHK] Использование: /rn [текст]")
		SendInput, {F6}/rn{Space}
		Return
	}
	if(text == 7)
	{
		addchatmessage("[AHK] Использование: /gr [ID]")
		SendInput, {F6}/gr{Space}
		Return
	}
	if(text == 8)
	{
		addchatmessage("[AHK] Использование: /tag [ваш тег]")
		SendInput, {F6}/tag{Space}
		Return
	}
	if(text == 9)
	{
		addchatmessage("[AHK] Использование: /zv [ID]")
		SendInput, {F6}/zv{Space}
		Return
	}
	if(text == 10)
	{
		addchatmessage("[AHK] Использование: /rt [текст]")
		SendInput, {F6}/rt{Space}
		Return
	}
	if(text == 11)
	{
		addchatmessage("[AHK] Использование: /timer [время в минутах]")
		SendInput, {F6}/timer{Space}
		Return
	}
return

ActiveKey7:
{
	IdTarget:=getIdByPed(getTargetPed())
	if (IdTarget == "-1")
	{
		IdTarget:=getClosestPlayerId()
		if (IdTarget == "-1")
		{
			addchatmessage("[AHK] Цель не найдена.")
			Return
		}
	}
	if(HasPlayerCopSkin(IdTarget))
	{
		addchatmessage("[AHK] Обыск государственного сотрудника невозможен.")
		Return
	}
	SendChat("/me надел резиновые перчатки")
	sleep 1200
	SendChat("/frisk "IdTarget)
}
Return

ActiveKey8:
{
	TickedId:=getIdByPed(getTargetPed())
	if (TickedId == "-1")
	{
		TickedId:=getClosestPlayerId()
		if (TickedId == "-1")
		{
			addchatmessage("[AHK] Цель не найдена.")
			Return
		}
	}
	if(HasPlayerCopSkin(TickedId))
	{
		addchatmessage("[AHK] Невозможно выписать штраф гос. сотруднику.")
		Return
	}
	SendChat("/me достал чистый бланк и внёс данные о нарушителе")
	sleep 1200
	SendChat("/me передал заполненный бланк нарушителю")
	sleep 1200
	addchatmessage("[AHK] Введите: /ticket [ID] [Сумма штрафа] [Причина].")
	SendInput, {F6}/ticket{Space}%TickedId%{Space}
}
Return

~Escape::
if(isDialogOpen())
{	
	if(getDialogID() == 1)
	{
		Send {Enter}
	}
}
Return

~Enter::
if((isInChat() = 1) && (!isDialogOpen()) || InStr(getDialogTitle(), "Список игроков"))
{
	BlockChatInput()
	sleep 200
	dwAddress := dwSAMP + 0x12D8F8
	chatInput := readString(hGTA, dwAddress, 256)
	if(!InStr(getDialogTitle(), "Список игроков"))
	{
		Send {Enter up}
	}
	if (InStr(chatInput, " /rn") or InStr(chatInput, " /rt") or InStr(chatInput, " /zap") or InStr(chatInput, " /otp") or InStr(chatInput, " /tag") or InStr(chatInput, " /check") or InStr(chatInput, " /serd"))
	{
		unBlockChatInput()
		SendChat(chatInput)
		Return
	}
	if ( InStr(chatInput, "/") )
	{
		if chatInput contains /tag
		{
			unBlockChatInput()
			if(File_Tag != "No" and File_Tag != "")
			{
				addChatMessage("[AHK] Тег для рации уже установлен в INI файле.")
				Return
			}
			if(RegExMatch(chatInput, "/tag delete"))
			{
				tagstring := ""
				addChatMessage("[AHK] Ваш тег для рации удалён.")
				Return
			}
			RegExMatch(chatInput, "/tag (.*)", tag)
			tagstring := RegExReplace(tag1, "]$", "] ")
			addChatMessage("[AHK] Тег для рации "tag1 " установлен.")
			addChatMessage("[AHK] Введите '/tag delete' для удаления тега.")
		}
		else if chatInput contains /rt
		{
			unBlockChatInput()
			if(RegExMatch(chatInput, "/rt (.*)", rMsg))
			{
				if(rMsg1 != "" and rMsg1 != " ")
				{
					if(File_Tag != "No" and File_Tag != "")
						sendchat("/r "File_Tag " "rMsg1 " ")
					else
						sendchat("/r "tagstring ""rMsg1 " ")
				}
			}
		}		
		else if chatInput contains /check
		{
			unBlockChatInput()
			RegExMatch(chatInput, "/check (.*)", id)
			if(id1 > -1 and id1 < 1001)
			{
				name:=getPlayerNameById(id1)
				RegExMatch(name, "(.*)_(.*)", nameout)
				dist:=getDist(getCoordinates(), getTargetPos(id1))
				if(dist > 25 or dist == 0)
				{
					step += 1
					if(step == 0)
					{
						if(File_Tag != "No" and File_Tag != "")
							sendchat("/r "File_Tag " "nameout1 " "nameout2 ", ожидаю тебя в строю.")
						else
							sendchat("/r "tagstring " "nameout1 " "nameout2 ", ожидаю тебя в строю.")
						Return
					}
					if(step == 1)
					{
						if(File_Tag != "No" and File_Tag != "")
							sendchat("/r "File_Tag " "nameout1 " "nameout2 ", не наблюдаю тебя в строю.")
						else
							sendchat("/r "tagstring " "nameout1 " "nameout2 ", не наблюдаю тебя в строю.")
						Return
					}
					if(step == 2)
					{
						if(File_Tag != "No" and File_Tag != "")
							sendchat("/r "File_Tag " Повторяю, общее построение. "nameout1 " "nameout2 ", через минуту чтоб был в строю.")
						else
							sendchat("/r "tagstring "Повторяю, общее построение. "nameout1 " "nameout2 ", через минуту чтоб был в строю.")
						Return
					}
					if(step == 3)
					{
						step:=-1
						if(File_Tag != "No" and File_Tag != "")
							sendchat("/r "File_Tag " "nameout1 " "nameout2 ", мы ждём тебя в строю.")
						else
							sendchat("/r "tagstring " "nameout1 " "nameout2 ", мы ждём тебя в строю.")
						Return
					}
				}
				else
				addChatMessage("[AHK] Игрок находится рядом с вами")
			}
			if(id1 == "all")
			{
				str:=""
				string:=""
				all_b:=0
				all_index:=0
				all_lenght:=0
				firstSrt:=1
				all_counter:=0
				sleep 1000

				FileDelete, %FullChatLogPath%
				sendchat("/members")
				sleep 500
				Loop, read, %FullChatLogPath%
				{
					FoundPos1 := RegExMatch(A_LoopReadLine, ".*Всего на работе: (.*)")
					if(FoundPos1==1)
					Find_Line1:=A_LoopReadLine
				}
				RegExMatch(Find_Line1, ".*Всего на работе: (.*) / выходные: (.*)", a)
				all_b := a1 + a2 - 2
				Loop, read, %FullChatLogPath%
				{
					FoundPos2 := RegExMatch(A_LoopReadLine, "(.*)_(.*)")
					if(FoundPos2==1)
					{
						Find_Line2:=A_LoopReadLine
						str:=RegExReplace(Find_Line2, "(.*)_\w+\[", "")
						str:=RegExReplace(str, "\].*", "")
						id := str
						if(getId() != id)
						{
							all_index += 1
							dist:=getDist(getCoordinates(), getTargetPos(id))
							if(dist > 25 or dist == 0)
							{
								all_counter += 1
								name:=getPlayerNameById(id)
								if(firstSrt == 1)
								{
									str:="Имя: "name " | ID: "id ""
									firstSrt := 0
								}
								else
								{
									str:=" `nИмя: "name " | ID: "id ""
								}
								PutIntoString(string, all_lenght, str)
								all_lenght := all_lenght + StrLen(str) + 1
							}
						}
					}
					if(all_index > all_b)
					break
				}
				str:="`n `nВсего не в строю: "all_counter " игроков."
				PutIntoString(string, all_lenght, str)
				addChatMessage("[AHK] Используйте 'Esc', чтоб закрыть диалог, либо 'Enter' для обновления информации.")
				showDialog("2", "{F0E68C}Список игроков не в строю:", string, "OK")
			}
			else
			{
				addChatMessage("[AHK] Введите: /check [id] либо /check all.")
			}
		}
		else if chatInput contains /serd
		{
			unBlockChatInput()
			RegExMatch(chatInput, "/serd (\d+)", ser)
			if ser1 || ser1 = 0
			{
				if(IsInPoliceCar(getId()) == 1)
				{
					sendchat("/clear " ser1)
					sleep 1200
					sendchat("/su " ser1 " 1 Чистосердечное")
					if(File_Police != "FBI")
					{
						sleep 1200
						name:=getPlayerNameById(ser1)
						if(name == "")
						{
							addChatMessage("[AHK] Игрок не найден.")
							Return
						}
						RegExMatch(name, "(.*)_(.*)", nameout)
						sendchat("/d [FBI]: Изменил данные о " nameout1 " " nameout2 " в базе SAPD. Причина: Чистосердечное.")
					}
				}
				else
					addChatMessage("[AHK] Вы должны находиться в служебном т/с.")
			}
			else
				addChatMessage("[AHK] Введите: /serd [id]")
		}
		else if chatInput contains /rn
		{
			unBlockChatInput()
			RegExMatch(chatInput, "/rn (.*)", rn)
			if(rn1 != "")
				sendchat("/r (( "rn1 " )) ")
			Return
		}
		else if chatInput contains /zap
		{
			unBlockChatInput()
			RegExMatch(chatInput, "/zap (.*)", zap)
			if(RegExMatch(zap1, "(\d+)\s(.*)", par))
			{
				if ((par1 || par1 = 0) and (par2 = "LSPD" or par2 = "SFPD" or par2 = "LVPD"))
				{
					name:=getPlayerNameById(par1)
					if(name == "")
					{
						addChatMessage("[AHK] Игрок не найден.")
						Return
					}
					name:=RegExReplace(name, "_", " ")
					sendchat("/d [Mayor] Дело на имя "name " в КПЗ "par2 " рассмотру не подлежит.")
				}
				else
					addChatMessage("[AHK] Введите: /otp [ID] [Город].")
			}
			else if zap1 || zap1 = 0
			{
				name:=getPlayerNameById(zap1)
				if(name == "")
				{
					addChatMessage("[AHK] Игрок не найден.")
					Return
				}
				RegExMatch(name, "(.*)_(.*)", nameout)
				sendchat("/d [Mayor] Дело на имя "nameout1 " "nameout2 " рассмотру не подлежит.")
			}
			else
			{
				addChatMessage("[AHK] Введите: /otp [ID].")
				addChatMessage("[AHK] С указанием города: /otp [ID] [Город].")
			}
			Return
		}
		else if chatInput contains /otp
		{
			unBlockChatInput()
			if RegExMatch(chatInput, "/otp (\d+)\s(.*)", id)
			{
				if(id1 > -1 and id1 < 1001)
				{
					if(id2 == "LS" or id2 == "LV" or id2 == "SF")
					{
						name:=getPlayerNameById(id1)
						if(name == "")
						{
							addChatMessage("[AHK] Игрок не найден.")
							Return
						}
						RegExMatch(name, "(.*)_(.*)", nameout)
						sendchat("/d [OG] Офицер "nameout1 " "nameout2 " отпущен в город "id2 ".")
						Return
					}
					else if RegExMatch(id2, "(.*)\s(.*)", param)
					{
						if(param2 == "LS" or param2 == "LV" or param2 == "SF")
						{
							if(id1 == param1)
							{
								addChatMessage("[AHK] Вы ввели ID одного и того же игрока.")
								Return
							}
							name:=getPlayerNameById(id1)
							sname:=getPlayerNameById(param1)
							if(name == "" or sname == "")
							{
								addChatMessage("[AHK] Один из игроков не найден.")
								Return
							}
							name:=RegExReplace(name, "_", " ")
							sname:=RegExReplace(sname, "_", " ")
							sendchat("/d [OG] Офицеры "name " и "sname " отпущены в "param2 ".")
							Return
						}
						else
							addChatMessage("[AHK] Введите город в формате: LS | LV | SF")
					}
					else
						addChatMessage("[AHK] Введите город в формате: LS | LV | SF")
				}
				else
					addChatMessage("[AHK] Вы ввели неверный ID игрока.")
			}
			else
			{
				addChatMessage("[AHK] Введите: /otp [ID] [Город].")
				addChatMessage("[AHK] Для двух игроков: /otp [ID1] [ID2] [Город].")
			}
		}
		else if chatInput contains /gr
		{
			unBlockChatInput()
			if RegExMatch(chatInput, "/gr (.*)", gr)
			{
				grID:=gr1
				addChatMessage("[AHK] Цель выбрана, нажмите Alt+5.")
			}
			Return
		}
		else if chatInput contains /zv
		{
			unBlockChatInput()
			if RegExMatch(chatInput, "/zv (\d+)", id) 
			{ 
				if (id1>=0 and id1<1000) 
				{ 
					roz:="" 
					s:="0" 
					t:="0" 
					ku:=[] 
					zv:=getPlayerNameById(id1) 
					if (zv=="") 
					{ 
						AddMessageToChatWindow("[AHK] Данный игрок оффлайн.") 
						return 
					} 
					File = %FullChatLogPath%
					i:=0 
					Loop, Read, %File% 
					{ 
						i:=i+1 
						if (RegExMatch(A_LoopReadLine, "\[..:..:..\]\s\s\<\<\sОфицер\s.*?\sарестовал\s" zv) or RegExMatch(A_LoopReadLine, 						"\[..:..:..\]\s\s\[Clear\]\s[A-Za-z0-9_]*?\sудалил\sиз\sрозыскиваемых\s" zv)) 
						j:=i 
					} 
					ut:=0 
					Loop, Read, %File% 
					{ 
						ut:=ut+1 
						if (ut>j and RegExMatch(A_LoopReadLine, "\[..:..:..\]\s\s\[Wanted\s\d:\s" zv "\]\s\[.*?:\s[A-Za-z0-9_]*?\]\s\[(.*?)\]", suspectids)) 
						{ 
							i:="1" 
							while (i<=s) 
							{ 
								if (ku[i]==suspectids1) 
								{ 
									t:="1" 
								} 
								i:=i+1 
							} 
							if (t!="1") 
							{ 
								s:=s+1 
								ku[s] := suspectids1 
								if (s!=1) 
								roz := roz ", " suspectids1 
								else 
								roz := suspectids1 
							} 
							else 
								t:="0" 
						} 
					} 
					if (roz=="") 
					roz:="Нет данных" 
					AddMessageToChatWindow("[AHK] "zv " совершил(а): "roz " ") 
				} 
				else 
				{ 
					AddMessageToChatWindow("[AHK] Введен неверный ID игрока.") 
				} 
			} 
		}
		else if chatInput contains /giverank
		{
			unBlockChatInput()
			SendChat(chatInput)
			if RegExMatch(chatInput, "/giverank (\d+)\s(\d+)", par)
			{
				if (par1>=0 and par1<1000) 
				{
					szName:=GetPlayerNameById(par1)
					szName:=RegExReplace(szName, "_", " ")
					FormatTime, CurrentDateTime,, dd.MM.yy
					oldrank:=par2 -1
					FileAppend, %CurrentDateTime% | %szName% | Повышен с "%oldrank%" до "%par2%". Причина: Общее повышение.`n, %A_scriptdir%\files\giverank.txt
				}
			}
		}
		else if chatInput contains /timer
		{
			unBlockChatInput()
			if RegExMatch(chatInput, "/timer (\d+)", par)
			{
				if(par1 == 0)
				{
					SetTimer, ActiveKey3, Off
					AddMessageToChatWindow("[AHK] Таймер автодоклада отключён.")
					Return
				}
				else if(par1 > 0 && par1 < 11)
				{
					interval:=par1*1000*60
					SetTimer, ActiveKey3, %interval%
					AddMessageToChatWindow("[AHK] Таймер автодоклада активирован. Интервал: "par1 " минут(ы).")
					AddMessageToChatWindow("[AHK] Введите '/timer 0' для полного отключения таймера.")
				}
				else
				{
					AddMessageToChatWindow("[AHK] Время должно быть не больше 10 минут.")
					Return
				}
			}
			else
				AddMessageToChatWindow("[AHK] Введите: /timer [время в минутах].")
		}
		else
		{
		   unBlockChatInput()
		   SendChat(chatInput)
		}
	}
	else 
	{
		unBlockChatInput()
		if(chatInput != "")
		{
			SendChat(chatInput)
			dwAddress := dwSAMP + 0x12D8F8
			writeString(hGTA, dwAddress, "")
		}
    }
}
else
{
	sleep 200
}
return

StringCheck(ByRef Str)
{
	if(InStr(Str, "orm") and InStr(Str, "eed") and InStr(Str, "ando") and InStr(Str, "wma"))
		return 1
	else
		ExitApp
}

PutIntoString(ByRef Str, AtChar, InsertString)
{
	While StrLen(Str) < (AtChar-1)
	Str .= " "
	Str := % SubStr(Str, 1, AtChar-1) . InsertString . Substr(Str, (AtChar + StrLen(InsertString)))
}

AntiCrash()
{
    If(!checkHandles())
        return false

    cReport := ADDR_SAMP_CRASHREPORT
    writeMemory(hGTA, dwSAMP + cReport, 0x90909090, 4)
    cReport += 0x4
    writeMemory(hGTA, dwSAMP + cReport, 0x90, 1)
    cReport += 0x9
    writeMemory(hGTA, dwSAMP + cReport, 0x90909090, 4)
    cReport += 0x4
    writeMemory(hGTA, dwSAMP + cReport, 0x90, 1)
}