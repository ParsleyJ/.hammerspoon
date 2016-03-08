local wman = {}

local mouse = hs.mouse
local hyper = {"cmd", "alt", "ctrl", "shift"}

wman.margins = hs.geometry.size(0, 0)
hs.grid.setMargins(wman.margins)
hs.grid.HINTS = {
    { "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10" },
    { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
    { "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P" },
    { "A", "S", "D", "F", "G", "H", "J", "K", "L", "ò" },
    { "Z", "X", "C", "V", "B", "N", "M", ",", ".", "-" }
}
hs.window.animationDuration = 0

function wman.toggleGrid(w, h)
	hs.grid.setGrid(hs.geometry.size(w,h))
    hs.grid.toggleShow()
end

function wman.goToLeftSpace()
	hs.eventtap.keyStroke({"ctrl"}, "left")
end

function wman.goToRightSpace()
	hs.eventtap.keyStroke({"ctrl"}, "right")
end

function wman.goToSpaceAt(direction)
	hs.eventtap.keyStroke({"ctrl"}, direction)
end

function wman.moveWindowOneSpace(direction)
    local mouseOrigin = mouse.getAbsolutePosition()
    local win = hs.window.focusedWindow()
    local clickPoint = win:zoomButtonRect()

    clickPoint.x = clickPoint.x + clickPoint.w + 5
    clickPoint.y = clickPoint.y + (clickPoint.h / 2)

    local mouseClickEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, clickPoint)
    mouseClickEvent:post()
    hs.timer.usleep(150000)

    local nextSpaceDownEvent = hs.eventtap.event.newKeyEvent({"ctrl"}, direction, true)
    nextSpaceDownEvent:post()
    hs.timer.usleep(150000)

    local nextSpaceUpEvent = hs.eventtap.event.newKeyEvent({"ctrl"}, direction, false)
    nextSpaceUpEvent:post()
    hs.timer.usleep(150000)

    local mouseReleaseEvent = hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, clickPoint)
    mouseReleaseEvent:post()
    hs.timer.usleep(150000)

    mouse.setAbsolutePosition(mouseOrigin)
end

function wman.moveWindowNextScreen()
	local window = hs.window.frontmostWindow()
    if window ~= nil then
        window:moveToScreen(hs.screen.mainScreen():next())
        window:focus()
        hs.window.desktop():focus()
        window:focus()
    end
end

function wman.toggleFullscreen()
	window = hs.window.frontmostWindow()
    if window ~= nil then
        window:toggleFullScreen(true)
    end
end

function wman.maximizeWindow()
	window = hs.window.frontmostWindow()
    if window ~= nil then
        window:maximize()
    end
end

local startFraction = 0.2639
local fraction = startFraction
local justPressedDirection = ""
function cycleFraction()
    if fraction == 0.7361 then
        fraction = 0.67
    elseif fraction == 0.67 then
        fraction = 0.50
    elseif fraction == 0.50 then
        fraction = 0.33
    elseif fraction == 0.33 then
        fraction = 0.2639
    elseif fraction == 0.2639 then
        fraction = 0.7361
    end
    return fraction
end

function wman.smartSnapAndResizeRight()
	window = hs.window.frontmostWindow()
    if justPressedDirection ~= "right" then
        fraction = startFraction
        justPressedDirection = "right"
    end
    if window ~= nil then
        fr = cycleFraction()
        window:moveToUnit(hs.geometry.rect(1 - fr, 0, fr, 1))
    end
end

function wman.smartSnapAndResizeLeft()
	window = hs.window.frontmostWindow()
    if justPressedDirection ~= "left" then
        fraction = startFraction
        justPressedDirection = "left"
    end
    if window ~= nil then
        window:moveToUnit(hs.geometry.rect(0, 0, cycleFraction(), 1))
    end
end

return wman