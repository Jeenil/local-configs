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
; "wt.exe" is not the real process name: https://stackoverflow.com/a/68006153/26408392
^1:: CycleOrLaunch("ahk_exe WindowsTerminal.exe", A_AppData . "\..\Local\Microsoft\WindowsApps\wt.exe")
; Open/activate VS Code
^2:: CycleOrLaunch("ahk_exe code.exe", "code.exe")
; Open/activate VSCodium
^3:: CycleOrLaunch("ahk_exe VSCodium.exe", "wsl.exe codium")
; Open/activate Chrome
^4:: CycleOrLaunch("ahk_exe chrome.exe", "chrome.exe")
; Open/activate Edge
^5:: CycleOrLaunch("ahk_exe msedge.exe", "msedge.exe")
; Open/activate Microsoft Teams
^6:: CycleOrLaunch("ahk_exe ms-teams.exe", "ms-teams.exe")
; Open/activate File Explorer
^7:: CycleOrLaunch("ahk_class CabinetWClass", "explorer.exe")

CycleOrLaunch(winCriteria, launchCmd) {
    titledWindows := []
    for hwnd in WinGetList(winCriteria) {
        if (WinGetTitle(hwnd) != "")
            titledWindows.Push(hwnd)
    }
    if (titledWindows.Length = 0) {
        Run(launchCmd)
        return
    }
    titledWindows := SortNumArray(titledWindows)
    activeHwnd := WinGetID("A")
    activeIndex := 0
    for i, hwnd in titledWindows {
        if (hwnd = activeHwnd) {
            activeIndex := i
            break
        }
    }
    nextIndex := Mod(activeIndex, titledWindows.Length) + 1
    WinActivate("ahk_id " titledWindows[nextIndex])
}