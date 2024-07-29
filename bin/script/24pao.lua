local pvz = require "script.pvz"
--pvz.Lineup = "LI43bJyUlNTYBS00RdPXWnxsNHHyXFdFslRUZEdMX1Y="

local function ZombieAlive()
    for v in pvz.AliveZombies() do
        return true
    end
    return false
end

local function ZombieMaxHp2()
    local maxu, maxd = 0, 0
    for v in pvz.AliveZombies() do
        if v.Row < 3 then
            if v.Hp > maxu then
                maxu = v.Hp
            end
        else
            if v.Hp > maxd then
                maxd = v.Hp
            end
        end
    end
    return maxu, maxd
end

--[[
    无红
]]
local function PD()
    pvz.Pao(2, 8.75)
    pvz.Pao(5, 8.75)
    pvz.Delay(102)
    pvz.Pao(2, 8.75)
    pvz.Pao(5, 8.75)
end

local function NR_NormalWave(w)
    pvz.UntilWaveTime(w, 297 - 373)
    PD()
    pvz.UntilWaveTime(w, 297 - 373 + 650)
    if pvz.NowTime(w + 1) < -9999 then
        pvz.Pao(2, 8.75)
        pvz.Pao(5, 8.75)
    end
end

--[[
    红白
]]
local function PDJW()
    pvz.Pao(2,9)
    pvz.Pao(5,9)
    pvz.Delay(110)
    pvz.Pao(1, 7.8125)
    pvz.Pao(5, 7.8125)
end

local function PI()
    pvz.Pao(2,9)
    pvz.Pao(5,9)

    pvz.Delay(373 - 298)
    pvz.UseCard({"荷叶", "冰", "咖啡豆"}, 4, 9)
end

local function CPI()
    local t = pvz.gameClock
    PI()

    pvz.UntilGameClock(t + 373 - 5)
    pvz.UseCard('小喷菇', 1, 9)
    pvz.UseCard('阳光菇', 2, 9)
    pvz.UseCard('花盆', 5, 9)
    pvz.UseCard('胆小菇', 6, 9)

    pvz.Delay(5)
    pvz.RemovePlant(1, 9)
    pvz.RemovePlant(2, 9)
    pvz.RemovePlant(5, 9)
    pvz.RemovePlant(6, 9)

end

local function PSD()
    pvz.Pao(2, 9)
    pvz.Pao(5, 9)
    pvz.Delay(110)
    pvz.Pao(1, 8.75)
    pvz.Pao(5, 8.75)
end



local function PADD()
    local fireCount = 0
    for p in PlantFilter() do
        if p.Type == 47 and p.State == 37 then
            fireCount = fireCount + 1
        end
    end
    if fireCount < 5 then
        return false
    end

    pvz.Pao(5, 9)
    if fireCount >= 6 then
        pvz.Pao(2, 9)
    else
        pvz.After(373 - 100):Run(function() pvz.UseCard('樱桃', 2, 9) end)
    end

    pvz.Delay(102)
    pvz.Pao(2, 8.75)
    pvz.Pao(5, 8.75)

    pvz.Delay(110)
    pvz.Pao(1, 8.75)
    pvz.Pao(5, 8.75)
    return true
end

local logic_wave = 1
local last_giga_wave = 19

local function RW_NormalWave(w)
    if logic_wave == 1 then
        pvz.UntilWaveTime(w, 359 - 373)
        PDJW()
        logic_wave = 2

        pvz.UntilGameClock(w, 1050 - 373)
        if pvz.NowTime(w + 1) < -9999 then
            CPI()
            logic_wave = 3
        end
    elseif logic_wave == 2 then
        pvz.UntilWaveTime(w, 0)
        CPI()
        logic_wave = 3

        pvz.UntilWaveTime(w, 980 - 373)
        if pvz.NowTime(w + 1) < -9999 then
            PSD()
            logic_wave = 1
        end
    elseif logic_wave == 3 then
        if w > last_giga_wave + 2 then
            logic_wave = -1
            NR_NormalWave(w)
            return
        end
        
        pvz.UntilWaveTime(w, -55)
        PSD()
    elseif logic_wave == -1 then
        NR_NormalWave(w)
    end
end

local function RW_9_19(w)
    RW_NormalWave(w)
    pvz.UntilWaveTime(w, 1151)
    if pvz.NowTime(w + 1) > -350 then
        return
    end

    local u, d = ZombieMaxHp2()
    print('ending wave hp', u, d)
    while u > 0 do
        u = u - 1800
        pvz.Pao(2, 8.8)
    end
    while d > 0 do
        d = d - 1800
        pvz.Pao(5, 8.8)
    end
end

local function RW_10_20(w)
    if PADD() then
        logic_wave = 1
        if w == 20 then
            pvz.Delay(600)
            if ZombieAlive() then
                pvz.Pao(2, 8.8)
                pvz.Pao(5, 8.8)
            end
        end
    else
        pvz.UntilWaveTime(w, 400 - 373)
        PI()
        logic_wave = 3

        pvz.Delay(520)
        if w == 20 or pvz.NowTime(w + 1) < -9999 then
            PSD()
            logic_wave = 1
        end
    end
end

--[[
    红无白
]]
local function PSD_CP(w, lw, d)
    local r3, r1 = 2, 5
    if lw % 2 == 0 then
        r3, r1 = 5, 2
    end

    pvz.Pao(r3, 9)
    pvz.Pao(r3, 8.8)
    pvz.After(70):Run(function()
        pvz.Pao(r1, 9)
    end)
    pvz.After(110):Run(function()
        pvz.Pao(r3, 8.75)
    end)

    if d and pvz.HasZombie('舞王') then
        pvz.After(249):Run(function()
            if lw % 2 == 0 then
                pvz.UseCard('小喷菇', 1, 9)
                pvz.UseCard('模仿小喷菇', 2, 9)
            else
                pvz.UseCard('胆小菇', 5, 9)
                pvz.UseCard('阳光菇', 6, 9)
            end
        end)
    end
end

local function R_NormalWave(w)
    if w == 10 or w == 20 then
        logic_wave = 2
    end
    if logic_wave ~= -1 and w > last_giga_wave + 1 then
        logic_wave = -1
    end
    if logic_wave == -1 and w ~= 20 then
        NR_NormalWave(w)
        return
    end

    pvz.UntilWaveTime(w, (w == 10 or w == 20) and -55 or -84)
    PSD_CP(w, logic_wave, true)
    logic_wave = logic_wave % 2 + 1

    pvz.Delay(600)
    if w == 20 or pvz.NowTime(w + 1) < -9999 then
        PSD_CP(w, logic_wave, false)
        logic_wave = logic_wave % 2 + 1
    end
end

local function R_Wave20()
    pvz.UntilWaveTime(20, -55)
end

local function Battle()
    if not pvz.HasZombie('红眼') then
        pvz.SelectCards("小喷菇", "模仿小喷菇", "阳光菇", "胆小菇", "向日葵", "双子向日葵", "南瓜头", "寒冰菇", "玉米", "玉米加农炮")
        for w = 1, 20 do
            pvz.At(w, -199):Run(function() NR_NormalWave(w) end)
        end
    elseif not not pvz.HasZombie('白眼') then
        pvz.SelectCards("小喷菇", "模仿小喷菇", "阳光菇", "胆小菇", "向日葵", "双子向日葵", "南瓜头", "寒冰菇", "玉米", "玉米加农炮")
        for w = 1, 20 do
            pvz.At(w, -199):Run(function() R_NormalWave(w) end)
        end
    else
        pvz.SelectCards("小喷菇", "花盆", "阳光菇", "胆小菇", "南瓜头", "咖啡豆", "模仿寒冰菇", "寒冰菇", "玉米", "玉米加农炮")
        for w = 1, 20 do
            pvz.At(w, -199):Run(function()
                if w == 10 or w == 20 then
                    RW_10_20(w)
                elseif w == 9 or w == 19 then
                    RW_9_19(w)
                else
                    RW_NormalWave(w)
                end
            end)
        end
    end
end

local function Start()
    pvz.At(1, -599):Run(function()
        if not pvz.HasZombie('红眼') or not pvz.HasZombie('白眼') then
            local sun = pvz.GetPlantAt(3, 9)
            if not sun or (sun.Type ~= 1 and sun.Type ~= 41) then
                pvz.RemovePlant(3, 9)
            end
            pvz.UseCard('向日葵', 3, 9)
            pvz.UseCard('双子向日葵', 3, 9)

            pvz.Delay(5001)
            local ice = pvz.GetPlantAt(4, 9)
            if not ice then
                pvz.UseCard('寒冰菇', 4, 9)
            end
        else
            local sun = pvz.GetPlantAt(3, 9)
            if sun and sun.Type == 41 then
                pvz.RemovePlant(3, 9)
            end

            while true do
                local iceCard
                if pvz.CanUseCard('寒冰菇') then
                    iceCard = '寒冰菇'
                elseif pvz.CanUseCard('模仿寒冰菇') then
                    iceCard = '模仿寒冰菇'
                end

                if iceCard then
                    if not pvz.GetPlantAt(3, 9) then
                        pvz.UseCard(iceCard, 3, 9)
                    elseif not pvz.GetPlantAt(4, 9) then
                        pvz.UseCard(iceCard, 4, 9)
                    end
                end
                pvz.Delay(5)
            end
        end
    end)

    pvz.At(8, 0):Run(function()
        pvz.UseCard('南瓜头', 3, 9)
        pvz.UseCard('南瓜头', 4, 9)
    end
    pvz.At(18, 0):Run(function()
        pvz.UseCard('南瓜头', 3, 9)
        pvz.UseCard('南瓜头', 4, 9)
    end

    pvz.At(20, 250 - 378):Run(function()
        pvz.Pao(4, 7.5)
    end)
end

pvz.NewLevel = function()
    Start()
    Battle()
end
