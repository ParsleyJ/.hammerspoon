require("hs.ipc") -- for hammerspoon cli

--------------------------------------------
-- Monitor and reload config when the file changes
--------------------------------------------
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon: Config loaded")

--------------------------------------------
-- some init.lua locals
--------------------------------------------

local builtInScreenName = "Color LCD"
local acerScreenName = "X223W"
local iDisplayScreenName = "Android"
local hyper = {"cmd", "alt", "ctrl", "shift"}
local mash = {"cmd", "alt", "ctrl"}
local cmd = {"cmd"}
pj = require("pjhammerspoon")
appman = require("appmanager")
http = require("httpserver")
wman = require("wmanager")
chsr = require("chooser")


--------------------------------------------
-- wifi watcher
--------------------------------------------

wifiwatcher = hs.wifi.watcher.new(function ()
    net = hs.wifi.currentNetwork()
    if net==nil then
        hs.notify.show("Wifi disconnected","","","")
    else
        hs.notify.show("Wifi connected","",net,"")
    end
end)
wifiwatcher:start()

--------------------------------------------
-- key bindings
--------------------------------------------

quickSwitchHotkeys = {
    F = "Finder",
    E = "Sublime Text",
    I = "iTunes",
    A = "Supertab for Whatsapp",
    O = "Sunrise Calendar",
    Q = "Telegram",
    R = "Safari",
    T = "Todoist",
    U = "Alternote",
    W = "Airmail 2",
    Y = "Pocket"
}

for key, app in pairs(quickSwitchHotkeys) do
    hs.hotkey.bind(hyper, key, function() appman.quickSwitch(app)end)
end

hs.hotkey.bind(hyper, "1", "Copy and show Whatsapp", function()
    pj.copy()
    appman.activateApp("Whatsapp")
end)
hs.hotkey.bind(hyper, "2", "Copy and show Telegram", function()
    pj.copy()
    appman.activateApp("Telegram")
end)
hs.hotkey.bind(hyper, "3", "New mail with selection", function()
    local text = pj.getSelectedText()
    hs.eventtap.keyStroke(mash, "W")
    hs.timer.doAfter(1,function()
        hs.eventtap.keyStroke({}, "tab")
        hs.eventtap.keyStroke({}, "tab")
        hs.eventtap.keyStrokes(text)
    end)
end)
hs.hotkey.bind(hyper, "4", "New text document with selection", function()
    local text = pj.getSelectedText()
    appman.activateApp("Sublime Text")
    hs.eventtap.keyStroke(cmd, "N")
    hs.eventtap.keyStrokes(text)
end)
hs.hotkey.bind(hyper, "5", "Search/GoTo selection in Safari", function()
    local text = pj.getSelectedText()
    appman.activateApp("Safari")
    hs.eventtap.keyStroke(cmd,"T")
    hs.eventtap.keyStroke(cmd,"L")
    hs.eventtap.keyStrokes(text)
    hs.eventtap.keyStroke({}, "return")
end)
hs.hotkey.bind(hyper, "6", "New Todo with selection", function()
    local text = pj.getSelectedText()
    hs.eventtap.keyStroke(mash,"T")
    hs.eventtap.keyStrokes(text)
end)
hs.hotkey.bind(hyper, "7", "Safari URL to Pocket", function()
    local theURL = pj.getSafariCurrentURL()
    if theURL then
        local systemClipboard = hs.pasteboard.getContents()
        hs.pasteboard.setContents(theURL)
        appman.activateApp("Pocket")
        hs.eventtap.keyStroke(cmd,"S")
        hs.pasteboard.setContents(systemClipboard)
        appman.switchToLastApp()
    end
end)
hs.hotkey.bind(hyper, "8", "New note with selection", function()
    local text = pj.getSelectedText()
    appman.activateApp("Alternote")
    hs.eventtap.keyStroke(cmd,"N")
    hs.eventtap.keyStroke(cmd,".")
    hs.eventtap.keyStrokes(text)
    appman.switchToLastApp()
end)

hs.hotkey.bind(hyper, "9", "Safari URL to music downloader", function()
    local theURL = pj.getSafariCurrentURL()
    if theURL then
        if string.find(theURL, "youtube.com") then
            pj.toast("Downloading YouTube audio")
            local logfile = "/Users/Giuseppe/Downloads/YouTube/log.txt"
            local envcommand = "export PATH=/opt/local/bin:/opt/local/sbin:/opt/local/bin/python2.7:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/Applications/SWI-Prolog.app/Contents/MacOS:/opt/X11/bin:/usr/texbin"
            local mvcommand = 'mv {} \\"/iTunes/iTunes Media/Automatically Add to iTunes.localized/\\"'
            local dlcommand = "/usr/local/bin/youtube-dl -f bestaudio -x --audio-format mp3 --audio-quality 0 -o '/Users/Giuseppe/Downloads/YouTube/%(title)s.%(ext)s'  --exec '"..mvcommand.."' "..theURL.." > "..logfile
            local command = envcommand.." ; "..dlcommand
            local ok, result = hs.applescript._applescript('do shell script "'..command..'"')
            if ok then
                pj.toast("Success!")
                print(result)
            else
                pj.toast("Error!")
                print(result)
                hs.openConsole()
                os.execute("open /Users/Giuseppe/Downloads/Youtube/")
            end
        else
            pj.toast("Downloading Soundcloud audio")
            hs.application.open("Soundcloud Downloader", 1, true)
            hs.eventtap.keyStrokes(theURL)
            hs.eventtap.keyStroke({}, "return")
        end
    end
end)

hs.hotkey.bind(hyper, "N", hs.toggleConsole)

hs.hotkey.bind(hyper, "è", wman.goToLeftSpace)
hs.hotkey.bind(hyper, "+", wman.goToRightSpace)
hs.hotkey.bind(hyper, "ì", function() wman.moveWindowOneSpace("right") end)
hs.hotkey.bind(hyper, "'", function() wman.moveWindowOneSpace("left") end)

hs.hotkey.bind(hyper, "S", function() wman.toggleGrid(3,3) end)
hs.hotkey.bind(hyper, "D", function() wman.toggleGrid(4,4) end)

hs.hotkey.bind(hyper, "0", wman.moveWindowNextScreen)
hs.hotkey.bind(hyper, "P", wman.toggleFullscreen)
hs.hotkey.bind(hyper, "ò", wman.maximizeWindow)

hs.hotkey.bind(hyper, "à", wman.smartSnapAndResizeLeft)
hs.hotkey.bind(hyper, "ù", wman.smartSnapAndResizeRight)

hs.hotkey.bind(hyper, "L", appman.saveAppShortcut)
hs.hotkey.bind(hyper, "K", appman.activateSavedShortcut)
hs.hotkey.bind(hyper, "M", http.toggleServer)

-- local chooser = hs.chooser.new(function(result)
--     if result ~= null then
--         pj.toast("ok")
--         print(hs.inspect(result))
--     else
--         pj.toast("dismissed")
--     end
-- end)
-- local choices = {
--     {
--         ["text"] = "First Choice",
--         ["subText"] = "This is the subtext of the first choice",
--         ["uuid"] = "0001"
--     },
--     {
--         ["text"] = "Second Option",
--         ["subText"] = "I wonder what I should type here?",
--         ["uuid"] = "Bbbb"
--     },
--     {
--         ["text"] = "Third Possibility",
--         ["subText"] = "What a lot of choosing there is going on here!",
--         ["uuid"] = "III3"
--     },
-- }
-- chooser:choices(choices)
-- hs.hotkey.bind(hyper, "space", function()
--     chooser:show()
-- end)
hs.hotkey.bind(hyper, "space", function()
    chsr.fastChooser({
        {
            ["text"] = "First Choice",
            ["subText"] = "This is the subtext of the first choice",
            ["uuid"] = "0001"
        },
        {
            ["text"] = "Second Option",
            ["subText"] = "I wonder what I should type here?",
            ["uuid"] = "Bbbb"
        },
        {
            ["text"] = "Third Possibility",
            ["subText"] = "What a lot of choosing there is going on here!",
            ["uuid"] = "III3"
        },
    }, function(result)
        pj.toast(hs.inspect(result))
    end, function()
        pj.toast("dismissed")
    end):show()
end)

local recognizer = nil

local speaker = hs.speech.new()

hs.hotkey.bind(hyper, "tab", function()
    if recognizer==nil then
        recognizer = hs.speech.listener.new()
        recognizer:commands({"casa", "prova", "palla"})
        recognizer:setCallback(function(recog, comm)
            recognizer:stop()
            speaker:speak("Hai detto  "..comm..".")
            recognizer:start()
        end)
        recognizer:start()
    else
        recognizer:delete()
        recognizer=nil
    end
end)

