local pvz = require "script.pvz"
--pvz.Lineup = "LI43bJyUlNTYBS00RdPXWnxsNHHyXFdFslRUZEdMX1Y="

local function ZombieAlive()
    for v in pvz.AliveZombies() do
        return true
    end
    return false
end

local function ZombieMaxHp()
    local max = 0
    for v in pvz.AliveZombies() do
        if v.Hp > max then
            max = v.Hp
        end
    end
    return max
end

local function PD()
    print('pd')
    pvz.Pao(2,9)
    pvz.Pao(5,9)
    pvz.Delay(110)
    pvz.Pao(1, 7.8125)
    pvz.Pao(5, 7.8125)
end

local function PI()
    pvz.Pao(2,9)
    pvz.Pao(5,9)
    pvz.Delay(373-298)
    pvz.UseCard({"荷叶", "冰", "咖啡豆"}, 4, 9)
end

local function PSD()
    print("psd")
    pvz.Pao(2, 9)
    pvz.Pao(5, 9)
    if ZombieMaxHp() > 3600 or pvz.wave ~= 9 then
        pvz.Pao(1, 8.75)
        pvz.Pao(5, 8.75)
    end
    pvz.Delay(110)
    pvz.Pao(1, 8.75)
    pvz.Pao(5, 8.75)
end

pvz.NewLevel = function()
    pvz.SelectCards("樱桃", "荷叶", "向日葵", "模仿咖啡豆", "小喷菇", "咖啡豆", "南瓜头", "冰川菇", "玉米", "玉米加农炮")
    
    for _, w in ipairs({1,4,7,11,14,17}) do
        pvz.At(w, 359-373):Run(function() PD() end)
    end
    for _, w in ipairs({2,5,8,12,15,18}) do
        pvz.At(w, -55):Run(PI)
    end
    for _, w in ipairs({3,6,9,10,13,16,19,20}) do
        pvz.At(w, -55):Run(PSD)
    end
    pvz.At(20, 250 - 370):Run(function()
        pvz.Pao(4, 7.625)
    end)
    for _, w in ipairs({9,19,20}) do
        pvz.At(w, 550):Run(function()
            if ZombieAlive() then
                pvz.Pao(2, 9)
                pvz.Pao(5, 9)
            end
        end)
    end
end
