#include <thread>
#include <vector>
#include <lua.hpp>

#include "pvz.h"

namespace Pt{
void init_script(PvZ *pvz);
void run_script(const char *script);

class Script : public PvZ
{
public:
    void init();
    void run(const char *script);

    // 读内存数组
    template <typename T>
    T ReadMemory(std::vector<uintptr_t>);

    lua_State *lua = nullptr;
};

template <typename T>
T Script::ReadMemory(std::vector<uintptr_t> addr)
{
    T result{};

    if (!IsValid())
        return result;

    T *buff = &result;
    uintptr_t offset = 0;
    for (auto it = addr.begin(); it != addr.end(); it++)
    {
        if (it != addr.end() - 1)
        {
            unsigned long read_size = 0;
            int ret = ReadProcessMemory(this->handle, (const void *)(offset + *it), &offset, sizeof(offset), &read_size);
            if (ret == 0 || sizeof(offset) != read_size)
                luaL_error(lua, "read memory error in cpp");
        }
        else
        {
            unsigned long read_size = 0;
            unsigned long to_read_size = sizeof(T);
            int ret = ReadProcessMemory(this->handle, (const void *)(offset + *it), buff, to_read_size, &read_size);
            if (ret == 0 || to_read_size != read_size)
                luaL_error(lua, "read memory error in cpp");
        }
    }
    return result;
}
}