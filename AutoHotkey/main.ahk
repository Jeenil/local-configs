; ------------
; CORE HOTKEYS
; ------------

^+!r:: Reload
#SuspendExempt True
^+!s:: Suspend
#SuspendExempt False

#Down::WinMinimize("A")

; Cycle program windows forward.
#Tab::{
  activeProcessName := WinGetProcessName("A")
  windowIDs := WinGetList("ahk_exe " activeProcessName)

  if (windowIDs.Length <= 1) {
    return
  }

  sortedWindowIDs := SortNumArray(windowIDs)
  activeWindowID := WinGetID("A")
  activeWindowIndex := 0

  for index, windowID in sortedWindowIDs
  {
    if (windowID = activeWindowID)
    {
      activeWindowIndex := index
      break
    }
  }

  if (activeWindowIndex = 0)
  {
    return
  }

  nextWindowIndex := activeWindowIndex + 1
  if (nextWindowIndex > sortedWindowIDs.Length)
  {
    nextWindowIndex := 1
  }

  nextWindowID := sortedWindowIDs[nextWindowIndex]
  WinActivate("ahk_id " nextWindowID)
}

; Cycle program windows backward.
#+Tab::{
  activeProcessName := WinGetProcessName("A")
  windowIDs := WinGetList("ahk_exe " activeProcessName)

  if (windowIDs.Length <= 1) {
    return
  }

  sortedWindowIDs := SortNumArray(windowIDs)
  activeWindowID := WinGetID("A")
  activeWindowIndex := 0

  for index, windowID in sortedWindowIDs
  {
    if (windowID = activeWindowID)
    {
      activeWindowIndex := index
      break
    }
  }

  if (activeWindowIndex = 0)
  {
    return
  }

  previousWindowIndex := activeWindowIndex - 1
  if (previousWindowIndex < 1)
  {
    previousWindowIndex := sortedWindowIDs.Length
  }

  previousWindowID := sortedWindowIDs[previousWindowIndex]
  WinActivate("ahk_id " previousWindowID)
}

; From: https://www.autohotkey.com/boards/viewtopic.php?t=113911
SortNumArray(arr) {
	str := ""
	for k, v in arr {
		str .= v "`n"
  }
	str := Sort(RTrim(str, "`n"), "N")
	return StrSplit(str, "`n")
}

; Open/activate Windows Terminal
^1:: {
    ; "wt.exe" is not the real process name:
    ; https://stackoverflow.com/a/68006153/26408392
    if (WinExist("ahk_exe WindowsTerminal.exe")) {
        WinActivate("ahk_exe WindowsTerminal.exe")
    } else {
        Run(A_AppData . "\..\Local\Microsoft\WindowsApps\wt.exe")
    }
}

; Open/activate VS Code
^2::
{
    if WinExist("ahk_exe code.exe") {
        WinActivate("ahk_exe code.exe")
    } else {
        Run("code.exe")
    }
}

;  Obsidien
^3:: ; Ctrl +  to open Obsidien
{
    if WinExist("ahk_exe obsidian.exe") {
        WinActivate("ahk_exe obsidian.exe")
    } else {
        Run("obsidian.exe")
    }
}


; Chrome
^4:: ;Ctrl + 4 to open Chrome
{
    if WinExist("ahk_exe chrome.exe") {
        WinActivate("ahk_exe chrome.exe")
    } else {
        Run("chrome.exe")
    }
}

;  Edge
^5:: ; Ctrl + 5 to open edges
{
    if WinExist("ahk_exe msedge.exe") {
        WinActivate("ahk_exe msedge.exe")
    } else {
        Run("msedge.exe")
    }
}

; Open/activate Notepad++
^6::  ; Ctrl + 6 to open Notepad++
{
    if WinExist("ahk_exe notepad++.exe") {
        WinActivate("ahk_exe notepad++.exe")
    } else {
        Run("notepad++.exe")
    }
}