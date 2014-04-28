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

function GetSectorInfo(_sector)
	local sector = GetSector(_sector)
	if sector then 
		-- start printing info 
		print("Sector name: " .. sector)
		print("Price to buy: "..sector:find("price"))
		print("Employee costs: "..sector:find("employees"))
		print("Fixed costs: "..sector.fixed)
		print("-- Sector Machinery Needed --")
		for machine_number, data in pairs(sector:find("machinery")) do 
			print(data.name..": "..data.amount)
		end 
		print("-- Sector Input --")
		for productnumber, data in pairs(sector:find("input")) do 
			print(data.name..": "..data.amount)
		end 
		print("-- Sector Output --")
		for productnumber, data in pairs(sector:find("output")) do 
			print(data.name..": "..data.amount)
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
