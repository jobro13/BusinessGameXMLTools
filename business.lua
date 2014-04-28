xml = require "LuaXML"

Sector = xml.load("sectors.xml")
Products = xml.load("products.xml")

ROOT = Sector

function FILEUPDATE()
	io.popen("curl -O http://businessgame.com/xml/products.xml")
	io.popen("curl -O http://businessgame.com/xml/sectors.xml")
end 

function GetSector(sector)
	for i,v in pairs(ROOT) do 
		if v:find("name") and v:find("name")[1] == sector then 
			return v 
		end 
	end
end 

function GetSectorInputs(_sector) -- [1] = name, [2] = pointer to data
	local sector = GetSector(_sector)
	local output = {}
	if sector then 
		for productnumber, data in pairs(sector:find("input")) do 
			if data:find("name") then 
				table.insert(output, {data:find("name")[1], data})
			end 
		end
	end 
	return output
end 

function getval(root, value)
	if root:find(value) then 
		if root:find(value)[1] ~= nil then 
			return (root:find(value)[1])
		end 
	end 
end 

function GetSectorInfo(_sector)
	local sector = GetSector(_sector)
	if sector then 
		-- start printing info 
		print("Sector name: " .. getval(sector, "name"))
		print("Price to buy: "..getval(sector, "price"))
		print("Employee costs: "..getval(sector, "employees"))
		print("Fixed costs: "..sector:find("fixed")[1])
		print("-- Sector Machinery Needed --")
		for machine_number, data in pairs(sector:find("machinery")) do 
			local data = data:find("product")
			if data then 
				print(getval(data, "name") ..": ".. getval(data, "amount"))
			end
		end 
		print("-- Sector Input --")
		for productnumber, data in pairs(sector:find("input")) do 
			local data = data:find("product")
			if data then 
				print(getval(data, "name") ..": ".. getval(data, "amount"))
			end
		end 
		print("-- Sector Output --")
		for productnumber, data in pairs(sector:find("output")) do 
			local data = data:find("product")
			if data then 
				print(getval(data, "name") ..": ".. getval(data, "amount"))
			end
		end 
	end 
end

function GetEmptySectors()
	for sectornumber, data in pairs(ROOT) do 
		if data:find("name") then 
			NAME = data:find("name")[1]
			if #GetSectorInputs(NAME) == 0 then 
				print(data:find("name")[1])
			end
		end
	end
end

GetEmptySectors()

while true do 
	local cmd = io.read()
	if cmd == "q" then 
		os.exit()
	else
		GetSectorInfo(cmd)
	end
end
