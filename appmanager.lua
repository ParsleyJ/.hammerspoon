local appm = {}
local pj = require("pjhammerspoon")

appm.callbackTable = {}
appm.applicationShortcut = {}
appm.applicationShortcut[""] = "Finder";
appm.lastApp = "Finder"

function appm.handleApplicationEventCallbacks(name, typ, appObject)
    for key, callback in pairs(appm.callbackTable) do
        if key[0] == name and key[1] == typ and callback ~= nil then
            callback(appObject)
            if(key[2]) then -- if temp
                appm.callbackTable[{name, typ, true}] = nil;
            end
        end
    end
end

function appm.addApplicationEventCallback(name, typ, callback, temp)
    appm.callbackTable[{name, typ, temp}] = callback;
end

function appm.removeApplicationEventCallback(name, typ, temp)
    temp = temp or false
    appm.callbackTable[{name, typ, temp}] = nil
end

function appm.doAfterApplicationEvent(name, typ, callback)
    appm.addApplicationEventCallback(name, typ, callback, true)
end


hs.application.watcher.new(function(name, typ, appObject)
    if typ == hs.application.watcher.deactivated then
        appm.lastApp = name
    end
    appm.handleApplicationEventCallbacks(name, typ, appObject)
end):start()

function appm.activateApp(app)
    hs.application.launchOrFocus(app)
end

function appm.saveAppShortcut(shortcutId)
    shortcutId = shortcutId or ""
    appm.applicationShortcut[shortcutId] = hs.window.focusedWindow():application():name();
    pj.toast("Saved shortcut: " .. appm.applicationShortcut[shortcutId])
end

function appm.activateSavedShortcut(shortcutId)
    shortcutId = shortcutId or ""
    appm.quickSwitch(appm.applicationShortcut[shortcutId])
    pj.toast("Using saved shortcut: " .. appm.applicationShortcut[shortcutId])
end

function appm.switchToLastApp()
    if appm.lastApp ~= nil then
        hs.application.launchOrFocus(appm.lastApp)
    end
end

function appm.quickSwitch(appname)
    if hs.application.frontmostApplication():name()~=appname then
        pj.toast("Switching to "..appname)
        appm.activateApp(appname)
    else
        pj.toast("Switch to last application: " .. appm.lastApp)
        appm.switchToLastApp()
    end
end




return appm