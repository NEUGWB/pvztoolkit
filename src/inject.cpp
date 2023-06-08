#include <windows.h>
#include <shlwapi.h>
#include <string>

#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "Advapi32.lib")

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

    HANDLE hProcess = NULL;
    HMODULE hKernel32Lib = NULL;
    FARPROC pThreadProc = NULL;
    LPVOID pRemoteBuf = NULL;
    SIZE_T NumberOfBytesWritten;
    HANDLE hRemoteThread = NULL;
    DWORD dwRemoteThreadID = 0;
    const SIZE_T nStringLen = strlen(szDllName) + 1;

    do
    {
        // 先检测DLL文件是否存在
        if (!PathFileExistsA(szDllName))
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
        // hProcess = OpenProcess(PROCESS_ALL_ACCESS|PROCESS_CREATE_THREAD | PROCESS_VM_OPERATION | PROCESS_VM_WRITE,
        // FALSE, dwPID);
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
