local xml = require "LuaXML"

local bgtools = {}

function bgtools.GetSector(sectorname)
	for sector_number, sector_data in pairs(bgtools.sector) do 
		if sector_data:find("name") and sector_data:find("name")[1] == sectorname then 
			return sector_data 
		end 
	end 
end 	

function bgtools.GetProductInfo(product_root)
	-- name and amount
	local product = {} 
	local name = product_root:find("name")
	local amount = product_root:find("amount") 
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
	if root:find(value) then 
		if root:find(value)[1] ~= nil then 
			return (root:find(value)[1])
		end 
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
		print((start or "") .. product_data.name..": "..product_data.amount)
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
	end 
end

function bgtools.GetSectorInfo(sectorname)
	local sector = bgtools.GetSector(sectorname)
	if sector then 
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

function bgtools.GetSectors()
	local out = {}
	for sector_number, sector_data in pairs(bgtools.sector) do 
		local name = getval(sector_data, "name")
		table.insert(out, name)
	end 
	return out
end 

function bgtools.fileupdate()
	io.popen("curl -O http://businessgame.com/xml/products.xml")
	io.popen("curl -O http://businessgame.com/xml/sectors.xml")
	bgtools.sector = xml.load("sectors.xml")
	bgtools.products = xml.load("products.xml")
end 

local out = {}

out.init = function(sector_xml, products_xml)
	if sector_xml and products_xml then 
		for i,v in pairs(bgtools) do 
			out[i] = v
		end
		bgtools.sector = sector_xml 
		bgtools.prizes = products_xml 
	end
end

return out 