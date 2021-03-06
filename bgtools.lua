local xml = require "LuaXML"

local debug = false 

local bgtools = {}

function bgtools.GetValues(root)
	local tags = {} 
	local data = tostring(root)
	for match in string.gmatch(data, "<([^>]*)>") do 
		local tag = root:find(match)
		if tag then 
		local my = tag[1]
		if not tostring(my):match("<([^>]*)>") then 
			tags[match] = true 
		end
		end
	end 
	local out = {} 
	for i,v in pairs(tags) do 
		table.insert(out, i)
	end 
	return out
end 

function bgtools.GetSector(sectorname)
	for sector_number, sector_data in pairs(bgtools.sector) do 
		if sector_data:find("name") and sector_data:find("name")[1]:lower() == sectorname:lower() then 
			return sector_data 
		end 
	end 
end 	

function bgtools.GetProduct(productname)
	for product_number, product_data in pairs(bgtools.products) do 
		if product_data:find("name") and product_data:find("name")[1]:lower() == productname:lower() then 
			return product_data
		end 
	end 
end 

function bgtools.FindTag(root, prop, val) 
	for i, data in pairs(root) do 
		if data:find(prop) and data:find(prop)[1]:lower() == val:lower() then 
			return data 
		end 
	end
end 

function bgtools.GetProductInfo(product_root)
	-- name and amount
	local product = {} 
	--print(product_root)
	local name = getval(product_root, "name")
	local amount = getval(product_root, "amount") 
	if name and amount then 
		product.name = name 
		product.amount = amount 
		return product 
	end 
	return false 
end 

function bgtools.GetSectorInputs(sectorname) 
	local sector = bgtools.GetSector(sectorname) 
	if sector and sector:find("input") then 
		local output = {} 
		local input_root = sector:find("input")
		for product_number, data in pairs(input_root) do 
			local wanted_data = bgtools.GetProductInfo(data) 
			if wanted_data then 
				table.insert(output, wanted_data)
			end 
		end
		return output
	end 
	return false 
end 

function getval(root, value)
	if root and root:find(value) then 
		if root:find(value)[1] ~= nil then 
			return (root:find(value)[1])
		end 
	end
	if debug then  
	print("warning: getval did not return anything, root:".. tostring(root) .. " value: ".. tostring(value))
	end 
end 

function bgtools.GetProducts(product_data_root)
	local out = {}
	for num, data in pairs(product_data_root) do 
		local wanted_data = bgtools.GetProductInfo(data) 
		if wanted_data then 
			table.insert(out, wanted_data)
		end 
	end 
	return out
end

function bgtools.ParseProducts(product_list, start)
	for num, product_data in pairs(product_list) do 
		pd((start or "") .. product_data.name, product_data.amount)
		
	end
end 

-- print data utility
function pd(name, value, len)
	if not name or not value then 
		return 
	end 
	local len = len or 30
	if string.len(name) < len then 
		local need = len - string.len(name)
		name = name .. string.rep(" ", need)
	end 
	print(name..": "..value)
end 

bgtools.pd = pd 

function print_group(gname, len, divider)
	local space = gname:len() + 2
	local const = len or 30
	local divider = divider or "-"
	local needl = math.floor(const - space)/2
	local needr = math.ceil(const - space)/2
	print(string.rep(divider, needl).." "..gname.." "..string.rep(divider, needr))
end

function bgtools.PrintSectorInfo(sectorname) 
	local data = bgtools.GetSectorInfo(sectorname) 
	if data then 
		pd("Sector Info", data.name)
		pd("Price", data.price)
		print_group("Costs")
		pd("|-Fixed",data.fixed_costs)
		pd("|-Employees",data.employee_costs)
		print_group("Sector machinery")
		bgtools.ParseProducts(data.machinery, "|-")
		print_group("Sector input")
		bgtools.ParseProducts(data.input, "|-")
		print_group("Sector output")
		bgtools.ParseProducts(data.output, "|-")
	else 
		print("Sector: "..( sectorname or "" ).." does not exist!")
	end
end

function bgtools.GetSectorInfo(sectorname)
	local sector = bgtools.GetSector(sectorname)
	if sector then 
		local data = sector 
		local output = {}
		output.name = getval(data, "name")
		output.price = getval(data, "price")
		output.employee_costs = getval(data, "employees")
		output.fixed_costs = getval(data, "fixed")
		output.machinery = bgtools.GetProducts(data:find("machinery"))
		output.input = bgtools.GetProducts(data:find("input"))
		-- YOU GENIUS
		output.output = bgtools.GetProducts(data:find("output"))
		return output 
	end 
	return sector 
end 

function bgtools.PrintProductInfo(productname)
	local data = bgtools.GetFullProductInfo(productname)
	if data then 
		pd("Product Info", data.name)
		print_group("Price")
		pd("|-Current", data.price)
		pd("|-Minimum", data.minimumprice)
		pd("|-Maximum", data.maximumprice)
		print_group("Price History")
		for i,v in pairs(data.history) do 
			pd("|-", v)
		end 
	end 
end 

function bgtools.GetSectors()
	local out = {}
	for sector_number, sector_data in pairs(bgtools.sector) do 
		local name = getval(sector_data, "name")
		table.insert(out, name)
	end 
	return out
end 

function bgtools.GetFullProductInfo(product_name)
	local product_name = product_name
	if type(product_name) == "string" then 
		product_name = bgtools.GetProduct(product_name)
	end 
	local data_root = product_name 
	if data_root then 
		local out = {}
		out.name = getval(data_root, "name")
		out.price = getval(data_root, "price")
		out.minimumprice = getval(data_root, "minimum")
		out.maximumprice = getval(data_root, "maximum")
		out.history = {} 
		for i,v in pairs(data_root:find("history")) do

			table.insert(out.history, v[1])

		end

		return out
	else 
		return false 
	end
end

function bgtools.GetProductList() 
	local out = {} 
	for pnum, pdata in pairs(bgtools.products) do 
		local name = getval(pdata, "name")
		table.insert(out, name)
	end 
	return out
end 

function bgtools.ListSectorProductRelation(product, relation, nope)
	local out = {} -- all sectors which have this relation
	for sector_number, sector_data in pairs(bgtools.sector) do 
		if sector_data and sector_data:find(relation) then 
			local product_data = bgtools.GetProducts(sector_data:find(relation))
			local got = false 
			for product_id, data in pairs(product_data) do 
				local bool = data.name:lower() == tostring(product):lower() 
				if bool then
					if not nope then 
						table.insert(out, getval(sector_data, "name"))
					end
					got = true 
					break
				end
			end
			if nope and not got then 
				table.insert(out, getval(sector_data, "name"))
			end
		end 
	end 
	return out 
end 

function bgtools.GetProductUses(product, nope)
	local usage = {}
	usage.machinery = bgtools.ListSectorProductRelation(product, "machinery", nope)
	usage.input = bgtools.ListSectorProductRelation(product, "input", nope)
	usage.output = bgtools.ListSectorProductRelation(product, "output", nope)
	return usage 
end 

function bgtools.PrintProductUses(product, nope)
	local data = bgtools.GetProductUses(product, nope) 
	print_group("To Construct")
	for i,v in pairs(data.machinery, nope) do 
		pd("|-", v) 
	end 
	print_group("As Input")
	for i,v in pairs(data.input, nope) do 
		pd("|-", v) 
	end 
	print_group("As Output")
	for i,v in pairs(data.output, nope) do 
		pd("|-", v) 
	end 
end

function bgtools.fileupdate()
	io.popen("curl -O http://businessgame.be/xml/products.xml")
	io.popen("curl -O http://businessgame.be/xml/sectors.xml")
	bgtools.sector = xml.load("sectors.xml")
	bgtools.products = xml.load("products.xml")
end 

function bgtools.GetSectorInventory(sector, mode, multiplier)
	local multiplier = multiplier or 1 
	local mode = mode or "input" 
	local sector = bgtools.GetSector(sector) 
	if sector then 
		local data = sector:find(mode) 
		if data then 
			local inventory = {} 
			local products = bgtools.GetProducts(data)
			for i,v in pairs(products) do 
				if v.amount then 
					inventory[v.name] = v.amount * multiplier
				end 
			end
			return inventory 
		end 
	end 
	return {}, false 
end 

function bgtools.InventoryWorth(inventory) -- {prodname = prodammount, ..}
	local worth = 0 
	for prodname, prodamount in pairs(inventory) do 
		local product = bgtools.GetProduct(prodname) 
		if product then 
			local price = getval(product, "price")
			worth = worth + prodamount * price 
		end
	end 
	return worth 
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function bgtools.SectorAddedValue(sector)
	local input = bgtools.GetSectorInventory(sector, "input")
	local output = bgtools.GetSectorInventory(sector, "output")
	local w1, w2 = bgtools.InventoryWorth(input), bgtools.InventoryWorth(output)
	local diff = w2 - w1 
	local percent_increase = ((w2 - w1) / w1) * 100
	local rounded = round(percent_increase, 1)
	return diff, rounded , w1, w2
end 

-- finds all possible routes from raw resources
function bgtools.Flow(product, raw)
	local routes = {}
	if bgtools.GetProduct(product) then 
		local ProductSources = bgtools.ListSectorProductRelation(product, "output")
		-- list of sectors in which the product is outputted ^
		
		return routes 
	end 
end


local out = {}

out.init = function(sector_xml, products_xml)
	if sector_xml and products_xml then 
		for i,v in pairs(bgtools) do 
			out[i] = v
		end
		bgtools.sector = sector_xml 
		bgtools.products = products_xml
		out.sector = sector_xml
		out.products = products_xml
	end
end

return out 