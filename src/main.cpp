
#include <FL/Fl_Window.H>
#include <FL/Fl_Box.H>
#include <FL/Fl_Image.H>
#include <FL/Fl_JPEG_Image.H>
#include <FL/Fl_PNG_Image.H>
#include <FL/Fl_BMP_Image.H>
#include <FL/Fl_Tooltip.H>
#include <FL/fl_ask.H>
#include <FL/Fl.H>

#include <Windows.h>
#include <WinTrust.h>
#include <SoftPub.h>
#include <VersionHelpers.h>

#include <cassert>
#include <random>
#include <ctime>

#include "toolkit.h"
#include "../res/version.h"

#define IDI_ICON 1001
#pragma warning(disable : 4996)

static_assert(_MSC_VER >= 1929);
static_assert(sizeof(void *) == 4);

Pt::PvZ *g_pvz;

bool VerifySignature(LPCWSTR);

void window_callback(Fl_Widget *w, void *)
{
    // 按 Esc 不退出, 而是还原默认窗口大小
    if (Fl::event() == FL_SHORTCUT && Fl::event_key() == FL_Escape)
    {
        if (Fl::screen_scale(((Fl_Double_Window *)w)->screen_num()) != 1.0f)
            Fl::screen_scale(((Fl_Double_Window *)w)->screen_num(), 1.0f);
        return;
    }

    ((Pt::Toolkit *)w)->close_all_sub_window();
    ((Pt::Toolkit *)w)->hide();
}

void callback_pvz_check(void *w)
{
    // 定期检查游戏进程状态
    bool on = ((Pt::Toolkit *)w)->pvz->GameOn();
    double t = on ? 0.4 : 0.2;
    Fl::repeat_timeout(t, callback_pvz_check, w);

    if (IsDebuggerPresent())
        exit(-42);
}

/// main ///

Fl_Font ui_font = FL_FREE_FONT + 1; // 主界面
Fl_Font ls_font = FL_FREE_FONT + 2; // 阵型代码
Fl_Font tt_font = FL_FREE_FONT + 3; // 提示信息

int main(int argc, char **argv)
{
#ifdef _DEBUG
    system("chcp 65001"); // 调试输出中文
#endif

#ifdef _DEBUG
    for (int i = 0; i < argc; i++)
        printf("argv[%d] = %s\n", i, argv[i]);
#endif

    if (argc == 0)
        return -0;

    if (argc == 4)
    {
        std::string m = argv[1];
        std::string file = argv[2];
        std::string dir = argv[3];

        Pt::PAK pak;
        if (m == "/U")
            return pak.Unpack(file, dir);
        else if (m == "/P")
            return pak.Pack(dir, file);
        else
            return 0xF7;
    }

    AllocConsole();
    SetConsoleTitle(TEXT("ptk"));
    freopen("CON", "w", stdout);
    SetConsoleOutputCP(CP_UTF8);
    SetConsoleCP(CP_UTF8);

    printf("ptk start");

    // 界面背景颜色
    Fl::background(243, 243, 243);

    // 界面字体
    Fl::set_font(ui_font, "Microsoft YaHei");
    Fl::set_font(ls_font, "Courier New");
    Fl::set_font(tt_font, "Segoe UI");

    // 设置对话框属性
    fl_message_font(ui_font, 13);
    fl_message_hotspot(1);

    // fl_cancel = "取消";
    // fl_close = "关闭";
    // fl_no = "否";
    // fl_ok = "好的";
    // fl_yes = "是";

    // 设置工具提示的样式
    Fl_Tooltip::delay(0.1f);
    Fl_Tooltip::hoverdelay(0.1f);
    Fl_Tooltip::hidedelay(5.0f);
    Fl_Tooltip::color(FL_WHITE);
    Fl_Tooltip::textcolor(FL_BLACK);
    Fl_Tooltip::font(tt_font);
    Fl_Tooltip::size(12);
    Fl_Tooltip::margin_width(5);
    Fl_Tooltip::margin_height(5);
    Fl_Tooltip::wrap_width(400);

    // 初始化随机数种子
    std::srand(static_cast<unsigned int>(std::time(nullptr)));

    // 第一次调用时启用线程锁机制
    Fl::lock();

    // 启动画面

    Fl_Window splash(400 + 2, 225 + 2, "");
    splash.begin();
    Fl_Box box(1, 1, 400, 225, nullptr);
    splash.end();

    box.labelsize(42);
    box.labelcolor(FL_GRAY);
    splash.color(FL_GRAY);
    splash.border(false);
    splash.set_non_modal();

    Fl_JPEG_Image img_jpeg("splash.jpg");
    Fl_PNG_Image img_png("splash.png");
    Fl_BMP_Image img_bmp("splash.bmp");

    if (img_jpeg.fail() == 0)
        box.image(img_jpeg);
    else if (img_png.fail() == 0)
        box.image(img_png);
    else if (img_bmp.fail() == 0)
        box.image(img_bmp);
    else
        box.label("PvZ Toolkit");

    if (box.image())
    {
        int w = box.image()->w();
        int h = box.image()->h();
        box.size(w, h);
        splash.size(w + 2, h + 2);
    }

    // 第一个窗口显示前设置标题栏图标
    extern HINSTANCE fl_display;
    splash.icon((const void *)LoadIcon(fl_display, MAKEINTRESOURCE(IDI_ICON)));

    splash.position((Fl::w() - splash.w()) / 2, (Fl::h() - splash.h()) / 2);
    splash.show();
    splash.wait_for_expose();

    splash.color(box.image() ? FL_GREEN : FL_DARK_GREEN);

    clock_t start = clock(); // 开始计时

    // 系统需求

    if (!IsWindowsVistaOrGreater())
    {
        fl_message_title("PvZ Toolkit");
        fl_alert("正在使用的操作系统不受支持！\n"
                 "需要 Windows Vista 或者更高版本才能运行。");
        return -10;
    }

    // 测试版在 2023-12-31 23:59:59 之后失效
    if (!RELEASE_VERSION && (std::time(nullptr) > std::time_t(1704038399)))
    {
        fl_message_title("测试版过期提示");
        if (fl_choice("这是很久以前的测试版哦，现在去下载新的正式版吗？", //
                      "No", "Yes", 0) == 1)
            ShellExecuteW(nullptr, L"open", L"https://pvz.lmintlcx.com/toolkit/", //
                          nullptr, nullptr, SW_SHOWNORMAL);
        return -1;
    }

    // 防篡改检测
    if (SIGNATURE_CHECK)
    {
        wchar_t exePath[MAX_PATH] = {0};
        GetModuleFileNameW(NULL, exePath, MAX_PATH);
        if (!VerifySignature(exePath))
        {
            fl_message_title("PvZ Toolkit 防篡改检测");
            if (fl_choice("本程序可能已经感染病毒，请在官方渠道重新下载！", //
                          "No", "Yes", 0) == 1)
                ShellExecuteW(nullptr, L"open", L"https://pvz.lmintlcx.com/toolkit/", //
                              nullptr, nullptr, SW_SHOWNORMAL);
            return -2;
        }
    }

    // 只运行单个实例
    HANDLE m = CreateMutexW(nullptr, true, L"PvZ Toolkit");
    if (GetLastError() == ERROR_ALREADY_EXISTS)
        return -3;

    // 主窗口
    Pt::Toolkit pvztoolkit(0, 0, "");
    g_pvz = pvztoolkit.pvz;
    assert(g_pvz);
    pvztoolkit.callback(window_callback);

#ifdef _DEBUG
    std::wcout << L"启动用时(毫秒): " << (clock() - start) << std::endl;
    // pvztoolkit.input_sun->value(clock() - start);
#endif

    // 隐藏启动画面

    double dt = 0.017; // 最短显示时间
    while ((clock() - start) / (double)CLOCKS_PER_SEC < dt)
        Fl::check();
    splash.hide();
    Fl::check();

    // 显示主窗口

    pvztoolkit.show(1, argv); // argc -> 1
    pvztoolkit.wait_for_expose();
    pvztoolkit.pvz->FindPvZ();
    SetForegroundWindow(fl_xid(&pvztoolkit));

#ifdef _DEBUG
    // 避免调试的时候频繁输出
#else
    Fl::add_timeout(0.01, callback_pvz_check, &pvztoolkit);
#endif

    int ret = Fl::run();

    // 结束主循环后再释放
    ReleaseMutex(m);
    CloseHandle(m);

    return ret;
}

bool VerifySignature(LPCWSTR pwszSourceFile)
{
    bool isGoodSignature = false;

    WINTRUST_FILE_INFO FileData;
    memset(&FileData, 0, sizeof(FileData));
    FileData.cbStruct = sizeof(WINTRUST_FILE_INFO);
    FileData.pcwszFilePath = pwszSourceFile;
    FileData.hFile = NULL;
    FileData.pgKnownSubject = NULL;

    GUID WVTPolicyGUID = WINTRUST_ACTION_GENERIC_VERIFY_V2;
    WINTRUST_DATA WinTrustData;
    memset(&WinTrustData, 0, sizeof(WinTrustData));
    WinTrustData.cbStruct = sizeof(WinTrustData);
    WinTrustData.pPolicyCallbackData = NULL;
    WinTrustData.pSIPClientData = NULL;
    WinTrustData.dwUIChoice = WTD_UI_NONE;
    WinTrustData.fdwRevocationChecks = WTD_REVOKE_NONE;
    WinTrustData.dwUnionChoice = WTD_CHOICE_FILE;
    WinTrustData.dwStateAction = WTD_STATEACTION_VERIFY;
    WinTrustData.hWVTStateData = NULL;
    WinTrustData.pwszURLReference = NULL;
    WinTrustData.dwUIContext = 0;
    WinTrustData.pFile = &FileData;

    LONG lStatus = WinVerifyTrust(NULL, &WVTPolicyGUID, &WinTrustData);
    // wprintf_s(L"WinVerifyTrust lStatus is: 0x%x.\n", lStatus);

    [[maybe_unused]] bool sig_good =
        (lStatus == ERROR_SUCCESS || lStatus == CERT_E_CHAINING || lStatus == TRUST_E_COUNTER_SIGNER);
    [[maybe_unused]] bool sig_not_bad = (lStatus != TRUST_E_NOSIGNATURE && lStatus != TRUST_E_BAD_DIGEST);
    isGoodSignature = sig_not_bad; // TODO

    WinTrustData.dwStateAction = WTD_STATEACTION_CLOSE;
    lStatus = WinVerifyTrust(NULL, &WVTPolicyGUID, &WinTrustData);

    if (!isGoodSignature)
        return false;

    HCERTSTORE hStore = NULL;
    HCRYPTMSG hMsg = NULL;
    CryptQueryObject(CERT_QUERY_OBJECT_FILE, pwszSourceFile,     //
                     CERT_QUERY_CONTENT_FLAG_PKCS7_SIGNED_EMBED, //
                     CERT_QUERY_FORMAT_FLAG_BINARY,              //
                     0, NULL, NULL, NULL, &hStore, &hMsg, NULL);

    DWORD dwSignerInfo = 0;
    CryptMsgGetParam(hMsg, CMSG_SIGNER_INFO_PARAM, 0, NULL, &dwSignerInfo);
    PCMSG_SIGNER_INFO pSignerInfo = (PCMSG_SIGNER_INFO)LocalAlloc(LPTR, dwSignerInfo);
    CryptMsgGetParam(hMsg, CMSG_SIGNER_INFO_PARAM, 0, (PVOID)pSignerInfo, &dwSignerInfo);

    CERT_INFO CertInfo;
    memset(&CertInfo, 0, sizeof(CertInfo));
    CertInfo.Issuer = pSignerInfo->Issuer;
    CertInfo.SerialNumber = pSignerInfo->SerialNumber;
    PCCERT_CONTEXT pCertContext =                                                   //
        CertFindCertificateInStore(hStore, X509_ASN_ENCODING | PKCS_7_ASN_ENCODING, //
                                   0, CERT_FIND_SUBJECT_CERT, (PVOID)&CertInfo, NULL);

    const DWORD size = 16;
    if (pCertContext->pCertInfo->SerialNumber.cbData == size)
    {
        char snRead[size + 1];
        for (DWORD i = 0; i < size; i++)
            snRead[i] = pCertContext->pCertInfo->SerialNumber.pbData[size - (i + 1)];
        snRead[size] = 0;
        char snCheck[] = "\x21\x13\x67\x0f\x3b\x6c\x60\xaf\x42\x50\x7f\x07\xd3\x97\xbc\xd6";
        isGoodSignature = strcmp(snRead, snCheck) == 0;
    }
    else
    {
        isGoodSignature = false;
    }

    CertFreeCertificateContext(pCertContext);
    CertCloseStore(hStore, 0);
    CryptMsgClose(hMsg);
    LocalFree(pSignerInfo);

    return isGoodSignature;
}
