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
	if what and what:match("^sector") then 
		local sectors = bgtools.GetSectors()
		table.sort(sectors)
		for i,v in pairs(sectors) do 
			print(v)
		end 
	elseif what and  what:match("^product") then 
		local products = bgtools.GetProductList()
		table.sort(products) 
		for i,v in pairs(products) do 
			print(v)
		end 
	else 
		print("Cannot list type: ".. (what or "") .." try: sector, product")
	end
end 

function cmds.help()
	print("Available commands:")
	for i,v in pairs(cmds) do 
		if v ~= cmds.help then 
			print(i)
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
			io.write("\n")
		end 
	end 
end
