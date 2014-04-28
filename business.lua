xml = require "LuaXML"
bgtools = require "bgtools"


Sector = xml.load("sectors.xml")
Products = xml.load("products.xml")

bgtools.init(Sector, Products)

function arg_get(str)
	local out = {} 
	for match in string.gmatch(str or "", "%w+") do 
		table.insert(out, match:lower())
	end 
	return out
end 

local cmds = {} 

function cmds.q()
	print("Goodbye")
	os.exit()
end 

function cmds.list(args)
	local what = args[1]
	if what:match("^sector") then 
		local sectors = bgtools.GetSectors()
		for i,v in pairs(sectors) do 
			print(v)
		end 
	end 
end 


while true do 
	local cmd = io.read()
	local args = arg_get(cmd) 
	if args then 
		local root_cmd = args[1] and args[1]:lower() 
		if root_cmd and cmds[root_cmd] then 
			-- remove first arg
			table.remove(args,1)
			cmds[root_cmd](args)
		end 
	end 
end
