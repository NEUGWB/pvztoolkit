#include "window.h"
#include "script.h"
#include <lua.hpp>
#include <future>

#pragma warning(disable:4244)
#pragma comment(lib, "winmm.lib") 

#define SET_DATA_ADDR(field) do {lua_pushinteger(lua, data.field);lua_setfield(lua, -2, #field);} while(0)

namespace Pt{

Script *g_pvz;

struct RunInMainThread
{
    std::function<void()> _func;
    std::promise<void> &promise;

    static void ThreadFun(void *data)
    {
        RunInMainThread *pThis = (RunInMainThread*)data;
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

//system
int Lua_Sleep(lua_State *L)
{
    ::Sleep(luaL_checkinteger(L, 1));
    return 0;
}

int Lua_ReadMemory(lua_State *L)
{
    std::vector<uintptr_t> addr;

    std::string type = luaL_checkstring(L, 1);
    //int num = luaL_checkinteger(L, 2);

    lua_pushnil(L);
    while (lua_next(L, -2))
    {
        /* 此时栈上 -1 处为 value, -2 处为 key */
        addr.push_back((uintptr_t)luaL_checkinteger(L, -1));
        lua_pop(L, 1);
    }
    //lua_pop(L, 1);
    
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
    else
    {
        lua_pushstring(L, "unsupport read memory type");
        lua_error(L);
    }

    return 1;
}

#define GET_X_LPARAM(lp)                        ((int)(short)LOWORD(lp))
#define GET_Y_LPARAM(lp)                        ((int)(short)HIWORD(lp))

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
    HDC hScreenDC = ::GetDC(g_pvz->hwnd); //获得屏幕的HDC.
    COLORREF ret = ::GetPixel(hScreenDC, x, y);
    ::ReleaseDC(g_pvz->hwnd, hScreenDC);

    lua_pushinteger(L, ret);
    return 1;
}

void set_lua_api()
{
    luaL_Reg funcs[] = 
    {
        {"SystemSleep", Lua_Sleep},
        {"PostMessage", Lua_PostMessage},
        {"ReadProcessMemory", Lua_ReadMemory},
        {"GetPixel", Lua_GetPixel},

        {NULL, NULL}
    };
    lua_getglobal(g_pvz->lua, "pvz");
    luaL_setfuncs(g_pvz->lua, funcs, 0);
    lua_pop(g_pvz->lua, 1);
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

    lua_getglobal(g_pvz->lua, "pvz");
    lua_pushnumber(g_pvz->lua, dpi);
    lua_setfield(g_pvz->lua, -2, "dpi");
    lua_pop(g_pvz->lua, 1);
}

void set_pvz_address()
{
    lua_State *lua = g_pvz->lua;
    const auto &data = g_pvz->data();

    lua_getglobal(lua, "pvz");
    lua_newtable(lua);

    //SET_DATA_ADDR(pvz_base);
    //SET_DATA_ADDR(main_object);
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
    //plant hp status

    SET_DATA_ADDR(zombie);
    SET_DATA_ADDR(zombie_status);
    SET_DATA_ADDR(zombie_dead);
    SET_DATA_ADDR(zombie_count_max);
    //zombie x y

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
    //wave wave_cd word 55EC 55A4?

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

void run_script(const char *script)
{
    
}

void Script::init()
{
    if (lua)
    {
        return;
    }
    timeBeginPeriod(1);
    g_pvz = this;
    lua = luaL_newstate();
    luaL_openlibs(lua);
    lua_newtable(lua);
    lua_setglobal(lua, "pvz");

    set_pvz_address();
    set_dpi();
    set_lua_api();
}

std::string file;
void Script::run(const char *script)
{
    file = script;
    std::thread t([this]()
    {
        ::Sleep(500);
        if (!g_pvz || !g_pvz->IsValid() || !g_pvz->lua)
        {
            return;
        }
        
        ActiveWindow();
        int ret = luaL_dofile(lua, file.c_str());
        if (ret != LUA_OK)
        {
            const char *errstr = lua_tostring(lua, -1);
            printf("luaL_dofile error : %s\n %s\n", file.c_str(), errstr);
        }
    });
    t.detach();
    //AttachThreadInput(g_threadId, GetCurrentThreadId(), false);
}
}