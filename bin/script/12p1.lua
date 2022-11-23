local cfg = require "script.config" 
local pvz = cfg
local addr = pvz.addr

pvz.LogFile("pvz.txt")
print(pvz.addr.sun)
print(pvz.Sun(), pvz.Wave(), pvz.Speed())
--pvz.Pao(2,9)
local Pao = function()
    print("pao")
    pvz.Pao(2, 9)
    pvz.Pao(5, 9)
end

local nuke_index = 1
local nuke_pos = {1,2,5,6}
local function nuke()
    nuke_index = nuke_index % 4 + 1
    local r, c = nuke_pos[nuke_index], 8
    print("nuke", r, c)
    pvz.UseCard({"末日菇", "咖啡豆"}, r, c)
end
local function p12()
    while true do
        local wave = pvz.Wave()
        print(wave)
        if wave == 4 then
            pvz.UseCard({"莲叶", "南瓜头", "大喷菇", "多嘴小蘑菇", "咖啡豆"}, 3, 9)
        end
        if wave == 14 then
            pvz.UseCard({"莲叶", "南瓜头", "大喷菇", "多嘴小蘑菇", "咖啡豆"}, 4, 9)
        end
        if wave == 9 or wave == 19 then
            print("wave 9 19 ", pvz.WaveCD())
            while not pvz.Check(function() return pvz.WaveCD() < 210 end, 560, 20) do
                print("wave 9 19 pao")
                Pao()
            end
            if wave == 19 then
                pvz.Prejudge(150)
                pvz.Pao(4, 7)
                pvz.Prejudge(55)
                pvz.Pao(2, 9)
                pvz.AddTask(function() 
                    pvz.Delay(273)
                    pvz.UseCard("樱桃炸弹", 5, 9)
                    if pvz.HasZombie("蹦极") then
                        pvz.Delay(100)
                        nuke()
                    end
                end)
            else
                pvz.Prejudge(55)
                Pao()
                pvz.AddTask(function() 
                    pvz.Delay(373)
                    nuke()
                    if pvz.HasZombie("气球") then
                        pvz.UseCard("三叶草", 5, 1)
                    end
                end)
            end
        elseif wave < 20 then
            pvz.Prejudge(95)
            Pao()
        end
        if wave == 20 then
            pvz.UseCard({"向日葵", "双胞向日葵"}, 1, 1)
            print("wave 20...")
            local function wave20_end()
                return pvz.WordType() == 12
            end
            while not pvz.Check(wave20_end, 560, 20) do
                print("wave 9 19 pao")
                Pao()
            end
            print("wave 20...end", pvz.WaveCD())
            break
        end
        pvz.WaitUntil(function() return pvz.Wave() == wave + 1 end)
    end
    print("script end")
end
pvz.AutoCollect()
for _ = 1, 9999 do
    if pvz.GameUI() == 4 then
        break
    end
    print("sun", pvz.Sun())
    pvz.AddTask(p12, "gamescript")
    pvz.GetSpawnInfo(true)
    pvz.ChooseCard("多嘴小蘑菇", "大喷菇", "樱桃炸弹", "南瓜头", 
        "咖啡豆", "双胞向日葵", "末日菇", "三叶草", "向日葵", "莲叶")
    pvz.RunOneLevel()
end
print("game over")