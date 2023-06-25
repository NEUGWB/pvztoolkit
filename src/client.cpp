#include "proto.h"
#include <Shlwapi.h>
#include <iostream>
#include <vector>
#include "pvz.h"
#include "script.h"
extern Pt::PvZ *g_pvz;
using namespace std;

void _Error(const char *msg)
{
    ::MessageBoxA(NULL, msg, "error", MB_OK);
}

SOCKET ServerSock = INVALID_SOCKET;
SOCKET avz_sock_remote = INVALID_SOCKET;
void ConnectServer()
{
    // Init Windows Socket
    WSADATA Ws;
    if (WSAStartup(MAKEWORD(2, 2), &Ws) != 0)
    {
        cout << "Init Windows Socket Failed::" << GetLastError() << endl;
        return;
    }

    ServerSock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (ServerSock == INVALID_SOCKET)
    {
        cout << "Create Socket Failed::" << GetLastError() << endl;
        return;
    }

    struct sockaddr_in ServerAddr;

    ServerAddr.sin_family = AF_INET;
    inet_pton(AF_INET, AVZ_IP, &ServerAddr.sin_addr);
    ServerAddr.sin_port = htons(AVZ_PORT);
    memset(ServerAddr.sin_zero, 0x00, 8);

    while (true)
    {
        printf("start connect\n");
        int Ret = connect(ServerSock, (struct sockaddr *)&ServerAddr, sizeof(ServerAddr));
        if (Ret == SOCKET_ERROR)
        {
            int ret = ::MessageBoxA(NULL, "connect error, ok to retry", "error", MB_OKCANCEL);
            if (ret != IDOK)
            {
                return;
            }
        }
        else
        {
            cout << "connect success!" << endl;
            break;
        }
    }
    avz_sock_remote = ServerSock;

    C2S::pvz_mem_t pvz_mem;
    pvz_mem.pvz_base = g_pvz->data().lawn;
    pvz_mem.game_ui = g_pvz->data().game_ui;
    pvz_mem.main_object = g_pvz->data().board;
    pvz_mem.game_clock = g_pvz->data().game_clock;
    pvz_mem.global_clock = g_pvz->data().game_clock + 4;
    pvz_mem.refresh_cd = 0x559c;
    pvz_mem.huge_cd = 0x55a4;
    pvz_mem.wave = 0x557c;

    pvz_mem.plant = g_pvz->data().plant;
    pvz_mem.seed = g_pvz->data().slot;

    pvz_mem.call_remove = g_pvz->data().call_delete_plant;
    if (g_pvz->version() == PVZ_1_0_0_1051_EN)
    {
        pvz_mem.call_fire = 0x466d50;
        pvz_mem.call_card = 0x488590;
        pvz_mem.call_plant = 0x40fd30;
        pvz_mem.call_release = 0x40CD80;
    }

    if (g_pvz->version() == PVZ_GOTY_1_2_0_1096_EN)
    {
        pvz_mem.call_fire = 0x46D1F0;
        pvz_mem.call_card = 0x496c30;
        pvz_mem.call_plant = 0x413250;
        pvz_mem.call_release = 0x410200;
    }

    if (g_pvz->isGOTY())
    {
        pvz_mem.refresh_cd += 0x18;
        pvz_mem.huge_cd += 0x18;
        pvz_mem.wave += 0x18;
    }
    Send(pvz_mem);
}

std::vector<C2S::op_t> vecOp;
void AddOp(int opt, int p1, int p2, int p3, int p4)
{
    vecOp.emplace_back((C2S::OP_TYPE)opt, p1, p2, p3, p4);
}

void Connect()
{
    ConnectServer();
    if (ServerSock == INVALID_SOCKET)
    {
        return;
    }

    while (true)
    {
        if (ServerSock == INVALID_SOCKET)
        {
            break;
        }
        auto tick = Recv<S2C::tick_t>();

        switch (tick.game_ui)
        {
        case 2:
        case 3:
            Script::Tick(tick.game_ui, tick.game_clock, tick.global_clock, tick.refresh_cd, tick.huge_cd, tick.wave);
        }

        C2S::sync_t sync;
        sync.op_num = (uint16_t)vecOp.size();
        Send(sync);
        for (auto &op : vecOp)
        {
            Send(op);
        }
        vecOp.clear();
    }
    system("pause");
}

BOOL SetSeDebugPrivilege(BOOL bEnablePrivilege, // TRUE to enable.  FALSE to disable
                         DWORD *pErrCode)
{
    BOOL bRet = 0;
    DWORD dwErr = 0;

    HANDLE hToken = NULL;

    TOKEN_PRIVILEGES tp;
    LUID luid;
    TOKEN_PRIVILEGES tpPrevious;
    DWORD cbPrevious;
    HANDLE hThread = GetCurrentThread();
    LPCTSTR Privilege = SE_DEBUG_NAME;

    do
    {
        // OpenThreadToken
        {
            if (OpenThreadToken(hThread, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, FALSE, &hToken))
            {
            }
            else
            {
                dwErr = GetLastError();
                if (dwErr != ERROR_NO_TOKEN)
                {
                    bRet = -1;
                    break;
                }

                if (!ImpersonateSelf(SecurityImpersonation))
                {
                    dwErr = GetLastError();
                    bRet = -2;
                    break;
                }

                if (!OpenThreadToken(hThread, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, FALSE, &hToken))
                {
                    dwErr = GetLastError();
                    bRet = -3;
                    break;
                }
            }
        }

        // LookupPrivilegeValue
        {
            if (!LookupPrivilegeValue(NULL, Privilege, &luid))
            {
                dwErr = GetLastError();
                bRet = -4;
                break;
            }

            // first pass.  get current privilege setting
            tp.PrivilegeCount = 1;
            tp.Privileges[0].Luid = luid;
            tp.Privileges[0].Attributes = 0;
            if (!AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(TOKEN_PRIVILEGES), &tpPrevious, &cbPrevious))
            {
                dwErr = GetLastError();
                bRet = -5;
                break;
            }

            // second pass.  set privilege based on previous setting
            tpPrevious.PrivilegeCount = 1;
            tpPrevious.Privileges[0].Luid = luid;
            if (bEnablePrivilege)
            {
                tpPrevious.Privileges[0].Attributes |= (SE_PRIVILEGE_ENABLED);
            }
            else
            {
                tpPrevious.Privileges[0].Attributes ^= (SE_PRIVILEGE_ENABLED & tpPrevious.Privileges[0].Attributes);
            }

            if (!AdjustTokenPrivileges(hToken, FALSE, &tpPrevious, cbPrevious, NULL, NULL))
            {
                dwErr = GetLastError();
                bRet = -6;
                break;
            }
        }

        bRet = TRUE;
        dwErr = 0;
    } while (0);

    if (hToken)
    {
        CloseHandle(hToken);
        hToken = NULL;
    }

    if (pErrCode)
        *pErrCode = dwErr;

    return bRet;
}

// DLL注入
BOOL InjectDll(HANDLE hProcess, LPCSTR szDllName, DWORD *pErrCode)
{
    BOOL bRet = FALSE;
    DWORD dwErr = 0;

    HMODULE hKernel32Lib = NULL;
    FARPROC pThreadProc = NULL;
    LPVOID pRemoteBuf = NULL;
    SIZE_T NumberOfBytesWritten;
    HANDLE hRemoteThread = NULL;
    DWORD dwRemoteThreadID = 0;
    const SIZE_T nStringLen = strlen(szDllName) + 1;

    do
    {
        HANDLE hMutex = OpenMutexA(MUTEX_ALL_ACCESS, FALSE, INJECT_ONCE);
        if (hMutex)
        {
            CloseHandle(hMutex);
            bRet = TRUE;
            break;
        }
        DWORD attr = GetFileAttributesA(szDllName);
        if (attr == INVALID_FILE_ATTRIBUTES || (attr & FILE_ATTRIBUTE_DIRECTORY))
        {
            dwErr = GetLastError();
            bRet = -1;
            break;
        }

        // Load Kernel32.dll
        hKernel32Lib = LoadLibraryA("kernel32.dll");
        if (hKernel32Lib == NULL)
        {
            dwErr = GetLastError();
            bRet = -2;
            break;
        }
        pThreadProc = GetProcAddress(hKernel32Lib, "LoadLibraryA");
        if (pThreadProc == NULL)
        {
            bRet = -3;
            break;
        }

        // 提升到DEBUG权限 SE_DEBUG_NAME
        if (SetSeDebugPrivilege(TRUE, &dwErr) <= 0)
        {
            bRet = -4;
            break;
        }

        // 打开进程
        // hProcess = OpenProcess(PROCESS_ALL_ACCESS|PROCESS_CREATE_THREAD | PROCESS_VM_OPERATION |
        // PROCESS_VM_WRITE, FALSE, dwPID);
        if (hProcess == NULL)
        {
            dwErr = GetLastError();
            bRet = -5;
            break;
        }

        // 申请内存
        pRemoteBuf = VirtualAllocEx(hProcess, NULL, nStringLen, MEM_COMMIT, PAGE_READWRITE);
        if (pRemoteBuf == NULL)
        {
            dwErr = GetLastError();
            bRet = -6;
            break;
        }

        // 写入路径
        if (!WriteProcessMemory(hProcess, pRemoteBuf, szDllName, nStringLen, &NumberOfBytesWritten))
        {
            dwErr = GetLastError();
            bRet = -7;
            break;
        }

        // 启动远程线程
        hRemoteThread = CreateRemoteThread(hProcess, NULL, 0, (LPTHREAD_START_ROUTINE)pThreadProc, pRemoteBuf, 0,
                                           &dwRemoteThreadID);
        if (hRemoteThread == NULL)
        {
            dwErr = GetLastError();
            bRet = -8;
            break;
        }

        // wait for thread startup
        // Sleep(5000000);
        bRet = TRUE;

    } while (0);

    // 结束清理
    {
        if (hRemoteThread)
        {
            WaitForSingleObject(hRemoteThread, INFINITE);
            CloseHandle(hRemoteThread);
            hRemoteThread = NULL;
        }

        if (hProcess && pRemoteBuf)
        {
            VirtualFreeEx(hProcess, pRemoteBuf, nStringLen, MEM_RELEASE);
            pRemoteBuf = NULL;
        }

        if (hKernel32Lib)
        {
            FreeLibrary(hKernel32Lib);
            hKernel32Lib = NULL;
        }
    }

    if (pErrCode)
        *pErrCode = dwErr;

    return bRet;
}

int PvzHook()
{
    int iRet = 0;
    DWORD dwErr = 0;

    char path[256];
    GetModuleFileNameA(NULL, path, 255);
    std::string sPath = path;
    sPath = sPath.substr(0, sPath.rfind('\\') + 1);
    sPath += "Hook.dll";
    iRet = InjectDll(0, sPath.c_str(), &dwErr);
    if (iRet)
    {
    }

    return iRet;
}
