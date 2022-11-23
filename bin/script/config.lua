local pvz = pvz
local ZOMBIE = {}
local PLANT = {}

local cards = {1,2,3,4,5,6,7,8,9,10}

local addr = pvz.addr
local pvz_base = addr.lawn
local main_object = addr.board

addr.wave = 0x557c
addr.wave_cd = 0x559c
addr.big_wave_cd = 0x55a4

addr.plant_struct_size = 0x14c
addr.zombie_struct_size = 0x15c
addr.grid_item_struct_size = 0xec
addr.slot_seed_struct_size = 0x50
addr.mouse_window = 0x320
addr.popup_window = 0x94

addr.item = 0xe4
addr.item_x = 0x24
addr.item_y = 0x28
addr.item_dissapear = 0x38
addr.item_collected = 0x50
addr.item_max_num = 0xe8
addr.item_struct_size = 0xd8

addr.word = 0x140
addr.word_type = 0x8c

if pvz.isGOTY then
    addr.wave = addr.wave + 0x18
    addr.wave_cd = addr.wave_cd + 0x18
    addr.big_wave_cd = addr.big_wave_cd + 0x18
    addr.item_max_num = addr.item_max_num + 0x18
    addr.zombie_struct_size = 0x168
    addr.popup_window = 0xac
    addr.item = addr.item + 0x18

    addr.word = addr.word + 0x18
    addr.item_max_num = 0xe8 + 0x18
end

addr.zombie_type = 0x24
addr.zombie_x = 0x2c
addr.zombie_y = 0x30

addr.plant_status = 0x3c
addr.plant_hp = 0x40

local function MakeLong(x, y)
    return (x & 0xffff) | ((y & 0xffff) << 16)
end

local function MakeLongWithDpi (x, y)
    if pvz.dpi then
        x = math.floor(x / pvz.dpi + 0.5)
        y = math.floor(y / pvz.dpi + 0.5)
    end
    return MakeLong(x, y)
end

local WIN_ENUM = 
{
    WM_LBUTTONDOWN = 0x0201,
    WM_LBUTTONUP = 0X202,
    --WM_LBUTTONDBLCLK = 0x0203,
    WM_RBUTTONDOWN = 0x0204,
    WM_RBUTTONUP = 0x0205,
}

pvz.Click = function(x, y)
    pvz.PostMessage(WIN_ENUM.WM_LBUTTONDOWN, 0, MakeLongWithDpi(x, y))
    pvz.PostMessage(WIN_ENUM.WM_LBUTTONUP, 0, MakeLongWithDpi(x, y))
end

pvz.RClick = function(x, y)
    pvz.PostMessage(WIN_ENUM.WM_RBUTTONDOWN, 0, MakeLongWithDpi(x, y))
    pvz.PostMessage(WIN_ENUM.WM_RBUTTONUP, 0, MakeLongWithDpi(x, y))
end

pvz.SafeClick = function ()
    pvz.RClick(60, 50)
end

pvz.SlowClick = function(x, y)
    pvz.SystemSleep(10)
    pvz.PostMessage(WIN_ENUM.WM_LBUTTONDOWN, 0, MakeLongWithDpi(x, y))
    pvz.SystemSleep(10)
    pvz.PostMessage(WIN_ENUM.WM_LBUTTONUP, 0, MakeLongWithDpi(x, y))
    pvz.SystemSleep(10)
end

pvz.ButtonClick = function(x, y)
    local function _do()
        pvz.PostMessage(WIN_ENUM.WM_LBUTTONDOWN, 0, MakeLongWithDpi(x, y))
        pvz.PostMessage(WIN_ENUM.WM_RBUTTONDOWN, 0, MakeLongWithDpi(x, y))
        pvz.PostMessage(WIN_ENUM.WM_LBUTTONUP, 0, MakeLongWithDpi(x, y))
        pvz.PostMessage(WIN_ENUM.WM_RBUTTONUP, 0, MakeLongWithDpi(x, y))
    end
    _do()
    pvz.SystemSleep(10)
    _do()
end

pvz.ClickFeild = function (r, c)
    local x = math.floor(80 * c + 0.5)
    local y = math.floor(30 + 85 * r + 0.5)
    pvz.Click(x, y);
end

local type_size = {
    float = 4,
    uint32_t = 4,
    uint16_t = 2,
    uint8_t = 1,
    bool = 1,
}
pvz.ReadMemory = function(t, a)
    local ret = pvz.ReadProcessMemory(t, a)
    if ret == nil then
        print(debug.traceback())
        error("read memory error")
    end
    return ret
end

pvz.ReadMemoryArray = function(t, n, a)
    local size = type_size[t]
    local a1 = {}
    for i = 1, #a - 1 do
        a1[i] = a[i]
    end
    local base = pvz.ReadProcessMemory("uint32_t", a1) + a[#a]

    local ret_array = {}
    for i = 1, n do
        local ret = pvz.ReadProcessMemory(t, {base + (i - 1) * size})
        if ret == nil then
            print(debug.traceback())
            error("read memory error")
        end
        ret_array[i] = ret
    end
    return ret_array
end

pvz.GameClock = function()
    return pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.game_clock})
end

pvz.Sun = function()
    return pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.sun})
end

pvz.GameUI = function ()
    return pvz.ReadMemory("uint32_t", {pvz_base, addr.game_ui})
end

pvz.HasDialog = function ()
    return pvz.ReadMemory("uint32_t", {pvz_base, addr.mouse_window, addr.popup_window}) ~= 0
end

pvz.Wave = function ()
    return pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.wave})
end

pvz.WaveCD = function ()
    return pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.wave_cd})
end

pvz.HugeWaveCD = function ()
    return pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.big_wave_cd})
end

pvz.WordType = function ()
    return pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.word, addr.word_type})
end

pvz.SlotCount = function ()
    return pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.slot, addr.slot_count})
end

pvz.Speed = function ()
    local ms = pvz.FrameDuration()
    return 10 / ms
end

pvz.FrameDuration = function ()
    return pvz.ReadMemory("uint32_t", {pvz_base, addr.frame_duration})
end

local TaskList = {}
pvz.RunOneLevel = function()
    local gameTime = 0
    local lastUpdate = os.clock()
    local maxUpdate = 0.5 / pvz.Speed()
    if maxUpdate < 0.2 then maxUpdate = 0.2 end
    while true do
        local curTime = pvz.GameClock()
        if curTime ~= gameTime then
            gameTime = curTime
            pvz.gameTime = gameTime
            for k, v in pairs(TaskList) do
                local s, m = coroutine.resume(v)
                if not s then
                    print(s, m, k)
                    --table.remove(TaskList, k)
                    TaskList[k] = nil
                end
                if coroutine.status(v) == "dead" then
                    
                end
            end
            lastUpdate = os.clock()
        end
        pvz.SystemSleep(1)
        if os.clock() - lastUpdate > maxUpdate then
            print("level end", maxUpdate, os.clock(), lastUpdate)
            break
        end
    end
    
    local wait = 5300 / pvz.Speed()
    if wait < 800 then wait = 800 end
    pvz.SystemSleep(wait)
    print("wait end", wait)
end

local function AddTask(f, tag)
    local task = coroutine.create(f)
    if tag then
        TaskList[tag] = task
    else
        table.insert(TaskList, task)
    end
end

pvz.AddTask = AddTask

pvz.Delay = function(t)
    local start = pvz.gameTime
    while (pvz.gameTime - start < t) do
        coroutine.yield()
    end
end

pvz.WaitUntil = function (p)
    while not p() do
        coroutine.yield()
    end
end

pvz.Prejudge = function (t)
    local wave = pvz.Wave()
    if wave == 9 or wave == 19 then
        while pvz.WaveCD() > 4 do
            coroutine.yield()
        end
        -- pvz.Delay(725 - t)   --maybe a choice
        while pvz.HugeWaveCD() > t do
            coroutine.yield()
        end
    else
        while pvz.WaveCD() > t do
            coroutine.yield()
        end
    end
end

pvz.CheckFor = function (pred, timeout, interval)
    local expire = 0
    while expire < timeout do
        if pred() then
            return true
        end

        if interval then
            pvz.Delay(interval)
            expire = expire + interval
        else
            coroutine.yield()
            expire = expire + 1
        end
    end
    return false
end



local startFromZero = true
local function PaoCoroFun()
    startFromZero = true
    local plant_count_max = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.plant_count_max})
    local plant_offset = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.plant})

    for i = 0, plant_count_max - 1 do
        local curOffset = plant_offset + addr.plant_struct_size * i
        local plant_dead = pvz.ReadMemory("bool", {curOffset + addr.plant_dead})
        local plant_squished = pvz.ReadMemory("bool", {curOffset + addr.plant_squished})
        local plant_type = pvz.ReadMemory("uint32_t", {curOffset + addr.plant_type})
        local plant_status = pvz.ReadMemory("uint32_t", {curOffset + addr.plant_status})
        
        if not plant_dead and not plant_squished and plant_type == 47 and plant_status == 37 then
            local plant_hp = pvz.ReadMemory("uint32_t", {curOffset + addr.plant_hp})
            local plant_row = pvz.ReadMemory("uint32_t", {curOffset + addr.plant_row})
            local plant_col = pvz.ReadMemory("uint32_t", {curOffset + addr.plant_col})
            coroutine.yield({plant_hp = plant_hp, plant_row = plant_row + 1, plant_col = plant_col + 1})
            startFromZero = false
        end
    end
    if startFromZero then
        print("get pao a round end,not get")
        coroutine.yield(nil)
    end
    PaoCoroFun()       --tail call
end
local PaoCoro = coroutine.wrap(PaoCoroFun)
local function GetPao()
    return PaoCoro()
end

pvz.Pao = function (r, c)
    for _ = 1, 2 do
        local pao = GetPao()
        if not pao then
            print("no valid pao")
            break
        end
        local near = math.abs(pao.plant_row - r) + math.abs(pao.plant_col - c) < 1.9

        if near then
            near = math.abs(pao.plant_row - r) + math.abs(pao.plant_col - c + 1) < 1.9
            if not near then
                pao.plant_col = pao.plant_col + 1
            end
        end
        if not near then
            for _ = 1, 3 do
                pvz.ClickFeild(pao.plant_row, pao.plant_col)
            end
            pvz.ClickFeild(r, c)
            break
        else
            print("get pao to0 near", pao.plant_row, pao.plant_col, r, c)
        end
    end
end

pvz.GetSpawnType = function()
    local spawnOffset = pvz.ReadMemory("uint32_t", {pvz_base, main_object}) + addr.spawn_type
    local spawnType = {}
    for i = 0, 32 do
        local spawn = pvz.ReadMemory("bool", {spawnOffset + i})
        spawnType[i] = spawn
    end
    return spawnType
end

pvz.GetSpawnInfo = function ()
    local spawnType = {}
    local mem = pvz.ReadMemoryArray("bool", 33, {pvz_base, main_object, addr.spawn_type})
    for i, v in ipairs(mem) do
        if v then
            spawnType[i - 1] = true
        end
    end
    pvz.SPAWN_TYPE = spawnType

    mem = pvz.ReadMemoryArray("uint32_t", 1000, {pvz_base, main_object, addr.spawn_list})
    local spawnList = {}
    for j = 0, 19 do
        local spawn = {}
        for k = 0, 49 do
            local z = mem[j * 50 + k + 1]
            if z >= 0 and z < 40 then
                spawn[z] = true
            else
                break
            end
        end
        spawnList[j + 1] = spawn
    end
    pvz.SPAWN_LIST = spawnList
end

pvz.GetAliveZombies = function()
    local zombies = {}
    local zombieOffset = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.zombie})
    local zombieMaxCount = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.zombie_count_max})
    print("GetAliveZombies", zombieMaxCount, zombieOffset)
    for i = 0, zombieMaxCount - 1 do
        local status = pvz.ReadMemory("uint32_t", {zombieOffset + i * addr.zombie_struct_size + addr.zombie_status})
        local dead = pvz.ReadMemory("bool", {zombieOffset + i * addr.zombie_struct_size + addr.zombie_dead})
        if not dead and status ~= 1 and status ~= 2 and status ~= 3 then
            local zombie_type = pvz.ReadMemory("uint32_t", {zombieOffset + i * addr.zombie_struct_size + addr.zombie_type})
            local x = pvz.ReadMemory("float", {zombieOffset + i * addr.zombie_struct_size + addr.zombie_x})
            local y = pvz.ReadMemory("float", {zombieOffset + i * addr.zombie_struct_size + addr.zombie_y})
            local hp = pvz.ReadMemory("uint32_t", {zombieOffset + i * addr.zombie_struct_size + 0xc8})
            table.insert(zombies, {zombie_type = zombie_type, x = x, y = y, hp = hp})
            print("GetAliveZombies", zombie_type, x, y, dead, pvz.GetZombieName(zombie_type), hp)
        end
    end
    return zombies
end

pvz.GetCurPlants = function ()
    local plants = {}
    local plant_count_max = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.plant_count_max})
    local plant_offset = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.plant})

    for i = 0, plant_count_max - 1 do
        local curOffset = plant_offset + addr.plant_struct_size * i
        local plant_dead = pvz.ReadMemory("bool", {curOffset + addr.plant_dead})
        local plant_squished = pvz.ReadMemory("bool", {curOffset + addr.plant_squished})
        local plant_type = pvz.ReadMemory("uint32_t", {curOffset + addr.plant_type})
        if not plant_dead and not plant_squished then
            local plant = {}
            plant.hp = pvz.ReadMemory("uint32_t", {curOffset + addr.plant_hp})
            plant.row = pvz.ReadMemory("uint32_t", {curOffset + addr.plant_row})
            plant.col = pvz.ReadMemory("uint32_t", {curOffset + addr.plant_col})
            plant.type = plant_type
            table.insert(plants, plant)
        end
    end
    return plants
end

pvz.HasZombie = function (z, n)
    local index = pvz.ZOMBIE[z]
    if not index then return false end

    local spawn = pvz.SPAWN_TYPE
    if n and n > 0 then
        spawn = pvz.SPAWN_LIST
    end
    return spawn[index]
end

local CollectCoro
CollectCoro = function ()
    local item_count_max = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.item_max_num})
    local item_offset = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.item})
    for i = 0, item_count_max - 1 do
        local curOffset = item_offset + addr.item_struct_size * i
        local item_dissapear = pvz.ReadMemory("bool", {curOffset + addr.item_dissapear})
        local item_collected = pvz.ReadMemory("bool", {curOffset + addr.item_collected})
        if not item_dissapear and not item_collected then
            local x = pvz.ReadMemory("float", {curOffset + addr.item_x})
            local y = pvz.ReadMemory("float", {curOffset + addr.item_y})
            if (x > 0 and y > 70) then
                pvz.Click(math.floor(x + 20), math.floor(y + 20))
                pvz.SafeClick()
                pvz.Delay(10)
            end
        end
    end
    pvz.Delay(10)
    CollectCoro()
end
AddTask(CollectCoro, "collect")

local function FindCard(card)

end
pvz.UseCard = function (card, r, c)
    local slotNum = pvz.SlotCount()
    if type(card) == "table" then
        for _, v in ipairs(card) do
            pvz.UseCard(v, r, c)
        end
    elseif type(card) == "string" then
        local plantIndex = PLANT[card]
        for i, v in ipairs(cards) do
            if v == plantIndex then
                local kmap = {[7] = 59, [8] = 55, [9] = 53, [10] = 51}
                print("UseCard", card, plantIndex, i, v, r, c)
                local k = kmap[slotNum] or 51
                pvz.Click(50 + k * i, 42)
                pvz.ClickFeild(r, c)
                pvz.SafeClick()
                break
            end
        end
    end    
end


local function GotoGame ()
    --TODO
end

pvz.SetCards = function (...)
    local c = {...}
    cards = {}
    for _, v in ipairs(c) do
        print("SetCards", v, PLANT[v])
        local plantIndex = PLANT[v]
        table.insert(cards, plantIndex)
    end
end
local function ChooseCard()
    for _, v in ipairs(cards) do
        local imit = false
        if v < 0 then
            v = -v
            imit = true
        end
        local row, col = math.floor(v / 8), v % 8
        print("choose", v, row, col)
        if not imit then
            pvz.Click(22 + 50/2 + col* 53, 123 + 70/2 + row * 70);
        else
            pvz.ButtonClick(490, 550);
            pvz.SystemSleep(200)
            pvz.Click(190 + 50/2 + col * 51, 125 + 70/2 + row * 71);
        end
        pvz.SystemSleep(50)
    end
    pvz.ButtonClick(234, 567)
    pvz.SystemSleep(200)
    if pvz.HasDialog() then
        pvz.ButtonClick(300, 400)
        pvz.SystemSleep(100)
    end
    local check = 100 / pvz.Speed()
    if check < 30 then check = 30 end
    for _ = 1, check do
        if pvz.GameUI() == 3 then
            return true
        end
        pvz.SystemSleep(100)
    end

    -- choose card failed
    for _ = 1, 20 do
        pvz.Click(100, 30)
        pvz.SystemSleep(20)
    end
    
    return false
end
pvz.ChooseCard = function(...)
    if pvz.GameUI() == 3 then
        return true
    end
    local cards = {...}
    print("pvz.ChooseCard", #cards)
    if #cards > 0 then
        pvz.SetCards(cards)
    end
    repeat until ChooseCard()
end
pvz.RunEndless = function (round)
    if not round then round = 9999999 end
    GotoGame()
    for r = 1, round do
        print("round start", r, pvz.Sun())
        if pvz.OnLevelStart then
            pvz.OnLevelStart()
        end
        repeat until ChooseCard()
        
        pvz.RunOneLevel()
        repeat pvz.SystemSleep(10) until pvz.GameUI() == 2
        pvz.SystemSleep(500 * pvz.FrameDuration())
    end
end

local seeds_string = {
    {"Peashooter", "豌豆射手", "豌豆", "单发"},
    {"Sunflower", "向日葵", "小向", "太阳花", "花"},
    {"Cherry Bomb", "樱桃炸弹", "樱桃", "炸弹", "爆炸", "草莓", "樱"},
    {"Wall-nut", "坚果", "坚果墙", "墙果", "建国", "柠檬圆"},
    {"Potato Mine", "土豆地雷", "土豆", "地雷", "土豆雷"},
    {"Snow Pea", "寒冰射手", "冰豆", "冰冻豌豆", "冰豌豆", "雪花豌豆", "雪花"},
    {"Chomper", "大嘴花", "大嘴", "食人花", "咀嚼者", "食"},
    {"Repeater", "双重射手", "双发射手", "双重", "双发", "双发豌豆"},
    {"Puff-shroom", "小喷菇", "小喷", "喷汽蘑菇", "烟雾蘑菇", "免费蘑菇", "炮灰菇", "小蘑菇", "免费货", "免费", "紫蘑菇"},
    {"Sun-shroom", "阳光菇", "阳光", "阳光蘑菇"},
    {"Fume-shroom", "大喷菇", "大喷", "烟雾喷菇", "大蘑菇", "喷子", "喷"},
    {"Grave Buster", "咬咬碑", "墓碑吞噬者", "墓碑破坏者", "噬碑藤", "墓碑", "墓碑苔藓", "苔藓"},
    {"Hypno-shroom", "迷糊菇", "魅惑菇", "魅惑", "迷惑菇", "迷蘑菇", "催眠蘑菇", "催眠", "花蘑菇", "毒蘑菇"},
    {"Scaredy-shroom", "胆小菇", "胆小", "胆怯蘑菇", "胆小鬼蘑菇", "杠子蘑菇"},
    {"Ice-shroom", "冰川菇", "寒冰菇", "冰菇", "冷冻蘑菇", "冰蘑菇", "冰莲菇", "面瘫", "蓝冰", "原版冰", "冰"},
    {"Doom-shroom", "末日菇", "毁灭菇", "核蘑菇", "核弹", "核武", "毁灭", "末日蘑菇", "末日", "黑核", "原版核", "核"},
    {"Lily Pad", "莲叶", "睡莲", "荷叶", "莲"},
    {"Squash", "窝瓜", "倭瓜", "窝瓜大叔", "倭瓜大叔", "镇压者"},
    {"Threepeater", "三重射手", "三线射手", "三头豌豆", "三联装豌豆", "三重", "三线", "三头", "三管", "管"},
    {"Tangle Kelp", "缠绕水草", "缠绕海草", "缠绕海藻", "缠绕海带", "水草", "海草", "海藻", "海带", "马尾藻", "绿毛线", "毛线"},
    {"Jalapeno", "火爆辣椒", "辣椒", "墨西哥胡椒", "墨西哥辣椒", "辣", "椒"},
    {"Spikeweed", "地刺", "刺", "尖刺", "尖刺杂草", "棘草", "荆棘"},
    {"Torchwood", "火炬树桩", "火树桩", "火树", "火炬", "树桩", "火炬木", "火"},
    {"Tall-nut", "高坚果", "搞基果", "高建国", "巨大墙果", "巨大", "高墙果", "大墙果", "大土豆"},
    {"Sea-shroom", "水兵菇", "海蘑菇"},
    {"Plantern", "路灯花", "灯笼", "路灯", "灯笼草", "灯笼花", "吐槽灯", "灯"},
    {"Cactus", "仙人掌", "小仙", "掌"},
    {"Blover", "三叶草", "三叶", "风扇", "吹风", "愤青"},
    {"Split Pea", "双向射手", "裂荚射手", "裂荚", "双头", "分裂豌豆", "双头豌豆"},
    {"Starfruit", "星星果", "杨桃", "星星", "五角星", "五星黄果", "1437", "大帝", "桃"},
    {"Pumpkin", "南瓜头", "南瓜", "南瓜罩", "南瓜壳", "套"},
    {"Magnet-shroom", "磁力菇", "磁铁", "磁力蘑菇", "磁"},
    {"Cabbage-pult", "卷心菜投手", "包菜", "卷心菜", "卷心菜投抛者", "包菜投掷手"},
    {"Flower Pot", "花盆", "盆"},
    {"Kernel-pult", "玉米投手", "玉米", "黄油投手", "玉米投抛者", "玉米投掷手"},
    {"Coffee Bean", "咖啡豆", "咖啡", "兴奋剂", "春药"},
    {"Garlic", "大蒜", "蒜"},
    {"Umbrella Leaf", "萝卜伞", "叶子保护伞", "伞型保护叶", "莴苣", "萝卜", "白菜", "保护伞", "叶子伞", "伞叶", "叶子", "伞", "叶"},
    {"Marigold", "金盏花", "金盏草", "金盏菊", "吐钱花"},
    {"Melon-pult", "西瓜投手", "西瓜", "绿皮瓜", "瓜", "西瓜投抛者", "西瓜投掷手"},
    {"Gatling Pea", "机枪射手", "加特林豌豆", "格林豌豆", "加特林", "机枪", "枪"},
    {"Twin Sunflower", "双胞向日葵", "双子向日葵", "双头葵花", "双胞", "双子", "双向", "双花"},
    {"Gloom-shroom", "多嘴小蘑菇", "忧郁蘑菇", "忧郁", "忧郁菇", "章鱼", "曾哥", "曾哥蘑菇", "曾"},
    {"Cattail", "猫尾草", "香蒲", "猫尾", "猫尾香蒲", "小猫香蒲", "小猫", "猫"},
    {"Winter Melon", "冰西瓜", "'冰'瓜", '"冰"瓜', "冰瓜", "冰冻西瓜", "冬季西瓜"},
    {"Gold Magnet", "吸金菇", "吸金磁", "吸金草", "金磁铁", "吸金", "磁力金钱菇"},
    {"Spikerock", "钢地刺", "钢刺", "地刺王", "尖刺岩石", "尖刺石", "石荆棘"},
    {"Cob Cannon", "玉米加农炮", "玉米炮", "加农炮", "春哥", "春哥炮", "炮", "春", "神"},
}

local zombies_string = {
    {"Zombie", "普僵", "普通", "领带"},
    {"Flag Zombie", "旗帜", "摇旗", "旗子"},
    {"Conehead Zombie", "路障"},
    {"Pole Vaulting Zombie", "撑杆", "撑杆跳"},
    {"Buckethead Zombie", "铁桶"},
    {"Newspaper Zombie", "读报", "报纸"},
    {"Screen Door Zombie", "铁门", "铁栅门", "门板"},
    {"Football Zombie", "橄榄", "橄榄球"},
    {"Dancing Zombie", "舞王", "MJ"},
    {"Backup Dancer", "伴舞", "舞伴"},
    {"Ducky Tube Zombie", "鸭子", "救生圈"},
    {"Snorkel Zombie", "潜水"},
    {"Zomboni", "冰车", "制冰车"},
    {"Zombie Bobsled Team", "雪橇", "雪橇队", "雪橇小队"},
    {"Dolphin Rider Zombie", "海豚", "海豚骑士"},
    {"Jack-in-the-Box Zombie", "小丑", "玩偶匣"},
    {"Balloon Zombie", "气球"},
    {"Digger Zombie", "矿工", "挖地"},
    {"Pogo Zombie", "跳跳", "弹跳"},
    {"Zombie Yeti", "雪人"},
    {"Bungee Zombie", "蹦极", "小偷"},
    {"Ladder Zombie", "扶梯", "梯子"},
    {"Catapult Zombie", "投篮", "投篮车", "篮球"},
    {"Gargantuar", "白眼", "伽刚特尔", "巨人"},
    {"Imp", "小鬼", "小恶魔", "IMP"},
    {"Dr. Zomboss", "僵王", "僵博"},
    {"Peashooter Zombie", "豌豆"},
    {"Wall-nut Zombie", "坚果"},
    {"Jalapeno Zombie", "辣椒"},
    {"Gatling Pea Zombie", "机枪", "加特林"},
    {"Squash Zombie", "倭瓜", "窝瓜"},
    {"Tall-nut Zombie", "高坚果"},
    {"GigaGargantuar", "红眼", "暴走伽刚特尔", "红眼巨人"},
}


for i, v in ipairs(seeds_string) do
    local id = i - 1
    for _, name in pairs(v) do
        PLANT[name] = id
    end
end

pvz.PLANT = PLANT


for i, v in ipairs(zombies_string) do
    local id = i - 1
    for _, name in pairs(v) do
        ZOMBIE[name] = id
    end
end

pvz.ZOMBIE = ZOMBIE

pvz.GetZombieName = function(z)
    return zombies_string[z+1][2]
end

pvz.GetPlantName = function(p)
    return seeds_string[p+1][2]
end

return pvz