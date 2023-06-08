#include <thread>
#include <vector>
#include <lua.hpp>

#include "pvz.h"
extern Pt::PvZ *g_pvz;

namespace Script
{
void Init();
void Run(const char *script);

void Tick(DWORD gameUI, DWORD gameClock, DWORD globalClock, DWORD refreshCd, DWORD hugeCd, DWORD wave);

} // namespace Script