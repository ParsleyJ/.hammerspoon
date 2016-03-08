local pj = {}

local hyper = {"cmd", "alt", "ctrl", "shift"}

function pj.toast(toBePrinted)
    hs.alert.show(toBePrinted)
end

function pj.copy()
    hs.eventtap.keyStroke({"cmd"}, "C")
end

function pj.getSelectedText()
    local oldText = hs.pasteboard.getContents()
    hs.eventtap.keyStroke({"cmd"}, "c")
    hs.timer.usleep(100000)
    local text = hs.pasteboard.getContents()
    hs.pasteboard.setContents(oldText)
    return text
end


function pj.getSafariCurrentURL()
    --if hs.application.frontmostApplication():name()=="Safari" then
        local ok, theURL = hs.applescript.applescript [[
            set theURL to ""
            tell application "Safari"
              set theURL to URL of current tab of window 1
            end tell
            return theURL
        ]]
        if ok then
            return theURL
        else
            pj.toast("An error occured while getting Safari's URL")
            return nil
        end
    --else
    --    pj.toast("Safari is not the frontmost application")
    --    return nil
    --end
end

return pj
