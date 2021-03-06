require "LuaXML"
assert(xml)
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

function cmds.quit()
	print("Goodbye!")
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
	elseif what and what:match("^tag") then 
		local tag_type = args[2] 
		if tag_type and tag_type:match("^sector") then 
			local tags = bgtools.GetValues(bgtools.sector[1])
			for i,v in pairs(tags) do 
				print(v) 
			end 
		elseif tag_type and tag_type:match("^product") then 
			local tags = bgtools.GetValues(bgtools.products[1])
			for i,v in pairs(tags) do 
				print(v) 
			end
		end
	else 
		print("Cannot list type: ".. (what or "") .." try: sector, product")
	end
end 

function cmds.update()
	bgtools.fileupdate()
end

function cmds.help()
	print("Available commands:")
	for i,v in pairs(cmds) do 
		if v ~= cmds.help then 
			print(i)
		end 
	end 
end

	local function get_name(args, lim)
		local sector = ""
		for i = lim or 2, #args do 
			sector = sector .. " " .. args[i]
		end 
		sector = sector:sub(2, sector:len())
		return sector 
	end 

function cmds.info(args)
	if args[1] == "sector" then 
		local sector = get_name(args)
		bgtools.PrintSectorInfo(sector)
	elseif args[1] == "product" then 
		local product = get_name(args)
		bgtools.PrintProductInfo(product)
	else 
		print("Could not find info on ".. (args[1] or "")..", try product or sector")
	end 
end 

function cmds.usage(args, nope) 
	local product = args[1]
	if not product or not bgtools.GetProduct(product) then 
		print(product.. " is not a valid product!")
		return 
	end 
	bgtools.PrintProductUses(product, nope)
end

function cmds.notusage(args)
	cmds.usage(args, true)
end

function cmds.valueincrease(args)
	local sector = get_name(args,1)
	local diff, round, input, output = bgtools.SectorAddedValue(sector) 
	local use = "+"
	if round < 0 then 
		use = ""
	end
	print("Input worth  : "..input)
	print("Output worth : " .. output)
	print("Added value  : ".. diff .. " ("..use .. round .. "%)")
end

function cmds.sort(args)
	if args[1] == "valueincrease" then 
		local mode = "absolute"
		if args[2] == "relative" then 
			mode = "relative"
		end 
		-- sort on value increase -> absolute / relative ?
	else 
		local type = args[1]
		if type:lower():match("^product") then 
			local products = bgtools.GetProductList()
			local tab = {}
			local tagger = args[2] 
			for i,v in pairs(products) do 
				local root = bgtools.GetProduct(v)
				local tag = root:find(tagger)
				if tag then 
					tab[i] = {v, tag[1]}
				end 
			end 
			table.sort(tab, function(a,b) return tonumber(a[2]) > tonumber(b[2]) end)

			for i,v in pairs(tab) do 
				bgtools.pd(i..". "..v[1], v[2])
			end
		elseif type:lower():match("^sector") then 
			local sectors = bgtools.GetSectors()
			local tab = {}
			local tagger = args[2] 
			for i,v in pairs(sectors) do 
				local root = bgtools.GetSector(v)
				local tag = root:find(tagger)
				if tag then 
					tab[i] = {v, tag[1]}
				end 
			end 
			table.sort(tab, function(a,b) return tonumber(a[2]) > tonumber(b[2]) end)

			for i,v in pairs(tab) do 
				bgtools.pd(i..". "..v[1], v[2])
			end
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
			io.write("\n")
			local success, err = pcall(function() cmds[root_cmd](args) end)
			if err then 
				print("Command error: "..err)
			end
			io.write("\n")
		else 
			print("Command ".. (args[1] or "") .. " is unknown: type help for more information on this utility.")
		end 
	end 
end
