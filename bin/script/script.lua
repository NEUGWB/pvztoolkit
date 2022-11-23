local cfg = require("script.config")
local pvz = cfg
pvz.OnLevelStart = function()
    pvz.GetSpawnType()
end
pvz.SetCards("樱桃", "荷叶", "向日葵", "双子向日葵", "毁灭菇", "咖啡豆", "南瓜头", "三叶草", "大喷", "曾哥")
local Pao = function()
    pvz.Pao(2, 9)
    pvz.Pao(5, 9)
end

local n = 1
function N()
    if n % 2 == 1 then
        pvz.UseCard({"核弹", "咖啡豆"}, 2, 8)
    else
        pvz.UseCard({"核弹", "咖啡豆"}, 5, 8)
    end
end

function N2()
    if n % 2 == 1 then
        pvz.UseCard({"核弹", "咖啡豆"}, 1, 8)
    else
        pvz.UseCard({"核弹", "咖啡豆"}, 6, 8)
    end
end

local function p12()
    while true do
        local wave = pvz.Wave()
        if wave >= 20 then
            pvz.UseCard({"向日葵", "双子向日葵"}, 1, 1)
            pvz.UseCard("南瓜", 3, 9)
            pvz.UseCard("南瓜", 4, 9)
            pvz.WaitUntil(function() return pvz.Wave() <= 1 end)
            wave = pvz.Wave()
        end
        if wave == 9 then
            pvz.Prejudge(55)
            Pao()
            pvz.Delay(300)
            N()
        elseif wave == 19 then
            pvz.Prejudge(150)
            pvz.Pao(4, 7)
            pvz.Prejudge(55)
            pvz.Pao(2, 9)
            pvz.Delay(273)
            pvz.UseCard("樱桃", 5, 9)
            N2()
            n = n+1
        else
            pvz.Prejudge(95)
            Pao()
            pvz.Delay(100)
        end
        
        if wave == 8 or wave == 18 or wave == 19 then
            local function HasZombie()
                local zombies = pvz.GetAliveZombies()
                for _, v in ipairs(zombies) do
                    if v.zombie_type ~= 24 then
                        print("alive zombie", v.zombie_type, v.x, v.y, pvz.GetZombieName(v.zombie_type))
                        return true
                    end
                end
            end
            if wave == 19 then
                pvz.Delay(200)
            else
                pvz.Delay(450)
            end
            
            if HasZombie() then
                Pao()
            end
            pvz.Delay(600)
            if HasZombie() then
                Pao()
            end
            
        end
    end
end

local function Test()
    while true do
        pvz.Delay(300)
        print(pvz.Sun())
    end
end

local spawn = pvz.GetSpawnType()
for i = 0, 32 do
    if spawn[i] then
        print(pvz.GetZombieName(i))
    end
end
--pvz.AddTask(Test)
pvz.AddTask(p12)

pvz.RunEndless()