local pj = require("pjhammerspoon")
local appm = require("appmanager")
local httpstarted = true
local http = {}
http.server = hs.httpserver.new()
http.server:setPort(12121)



function http.toggleServer()
	if httpstarted then
        http.server:stop()
        pj.toast("HTTP server stopped")
    else
        http.server:start()
        pj.toast("HTTP server started, port: "..http.server:getPort())
    end
    httpstarted = not httpstarted
end

function http:isStarted()
	return httpstarted
end

function http.unescapeurl (s)
      s = string.gsub(s, "+", " ")
      s = string.gsub(s, "%%(%x%x)", function (h)
            return string.char(tonumber(h, 16))
          end)
      return s
end

function mysplit(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end



function generateHTTPResponse(body)
	return body, 200, {}
end

function getPlayingStateHTTPResponse()
	if hs.itunes.isPlaying() then
		return "iTunes is Playing: "..hs.itunes.getCurrentTrack(), 200, {}
	else
		return "iTunes is Playing: ", 200, {}
	end
end

http.server:setCallback(function (requestType, path)
	local unescapedpath = http.unescapeurl(path)
	local splitted = mysplit(unescapedpath, "/")
	hs.alert.show(requestType.." "..path)
	pj.toast(splitted[2])
	if splitted[2] == "app" then
		if splitted[3]~=nil then
			pj.toast(splitted[3])
			appm.activateApp(splitted[3])
			return generateHTTPResponse("App launched: "..splitted[3])
		end
	elseif splitted[2] == "itunes" then
		if splitted[3]~=nil then
			pj.toast(splitted[3])
		end
		if splitted[3] == "next" then
			hs.itunes.next()
			return "Next: "..hs.itunes.getCurrentTrack(), 200, {}
		elseif splitted[3] == "previous" then
			hs.itunes.previous()
			return "Previous: "..hs.itunes.getCurrentTrack(), 200, {}
		elseif splitted[3] == "playpause" then
			hs.itunes.playpause()
			return getPlayingStateHTTPResponse();
		elseif splitted[3] == "play" then
			hs.itunes.play()
			return getPlayingStateHTTPResponse();
		elseif splitted[3] == "pause" then
			hs.itunes.pause()
			return getPlayingStateHTTPResponse();
		elseif splitted[3] == "filter" then
			if splitted[4] == nil or splitted[4] == "" then
				--todo select search field and backspace all
			else
				--todo select search fiels and insert search, then enter
			end
		end
	elseif splitted[2] == "bigtext" then
		if splitted[3] ~= nil then
			pj.toast(splitted[3])
			hs.eventtap.keyStroke({"cmd"}, "space") --shows alfred
			hs.timer.doAfter(1, function()
				hs.eventtap.keyStrokes(splitted[3])
				hs.eventtap.keyStroke({"cmd", "alt"}, "L")
			end)
			generateHTTPResponse("Done.")
		end
	end
	return "Invalid request.", 200, {}
end)
http.server:start()
return http