local pvz = require "script.pvz"
pvz.Lineup = "LI43bJyUdO0CJnmXAlJ0X1h0dmdFdlpTSQRkYkUYCVhMcldUL/tMuVY="

local function ZombieAlive()
    for v in pvz.AliveZombies() do
        if v.Type ~= 24 then
            return true
        end
    end
    return false
end

local doom = 0
local Fire = pvz.NewTask(function()
    if not pvz.Pao(2, 9) then
        pvz.Delay(373 - 298)
        pvz.UseCard({"荷叶", "核弹", "咖啡豆"}, doom % 2 == 0 and 3 or 4, 9)
        doom = doom + 1
        return
    end
    if not pvz.Pao(5, 9) then
        pvz.Delay(373 - 100)
        pvz.UseCard('樱桃', 5, 9)
    end
end)

local function WaveEnd(w)
    if w == 20 then
        return not ZombieAlive()
    elseif w ==9 or w == 19 then
        return pvz.NowTime(w + 1) > -700 or not ZombieAlive()
    else
        return pvz.NowTime(w + 1) > -201
    end
end

pvz.NewLevel = function()
    pvz.SelectCards("樱桃", "荷叶", "向日葵", "模仿咖啡豆", "末日菇", "咖啡豆", "南瓜头", "冰川菇", "玉米", "玉米加农炮")
    pvz.AutoFixPao(150, 3000)
    for w = 1, 20 do
        pvz.At(w, -42):Run(function()
            repeat
                Fire()
                pvz.Delay(450)
            until WaveEnd(w)
        end)
    end

    pvz.At(20, 250 - 370):Run(function()
        pvz.Pao(4, 7.625)
    end)
end
