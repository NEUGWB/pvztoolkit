local pvz = require "script.pvz"
pvz.Lineup = "LI43NMQIf+0GJn+XFVJsVN6YEEIlbLyUtORBGFZlIkUYCVhMcldUgKBB+VY="

local dianNum = 4
local Dian = pvz.NewTask(function()
    local rows = {1, 2, 5, 6}
    for i, r in ipairs(rows) do
        pvz.UseCard(i, r, 9)
    end
    pvz.Delay(180)
    for i, r in ipairs(rows) do
        pvz.RemovePlant(r, 9, 3)
    end
end)

local CanDian = function(t)
    t = t or 0
    for i = 1, dianNum do
        local seed = pvz.SeedHead() + (i - 1)
        if not seed.IsUsable and seed.InitialCd - seed.Cd + 1 > t then
            return false
        end
    end
    return true
end

local doom = 0
local Fire = pvz.NewTask(function()
    if not pvz.Pao(2, 8.5) then
        pvz.Delay(373 - 298)
        pvz.UseCard({"荷叶", "核弹", "咖啡豆"}, doom % 2 == 0 and 3 or 4, 9)
        doom = doom + 1
        return
    end
    pvz.Pao(5, 8.5)
end)

local function ZombieAlive()
    for v in pvz.AliveZombies() do
        if v.Type ~= 24 and v.Type ~= 17 then
            return true
        end
    end
    return false
end

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
    pvz.SelectCards("小喷菇", "模仿小喷菇", "花盆", "阳光菇", "咖啡豆", "末日菇", "冰川菇", "玉米", "玉米加农炮", "荷叶")
    pvz.AutoFixPao(150, 3000)
    for w = 1, 20 do
        if pvz.SPAWN_LIST[w][DANCING_ZOMBIE] then
            pvz.At(w, -42):Run(function()
                if not CanDian(165) then
                    Fire()
                    return
                end
                pvz.UntilWaveTime(w, 120)
                Dian()
                pvz.UntilWaveTime(w, 650 - 373)
                Fire()
            end)
        else
            pvz.At(w, 650 - 373):Run(Fire)
        end

        pvz.At(w, 650 - 373 + 850):Run(function()
            while not WaveEnd(w) do
                print("check delay", w, pvz.wave)
                Fire()
                pvz.Delay(850)
            end
        end)
    end

    pvz.At(20, -350):Run(function()
        pvz.UseCard({"冰", "咖啡豆"}, 1, 1)
    end)
end
