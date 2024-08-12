#include "../src/proto.h"
#include <iostream>
#include <thread>
#pragma warning(disable : 4996)
#pragma comment(lib, "User32.lib")

SOCKET avz_sock_remote = INVALID_SOCKET;

uint32_t pvz_base_ptr;
uint32_t main_object_ptr;
uint32_t plant_ptr;

uint32_t call_fire_ptr;
uint32_t call_plant_ptr;
uint32_t call_card_ptr;
uint32_t call_release_ptr;
uint32_t call_remove_ptr;

uint32_t call_rock_ptr;
uint32_t call_choose_ptr;

uint32_t call_mouse_down_ptr;

uint32_t pvz_update_fun;

C2S::pvz_mem_t pvz_mem;

SOCKET ServerSocket = INVALID_SOCKET;
SOCKET ClientSocket = INVALID_SOCKET;

void _Error(const char *msg)
{
    ::MessageBoxA(NULL, msg, "error", MB_OK);
    printf("error : %s\n", msg);
}

void Hook();
void Accept()
{
    struct sockaddr_in ClientAddr;
    int AddrLen = sizeof(ClientAddr);
    ClientSocket = accept(ServerSocket, (struct sockaddr *)&ClientAddr, &AddrLen);
    if (ClientSocket == INVALID_SOCKET)
    {
        printf("Accept Failed:: %lu\n", GetLastError());
        return;
    }

    char ipbuff[256];
    inet_ntop(AF_INET, &ClientAddr.sin_addr, ipbuff, 256);
    printf("Iclient connect %s %d\n", ipbuff, ClientAddr.sin_port);
    avz_sock_remote = ClientSocket;

    pvz_mem = Recv<C2S::pvz_mem_t>();
    printf("recv pvz mem info 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n", pvz_mem.pvz_base, pvz_mem.game_ui,
           pvz_mem.main_object, pvz_mem.game_clock, pvz_mem.global_clock, pvz_mem.refresh_cd, pvz_mem.huge_cd,
           pvz_mem.wave);
    if (pvz_mem.head == C2S::MSG::PVZ_MEM)
    {
        pvz_base_ptr = pvz_mem.pvz_base;
        main_object_ptr = pvz_mem.main_object;
        plant_ptr = pvz_mem.plant;

        call_fire_ptr = pvz_mem.call_fire;
        call_plant_ptr = pvz_mem.call_plant;
        call_card_ptr = pvz_mem.call_card;
        call_release_ptr = pvz_mem.call_release;
        call_remove_ptr = pvz_mem.call_remove;

        call_rock_ptr = pvz_mem.call_rock;
        call_choose_ptr = pvz_mem.call_choose;
        Hook();
    }
}

template <typename T> T ReadMemory(std::initializer_list<uint32_t> mem)
{
    uint32_t addr = *mem.begin();
    for (auto i = mem.begin() + 1; i != mem.end(); ++i)
    {
        addr = *std::bit_cast<uint32_t *>(addr);
        addr += *i;
    }
    return *(T *)addr;
}

void SendTick()
{
    if (ClientSocket == INVALID_SOCKET)
    {
        return;
    }
    S2C::tick_t tick;
    tick.game_ui = ReadMemory<int>({pvz_mem.pvz_base, pvz_mem.game_ui});
    if (tick.game_ui == 2 || tick.game_ui == 3)
    {
        uint32_t obj_addr = ReadMemory<uint32_t>({pvz_mem.pvz_base, pvz_mem.main_object});
        tick.game_clock = ReadMemory<int>({obj_addr + pvz_mem.game_clock});
        tick.global_clock = ReadMemory<int>({obj_addr + pvz_mem.global_clock});
        tick.refresh_cd = ReadMemory<int>({obj_addr + pvz_mem.refresh_cd});
        tick.huge_cd = ReadMemory<int>({obj_addr + pvz_mem.huge_cd});
        tick.wave = ReadMemory<int>({obj_addr + pvz_mem.wave});
        // printf("server tick game %d %d %d\n", tick.game_ui, tick.game_clock, tick.global_clock);
    }

    Send(tick);
}

void ASMFire(int x, int y, int index)
{
    if (!call_fire_ptr)
    {
        return;
    }
    uint32_t plant = ReadMemory<uint32_t>({pvz_mem.pvz_base, pvz_mem.main_object, pvz_mem.plant});
    plant += index * 0x14c;
    printf("asm fire %d %d %d %d\n", *(int *)(plant + 0x24), x, y, index);
    __asm
    {
        pushad
        mov eax, plant
        push y
        push x
        mov edx, call_fire_ptr
        call edx
        popad
    }
}

void ASMCard(int x, int y, int index)
{
    uint32_t board = ReadMemory<uint32_t>({pvz_mem.pvz_base, pvz_mem.main_object});
    uint32_t seed = ReadMemory<uint32_t>({pvz_mem.pvz_base, pvz_mem.main_object, pvz_mem.seed});
    seed += index * 0x50 + 0x28;
    uint32_t click = 1;
    printf("ASMCard %d %d %d\n", x, y, index);
    __asm
    {
        pushad
        push seed
        mov edx, call_card_ptr
        call edx

        push y
        push x
        push board
        mov ecx, 1h
        mov edx, call_plant_ptr
        call edx

        mov eax, board
        mov edx, call_release_ptr
        call edx
        popad
    }
}

void ASMRock()
{
    if (!call_rock_ptr)
    {
        return;
    }
    uint32_t screen = ReadMemory<uint32_t>({pvz_mem.pvz_base, pvz_mem.card_screen});
    printf("asm rock 0x%p 0x%p\n", pvz_mem.card_screen, call_rock_ptr);

    if (pvz_mem.main_object == 0x868)
    {
        __asm
        {
            pushad
            push screen
            call call_rock_ptr
            popad
        }
    }
    else
    {
        __asm
        {
            pushad
            mov ebx, screen
            call call_rock_ptr
            popad
        }
    }
}

void ASMChoose(int card, bool imm)
{
    if (!call_choose_ptr)
    {
        return;
    }
    uint32_t screen = ReadMemory<uint32_t>({pvz_mem.pvz_base, pvz_mem.card_screen});
    uint32_t seed = screen + pvz_mem.choose_seed;
    uint32_t seed2 = ReadMemory<uint32_t>({pvz_mem.pvz_base, pvz_mem.card_screen, pvz_mem.choose_seed});

    printf("asm choose %d %d 0x%p 0x%p 0x%p\n", card, imm, seed, seed2, screen);

    if (!imm)
    {
        seed += card * 60;
        __asm
        {
            pushad
            mov eax, screen
            push seed
            call call_choose_ptr
            popad
        }
    }
    else
    {
        seed += 48 * 60;
        *(uint32_t *)(seed + 0x24) = 3;
        *(uint32_t *)(seed + 0x34) = card;
        __asm
        {
            pushad
            mov eax, screen
            push seed
            call call_choose_ptr
            popad
        }
    }
}

void ASMRemove(int index)
{
    uint32_t plant = ReadMemory<uint32_t>({pvz_mem.pvz_base, pvz_mem.main_object, pvz_mem.plant});
    plant += index * 0x14c;
    printf("asm remove %d 0x%x\n", index, call_remove_ptr);
    __asm
    {
        pushad
        push plant
        mov edx, call_remove_ptr
        call edx
        popad
    }
}

void ASMMouseDown(int x, int y, int click)
{
    uint32_t p1, p2, p3, p4;
    {
        p1 = *(uint32_t *)pvz_base_ptr + main_object_ptr;
        p2 = *(uint32_t *)p1 + 0;
        p3 = *(uint32_t *)p2 + 0xD8;
        p4 = *(uint32_t *)p3;

        call_mouse_down_ptr = p4;
    }

    if (!call_mouse_down_ptr)
    {
        return;
    }
    uint32_t board = ReadMemory<uint32_t>({pvz_mem.pvz_base, pvz_mem.main_object});
    printf("asm mouse down %d %d %d\n", x, y, click);

    __asm
    {
        pushad
        push click
        push y
        push x
        mov ecx, board
        call call_mouse_down_ptr
        popad
    }
}

void ASMSafeClick()
{
    ASMMouseDown(60, 50, -1);
}

void RecvSync()
{
    if (ClientSocket == INVALID_SOCKET)
    {
        return;
    }
    auto recv = Recv<C2S::sync_t>();
    if (recv.head != C2S::MSG::SYNC)
    {
        char buff[256];
        snprintf(buff, 256, "not valid sync msg %d", recv.head);
        _Error(buff);
        return;
    }
    for (auto i = 0; i < recv.op_num; ++i)
    {
        auto op = Recv<C2S::op_t>();
        switch (op.op_type)
        {
        case C2S::OP_TYPE::FIRE:
            ASMFire(op.param1, op.param2, op.param3);
            break;
        case C2S::OP_TYPE::CARD:
            ASMCard(op.param1, op.param2, op.param3);
            break;
        case C2S::OP_TYPE::SHOVEL:
            ASMRemove(op.param1);
            break;
        case C2S::OP_TYPE::ROCK:
            ASMRock();
            break;
        case C2S::OP_TYPE::CHOOSE:
            ASMChoose(op.param1, op.param2);
            break;
<<<<<<< HEAD
        case C2S::OP_TYPE::Collect:
            ASMMouseDown(op.param1, op.param2, 1);
            ASMSafeClick();
            break;
=======
>>>>>>> 74b52a3 (choose)
        }
    }
}

void TotalLoop()
{
    __asm
    {
        pushad
        mov ecx, pvz_base_ptr
        mov ecx, [ecx]
        mov eax, pvz_update_fun
        call eax
        popad
    }
}

void _HookUpdateFrame()
{
    TotalLoop();
    SendTick();
    RecvSync();
}

void Hook()
{
    DWORD temp;
    VirtualProtect((void *)0x400000, 0x35E000, PAGE_EXECUTE_READWRITE, &temp);

    uint32_t p1, p2, p3, p4;
    {
        p1 = pvz_base_ptr;
        p2 = *(uint32_t *)p1 + 0;
        p3 = *(uint32_t *)p2 + 0x20;
        p4 = *(uint32_t *)p3;

        pvz_update_fun = p4;
    }

    char buff[256];
    snprintf(buff, 256, "p4 is 0x%x", pvz_update_fun);
    //::MessageBoxA(NULL, buff, "def", MB_OK);
    printf("hook success 0x%x\n", pvz_update_fun);
    *(uint32_t *)p3 = (uint32_t)&_HookUpdateFrame;
}

void InitServer()
{
    WSADATA Ws;
    if (WSAStartup(MAKEWORD(2, 2), &Ws) != 0)
    {
        printf("Init Windows Socket Failed:: %lu\n", GetLastError());
        return;
    }

    struct sockaddr_in LocalAddr;

    ServerSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (ServerSocket == INVALID_SOCKET)
    {
        printf("Create Socket Failed:: %lu\n", GetLastError());
        return;
    }

    LocalAddr.sin_family = AF_INET;
    inet_pton(AF_INET, AVZ_IP, &LocalAddr.sin_addr);
    LocalAddr.sin_port = htons(AVZ_PORT);
    memset(LocalAddr.sin_zero, 0x00, 8);

    // Bind Socket
    int Ret = bind(ServerSocket, (struct sockaddr *)&LocalAddr, sizeof(LocalAddr));
    if (Ret != 0)
    {
        printf("Bind Socket Failed:: %lu\n", GetLastError());
        return;
    }

    // listen
    Ret = listen(ServerSocket, 10);
    if (Ret != 0)
    {
        printf("listen Socket Failed:: %lu\n", GetLastError());
        return;
    }

    printf("server start\n");

    u_long mode = 1;
    // ioctlsocket(ServerSocket, FIONBIO, &mode);
    std::thread t(Accept);
    t.detach();
}

HANDLE g_mutex;

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
    char buff[128];
    sprintf_s(buff, "dllmain reason %d", ul_reason_for_call);
    //::MessageBoxA(NULL, buff, buff, MB_OK);
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH: {
        AllocConsole();
        SetConsoleTitle(TEXT("avz_lua"));
        freopen("CON", "w", stdout);
        setlocale(LC_ALL, "chs");

        g_mutex = CreateMutexA(NULL, NULL, INJECT_ONCE);

        InitServer();
        break;
    }
    case DLL_THREAD_ATTACH:
        break;
    case DLL_THREAD_DETACH:
        break;
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
