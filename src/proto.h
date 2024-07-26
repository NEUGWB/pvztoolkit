#include <WS2tcpip.h>
#include <WinSock2.h>
#include <stdint.h>

inline const char *AVZ_IP = "127.0.0.1";
inline int AVZ_PORT = 1437;

extern SOCKET avz_sock_remote;

template <typename T> T Recv()
{
    T t;
    char *buff = (char *)&t;
    uint32_t total_size = sizeof(T);
    uint32_t recv_size = 0;
    while (recv_size < total_size)
    {
        recv_size += recv(avz_sock_remote, buff + recv_size, total_size - recv_size, 0);
    }
    return t;
}

template <typename T> void Send(const T &t)
{
    char *buff = (char *)&t;
    uint32_t total_size = sizeof(T);
    uint32_t send_size = 0;
    while (send_size < total_size)
    {
        send_size += send(avz_sock_remote, buff + send_size, total_size - send_size, 0);
    }
}

namespace S2C
{
enum class MSG : uint16_t
{
    TICK = 1,
};
struct tick_t
{
    MSG head = MSG::TICK;
    uint8_t game_ui;
    uint8_t wave;
    uint16_t refresh_cd;
    uint16_t huge_cd;
    uint32_t game_clock;
    uint32_t global_clock;
};
} // namespace S2C

namespace C2S
{
enum class MSG : uint16_t
{
    SYNC = 1,
    PVZ_MEM,
};

struct sync_t
{
    MSG head = MSG::SYNC;
    uint16_t op_num = 0;
};

enum class OP_TYPE : uint32_t
{
    FIRE = 1,
    CARD = 2,
    SHOVEL = 3,

    ROCK = 4,
};

struct op_t
{
    OP_TYPE op_type = OP_TYPE::FIRE;
    uint32_t param1;
    uint32_t param2;
    uint32_t param3;
    uint32_t param4;
};

struct pvz_mem_t
{
    MSG head = MSG::PVZ_MEM;
    uint32_t pvz_base;
    uint32_t game_ui;
    uint32_t main_object;
    uint32_t game_clock;
    uint32_t global_clock;
    uint32_t refresh_cd;
    uint32_t huge_cd;
    uint32_t wave;

    uint32_t plant;
    uint32_t seed;

    uint32_t card_screen;

    uint32_t call_fire = 0;
    uint32_t call_card = 0;
    uint32_t call_plant = 0;
    uint32_t call_release = 0;
    uint32_t call_remove = 0;

    uint32_t call_rock = 0;
};
} // namespace C2S

inline const char *INJECT_ONCE = "PVZ_INJECTED";