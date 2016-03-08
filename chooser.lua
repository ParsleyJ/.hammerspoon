chsr = {}

function chsr.fastChooser(opts, onChosen, onDismissed)
	local chosr = hs.chooser.new(function(result)
		if result == nil then
			onDismissed()
		else
			onChosen(result)
		end
	end)
	chosr:choices(opts)
	-- chosr:bgDark(true)
	-- chosr:fgColor(hs.drawing.color.asRGB({1,1,1,1}))
	-- chosr:subTextColor(hs.drawing.color.asRGB({1,1,1,1}))
	return chosr
end

return chsr