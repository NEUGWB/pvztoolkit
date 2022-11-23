local pvz = require "script.config"
setmetatable(_ENV, {__index = pvz})
print("test start", pvz)
local start = os.clock()
--pvz.GetSpawnInfo()
--[[for i, v in pairs(pvz.SPAWN_LIST[1]) do
    --print(pvz.GetZombieName(i))
end]]

local plants = GetCurPlants()
for k, v in pairs(plants) do
    print(pvz.GetPlantName(v.type), v.hp, v.row, v.col)
end
print("test end", os.clock() - start)