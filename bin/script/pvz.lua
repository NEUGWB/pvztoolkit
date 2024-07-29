local pvz = pvz
local ZOMBIES = {}
local PLANTS = {}

PEASHOOTER = 0 -- 豌豆射手 
SUNFLOWER = 1 -- 向日葵    
CHERRY_BOMB = 2 -- 樱桃炸弹
WALL_NUT = 3 -- 坚果       
POTATO_MINE = 4 -- 土豆地雷
SNOW_PEA = 5 -- 寒冰射手   
CHOMPER = 6 -- 大嘴花      
REPEATER = 7 -- 双重射手   
PUFF_SHROOM = 8 -- 小喷菇  
SUN_SHROOM = 9 -- 阳光菇   
FUME_SHROOM = 10 -- 大喷菇
GRAVE_BUSTER = 11 -- 墓碑吞噬者
HYPNO_SHROOM = 12 -- 魅惑菇
SCAREDY_SHROOM = 13 -- 胆小菇
ICE_SHROOM = 14 -- 寒冰菇
DOOM_SHROOM = 15 -- 毁灭菇
LILY_PAD = 16 -- 荷叶
SQUASH = 17 -- 倭瓜
THREEPEATER = 18 -- 三发射手
TANGLE_KELP = 19 -- 缠绕海藻
JALAPENO = 20 -- 火爆辣椒
SPIKEWEED = 21 -- 地刺
TORCHWOOD = 22 -- 火炬树桩
TALL_NUT = 23 -- 高坚果
SEA_SHROOM = 24 -- 水兵菇
PLANTERN = 25 -- 路灯花
CACTUS = 26 -- 仙人掌
BLOVER = 27 -- 三叶草
SPLIT_PEA = 28 -- 裂荚射手
STARFRUIT = 29 -- 杨桃
PUMPKIN = 30 -- 南瓜头
MAGNET_SHROOM = 31 -- 磁力菇
CABBAGE_PULT = 32 -- 卷心菜投手
FLOWER_POT = 33 -- 花盆
KERNEL_PULT = 34 -- 玉米投手
COFFEE_BEAN = 35 -- 咖啡豆
GARLIC = 36 -- 大蒜
UMBRELLA_LEAF = 37 -- 叶子保护伞
MARIGOLD = 38 -- 金盏花
MELON_PULT = 39 -- 西瓜投手
GATLING_PEA = 40 -- 机枪射手
TWIN_SUNFLOWER = 41 -- 双子向日葵
GLOOM_SHROOM = 42 -- 忧郁菇
CATTAIL = 43 -- 香蒲
WINTER_MELON = 44 -- 冰西瓜投手
GOLD_MAGNET = 45 -- 吸金磁
SPIKEROCK = 46 -- 地刺王
COB_CANNON = 47 -- 玉米加农炮
IMITATOR = 48 -- 模仿者

M_PEASHOOTER = 49 -- 豌豆射手
M_SUNFLOWER = 50 -- 向日葵
M_CHERRY_BOMB = 51 -- 樱桃炸弹
M_WALL_NUT = 52 -- 坚果
M_POTATO_MINE = 53 -- 土豆地雷
M_SNOW_PEA = 54 -- 寒冰射手
M_CHOMPER = 55 -- 大嘴花
M_REPEATER = 56 -- 双重射手
M_PUFF_SHROOM = 57 -- 小喷菇
M_SUN_SHROOM = 58 -- 阳光菇
M_FUME_SHROOM = 59 -- 大喷菇
M_GRAVE_BUSTER = 60 -- 墓碑吞噬者
M_HYPNO_SHROOM = 61 -- 魅惑菇
M_SCAREDY_SHROOM = 62 -- 胆小菇
M_ICE_SHROOM = 63 -- 寒冰菇
M_DOOM_SHROOM = 64 -- 毁灭菇
M_LILY_PAD = 65 -- 荷叶
M_SQUASH = 66 -- 倭瓜
M_THREEPEATER = 67 -- 三发射手
M_TANGLE_KELP = 68 -- 缠绕海藻
M_JALAPENO = 69 -- 火爆辣椒
M_SPIKEWEED = 70 -- 地刺
M_TORCHWOOD = 71 -- 火炬树桩
M_TALL_NUT = 72 -- 高坚果
M_SEA_SHROOM = 73 -- 水兵菇
M_PLANTERN = 74 -- 路灯花
M_CACTUS = 75 -- 仙人掌
M_BLOVER = 76 -- 三叶草
M_SPLIT_PEA = 77 -- 裂荚射手
M_STARFRUIT = 78 -- 杨桃
M_PUMPKIN = 79 -- 南瓜头
M_MAGNET_SHROOM = 80 -- 磁力菇
M_CABBAGE_PULT = 81 -- 卷心菜投手
M_FLOWER_POT = 82 -- 花盆
M_KERNEL_PULT = 83 -- 玉米投手
M_COFFEE_BEAN = 84 -- 咖啡豆
M_GARLIC = 85 -- 大蒜
M_UMBRELLA_LEAF = 86 -- 叶子保护伞
M_MARIGOLD = 87 -- 金盏花
M_MELON_PULT = 88 -- 西瓜投手

PUJIANG = 0 -- 普僵
FLAG_ZOMBIE = 1 -- 旗帜
CONEHEAD_ZOMBIE = 2 -- 路障
POLE_VAULTING_ZOMBIE = 3 -- 撑杆
BUCKETHEAD_ZOMBIE = 4 -- 铁桶
NEWSPAPER_ZOMBIE = 5 -- 读报
SCREEN_DOOR_ZOMBIE = 6 -- 铁门
FOOTBALL_ZOMBIE = 7 -- 橄榄
DANCING_ZOMBIE = 8 -- 舞王
BACKUP_DANCER = 9 -- 伴舞
DUCKY_TUBE_ZOMBIE = 10 -- 鸭子
SNORKEL_ZOMBIE = 11 -- 潜水
ZOMBONI = 12 -- 冰车
ZOMBIE_BOBSLED_TEAM = 13 -- 雪橇
DOLPHIN_RIDER_ZOMBIE = 14 -- 海豚
JACK_IN_THE_BOX_ZOMBIE = 15 -- 小丑
BALLOON_ZOMBIE = 16 -- 气球
DIGGER_ZOMBIE = 17 -- 矿工
POGO_ZOMBIE = 18 -- 跳跳
ZOMBIE_YETI = 19 -- 雪人
BUNGEE_ZOMBIE = 20 -- 蹦极
LADDER_ZOMBIE = 21 -- 扶梯
CATAPULT_ZOMBIE = 22 -- 投篮
GARGANTUAR = 23 -- 白眼
IMP = 24 -- 小鬼
DR_ZOMBOSS = 25 -- 僵博
GIGA_GARGANTUAR = 32 -- 红眼

local asm_version =
{
    [1001] = true,
    [2001] = true,
    [2002] = true,
}
local use_asm = asm_version[pvz.version]

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
addr.zombie_hp = 0xc8
addr.zombie_row = 0x1c
addr.zombie_slow_cd = 0xac
addr.zombie_freeze_cd = 0xb4
addr.zombie_exist_time = 0x60
addr.zombie_wave = 0x6c

addr.plant_status = 0x3c
addr.plant_status_count_down = 0x54
addr.plant_hp = 0x40

local _meta_pvz_struct
local function LuaPvzStruct(ptr, meta)
    local struct = {_ptr = ptr,
        _memory = rawget(meta, "_memory"),
        _size = rawget(meta, "_size"),
        _method = rawget(meta, "_method")
    }

    setmetatable(struct, _meta_pvz_struct)
    --print("LuaPvzStruct", struct, struct.ptr)
    return struct
end

_meta_pvz_struct =
{
    __index = function(t, k)
        --print("_meta_pvz_struct", t, k)
        local _method = rawget(t, "_method")
        if _method and _method[k] then
            return _method[k]
        end

        local _memory = rawget(t, "_memory")
        local _ptr = rawget(t, "_ptr")
        if not _memory or not _ptr then
            print("__index not valid lua pvz struct", t, _memory, _ptr)
            pvz.Error("")
        end

        local mem = _memory[k]
        if not mem then
            print("__index not valid key", t, k)
            pvz.Error("")
        end
        local data = pvz.ReadMemory(mem[1], {_ptr + mem[2]})
        --print("read meta memory", mem[1], _ptr, mem[2], k)
        if (mem.meta) then
            return LuaPvzStruct(data, mem.meta)
        end
        return data
    end,

    __add = function(t, n)
        if n == 0 then
            return t
        end
        local _size = rawget(t, "_size")
        local _ptr = rawget(t, "_ptr")
        if not _size or not _ptr then
            print("__add not valid lua pvz struct", t, _size, _ptr)
            pvz.Error()
        end
        local ptr = _ptr + n * _size
        return LuaPvzStruct(ptr, t)
    end,

    __newindex = function(t, k, v)
        --print("__newindex", t, k, v)
        local _memory = rawget(t, "_memory")
        local _ptr = rawget(t, "_ptr")
        if not _memory or not _ptr then
            print("__newindex not valid lua pvz struct", t, _memory, _ptr)
        end

        local mem = _memory[k]
        if not mem then
            print("__newindex not valid key", t, k)
        end
        pvz.WriteMemory(mem[1], {_ptr + mem[2]}, v)
    end
}

local _meta_seed = {
    _memory =
    {
        IsUsable = {"bool", 0x48 + 0x28},
        Cd = {"int32_t", 0x24 + 0x28},
        InitialCd = {"int32_t", 0x28 + 0x28},
        ImitaterType = {"int32_t", 0x38 + 0x28},
        Type = {"int32_t", 0x34 + 0x28},
    },
    _size = 0x50,
}

pvz.SeedHead = function()
    local ptr = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.slot})
    return LuaPvzStruct(ptr, _meta_seed)
end

local _meta_plant = {
    _memory =
    {
        Row = {"int32_t", addr.plant_row},
        Col = {"int32_t", addr.plant_col},
        Type = {"int32_t", addr.plant_type},
        Status = {"int32_t", addr.plant_status},
        StatusCountDown = {"int32_t", addr.plant_status_count_down},
        Hp = {"int32_t", addr.plant_hp},
        --StateCountdown = {"int32_t", addr.plant_hp},

        Dead = {"bool", addr.plant_dead},
        Squished = {"bool", addr.plant_squished},
        --Sleeping = {"bool", addr.plant_asleep},
    },
    _method =
    {
        Alive = function(v) return not v.Dead and not v.Squished end,
    },
    _size = addr.plant_struct_size,
}

pvz.PlantHead = function()
    local ptr = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.plant})
    return LuaPvzStruct(ptr, _meta_plant)
end

local _meta_zombie = {
    _memory =
    {
        X = {"int32_t", addr.zombie_x},
        Y = {"int32_t", addr.zombie_y},
        Row = {"int32_t", addr.zombie_row},
        Type = {"int32_t", addr.zombie_type},
        Status = {"int32_t", addr.zombie_status},
        Hp = {"int32_t", addr.zombie_hp},

        SlowCd = {"int32_t", addr.zombie_slow_cd},
        FreezeCd = {"int32_t", addr.zombie_freeze_cd},
        ExistTime = {"int32_t", addr.zombie_exist_time},
        Wave = {"int32_t", addr.zombie_wave},

        Dead = {"bool", addr.zombie_dead},
    },
    _method =
    {
        Alive = function(z)
            local st = z.Status
            local dead = z.Dead
            return not dead and st ~= 1 and st ~= 2 and st ~= 3
        end
    },
    _size = addr.zombie_struct_size,
}

pvz.ZombieHead = function()
    local ptr = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.zombie})
    return LuaPvzStruct(ptr, _meta_zombie)
end

local function ObjectIter(array, max, pred)
    local index = 0
    return function()
        while index < max do
            local r = array + index
            local i = index
            index = index + 1
            if not pred or pred(r) then
                return r, i
            end
        end
    end
end

pvz.AliveZombies = function()
    local zombies = pvz.ZombieHead()
    local max = pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.zombie_count_max})
    local alive = function(z)
        return z:Alive()
    end
    return ObjectIter(zombies, max, alive)
end

pvz.AlivePlants = function()
    local plants = pvz.PlantHead()
    local max = pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.plant_count_max})
    local alive = function(p)
        return not p.Squished and not p.Dead
    end
    return ObjectIter(plants, max, alive)
end

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

local GlobalDelay = function(t)
    local start = pvz.globalClock
    while (pvz.globalClock - start < t) do
        coroutine.yield()
    end
end

pvz.SlowClick = function(x, y)
    pvz.PostMessage(WIN_ENUM.WM_LBUTTONDOWN, 0, MakeLongWithDpi(x, y))
    GlobalDelay(2)
    pvz.PostMessage(WIN_ENUM.WM_LBUTTONUP, 0, MakeLongWithDpi(x, y))
end

pvz.ButtonClick = function(x, y)
    local function _do()
        pvz.PostMessage(WIN_ENUM.WM_LBUTTONDOWN, 0, MakeLongWithDpi(x, y))
        GlobalDelay(2)
        pvz.PostMessage(WIN_ENUM.WM_LBUTTONUP, 0, MakeLongWithDpi(x, y))
    end
    _do()
    GlobalDelay(3)
    _do()
end

pvz.GridToXY = function(r, c)
    local x = 80 * c
    local y = 0
    if pvz.scene == 2 or pvz.scene == 3 then
        y = 55 + 85 * r
    elseif pvz.scene == 4 or pvz.scene == 5 then
        if c >= 6 then
            y = 45 + 85 * r
        else
            y = 45 + 85 * r + 20 * (6 - c)
        end
    else
        y = 40 + 100 * r
    end
    return math.floor(x), math.floor(y)
end

pvz.ClickFeild = function (r, c)
    local x, y = pvz.GridToXY(r, c)
    pvz.Click(x, y);
end

local type_size = {
    float = 4,
    uint32_t = 4,
    int32_t = 4,
    bool = 1,
}
pvz.ReadMemory = function(t, a)
    --print("read memory", t, a, debug.traceback())
    local ret = pvz.ReadProcessMemory(t, a)
    if ret == nil then
        print(debug.traceback())
        pvz.Error("read memory error")
    end
    return ret
end

pvz.WriteMemory = function(t, a, v)
    pvz.WriteProcessMemory(t, a, v)
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
    return pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.game_clock})
end

pvz.Sun = function()
    return pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.sun})
end

pvz.GameUI = function ()
    return pvz.ReadMemory("int32_t", {pvz_base, addr.game_ui})
end

pvz.HasDialog = function ()
    return pvz.ReadMemory("int32_t", {pvz_base, addr.mouse_window, addr.popup_window}) ~= 0
end

pvz.Wave = function ()
    return pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.wave})
end

pvz.WaveCD = function ()
    return pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.wave_cd})
end

pvz.HugeWaveCD = function ()
    return pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.big_wave_cd})
end

pvz.WordType = function ()
    return pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.word, addr.word_type})
end

pvz.SlotCount = function ()
    return pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.slot, addr.slot_count})
end

pvz.Speed = function ()
    local ms = pvz.FrameDuration()
    return 10 / ms
end

pvz.FrameDuration = function ()
    return pvz.ReadMemory("int32_t", {pvz_base, addr.frame_duration})
end

local TaskList = {}
local function AddTask(f, tag)
    local task = coroutine.create(f)
    if tag then
        if TaskList[tag] then
            print("add duplicate task", tag, debug.traceback())
            pvz.Error()
        end
        TaskList[tag] = task
    else
        table.insert(TaskList, task)
    end
end

local function RunTask(f, tag)
    local task = coroutine.create(f)
    local s, m = coroutine.resume(task)
    if not s then
        print(s, m, debug.traceback(task))
        pvz.Error()
        return
    end
    if coroutine.status(task) == "dead" then
        return
    end

    if tag then
        TaskList[tag] = task
    else
        table.insert(TaskList, task)
    end
end

pvz.NewTask = function(f, tag)
    return function()
        RunTask(f, tag)
    end
end

pvz.Delay = function(t)
    local start = pvz.gameClock
    while (pvz.gameClock - start < t) do
        coroutine.yield()
    end
end

pvz.UntilGameClock = function(c)
    while pvz.gameClock < c do
        coroutine.yield()
    end
end

pvz.UntilWaveTime = function(w, t)
    while pvz.NowTime(w) < t do
        coroutine.yield()
    end
end

pvz.WaitUntil = function (p)
    while not p() do
        coroutine.yield()
    end
end



pvz.Check = function(t, p, i)
    if not i then i = 1 end
    local tt = 0
    while tt < t do
        tt = tt + i
        if p() then
            return true
        end
        for _ = 1, i do
            coroutine.yield()
        end
    end
    return false
end

local initPao = {}
local recentPao = {}

local lastPao = 0
local function GetPao()
    local now = pvz.gameClock
    for i, t in pairs(recentPao) do
        if now - t > 600 then
            recentPao[i] = nil
        end
    end

    for i = 0, #initPao - 1 do
        local cur = (i + lastPao) % #initPao
        local index, r, c = table.unpack(initPao[cur + 1])
        local plant = pvz.PlantHead() + index

        if not recentPao[index] and plant.Type == 47 and plant:Alive() and plant.Status == 37 then
            lastPao = cur
            return {plant_row = plant.Row + 1, plant_col = plant.Col + 1, plant_index = index}
        end
    end
end

local fixPaoHp = 300
local fixPaoSun = 3000

local function FixPao()
    for ii, v in ipairs(initPao) do
        pvz.Delay(1)
        if pvz.wave > 19 then
            return
        end
        local i, r, c = table.unpack(v)
        local p = pvz.PlantHead() + i
        --print("fix pao check", p.Type, p:Alive(), p.Hp, pvz.Sun())
        if p.Type ~= 47 or not p:Alive() or (p:Alive() and p.Hp < fixPaoHp and p.Status == 35 and p.StatusCountDown > 1450) then
            if pvz.Sun() > fixPaoSun and pvz.CanUseCard('玉米加农炮') and pvz.CanUseCard'玉米投手' then
                if p:Alive() and p.Type == 47 then
                    pvz.RemovePlant(r, c)
                end
                pvz.UseCard('玉米', r, c)
                pvz.Delay(751)
                pvz.UseCard('玉米', r, c + 1)
                pvz.UseCard('玉米加农炮', r, c)
                pvz.Delay(2)
                local newPao, newIndex = pvz.GetPlantAt(r, c)
                initPao[ii] = {newIndex, r, c}
                pvz.Delay(5001)
            end
        end
    end
    return FixPao()
end

pvz.AutoFixPao = function(hp, sun)
    fixPaoHp = hp
    fixPaoSun = sun
end

local function Pao(r, c, i)
    if use_asm then
        local x, y = pvz.GridToXY(r, c)
        pvz.AddOp(1, x, y, i)
        recentPao[i] = pvz.gameClock
        return true
    end
end

pvz.Pao = function (r, c, check)
    for _ = 1, 2 do
        local pao = GetPao()
        if not pao then
            print("no valid pao")
            break
        end
        if use_asm then
            local x, y = pvz.GridToXY(r, c)
            pvz.AddOp(1, x, y, pao.plant_index)
            recentPao[pao.plant_index] = pvz.gameClock
            return true
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
            recentPao[i] = pvz.gameClock
            return true
        else
            print("get pao to0 near", pao.plant_row, pao.plant_col, r, c)
        end
    end
    if check then
        print("no valid pao", debug.traceback())
        pvz.Error()
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

pvz.UpdateSpawnInfo = function ()
    local spawnType = {}
    local mem = pvz.ReadMemoryArray("bool", 33, {pvz_base, main_object, addr.spawn_type})
    for i, v in ipairs(mem) do
        if v then
            spawnType[i - 1] = true
        end
    end
    pvz.SPAWN_TYPE = spawnType

    mem = pvz.ReadMemoryArray("int32_t", 1000, {pvz_base, main_object, addr.spawn_list})
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

pvz.HasZombie = function (z, w)
    local index = pvz.ZOMBIE[z]
    if not index then return false end

    local spawn = pvz.SPAWN_TYPE
    if w and w > 0 then
        spawn = pvz.SPAWN_LIST[w]
    end
    return spawn[index]
end

local CollectCoro
CollectCoro = function ()
    local item_count_max = pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.item_max_num})
    local item_offset = pvz.ReadMemory("uint32_t", {pvz_base, main_object, addr.item})
    for i = 0, item_count_max - 1 do
        local curOffset = item_offset + addr.item_struct_size * i
        local item_dissapear = pvz.ReadMemory("bool", {curOffset + addr.item_dissapear})
        local item_collected = pvz.ReadMemory("bool", {curOffset + addr.item_collected})
        if not item_dissapear and not item_collected then
            local x = pvz.ReadMemory("float", {curOffset + addr.item_x})
            local y = pvz.ReadMemory("float", {curOffset + addr.item_y})
            if (x > 0 and y > 70) then
                if use_asm then
                    pvz.AddOp(6, math.floor(x + 20), math.floor(y + 20), 1)
                else
                    pvz.Click(math.floor(x + 20), math.floor(y + 20))
                    pvz.SafeClick()
                end
                pvz.Delay(12)
            end
        end
    end
    pvz.Delay(8)
    CollectCoro()
end

local function FindCard(card)

end

local slotCount
local UseCard = function(cardIndex, r, c)
    local seed = pvz.SeedHead() + (cardIndex - 1)
    if not seed.IsUsable then
        print("card cannot use", seed.Cd, seed.InitialCd, seed.Type, seed.ImitaterType)
    end
    if use_asm then
        local x, y = pvz.GridToXY(r, c)
        pvz.AddOp(2, x, y, cardIndex - 1)
    else
        local kmap = {[7] = 59, [8] = 55, [9] = 53, [10] = 51}
        local k = kmap[slotCount] or 51
        pvz.Click(50 + k * cardIndex, 42)
        pvz.ClickFeild(r, c)
        pvz.SafeClick()
    end
end

pvz.GetPlantIndexByName = function(name)
    local m1, m2
    local imstr = {'模仿', "Imitater"}
    for _, v in ipairs(imstr) do
        m1, m2 = name:find(v)
        if m1 then
            break
        end
    end

    if m2 then
        name = name:sub(m2 + 1)
    end

    local plantIndex = PLANTS[name]
    if m2 then
        plantIndex = -plantIndex
    end
    return plantIndex
end

pvz.GetCardIndexByName = function(name)
    local plantIndex = pvz.GetPlantIndexByName(name)
    for i, v in ipairs(cards) do
        if v == plantIndex then
            return i
        end
    end
    print("unknown card", name)
end

pvz.CanUseCard = function(card)
    local cardIndex
    if type(card) == "string" then
        cardIndex = pvz.GetCardIndexByName(card)
    elseif type(card) == "number" and card >= 1 and card <= 10 then
        cardIndex = card
    end
    if cardIndex then
        local seed = pvz.SeedHead() + (cardIndex - 1)
        return seed.IsUsable
    end
end

pvz.UseCard = function(card, r, c)
    if not slotCount then
        slotCount = pvz.SlotCount()
    end
    --print("use card", card, r, c, type(card))
    if type(card) == "string" then
        local cardIndex = pvz.GetCardIndexByName(card)
        if cardIndex then
            UseCard(cardIndex, r, c)
        end
    elseif type(card) == "number" then
        UseCard(card, r, c)
    elseif type(card) == "table" then
        for _, v in ipairs(card) do
            pvz.UseCard(v, r, c)
        end
    end
end

pvz.GetPlantAt = function(r, c, t)
    t = t or 0
    for p, i in pvz.AlivePlants() do
        if p.Row + 1 == r and p.Col + 1 == c then
            if t == 1 and p.Type == 30 then
                return p, i
            elseif t == 0 and p.Type ~= 33 and p.Type ~= 16 and p.Type ~= 30 then
                return p, i
            end
        end
    end
end

-- 0主要植物，1南瓜，2南瓜+主要植物，3南瓜+主要植物+莲叶/花盆
pvz.RemovePlant = function(r, c, t)
    t = t or 0

    local remove = {}
    local head = pvz.PlantHead()
    local max = pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.plant_count_max})
    --for p in pvz.AlivePlants() do
    for index = 0, max - 1 do
        local p = head + index
        if p.Row + 1 == r and p.Col + 1 == c and not p.Squished and not p.Dead then
            if t == 3 then
                table.insert(remove, index)
            elseif t == 2 and p.Type ~= 33 and p.Type ~= 16 then
                table.insert(remove, index)
            elseif t == 1 and p.Type == 30 then
                table.insert(remove, index)
            elseif t == 0 and p.Type ~= 33 and p.Type ~= 16 and p.Type ~= 30 then
                table.insert(remove, index)
            end
        end
    end
    for _, p in ipairs(remove) do
        pvz.AddOp(3, p)
    end
end

local function GotoGame ()
    --TODO
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
        PLANTS[name] = id
    end
end

pvz.PLANTS = PLANTS


for i, v in ipairs(zombies_string) do
    local id = i - 1
    for _, name in pairs(v) do
        ZOMBIES[name] = id
    end
end

pvz.ZOMBIES = ZOMBIES

pvz.GetZombieName = function(z)
    return zombies_string[z+1][2]
end

pvz.GetPlantName = function(p)
    return seeds_string[p+1][2]
end

function mp(...)
    local s = ""
    local tab = {...}
    for i, v in ipairs(tab) do
        if v then
            s = s..v
            if i < #tab then
                s = s.."\t"
            end
        end
    end
    return s
end

local logfile = nil
local log = function (...)
    if logfile then
        logfile:write(mp(...).."\n")
    end
end

pvz.LogFile = function (file)
    logfile = io.open(file, "w")
    ori_print = print
    print = function(...)
        ori_print(...)
        log(...)
    end
end

local waveRefreshTime = {}
local function UpdateRefreshTime()
    local wave = pvz.wave + 1
    if waveRefreshTime[wave] or wave > 20 then
        return
    end
    local clock = pvz.gameClock
    local wavecd = pvz.refreshCd

    if wave == 1 then
        if wavecd <= 599 and wavecd > 0 then
            waveRefreshTime[wave] = wavecd + clock
        end
    elseif wave % 10 ~= 0 then
        if wavecd <= 200 then
            waveRefreshTime[wave] = wavecd + clock
        end
    else
        if wavecd <= 200 and wavecd > 5 then
            waveRefreshTime[wave] = wavecd + 745 + clock
        elseif wavecd <= 5 then
            waveRefreshTime[wave] = pvz.hugeCd + clock
        end
    end
end

local connectTimeTask = {}
local curTimeTaskWave = 1

local function ClearTimeTask()
    waveRefreshTime = {}
    connectTimeTask = {}
    curTimeTaskWave = 1
end

local function UpdateTimeTask()
    local clock = pvz.gameClock
    for w = curTimeTaskWave, 20 do
        if not waveRefreshTime[w] then
            break
        end
        local waveTask = connectTimeTask[w] or {}
        local waveNowTime = clock - waveRefreshTime[w]

        for i, v in pairs(waveTask) do
            if v.time <= waveNowTime then
                v.func()
                waveTask[i] = nil
            end
        end
    end
end

local function NowTime(wave)
    local clock = pvz.gameClock
    if not wave then
        wave = pvz.wave
        if wave == 0 then
            wave = 1
        end
        if waveRefreshTime[wave + 1] then
            return wave + 1, clock - waveRefreshTime[wave + 1]
        elseif waveRefreshTime[wave]
            return wave, clock - waveRefreshTime[wave]
        else
            return 0, -math.huge
        end
    end

    if waveRefreshTime[wave] then
        return clock - waveRefreshTime[wave]
    else
        return -math.huge
    end
end

local function Connect(t, f)
    local wave = t[1]
    local time = t[2]
    local now = NowTime(wave)
    if time <= now then
        f()
        return
    end

    local waveTask = connectTimeTask[wave]
    if not waveTask then
        waveTask = {}
        connectTimeTask[wave] = waveTask
    end
    table.insert(waveTask, {time = time, func = f})
end

pvz.At = function(w, t)
    local at =
    {
        w = w, t = t,
        Run = function(self, func, effectTime)
            Connect({self.w, self.t - (effectTime or 0)}, pvz.NewTask(func), true)
            return self
        end,
        At = function(self, t)
            self.t = t
            return self
        end,
        Delay = function(self, d)
            self.t = self.t + d
            return self
        end
    }
    return at
end

pvz.Now = function()
    local w, t = NowTime()
    return pvz.At(w, t)
end

pvz.After = function(after)
    local w, t = NowTime()
    return pvz.At(w, t + after)
end

pvz.NowTime = NowTime

local function ChooseOneCard(card)
    local imit = false
    if card < 0 then
        card = -card
        imit = true
    end

    if use_asm then
        pvz.AddOp(5, card, imit and 1 or 0, 0)
        return
    end

    local row, col = math.floor(card / 8), card % 8
    if not imit then
        pvz.Click(22 + 50/2 + col* 53, 123 + 70/2 + row * 70);
    else
        pvz.ButtonClick(490, 550);
        pvz.Click(190 + 50/2 + col * 51, 125 + 70/2 + row * 71);
    end
end

local function ChooseCardProc()
    pvz.WaitUntil(function() return pvz.GameUI() == 2 end)
    GlobalDelay(485)
    pvz.UpdateSpawnInfo()
    pvz.NewLevel()

    while true do
        if #cards < 5 then
            print("you has not select cards")
            return
        end
        for _, v in ipairs(cards) do
            ChooseOneCard(v)
            GlobalDelay(3)
        end

        --Lets Rock
        if use_asm then
            GlobalDelay(30)
            pvz.AddOp(4, 0, 0, 0)
            GlobalDelay(30)
        else
            pvz.ButtonClick(234, 567)
            GlobalDelay(3)
            if pvz.HasDialog() then
                pvz.ButtonClick(300, 400)
                GlobalDelay(3)
            end
        end

        if pvz.Check(500, function() return pvz.GameUI() ~= 2 end) then
            print("choose card check success", pvz.GameUI())
            return
        end
        print("choose card check fail", pvz.GameUI())

        for _ = 1, 20 do
            pvz.Click(100, 30)
            GlobalDelay(2)
        end
    end
end

local ChooseCardTask

function OnEnterSelectCardsStage()
    pvz.scene = pvz.ReadMemory("int32_t", {pvz_base, main_object, addr.scene})
    ChooseCardTask = coroutine.create(ChooseCardProc)
end

pvz.SelectCards = function(...)
    cards = {}
    for _, v in ipairs({...}) do
        local plantIndex = pvz.GetPlantIndexByName(v)
        table.insert(cards, plantIndex)
    end
end

function OnEnterFightState()
    if pvz.Lineup then
        pvz.SetLineup(pvz.Lineup)
        pvz.Lineup = nil
    end

    AddTask(CollectCoro, "collect")

    if #initPao == 0 then
        for p, i in pvz.AlivePlants() do
            if p.Type == 47 then
                table.insert(initPao, {i, p.Row + 1, p.Col + 1})
            end
        end
    end

    if fixPaoHp < 300 and pvz.GetCardIndexByName'玉米' and pvz.GetCardIndexByName'玉米炮' then
        AddTask(FixPao)
    end
end

function OnLeaveFightState()
    ClearTimeTask()
    TaskList = {}
end

function TickGlobal()
    if ChooseCardTask then
        local s, m = coroutine.resume(ChooseCardTask)
        if not s then
            print("TickGlobal", m, debug.traceback(ChooseCardTask))
            pvz.Error()
            ChooseCardTask = nil
        end
        if coroutine.status(ChooseCardTask) == "dead" then
            ChooseCardTask = nil
        end
    end
end

function TickGame()
    UpdateRefreshTime()
    UpdateTimeTask()

    for k, v in pairs(TaskList) do
        local s, m = coroutine.resume(v)
        if not s then
            print("tick game error", s, m, k, debug.traceback())
            pvz.Error()
            TaskList[k] = nil
        end
        if coroutine.status(v) == "dead" then
            TaskList[k] = nil
        end
    end
end

return pvz