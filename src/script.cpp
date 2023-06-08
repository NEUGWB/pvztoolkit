#include "script.h"
#include "window.h"
#include <future>
#include <lua.hpp>
#include <filesystem>

#pragma warning(disable : 4244)
#pragma comment(lib, "winmm.lib")

#define SET_DATA_ADDR(field)                                                                                           \
    do                                                                                                                 \
    {                                                                                                                  \
        lua_pushinteger(lua, data.field);                                                                              \
        lua_setfield(lua, -2, #field);                                                                                 \
    } while (0)

BOOL InjectDll(HANDLE hProcess, LPCSTR szDllName, DWORD *pErrCode);
void Connect();
void AddOp(int opt, int p1, int p2, int p3, int p4);

namespace Script
{
lua_State *g_lua;

int lua_pcall_msg(lua_State *L, int n, int r, int f)
{
    int ret = lua_pcall(L, n, r, f);
    if (ret != LUA_OK)
    {
        printf("lua pcall error %s\n", lua_tostring(L, -1));
    }
    return ret;
}

struct RunInMainThread
{
    std::function<void()> _func;
    std::promise<void> &promise;

    static void ThreadFun(void *data)
    {
        RunInMainThread *pThis = (RunInMainThread *)data;
        pThis->_func();
        pThis->promise.set_value();
    }

    void Run()
    {
        std::promise<void> promise;
        Fl::awake(RunInMainThread::ThreadFun, this);
        std::future<void> future = promise.get_future();
        return future.get();
    }
};

/*
纳秒休眠，符号ns（英语：nanosecond ）.
1纳秒等于十亿分之一秒（10-9秒）
1 纳秒 = 1000皮秒
1,000 纳秒 = 1微秒
1,000,000 纳秒 = 1毫秒
1,000,000,000 纳秒 = 1秒
*/
int NSSleep(long long ns)
{
    HANDLE hTimer = NULL;
    LARGE_INTEGER liDueTime;

    liDueTime.QuadPart = -ns;

    // Create a waitable timer.
    hTimer = CreateWaitableTimerA(NULL, TRUE, "WaitableTimer");
    if (!hTimer)
    {
        printf("CreateWaitableTimer failed (%d)\n", GetLastError());
        return 1;
    }

    // Set a timer to wait for 10 seconds.
    if (!SetWaitableTimer(hTimer, &liDueTime, 0, NULL, NULL, 0))
    {
        printf("SetWaitableTimer failed (%d)\n", GetLastError());
        return 2;
    }

    // Wait for the timer.
    // printf("before wait object %lld %llu\n", liDueTime.QuadPart, GetTickCount64());
    if (WaitForSingleObject(hTimer, INFINITE) != WAIT_OBJECT_0)
        printf("WaitForSingleObject failed (%d)\n", GetLastError());
    // printf("after wait object %lld %llu\n", liDueTime.QuadPart, GetTickCount64());
    return 0;
}

// system
int Lua_Sleep(lua_State *L)
{
    //::Sleep(luaL_checkinteger(L, 1));
    NSSleep(long long(luaL_checknumber(L, 1) * 10'000ll));
    return 0;
}

int Lua_ReadMemory(lua_State *L)
{
    std::vector<uintptr_t> addr;
    addr.reserve(6);

    std::string type = luaL_checkstring(L, 1);
    // int num = luaL_checkinteger(L, 2);

    /*lua_pushnil(L);
    while (lua_next(L, -2))
    {
        addr.push_back((uintptr_t)luaL_checkinteger(L, -1));
        lua_pop(L, 1);
    }*/
    // lua_pop(L, 1);

    int n = lua_rawlen(L, -1);
    for (int i = 1; i <= n; ++i)
    {
        lua_rawgeti(L, -1, i);
        addr.push_back((uintptr_t)luaL_checkinteger(L, -1));
        lua_pop(L, 1);
    }

    if (type == "float")
    {
        auto result = g_pvz->ReadMemory<float>(addr);
        lua_pushnumber(L, result);
    }
    else if (type == "uint8_t")
    {
        auto result = g_pvz->ReadMemory<uint8_t>(addr);
        lua_pushinteger(L, result);
    }
    else if (type == "bool")
    {
        auto result = g_pvz->ReadMemory<uint8_t>(addr);
        lua_pushboolean(L, result);
    }
    else if (type == "uint16_t")
    {
        auto result = g_pvz->ReadMemory<uint16_t>(addr);
        lua_pushinteger(L, result);
    }
    else if (type == "uint32_t")
    {
        auto result = g_pvz->ReadMemory<uint32_t>(addr);
        lua_pushinteger(L, result);
    }
    else if (type == "int32_t")
    {
        auto result = g_pvz->ReadMemory<int32_t>(addr);
        lua_pushinteger(L, result);
    }
    else if (type == "int16_t")
    {
        auto result = g_pvz->ReadMemory<int16_t>(addr);
        lua_pushinteger(L, result);
    }
    else if (type == "int8_t")
    {
        auto result = g_pvz->ReadMemory<int8_t>(addr);
        lua_pushinteger(L, result);
    }
    else
    {
        lua_pushstring(L, "unsupport read memory type");
        lua_error(L);
    }

    return 1;
}

#define GET_X_LPARAM(lp) ((int)(short)LOWORD(lp))
#define GET_Y_LPARAM(lp) ((int)(short)HIWORD(lp))

int Lua_PostMessage(lua_State *L)
{
    int64_t msg = luaL_checkinteger(L, 1);
    int64_t wparam = luaL_checkinteger(L, 2);
    int64_t lparam = luaL_checkinteger(L, 3);

    int x = GET_X_LPARAM(lparam);
    int y = GET_Y_LPARAM(lparam);
    ::PostMessageW(g_pvz->hwnd, msg, wparam, lparam);
    return 0;
}

int Lua_GetPixel(lua_State *L)
{
    int x = luaL_checkinteger(L, 1);
    int y = luaL_checkinteger(L, 2);
    HDC hScreenDC = ::GetDC(g_pvz->hwnd); // 获得屏幕的HDC.
    COLORREF ret = ::GetPixel(hScreenDC, x, y);
    ::ReleaseDC(g_pvz->hwnd, hScreenDC);

    lua_pushinteger(L, ret);
    return 1;
}

int Lua_AddOp(lua_State *L)
{
    int opt = luaL_optinteger(L, 1, -1);
    int p1 = luaL_optinteger(L, 2, -1);
    int p2 = luaL_optinteger(L, 3, -1);
    int p3 = luaL_optinteger(L, 4, -1);
    int p4 = luaL_optinteger(L, 5, -1);
    AddOp(opt, p1, p2, p3, p4);
    return 0;
}

int Lua_Error(lua_State *L)
{
    ::MessageBoxA(NULL, "error", "pause", MB_OK);
    return 0;
}

void set_lua_api()
{
    luaL_Reg funcs[] = {{"SystemSleep", Lua_Sleep},
                        {"PostMessage", Lua_PostMessage},
                        {"ReadProcessMemory", Lua_ReadMemory},
                        {"GetPixel", Lua_GetPixel},
                        {"AddOp", Lua_AddOp},
                        {"Error", Lua_Error},

                        {NULL, NULL}};
    lua_getglobal(g_lua, "pvz");
    luaL_setfuncs(g_lua, funcs, 0);
    lua_pop(g_lua, 1);
}

void get_spawn_list_and_type()
{
}

void set_dpi()
{
    double dpi = 1.0;
    HDC screen = GetDC(NULL);
    if (screen)
    {
        int virtual_width = GetDeviceCaps(screen, HORZRES);
        int physical_width = GetDeviceCaps(screen, DESKTOPHORZRES);
        ReleaseDC(NULL, screen);
        dpi = 1.0 * physical_width / virtual_width;
    }
    else
    {
        dpi = 1.0;
    }

    lua_getglobal(g_lua, "pvz");
    lua_pushnumber(g_lua, dpi);
    lua_setfield(g_lua, -2, "dpi");
    lua_pop(g_lua, 1);
}

void set_version()
{
    int version = g_pvz->version();
    lua_getglobal(g_lua, "pvz");
    lua_pushnumber(g_lua, version);
    lua_setfield(g_lua, -2, "version");
    lua_pop(g_lua, 1);
}

void set_pvz_address()
{
    lua_State *lua = g_lua;
    const auto &data = g_pvz->data();

    lua_getglobal(lua, "pvz");
    lua_newtable(lua);

    SET_DATA_ADDR(lawn);
    SET_DATA_ADDR(board);

    SET_DATA_ADDR(plant);
    SET_DATA_ADDR(plant_row);
    SET_DATA_ADDR(plant_type);
    SET_DATA_ADDR(plant_col);
    SET_DATA_ADDR(plant_asleep);
    SET_DATA_ADDR(plant_dead);
    SET_DATA_ADDR(plant_squished);
    SET_DATA_ADDR(plant_count_max);
    // plant hp status

    SET_DATA_ADDR(zombie);
    SET_DATA_ADDR(zombie_status);
    SET_DATA_ADDR(zombie_dead);
    SET_DATA_ADDR(zombie_count_max);
    // zombie x y

    SET_DATA_ADDR(slot);
    SET_DATA_ADDR(slot_count);
    SET_DATA_ADDR(slot_seed_cd_past);
    SET_DATA_ADDR(slot_seed_cd_total);
    SET_DATA_ADDR(slot_seed_type);

    SET_DATA_ADDR(grid_item);
    SET_DATA_ADDR(grid_item_type);
    SET_DATA_ADDR(grid_item_col);
    SET_DATA_ADDR(grid_item_row);
    SET_DATA_ADDR(grid_item_dead);
    SET_DATA_ADDR(grid_item_count_max);

    SET_DATA_ADDR(sun);
    SET_DATA_ADDR(game_clock);
    SET_DATA_ADDR(game_ui);
    SET_DATA_ADDR(frame_duration);
    SET_DATA_ADDR(game_mode);
    SET_DATA_ADDR(spawn_list);
    SET_DATA_ADDR(spawn_type);
    SET_DATA_ADDR(scene);
    // wave wave_cd word 55EC 55A4?

    SET_DATA_ADDR(endless_rounds);

    SET_DATA_ADDR(user_data);
    SET_DATA_ADDR(money);
    SET_DATA_ADDR(tree_height);

    lua_setfield(lua, -2, "addr");

    lua_pushboolean(lua, g_pvz->isGOTY());
    lua_setfield(lua, -2, "isGOTY");

    lua_pop(lua, 1);
}

DWORD g_threadId = 0;
void ActiveWindow()
{
    HWND needTopWindow = g_pvz->hwnd;
    DWORD dwThreadID = GetWindowThreadProcessId(needTopWindow, NULL);
    AttachThreadInput(dwThreadID, GetCurrentThreadId(), true);

    SetWindowPos(needTopWindow, HWND_TOPMOST, NULL, NULL, NULL, NULL, SWP_NOMOVE | SWP_NOSIZE);
    SetWindowPos(needTopWindow, HWND_NOTOPMOST, NULL, NULL, NULL, NULL, SWP_NOMOVE | SWP_NOSIZE);

    SetForegroundWindow(needTopWindow);
    SetActiveWindow(needTopWindow);
    SetFocus(needTopWindow);
    g_threadId = dwThreadID;
}

BOOL g_injected = false;
void Init()
{
    // DLL注入
    if (!g_injected)
    {
        char path[256];
        GetModuleFileNameA(NULL, path, 256);
        std::filesystem::path fpath = path;
        fpath = fpath.parent_path() / "server.dll";
        DWORD err;
        g_injected = InjectDll(g_pvz->handle, fpath.string().c_str(), &err);
        printf("InjectDll return %s %d %d\n", fpath.string().c_str(), g_injected, err);
    }
    if (!g_injected)
    {
        return;
    }

    if (g_lua)
    {
        lua_close(g_lua);
    }
    timeBeginPeriod(1);
    g_lua = luaL_newstate();
    luaL_openlibs(g_lua);
    lua_newtable(g_lua);
    lua_setglobal(g_lua, "pvz");

    set_pvz_address();
    set_dpi();
    set_version();
    set_lua_api();
}

void CallLuaFunction(const char *func)
{
    lua_getglobal(g_lua, func);
    if (!lua_isfunction(g_lua, -1))
    {
        printf("cannot get global function %s\n", func);
        lua_pop(g_lua, 1);
        return;
    }
    lua_pcall_msg(g_lua, 0, 0, 0);
}

DWORD lastGameClock = -1;
DWORD lastGlobalClock = -1;
DWORD lastGameUI = -1;
bool fightStart = false;
bool script_valid = false;
void Tick(DWORD gameUI, DWORD gameClock, DWORD globalClock, DWORD refreshCd, DWORD hugeCd, DWORD wave)
{
    if (lastGameUI == -1 && gameUI != 2)
    {
        return;
    }

    if (lastGlobalClock == globalClock)
    {
        // error
        return;
    }

    lua_getglobal(g_lua, "pvz");
    lua_pushinteger(g_lua, gameUI);
    lua_setfield(g_lua, -2, "gameUI");
    lua_pushinteger(g_lua, gameClock);
    lua_setfield(g_lua, -2, "gameClock");
    lua_pushinteger(g_lua, globalClock);
    lua_setfield(g_lua, -2, "globalClock");
    lua_pushinteger(g_lua, refreshCd);
    lua_setfield(g_lua, -2, "refreshCd");
    lua_pushinteger(g_lua, hugeCd);
    lua_setfield(g_lua, -2, "hugeCd");
    lua_pushinteger(g_lua, wave);
    lua_setfield(g_lua, -2, "wave");
    lua_pop(g_lua, 1);

    if (gameUI == 2 && lastGameUI != 2)
    {
        CallLuaFunction("OnEnterSelectCardsStage");
    }
    if (gameUI == 3 && lastGameUI != 3)
    {
        fightStart = true;
        CallLuaFunction("OnEnterFightState");
    }
    if (lastGameClock == gameClock && fightStart)
    {
        fightStart = false;
        CallLuaFunction("OnLeaveFightState");
    }

    CallLuaFunction("TickGlobal");

    if (gameUI == 3 && lastGameClock != gameClock)
    {
        CallLuaFunction("TickGame");
    }

    lastGameUI = gameUI;
    lastGameClock = gameClock;
    lastGlobalClock = globalClock;
}

void Run(const char *script)
{
    ::Sleep(500);
    if (!g_pvz || !g_pvz->IsValid() || !g_lua)
    {
        return;
    }

    // ActiveWindow();
    int ret = luaL_dofile(g_lua, script);
    if (ret != LUA_OK)
    {
        const char *errstr = lua_tostring(g_lua, -1);
        printf("luaL_dofile error : %s\n %s\n", script, errstr);
        return;
    }

    script_valid = true;

    std::thread t(Connect);
    t.detach();
}

} // namespace Script