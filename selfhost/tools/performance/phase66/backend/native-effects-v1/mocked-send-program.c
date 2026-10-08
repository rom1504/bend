
// Imports
// =======

#pragma clang fp contract(off)

#ifdef __METAL_VERSION__
#include <metal_stdlib>
using namespace metal;
#elif !defined(__CUDACC_RTC__)
#ifndef __APPLE__
#define _GNU_SOURCE
#endif
#include <stdint.h>
#include <stdbool.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sched.h>
#include <stdatomic.h>
#include <unistd.h>
#include <signal.h>
#include <sys/mman.h>
#include <time.h>
#include <poll.h>
#ifdef __APPLE__
#include <mach-o/dyld.h>
#endif
#ifdef __OBJC__
// #include, not #import: bend -o reads an #import as an effect's framework
#include <Metal/Metal.h>
#include <Foundation/Foundation.h>
#elif BEND_CUDA
#include <cuda.h>
#include <nvrtc.h>
#include <fcntl.h>
#include <sys/stat.h>
#endif
#endif

// Dialect
// =======

#ifdef __METAL_VERSION__
// coherent(device) (MSL 3.2): M1-class parts else lose stores across
// threadgroups within a dispatch
#if __METAL_VERSION__ >= 320
#define DEV     coherent(device) device
#define DEVL    coherent(device) device
#else
#define DEV     device
#define DEVL    device
#endif
#define GA32    threadgroup atomic_uint
#define THR     thread
#define INLINE  inline
#define OUTLINE static
#define CONSTV  constant
#define DEVICE  1
#define CLZ(x)  clz(x)
#define A32(p)  ((DEV atomic_uint*)(p))
#define RLX     memory_order_relaxed
#define FENCE() atomic_thread_fence(mem_flags::mem_device, memory_order_seq_cst)
#define BAR()   threadgroup_barrier(mem_flags::mem_threadgroup)
#define BARD()  threadgroup_barrier(mem_flags::mem_device \
  | mem_flags::mem_threadgroup)

#define g32_ini(p)    atomic_store_explicit(p, 0, RLX)
#define g32_add(p, v) atomic_fetch_add_explicit(p, v, RLX)
#define g32_get(p)    atomic_load_explicit(p, RLX)
#else
#define DEVL
#define THR
#define INLINE  static inline
#define CONSTV  static const

#define g32_ini(p)    a32_store(p, 0)
#define g32_add(p, v) a32_add(p, v)
#define g32_get(p)    a32_load(p)
#ifdef __CUDACC_RTC__
// plain data stays L1-cacheable: cross-lane handoffs go through a32 + FENCE
#define DEV
#define GA32    __shared__ u32
#define OUTLINE static __attribute__((noinline))
#define DEVICE  1
#define CLZ(x)  (u32)__clz((int)(x))
#define FENCE() __threadfence()
#define BAR()   __syncthreads()
#define BARD()  \
  { __threadfence(); __syncthreads(); }
#else
#define DEV
// only clang 19+ has both, and only it compiles preserve_most soundly
#if __has_attribute(preserve_none) && __has_attribute(preserve_most)
#define PRESERVE(A) __attribute__((A))
#else
#define PRESERVE(A)
#endif
#define OUTLINE static __attribute__((noinline, cold)) PRESERVE(preserve_most)
#define DEVICE  0
#define CLZ(x)  (u32)__builtin_clz(x)
#endif
#endif
#define FAR static __attribute__((noinline))

// A segment: a case of the device's switch; on the host, a preserve_none
// function (WL_SIG) left by a musttail call, its words fresh at WL_OPEN.
#if DEVICE
#define LOCK(l)
#define UNLOCK(l)
#define WL_CASE(F) case F:
#define WL_OPEN    {
#define WL_JMP(F)  { fid = (F); break; }
#define WL_DYN     WL_JMP
#else
#define LOCK(l)    while (__atomic_exchange_n(&(l), 1, __ATOMIC_ACQUIRE)) {}
#define UNLOCK(l)  __atomic_store_n(&(l), 0, __ATOMIC_RELEASE)
#define WL_FN      static PRESERVE(preserve_none) __attribute__((noinline)) Reply
#define WL_CASE(F) WL_FN WL_##F(WL_SIG)
#define WL_OPEN    { WL_BANK u32 rn;
#define WL_JMP(F)  __attribute__((musttail)) return WL_##F(WL_ALL)
#define WL_DYN(F)  __attribute__((musttail)) return wl_tab[F](WL_ALL)
#endif
#define WL_SPIN     for (;;) { if (err_spun(e.mem, &wpoll)) { return 0; }
#define WL_SPUN     } break;
#define WL_AGAIN(F) continue
#define WL_POP()    { sp -= LANE_STEP; WL_DYN((Fid)STK(0)); }

#define LANE_STEP (DEVICE ? (int64_t)CUBE : 1)
#define STK(I)    sp[(int64_t)(I) * LANE_STEP]

#define WL_RETN(N)  { rn = (N); WL_POP(); }
#define WL_CONT     STK(-3)
#define WL_IDX      STK(-2)
#define WL_POPN(N)  sp -= N * LANE_STEP
#define WL_PUSHN(N) sp += N * LANE_STEP
#define WL_FRAME(T) \
  Loc wtl = task_tail(T); \
  u64 wtw = e.mem[wtl + 1]; \
  STK(0) = e.mem[wtl]; \
  STK(1) = (wtw >> 32) & 0xFFFF; \
  STK(2) = FID_EXIT; \
  sp += 3 * LANE_STEP;
#define WL_ARGS(A, N) \
  for (u32 wi = 0; wi + 1 < N; wi += 1) { \
    STK(wi) = e.mem[A + wi]; \
  } \
  sp += (N - 1) * LANE_STEP;
#define WL_ROOM(N) \
  if (DEVICE && sp + (N) * CUBE >= e.mem + HEAP_OFF + CUBE) { \
    err_post(e.mem, ERR_DEEP); \
    return 0; \
  }

// Types
// =====

#ifdef __METAL_VERSION__
typedef ulong u64;
typedef uint  u32;
typedef uchar u8;
typedef float f32;
#elif defined(__CUDACC_RTC__)
typedef unsigned long long u64;
typedef long long          int64_t;
typedef unsigned int       u32;
typedef unsigned char      u8;
typedef float              f32;
#else
typedef uint64_t u64;
typedef uint32_t u32;
typedef uint8_t  u8;
typedef float    f32;
#endif

typedef u64 Loc;
#define LOC_MASK ((1ull << 40) - 1)

typedef u32 Cls;
typedef u32 Fid;

typedef u64 Term;
#define TAG_PAK 1ull
#define TAG_CTR 2ull
#define TAG_CLO 3ull
#define TAG_BUF 4ull
#define TAG_TSK 5ull
#define TAG_ARR 6ull

#define TERM_HOLE (~0ull)

#define RFC_BIT  (1ull << 63)
#define RFC_CNT  ((1u << 24) - 1)

typedef Term Reply;

typedef u32 Err;
#define ERR_RING 1
#define ERR_TAGS 2
#define ERR_HEAP 3
#define ERR_FIDS 4
#define ERR_NATS 5
#define ERR_RFCS 6
#define ERR_DEEP 7
#define ERR_ARRS 8

typedef u32 Ring;

typedef DEV u64* Corpus;

typedef struct {
  Corpus   mem;
  DEV u64* alc;
} Env;

typedef struct {
  u64 off;
  u32 rd;
  u32 wr;
  u32 top;
} Bank;

typedef DEVL Term* Stk;

typedef Term Nat;
#define NAT_IMM ((1ull << 48) - 1)

typedef Term U32;

#if DEVICE
typedef u32 u32a;
#else
typedef u32 __attribute__((may_alias)) u32a;
#endif

#ifdef __METAL_VERSION__
typedef threadgroup atomic_uint* Cur;
#else
typedef u32* Cur;
#endif

// Constants
// =========

#define LINE      16
#define PAGE_BITS 7
#define PAGE_LEN  (1ull << PAGE_BITS)
#define CUBE_T    128
#define CUBE      ((u64)CUBE_T * CUBE_T)
#define CUBE_G    (1u << CUBE_LOG)
#define LANES     ((u64)CUBE_T << CUBE_LOG)
#define RING_LOG  (17 - CUBE_LOG)
#define RING_LEN  (1ull << RING_LOG)
#define STAK_LEN  (1ull << 11)
#define NCLS      8
#define NCLS_ALL  32
#define IO_HELP   64

#define ALC_WORDS NCLS_ALL
#define TG_HOLD   2304
#define CHUNK     256
#define CAP_WORDS 32768
#define QUANTUM   (DEVICE ? PAGE_LEN \
  : KEEP_WORDS < 32 * PAGE_LEN ? KEEP_WORDS : 32 * PAGE_LEN)
#if DEVICE
#define KEEP_WORDS CHUNK
#endif
#define RING_WORDS ((1ull << 10) + 2)

#define H_BUMP       0
#define H_CAP        1
#define H_CURSOR     LINE
#define H_ROOT_DONE  (2 * LINE)
#define H_ERROR_CODE (3 * LINE)
#define H_ROOT_WORD  (4 * LINE)
#define H_BANK       (H_ROOT_WORD + WL_RESW)

#define PAGE_UP(n) (((n) + PAGE_LEN - 1) & ~(PAGE_LEN - 1))
#define ALC_OFF  PAGE_UP(H_BANK + 3 * NCLS_ALL)
#define RING_OFF (ALC_OFF + CUBE * 2 * ALC_WORDS)
#define STAK_OFF (RING_OFF + CUBE * RING_WORDS)
#define STAT_OFF (STAK_OFF + CUBE * STAK_LEN)
#define HEAP_OFF (STAT_OFF + PAGE_UP(STAT_LEN))

// Globals
// =======

#if !DEVICE

typedef pthread_mutex_t lock;

static Corpus CORPUS;
static u64    ALC[CUBE_T + 1][3 * ALC_WORDS] __attribute__((aligned(128)));
static u32    KEEP_WORDS;
// the bag: 2^CUBE_LOG groups of CUBE_T lanes (a -D constant on the device)
static u32    CUBE_LOG = 7;
static u32    bank_lock;

static u32            pool_size;
static _Atomic u32    pool_row;
static bool           pool_grow;
static _Atomic u64    pool_tick;
static _Atomic u32    pool_done;
static lock           pool_lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t pool_wake = PTHREAD_COND_INITIALIZER;

// The device program compiles from the binary's own text.
#if BEND_METAL || BEND_CUDA
#pragma clang diagnostic ignored "-Wc23-extensions"
static const char BEND_SRC[] = {
#embed __FILE__
, 0 };
#endif

#ifdef __OBJC__
static id<MTLDevice>               gpu_dev;
static id<MTLCommandQueue>         gpu_que;
static id<MTLComputePipelineState> gpu_pso;
static id<MTLBuffer>               gpu_buf;
static id<MTLComputeCommandEncoder> gpu_enc;
#elif BEND_CUDA
static CUdevice   gpu_dev;
static CUmodule   gpu_lib;
static CUfunction gpu_pso;
#endif
static bool io_gpu;
static Stk  io_stk;

static const char* CLI_HELP =
  "usage: %s [options] [arguments]\n"
  "  --threads N       worker threads, 1 to 128 (default: the CPU count)\n"
  "  --gpu on|off|4GB  run ! calls on the GPU, over this much of its memory\n"
  "                    (default: on if present, over 2GB on Metal)\n"
  "  --gpu-build       write the GPU program and exit\n"
  "  --help            show this text\n"
  "  --                the rest are the program's arguments (IO.args)\n";

#endif

// Tables
// ======

#define FID_109_97_105_110_ 0
#define FID_110_97_116_105_118_101_95_107_95_49_48_50_54_ 1
#define FID_110_97_116_105_118_101_95_107_95_49_48_50_55_ 2
#define FID_110_97_116_105_118_101_95_107_95_49_48_50_56_ 3
#define FID_110_97_116_105_118_101_95_107_95_49_48_51_49_ 4
#define FID_110_97_116_105_118_101_95_107_95_49_48_51_50_ 5
#define FID_110_97_116_105_118_101_95_107_95_49_48_51_51_ 6
#define FID_110_97_116_105_118_101_95_107_95_49_48_51_54_ 7
#define FID_110_97_116_105_118_101_95_107_95_49_48_51_55_ 8
#define FID_110_97_116_105_118_101_95_107_95_49_48_51_56_ 9
#define FID_110_97_116_105_118_101_95_107_95_49_48_52_49_ 10
#define FID_110_97_116_105_118_101_95_107_95_49_48_52_50_ 11
#define FID_110_97_116_105_118_101_95_107_95_49_48_52_53_ 12
#define FID_110_97_116_105_118_101_95_107_95_49_48_52_54_ 13
#define FID_110_97_116_105_118_101_95_107_95_49_48_52_57_ 14
#define FID_110_97_116_105_118_101_95_107_95_49_48_53_48_ 15
#define FID_110_97_116_105_118_101_95_107_95_49_48_53_51_ 16
#define FID_110_97_116_105_118_101_95_107_95_49_48_53_52_ 17
#define FID_110_97_116_105_118_101_95_107_95_49_48_53_55_ 18
#define FID_110_97_116_105_118_101_95_107_95_49_48_53_56_ 19
#define FID_110_97_116_105_118_101_95_107_95_49_48_54_49_ 20
#define FID_110_97_116_105_118_101_95_107_95_49_48_54_50_ 21
#define FID_110_97_116_105_118_101_95_107_95_49_48_54_53_ 22
#define FID_110_97_116_105_118_101_95_107_95_49_48_54_54_ 23
#define FID_73_79_46_98_105_110_100_ 24
#define FID_110_97_116_105_118_101_95_107_95_50_48_57_49_ 25
#define FID_110_97_116_105_118_101_95_107_95_50_48_57_50_ 26
#define FID_110_97_116_105_118_101_95_107_95_50_48_57_51_ 27
#define FID_110_97_116_105_118_101_95_107_95_50_48_57_54_ 28
#define FID_110_97_116_105_118_101_95_107_95_50_48_57_55_ 29
#define FID_110_97_116_105_118_101_95_107_95_50_48_57_56_ 30
#define FID_110_97_116_105_118_101_95_107_95_50_49_48_49_ 31
#define FID_110_97_116_105_118_101_95_107_95_50_49_48_50_ 32
#define FID_110_97_116_105_118_101_95_107_95_50_49_48_53_ 33
#define FID_110_97_116_105_118_101_95_107_95_50_49_48_54_ 34
#define FID_36_100_105_114_101_99_116_46_73_79_46_98_105_110_100_ 35
#define FID_110_97_116_105_118_101_95_107_95_50_49_49_50_ 36
#define FID_110_97_116_105_118_101_95_107_95_50_49_49_51_ 37
#define FID_110_97_116_105_118_101_95_107_95_50_49_49_52_ 38
#define FID_110_97_116_105_118_101_95_107_95_50_49_49_55_ 39
#define FID_110_97_116_105_118_101_95_107_95_50_49_49_56_ 40
#define FID_110_97_116_105_118_101_95_107_95_50_49_50_49_ 41
#define FID_110_97_116_105_118_101_95_107_95_50_49_50_50_ 42
#define FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_102_102_ 43
#define FID_110_97_116_105_118_101_95_107_95_51_49_52_56_ 44
#define FID_36_100_105_114_101_99_116_46_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_102_102_ 45
#define FID_73_79_46_112_114_105_110_116_ 46
#define FID_110_97_116_105_118_101_95_107_95_52_49_55_53_ 47
#define FID_110_97_116_105_118_101_95_107_95_52_49_55_54_ 48
#define FID_36_100_105_114_101_99_116_46_73_79_46_112_114_105_110_116_ 49
#define FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_110_97_109_101_ 50
#define FID_110_97_116_105_118_101_95_107_95_53_50_48_53_ 51
#define FID_110_97_116_105_118_101_95_107_95_53_50_48_56_ 52
#define FID_110_97_116_105_118_101_95_107_95_53_50_48_57_ 53
#define FID_110_97_116_105_118_101_95_107_95_53_50_49_51_ 54
#define FID_110_97_116_105_118_101_95_107_95_53_50_49_52_ 55
#define FID_110_97_116_105_118_101_95_107_95_53_50_49_56_ 56
#define FID_110_97_116_105_118_101_95_107_95_53_50_49_57_ 57
#define FID_110_97_116_105_118_101_95_107_95_53_50_50_50_ 58
#define FID_110_97_116_105_118_101_95_107_95_53_50_50_52_ 59
#define FID_110_97_116_105_118_101_95_107_95_53_50_50_54_ 60
#define FID_110_97_116_105_118_101_95_107_95_53_50_51_48_ 61
#define FID_110_97_116_105_118_101_95_107_95_53_50_51_49_ 62
#define FID_110_97_116_105_118_101_95_107_95_53_50_51_53_ 63
#define FID_110_97_116_105_118_101_95_107_95_53_50_51_54_ 64
#define FID_110_97_116_105_118_101_95_107_95_53_50_51_57_ 65
#define FID_110_97_116_105_118_101_95_107_95_53_50_52_49_ 66
#define FID_110_97_116_105_118_101_95_107_95_53_50_52_52_ 67
#define FID_110_97_116_105_118_101_95_107_95_53_50_52_53_ 68
#define FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_110_ 69
#define FID_110_97_116_105_118_101_95_107_95_54_50_55_48_ 70
#define FID_36_100_105_114_101_99_116_46_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_110_ 71
#define FID_IO_EMIT 72
#define BEND_CLO_APPLY 73
#define FID_EXIT 74
#define FID_ENTER 75
#define CID_UNIT 0
#define CID_FALSE 1
#define CID_TRUE 2
#define CID_LT 3
#define CID_EQ 4
#define CID_GT 5
#define CID_INL 6
#define CID_INR 7
#define CID_TUPLE 8
#define CID_ZERO 9
#define CID_SUCC 10
#define CID_NONE 11
#define CID_SOME 12
#define CID_FAIL 13
#define CID_DONE 14
#define CID_READY 15
#define CID_WAIT 16
#define CID_NIL 17
#define CID_CON 18
#define CID_WNIL 19
#define CID_WCON 20
#define CID_U32 21
#define CID_F32 22
#define CID_CHR 23
#define CID_SNIL 24
#define CID_SCON 25
#define CID_ALEAF 26
#define CID_ANODE 27
#define CID_PIX 28
#define CID_QUA 29
#define CID_KEY 30
#define CID_MOUSE 31
#define CID_MOVE 32
#define CID_LOOK 33
#define CID_SCROLL 34
#define CID_CLOSE 35
#define CID_MTIP 36
#define CID_MLEAF 37
#define CID_MNODE 38
#define CID_FILE 39
#define CID_SOCKET 40
#define CID_LISTENER 41
#define CID_WINDOW 42
#define CID_AUDIO 43
#define CID_CHAN 44
#define CID_EMIT 45
#define CID_HALT 46
#define CID_APP 47
#define CID_IO_PRINT 48
#define CID_IO_WRITE 49
#define CID_IO_PRINT_ERR 50
#define CID_IO_GET_ENV 51
#define CID_IO_ARGS 52
#define CID_PROCESS_RUN 53
#define CID_IO_RANDOM_U32 54
#define CID_IO_SPAWN 55
#define CID_IO_SLEEP 56
#define CID_IO_NOW 57
#define CID_IO_THREAD_COUNT 58
#define CID_CHAN_NEW 59
#define CID_CHAN_SEND 60
#define CID_CHAN_RECV 61
#define CID_CHAN_TRY_SEND 62
#define CID_CHAN_TRY_RECV 63
#define CID_CHAN_CLOSE 64
#define CID_FILE_OPEN 65
#define CID_FILE_READ 66
#define CID_FILE_READ_BYTES 67
#define CID_FILE_READ_AT 68
#define CID_FILE_SIZE 69
#define CID_FILE_WRITE 70
#define CID_FILE_WRITE_BYTES 71
#define CID_FILE_CLOSE 72
#define CID_TCP_LISTEN 73
#define CID_TCP_ACCEPT 74
#define CID_TCP_TRY_ACCEPT 75
#define CID_TCP_CONNECT 76
#define CID_TCP_SEND 77
#define CID_TCP_TRY_SEND 78
#define CID_TCP_RECV 79
#define CID_TCP_TRY_RECV 80
#define CID_TCP_SEND_BYTES 81
#define CID_TCP_TRY_SEND_BYTES 82
#define CID_TCP_RECV_BYTES 83
#define CID_TCP_TRY_RECV_BYTES 84
#define CID_UDP_BIND 85
#define CID_UDP_SEND_TO 86
#define CID_UDP_TRY_SEND_TO 87
#define CID_UDP_SEND_BYTES_TO 88
#define CID_UDP_TRY_SEND_BYTES_TO 89
#define CID_UDP_RECV_FROM 90
#define CID_UDP_TRY_RECV_FROM 91
#define CID_UDP_RECV_BYTES_FROM 92
#define CID_UDP_TRY_RECV_BYTES_FROM 93
#define CID_SOCKET_CLOSE 94
#define CID_LISTENER_CLOSE 95
#define CID_WINDOW_OPEN 96
#define CID_WINDOW_FRAME 97
#define CID_WINDOW_SET_TITLE 98
#define CID_WINDOW_GRAB 99
#define CID_WINDOW_CLOSE 100
#define CID_AUDIO_OPEN 101
#define CID_AUDIO_WRITE 102
#define CID_AUDIO_CLOSE 103
#define CID_U32_TO_F32 104
#define CID_F32_TO_U32 105
#define CID_F32_ADD 106
#define CID_F32_SUB 107
#define CID_F32_MUL 108
#define CID_F32_DIV 109
#define CID_F32_MOD 110
#define CID_F32_POW 111
#define CID_F32_ATAN2 112
#define CID_F32_NEG 113
#define CID_F32_ABS 114
#define CID_F32_SQRT 115
#define CID_F32_EXP 116
#define CID_F32_LOG 117
#define CID_F32_LOG2 118
#define CID_F32_LOG10 119
#define CID_F32_SIN 120
#define CID_F32_COS 121
#define CID_F32_TAN 122
#define CID_F32_ASIN 123
#define CID_F32_ACOS 124
#define CID_F32_ATAN 125
#define CID_F32_SINH 126
#define CID_F32_COSH 127
#define CID_F32_TANH 128
#define CID_F32_FLOOR 129
#define CID_F32_CEIL 130
#define CID_F32_TRUNC 131
#define CID_F32_IS_EQ 132
#define CID_F32_IS_NE 133
#define CID_F32_IS_LT 134
#define CID_F32_IS_LE 135
#define CID_F32_IS_GT 136
#define CID_F32_IS_GE 137
#define CID_F32_SHOW 138
#define CID_F32_BITS 139
#define CID_F32_READ 140
#define CID_ARRAY_ATOMIC_ADD 141
#define CID_ARRAY_ATOMIC_MIN 142
#define CID_ARRAY_ATOMIC_MAX 143
#define CID_ARRAY_ATOMIC_AND 144
#define CID_ARRAY_ATOMIC_OR 145
#define CID_ARRAY_ATOMIC_XOR 146
#define CID_ARRAY_ATOMIC_EXCH 147
#define CID_ARRAY_ATOMIC_CAS 148
#define CID_ARRAY_ATOMIC_FADD 149
#define CID__CTOR_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_79_102_102_ 150
#define CID__CTOR_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_79_110_ 151
#define CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_OFF 152
#define CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_ON 153
#define WL_RESW 1
#define BANGS 0
#define WL_BANK Term r0, r1, r2;
#define WL_LOAD(A, N) \
  do { \
    if ((N) <= 0) break; r0 = e.mem[(A) + 0]; \
    if ((N) <= 1) break; r1 = e.mem[(A) + 1]; \
    if ((N) <= 2) break; r2 = e.mem[(A) + 2]; \
  } while (0);
#define WL_LAST(X) \
  switch (war) { \
    case 0: r0 = (X); break; \
    case 1: r1 = (X); break; \
    case 2: r2 = (X); break; \
  }
#define WL_SAVE(V) (V)[0] = r0; 
#define WL_TAKE(V) r0 = (V)[0]; 
#define WL_SIG Env e, Stk sp, u32 seq, u32 rn, Term r0, Term r1, Term r2
#define WL_ALL e, sp, seq, rn, r0, r1, r2
CONSTV u8 FID_ARITY_T[] = { 0, 1, 2, 1, 1, 2, 1, 1, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 1, 2, 0, 1, 2, 3, 3, 2, 3, 2, 2, 2, 2, 3, 3, 2, 3, 2, 2, 2, 2, 0, 1, 1, 0, 1, 2, 2, 0, 1, 1, 2, 1, 2, 1, 2, 1, 1, 1, 1, 2, 1, 2, 1, 1, 2, 2, 0, 1, 1, 1, 2 };
CONSTV u8 FID_FLAG_T[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0 };
CONSTV u8 FID_RESW_T[] = { 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0 };
CONSTV u8 CID_ARITY_T[] = { 0, 0, 0, 0, 0, 0, 1, 1, 2, 0, 1, 0, 1, 1, 1, 1, 1, 0, 2, 0, 2, 1, 1, 1, 0, 2, 1, 2, 1, 4, 2, 4, 2, 2, 4, 0, 0, 2, 3, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 2, 2, 2, 1, 6, 1, 2, 2, 1, 1, 2, 3, 2, 4, 3, 2, 3, 3, 3, 4, 2, 3, 3, 2, 3, 2, 3, 3, 3, 4, 3, 4, 3, 4, 3, 4, 3, 5, 6, 5, 6, 3, 4, 3, 4, 2, 2, 4, 3, 3, 3, 2, 2, 3, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 4, 3, 0, 1, 1, 1, 0 };
CONSTV u8 CID_HOT_T[] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0 };
#define STAT_LEN 0
#define WL_TABLE WL_X(FID_109_97_105_110_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_50_54_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_50_55_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_50_56_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_51_49_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_51_50_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_51_51_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_51_54_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_51_55_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_51_56_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_52_49_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_52_50_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_52_53_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_52_54_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_52_57_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_53_48_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_53_51_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_53_52_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_53_55_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_53_56_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_54_49_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_54_50_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_54_53_) WL_X(FID_110_97_116_105_118_101_95_107_95_49_48_54_54_) WL_X(FID_73_79_46_98_105_110_100_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_48_57_49_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_48_57_50_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_48_57_51_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_48_57_54_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_48_57_55_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_48_57_56_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_48_49_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_48_50_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_48_53_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_48_54_) WL_X(FID_36_100_105_114_101_99_116_46_73_79_46_98_105_110_100_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_49_50_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_49_51_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_49_52_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_49_55_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_49_56_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_50_49_) WL_X(FID_110_97_116_105_118_101_95_107_95_50_49_50_50_) WL_X(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_102_102_) WL_X(FID_110_97_116_105_118_101_95_107_95_51_49_52_56_) WL_X(FID_36_100_105_114_101_99_116_46_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_102_102_) WL_X(FID_73_79_46_112_114_105_110_116_) WL_X(FID_110_97_116_105_118_101_95_107_95_52_49_55_53_) WL_X(FID_110_97_116_105_118_101_95_107_95_52_49_55_54_) WL_X(FID_36_100_105_114_101_99_116_46_73_79_46_112_114_105_110_116_) WL_X(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_110_97_109_101_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_48_53_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_48_56_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_48_57_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_49_51_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_49_52_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_49_56_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_49_57_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_50_50_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_50_52_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_50_54_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_51_48_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_51_49_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_51_53_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_51_54_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_51_57_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_52_49_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_52_52_) WL_X(FID_110_97_116_105_118_101_95_107_95_53_50_52_53_) WL_X(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_110_) WL_X(FID_110_97_116_105_118_101_95_107_95_54_50_55_48_) WL_X(FID_36_100_105_114_101_99_116_46_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_110_) WL_X(FID_IO_EMIT) WL_X(BEND_CLO_APPLY) WL_X(FID_EXIT)
#define MAIN_FID FID_109_97_105_110_
#define MAIN_PURE 0
#if !DEVICE
static const u32 SHOW_DESC[] = { 0 };
static const char* SHOW_NAMES[] = {"False", "True", "Unit"};
#endif


#define TAB_AT(T, S, I) T[S < I ? S : I]

// Fid
// ===

#define fid_arity(x) ((u32)FID_ARITY_T[x])

#define fid_bangs(x) ((bool)(FID_FLAG_T[x] & 1))

#define fid_nofk(x) ((bool)(FID_FLAG_T[x] & 2))

#define fid_seqk(x) (fid_resw(x) != 0)

#define fid_resw(x) ((u32)FID_RESW_T[x])

// Cid
// ===

#define cid_arity(x) ((u32)CID_ARITY_T[x])
#define cid_hot(x) ((bool)CID_HOT_T[x])

// A32
// ===

#ifdef __METAL_VERSION__

// via a volatile local: else the M1 backend folds the zext into the atomic
// load, cannot legalize it, and the pipeline build dies
#define a32_load(p)      \
  ({ volatile thread u32 _a32v = atomic_load_explicit(A32(p), RLX); _a32v; })
#define a32_store(p, v)  atomic_store_explicit(A32(p), v, RLX)
#define a32_add(p, v)    atomic_fetch_add_explicit(A32(p), v, RLX)
#define a32_sub(p, v)    atomic_fetch_sub_explicit(A32(p), v, RLX)
#define a32_swp(p, e, v) \
  atomic_compare_exchange_weak_explicit(A32(p), e, v, RLX, RLX)

#elif defined(__CUDACC_RTC__)

#define a32_load(p)     (*(volatile u32*)(p))
#define a32_store(p, v) (*(volatile u32*)(p) = (v))
#define a32_add(p, v)   atomicAdd((u32*)(p), v)
#define a32_sub(p, v)   atomicSub((u32*)(p), v)

INLINE bool a32_swp(DEV u32* p, u32* e, u32 v) {
  u32 x = *e;
  *e = atomicCAS((u32*)p, x, v);
  return *e == x;
}

#endif

#if DEVICE

INLINE u32 a32_sub_rel(DEV u32* p, u32 v) {
  FENCE();
  return a32_sub(p, v);
}

INLINE void a32_store_rel(DEV u32* p, u32 v) {
  FENCE();
  a32_store(p, v);
}

INLINE u32 a32_load_acq(DEV u32* p) {
  u32 v = a32_load(p);
  FENCE();
  return v;
}

#define a32_acq(p) FENCE()

INLINE bool a32_cas(DEV u32* p, THR u32* e, u32 v) {
  FENCE();
  bool ok = a32_swp(p, e, v);
  FENCE();
  return ok;
}

#else

#define a32_load(p)         __atomic_load_n(p, __ATOMIC_RELAXED)
#define a32_store(p, v)     __atomic_store_n(p, v, __ATOMIC_RELAXED)
#define a32_add(p, v)       __atomic_fetch_add(p, v, __ATOMIC_RELAXED)
#define a32_sub(p, v)       __atomic_fetch_sub(p, v, __ATOMIC_RELAXED)
#define a32_sub_rel(p, v)   __atomic_fetch_sub(p, v, __ATOMIC_RELEASE)
#define a32_store_rel(p, v) __atomic_store_n(p, v, __ATOMIC_RELEASE)
#define a32_load_acq(p)     __atomic_load_n(p, __ATOMIC_ACQUIRE)
#define a32_acq(p)          ((void)a32_load_acq(p))

INLINE bool a32_cas(u32* p, u32* e, u32 v) {
  return __atomic_compare_exchange_n(
    p, e, v, 1, __ATOMIC_ACQ_REL, __ATOMIC_ACQUIRE);
}

#endif

#define a32_at(H, word) ((DEV u32*)&(H)[word])

// Err
// ===

#if DEVICE

INLINE void err_post(Corpus H, Err code) {
  u32 seen = 0;
  while (seen == 0 && !a32_cas(a32_at(H, H_ERROR_CODE), &seen, code)) {}
}

#else

static const char* ERR_TEXT[] = { "", "runtime fail-stop", "runtime fail-stop", "out of memory: run again with a bigger span, as in --gpu 8GB", "a function the device does not hold", "a Nat past the largest immediate 2^48-1", "runtime fail-stop", "memory fault (machine stack overflow?)", "an array past the deepest block class 31" };

static void err_fail(const char* msg) {
  fflush(stdout);
  fprintf(stderr, "bend: %s\n", msg);
  _exit(1);
}

static void err_post(Corpus H, Err code) {
  err_fail(ERR_TEXT[code]);
}

static void err_trap(int sig) {
  // A machine stack fault can interrupt stdio or exhaust the handler's small
  // alternate stack. Only async-signal-safe operations may run here.
  static const char message[] = "bend: memory fault (machine stack overflow?)\n";
  (void)write(STDERR_FILENO, message, sizeof(message) - 1);
  _exit(1);
}

#endif

#define err_seen(H)    (DEVICE && a32_load(a32_at(H, H_ERROR_CODE)) != 0)
#define err_spun(H, n) ((++*(n) & 4095) == 0 && err_seen(H))

#ifdef __METAL_VERSION__
// Metal's atan2 is NaN at the origin; libm answers +-0 or +-pi there
INLINE f32 atan2_c99(f32 y, f32 x) {
  return y == 0.0f && x == x
    ? copysign(signbit(x) ? M_PI_F : 0.0f, y) : atan2(y, x);
}
#define sqrt  precise::sqrt
#define exp   precise::exp
#define log   precise::log
#define log2  precise::log2
#define log10 precise::log10
#define sin   fast::sin
#define cos   fast::cos
#define tan   fast::tan
#define pow   precise::pow
#define fmod  precise::fmod
#define atan2 atan2_c99
#endif

#define U32_BIN(a, o, b) ((u64)((u32)(a) o (u32)(b)))

// Metal folds a constant dividend within 128 of 2^32 through an f32: divide
// its half, then fix the odd bit.
#define U32_QUO(a, b) \
  ((a) / 2 / (b) * 2 + ((a) - (a) / 2 / (b) * 2 * (b) >= (b)))

INLINE f32 f32_unbox(u64 x) {
  union { u32 u; f32 f; } p = { (u32)x };
  return p.f;
}

INLINE u64 f32_rewrap(f32 x) {
  union { f32 f; u32 u; } p = { x };
  return p.u;
}

INLINE U32 f32_to_u32(U32 a) {
  f32 v = f32_unbox(a);
  return v >= 0.0f && v < 4294967296.0f ? (u32)v : 0;
}

INLINE Nat nat_chk(Env e, Nat n) {
  if (n > NAT_IMM) {
    err_post(e.mem, ERR_NATS);
    return NAT_IMM;
  }
  return n;
}

INLINE Nat nat_mul(Env e, Nat a, Nat b) {
  return nat_chk(e, b != 0 && a > NAT_IMM / b ? NAT_IMM + 1 : a * b);
}

#if DEVICE

#define f32_show(e, x) (err_post(e.mem, ERR_FIDS), 0)
#define f32_read(e, s) (err_post(e.mem, ERR_FIDS), 0)

#else

static Term f32_show(Env e, Term x);
static Term f32_read(Env e, Term s);

#endif

// Cls
// ===

INLINE Cls cls_fit(u32 words) {
  return words > 1 ? 32 - CLZ(words - 1) : 0;
}

// Bank
// ====

// One stack of exact generations per class; 2 heap_words / max(CHUNK,
// 2^c) entries cover the old ones plus a pass of returns. The host
// pops and pushes at rd under bank_lock; a device pass pops down from
// rd and pushes above top, and the host then compacts [top, wr) onto
// rd, so a pass never sees what it handed.

#define bank_at(H, c) ((DEV Bank*)((H) + H_BANK) + (c))

INLINE Loc bank_pop(Corpus H, Cls c) {
  DEV Bank* b = bank_at(H, c);
  Loc got = 0;
  LOCK(bank_lock);
  u32 t = a32_sub(&b->rd, 1);
  if ((int)t > 0) {
    got = H[b->off + t - 1];
  } else {
    a32_add(&b->rd, 1);
  }
  if (!DEVICE) {
    b->wr = b->top = b->rd;
  }
  UNLOCK(bank_lock);
  return got;
}

INLINE void bank_push(Corpus H, Cls c, Loc head) {
  DEV Bank* b = bank_at(H, c);
  LOCK(bank_lock);
  H[b->off + a32_add(&b->wr, 1)] = head;
  if (!DEVICE) {
    b->rd = b->top = b->wr;
  }
  UNLOCK(bank_lock);
}

// Heap
// ====

// Per lane and class (a tile row on the device): HOT, a LIFO chain of
// free slots (word 0 the head it replaced); LEN, its exact length in
// words, off the chain; on the host COLD, one generation. A free is a
// push and an add. A host free at KEEP_WORDS (a slot for a wide class)
// runs heap_hand: COLD to the bank, HOT parked as COLD, generations
// exact. A miss takes COLD, else a bank entry, else a quantum of at
// most a generation, and sets LEN to what it took: no adoption past a
// generation, no list re-aged. A device lane keeps its frees for the
// pass; at the kernel end dev_cut hands its complete generations,
// walking only those. KEEP_WORDS is CAP_WORDS, or CHUNK with the GPU
// (fixed at boot), so a device lane may adopt every host entry.
// Bounds: a host lane and class under 2 max(KEEP_WORDS, 2^c) words, a
// device one under max(CHUNK, 2^c) after each kernel plus its own
// frees within one, bank entries exact. The bump grows only when this
// lane's HOT and COLD and the class's bank are empty. A zero row is an
// empty lane.

#define ALC_AT(e, i)   (e).alc[(i) * LANE_STEP]
#define ALC_LEN(e, c)  ALC_AT(e, ALC_WORDS + (c))
#define ALC_COLD(e, c) ALC_AT(e, 2 * ALC_WORDS + (c))
#define KEEP(c)        (KEEP_WORDS >> (c) ? KEEP_WORDS >> (c) : 1)

OUTLINE void heap_hand(Env e, Cls cls) {
  Loc cold = ALC_COLD(e, cls);
  if (cold) {
    bank_push(e.mem, cls, cold);
  }
  ALC_COLD(e, cls) = ALC_AT(e, cls);
  ALC_AT(e, cls)   = 0;
  ALC_LEN(e, cls)  = 0;
}

#if DEVICE
#define corpus_grow(H, n) false
#else
static bool corpus_grow(Corpus H, u64 need);
#endif

OUTLINE Loc heap_alloc_miss(Env e, Cls cls) {
  Corpus H = e.mem;
  Loc  got = 0;
  if (!DEVICE) {
    got = ALC_COLD(e, cls);
    ALC_COLD(e, cls) = 0;
  }
  if (!got) {
    got = bank_pop(H, cls);
  }
  u32 n = got ? KEEP(cls) : cls < NCLS ? QUANTUM >> cls : 1;
  if (!got) {
    u32 pages = (n << cls) >> PAGE_BITS;
    u32 p     = a32_add(a32_at(H, H_BUMP), pages);
    if ((u64)p + pages > a32_load_acq(a32_at(H, H_CAP))
      && !corpus_grow(H, (u64)p + pages)) {
      err_post(H, ERR_HEAP);
      p = 0;
    }
    got = HEAP_OFF + ((u64)p << PAGE_BITS);
    for (u32 i = 1; i <= n; i += 1) {
      H[got + ((u64)(i - 1) << cls)] = i < n ? got + ((u64)i << cls) : 0;
    }
  }
  ALC_AT(e, cls)  = H[got];
  ALC_LEN(e, cls) = (u64)(n - 1) << cls;
  return got;
}

INLINE Loc heap_alloc(Env e, Cls cls) {
  Loc h = ALC_AT(e, cls);
  if (h) {
    ALC_AT(e, cls)   = e.mem[h];
    ALC_LEN(e, cls) -= 1ull << cls;
    return h;
  }
  return heap_alloc_miss(e, cls);
}

INLINE void heap_free(Env e, Cls cls, Loc loc) {
  if (err_seen(e.mem)) {
    return;
  }
  e.mem[loc]       = ALC_AT(e, cls);
  ALC_AT(e, cls)   = loc;
  ALC_LEN(e, cls) += 1ull << cls;
  if (!DEVICE && ALC_LEN(e, cls) >= KEEP_WORDS) {
    heap_hand(e, cls);
  }
}

// Spare
// =====

INLINE void spare_free(Env e, Cls cls, Loc loc) {
  if (loc >= HEAP_OFF) {
    heap_free(e, cls, loc);
  }
}

// Term
// ====

#define term_make(tag, aux, loc) \
  (((u64)(tag) << 56) | ((u64)(aux) << 40) | (u64)(loc))

#define term_ctr(cid, loc) term_make(TAG_CTR, cid, loc)
#define term_pak(cid, loc) term_make(TAG_PAK, cid, loc)
#define term_clo(fid, loc) term_make(TAG_CLO, fid, loc)
#define term_buf(cls, loc) term_make(TAG_BUF, cls, loc)
#define term_tsk(fid, loc) term_make(TAG_TSK, fid, loc)

INLINE Term term_blk(bool arr, Cls cls, Loc loc) {
  return term_buf(cls, loc) | ((u64)arr << 57);
}

INLINE u64 term_tag(Term t) {
  return (t >> 56) & 0x7f;
}

INLINE bool term_rfc(Term t) {
  return (t & RFC_BIT) != 0;
}

INLINE u64 term_aux(Term t) {
  return (t >> 40) & 0xFFFF;
}

INLINE Loc term_loc(Term t) {
  return t & LOC_MASK;
}

// A static node (below the heap) is trivial, as is a captureless closure.
INLINE bool term_triv(Term t) {
  return term_tag(t) <= TAG_PAK || t == TERM_HOLE || term_loc(t) < HEAP_OFF;
}

OUTLINE Term rfc_wrap(Env e, Term t, u32 cnt) {
  if (term_tag(t) == TAG_CLO || term_tag(t) == TAG_TSK) {
    err_post(e.mem, ERR_RFCS);
    return t;
  }
  Loc r = heap_alloc(e, 0);
  e.mem[r] = ((u64)term_loc(t) << 24) | cnt;
  return (t & ~LOC_MASK) | RFC_BIT | r;
}

INLINE Term rfc_seal(Env e, Term t) {
  if (term_tag(t) != TAG_CTR || term_rfc(t)) {
    return t;
  }
  return rfc_wrap(e, t, 1);
}

INLINE u64 rfc_view(Env e, Loc r) {
  DEV u32* w = a32_at(e.mem, r);
  u64 cell = ((u64)a32_load(w + 1) << 32) | a32_load(w);
  if ((cell & RFC_CNT) == 1) {
    a32_acq(w);
  }
  return cell;
}

INLINE void rfc_bump(Env e, Loc r, u32 k) {
  u32 c = a32_add(a32_at(e.mem, r), k);
  if ((c & RFC_CNT) >= RFC_CNT - k) {
    err_post(e.mem, ERR_RFCS);
  }
}

INLINE Term term_keep(Env e, Term t) {
  if (term_rfc(t)) {
    rfc_bump(e, term_loc(t), 1);
    return t;
  }
  if (term_triv(t)) {
    return t;
  }
  return rfc_wrap(e, t, 2);
}

INLINE Loc term_peek(Env e, Term t) {
  if (term_rfc(t)) {
    return rfc_view(e, term_loc(t)) >> 24;
  }
  return term_loc(t);
}

INLINE Cls blk_cls(Term t) {
  return (u32)term_aux(t) & 31;
}

#define buf_wcls(c) ((c) == 0 ? 0 : (c) - 1)

INLINE Cls blk_span(Term t) {
  Cls c = blk_cls(t);
  return term_tag(t) == TAG_ARR ? c : buf_wcls(c);
}

FAR void term_drop(Env e, Term t);

INLINE void blk_free(Env e, Term t) {
  if (term_rfc(t)) {
    term_drop(e, t);
  } else {
    heap_free(e, blk_span(t), term_loc(t));
  }
}

FAR void term_drop(Env e, Term t) {
  Corpus H = e.mem;
  u64  cur = 0;
  Term c0  = 0;
  u32  step = 0;
  for (;;) {
    if (!term_triv(t) && term_rfc(t)) {
      Loc      r = term_loc(t);
      DEV u32* p = a32_at(H, r);
      if ((a32_sub_rel(p, 1) & RFC_CNT) != 1) {
        t = 0;
      } else {
        a32_acq(p);
        t = (t & ~(RFC_BIT | LOC_MASK)) | (H[r] >> 24);
        heap_free(e, 0, r);
      }
    }
    if (!term_triv(t)) {
      u64 tag = term_tag(t);
      if (tag == TAG_BUF) {
        blk_free(e, t);
      } else {
        u32 aux = (u32)term_aux(t);
        Loc loc = term_loc(t);
        u32 n   = 0;
        Cls cls;
        if (tag == TAG_ARR) {
          cls = 64 | blk_cls(t);
        } else {
          u32 ar;
          if (tag == TAG_CTR) {
            ar = cid_arity(aux);
          } else if (tag == TAG_CLO) {
            ar = fid_arity(aux) - 1;
          } else {
            ar = fid_arity(aux);
          }
          n   = ar;
          cls = cls_fit(tag == TAG_TSK ? ar + 2 : ar);
        }
        c0 = H[loc];
        H[loc] = cur;
        cur = loc | ((u64)n << 48) | ((u64)cls << 56);
      }
    }
    for (;;) {
      if (err_spun(H, &step)) {
        return;
      }
      if (cur == 0) {
        return;
      }
      Loc  loc = cur & LOC_MASK;
      u32  i   = (u8)(cur >> 40);
      u32  n   = (u8)(cur >> 48);
      Cls  cls = (u32)(cur >> 56);
      bool arr = cls > 63;
      u32  j   = i;
      if (arr) {
        cls &= 63;
        n   = 1u << cls;
        if (i == 2) {
          j = (u32)H[loc + 1];
        }
      }
      if (j < n) {
        Term c = j == 0 ? c0 : H[loc + j];
        if (arr && j > 0) {
          H[loc + 1] = j + 1;
        }
        if (!arr || i < 2) {
          cur += 1ull << 40;
        }
        if (!term_triv(c)) {
          t = c;
          break;
        }
      } else {
        u64 up = H[loc];
        heap_free(e, cls, loc);
        cur = up;
      }
    }
  }
}

INLINE void term_sink(Env e, Term t) {
  if (!term_triv(t)) {
    term_drop(e, t);
  }
}

OUTLINE void span_fade(Env e, Term t, Loc src, u32 n) {
  for (u32 j = 0; j < n; j += 1) {
    Term f = e.mem[src + j];
    if (term_rfc(f)) {
      rfc_bump(e, term_loc(f), 1);
    } else if (!term_triv(f)) {
      err_post(e.mem, ERR_RFCS);
    }
  }
  term_drop(e, t);
}

INLINE Loc ctr_take(Env e, Term t, u32 n, THR Term* out) {
  Corpus H = e.mem;
  if (!term_rfc(t)) {
    for (u32 j = 0; j < n; j += 1) {
      out[j] = H[term_loc(t) + j];
    }
    return term_loc(t);
  }
  Loc r    = term_loc(t);
  u64 cell = rfc_view(e, r);
  Loc src  = cell >> 24;
  for (u32 j = 0; j < n; j += 1) {
    out[j] = H[src + j];
  }
  if ((cell & RFC_CNT) == 1) {
    heap_free(e, 0, r);
    return src;
  }
  span_fade(e, t, src, n);
  return 0;
}

INLINE Term term_word(Env e, Term w) {
  u32 x = 0;
  Term t = w;
  for (u32 i = 0; i < 32 && term_aux(t) == CID_WCON; i += 1) {
    Loc l = term_peek(e, t);
    x |= (u32)(e.mem[l] & 1) << i;
    t = e.mem[l + 1];
  }
  term_sink(e, w);
  return x;
}

// Blk
// ===

// A block owns one allocation in its physical class (an ARR of class
// c 2^c Terms in 2^c words, a BUF 2^c u32 in 2^buf_wcls(c) words) and
// blk_free returns it there. A match on ANode is blk_half twice: each
// half allocated in its class and copied, the source freed shallow by
// the high call (its elements moved; the emitter binds the low half
// first). ANode{l, r} is blk_node: the merged class, l and r copied
// and freed shallow. Shared handles instead retain copied ARR elements and
// decrement their RFC; Array.clone keeps the original first and a fresh copy
// second. A match to the leaves copies
// O(n log n) words where a view copied none; get, set, swap, size and
// new open no half.

#define BLK_ALLOC(n, w) \
  Loc n = heap_alloc(e, w); \
  if (err_seen(e.mem)) { \
    return term_buf(0, n); \
  }

INLINE DEV u32a* blk_ptr(Corpus H, Loc loc, u32 i) {
  return (DEV u32a*)(H + loc) + i;
}

INLINE Term blk_read(Corpus H, bool arr, Loc loc, u32 i) {
  if (arr) {
    return H[loc + i];
  }
  return (u64)*blk_ptr(H, loc, i);
}

INLINE void blk_write(Corpus H, bool arr, Loc loc, u32 i, Term v) {
  if (arr) {
    H[loc + i] = v;
  } else {
    *blk_ptr(H, loc, i) = (u32)v;
  }
}

INLINE u32 blk_at(Term a, U32 i, u32 lgs) {
  return ((u32)i & (u32)((1ull << (blk_cls(a) - lgs)) - 1)) << lgs;
}

INLINE Term blk_keep(Env e, Loc at) {
  Term w = e.mem[at];
  Term v = term_keep(e, w);
  if (v != w) {
    e.mem[at] = v;
  }
  return v;
}

// A shared leaf gives its caller a retained element before dropping the handle.
INLINE Term blk_leaf(Env e, Term a) {
  Loc at = term_peek(e, a);
  return term_rfc(a) ? blk_keep(e, at) : e.mem[at];
}

// Uniform arrays keep U32/F32 payloads in the low half of each 64-bit slot.
// Existing a32 operations provide a single atomic update for every backend.
INLINE u64 array_atomic(Env e, Term a, u32 i, u32 v, u32 x, u32 op) {
  DEV u32* p = a32_at(e.mem, term_peek(e, a) + blk_at(a, i, 0));
  u32 old = a32_load(p);
  for (;;) {
    u32 next = v;
    switch (op) {
      case 1: next = old + v; break;
      case 2: next = old < v ? old : v; break;
      case 3: next = old > v ? old : v; break;
      case 4: next = old & v; break;
      case 5: next = old | v; break;
      case 6: next = old ^ v; break;
      case 8: next = old == v ? x : old; break;
      case 9: next = (u32)f32_rewrap(f32_unbox(old) + f32_unbox(v)); break;
    }
    u32 expected = old;
    if (a32_cas(p, &expected, next)) {
      return old;
    }
    old = expected;
  }
}

OUTLINE Term blk_copy(Env e, Term a) {
  Corpus H = e.mem;
  bool arr = term_tag(a) == TAG_ARR;
  Cls cls = blk_span(a);
  Loc src = term_peek(e, a);
  BLK_ALLOC(dst, cls)
  for (u64 j = 0; j < (1ull << cls); j += 1) {
    H[dst + j] = arr ? blk_keep(e, src + j) : H[src + j];
  }
  return term_blk(arr, blk_cls(a), dst);
}

INLINE Term blk_node(Env e, Term l, Term r) {
  Corpus H = e.mem;
  bool arr = term_tag(l) == TAG_ARR;
  Cls c = blk_cls(l);
  if (c != blk_cls(r) || c + 1 >= NCLS_ALL) {
    err_post(H, ERR_TAGS);
    return l;
  }
  Loc pl = term_peek(e, l);
  Loc pr = term_peek(e, r);
  BLK_ALLOC(n, arr ? c + 1 : c)
  if (!arr && c == 0) {
    H[n] = (u64)*blk_ptr(H, pl, 0) | ((u64)*blk_ptr(H, pr, 0) << 32);
  } else {
    u64 cw = 1ull << blk_span(l);
    for (u64 w = 0; w < cw; w += 1) {
      H[n + w]      = arr && term_rfc(l) ? blk_keep(e, pl + w) : H[pl + w];
      H[n + cw + w] = arr && term_rfc(r) ? blk_keep(e, pr + w) : H[pr + w];
    }
  }
  blk_free(e, l);
  blk_free(e, r);
  return term_blk(arr, c + 1, n);
}

INLINE Term blk_half(Env e, Term a, u32 hi) {
  Corpus H = e.mem;
  bool arr = term_tag(a) == TAG_ARR;
  Cls c = blk_cls(a);
  if (c == 0) {
    err_post(H, ERR_TAGS);
    return a;
  }
  c -= 1;
  Cls cw = arr ? c : buf_wcls(c);
  BLK_ALLOC(n, cw)
  if (!arr && c == 0) {
    H[n] = (u64)*blk_ptr(H, term_peek(e, a), hi);
  } else {
    Loc src = term_peek(e, a) + ((u64)hi << cw);
    for (u64 w = 0; w < (1ull << cw); w += 1) {
      H[n + w] = arr && term_rfc(a) ? blk_keep(e, src + w) : H[src + w];
    }
  }
  if (hi) {
    blk_free(e, a);
  }
  return term_blk(arr, c, n);
}

INLINE Term blk_new(Env e, bool arr, Nat d, u32 lgs, u32 n, THR Term* v) {
  Corpus H = e.mem;
  if (d + lgs > 31) {
    err_post(H, ERR_ARRS);
    d = 0;
  }
  Cls c = (u32)d + lgs;
  BLK_ALLOC(l, arr ? c : buf_wcls(c))
  for (u32 j = 0; j < n; j += 1) {
    Term w = v[j];
    if (arr && d > 0 && !term_triv(w)) {
      if (d >= 24) {
        err_post(H, ERR_RFCS);
      } else if (term_rfc(w)) {
        rfc_bump(e, term_loc(w), (1u << d) - 1);
      } else {
        w = rfc_wrap(e, w, 1u << d);
      }
    }
    v[j] = w;
  }
  for (u64 i = 0; i < (1ull << c); i += 1) {
    blk_write(H, arr, l, (u32)i, i % (1u << lgs) < n ? v[i % (1u << lgs)] : 0);
  }
  return term_blk(arr, c, l);
}

// Ring
// ====

// planes LANES wide: a smaller bag has deeper rings in the same region
#define ring_word(H, r, w) ((H) + RING_OFF + (w) * LANES + (r))
#define ring_slot(H, r, p) ring_word(H, r, (p) & (RING_LEN - 1))
#define ring_get(H, r)     ((DEV u32*)ring_word(H, r, RING_LEN))
#define ring_put(H, r)     ((DEV u32*)ring_word(H, r, RING_LEN + 1))

INLINE u32 ring_lap(u32 pos) {
  return ~(u32)(pos / RING_LEN) & 1;
}

INLINE void ring_push(Corpus H, Ring r, Term tsk) {
  u32 pos = a32_add(ring_put(H, r), 1);
  if (pos - a32_load(ring_get(H, r)) >= RING_LEN) {
    err_post(H, ERR_RING);
    return;
  }
  DEV u32* lo = (DEV u32*)ring_slot(H, r, pos);
  a32_store(lo, (u32)tsk);
  a32_store_rel(lo + 1, (u32)(tsk >> 32) | (ring_lap(pos) << 31));
}

INLINE Ring ring_flip(u32 i) {
  return (i % CUBE_T << CUBE_LOG) + i / CUBE_T;
}

#define ring_pick(b, s, c) ((b) + (s) * (g32_add(c, 1) & (CUBE_T - 1)))

// Task
// ====

INLINE Loc task_node(Env e, Fid fid, Term cont, u32 idx, u32 rem) {
  u32 ar  = fid_arity(fid);
  Loc loc = heap_alloc(e, cls_fit(ar + 2));
  for (u32 i = 0; rem && i < ar; i += 1) {
    e.mem[loc + i] = TERM_HOLE;
  }
  e.mem[loc + ar]     = cont;
  e.mem[loc + ar + 1] = ((u64)idx << 32) | rem;
  return loc;
}

INLINE Loc task_tail(Term t) {
  return term_loc(t) + fid_arity((u32)term_aux(t));
}

INLINE Term task_deliver(Corpus H, Term cont, u32 idx, THR Term* v, u32 n) {
  Loc at = cont == TERM_HOLE ? H_ROOT_WORD : term_loc(cont) + idx;
  for (u32 j = 0; j < WL_RESW; j += 1) {
    if (j < n) {
      H[at + j] = v[j];
    }
  }
  if (cont == TERM_HOLE) {
    a32_store_rel(a32_at(H, H_ROOT_DONE), n + 1);
    return 0;
  }
  Loc tl = task_tail(cont);
  if (a32_sub_rel(a32_at(H, tl + 1), 1) == 1) {
    a32_acq(a32_at(H, tl + 1));
    return cont;
  }
  return 0;
}

INLINE void task_deal(Corpus H, Term join, u32 base, u32 stride, Cur cur) {
  Loc loc = term_loc(join);
  u32 ar  = fid_arity((u32)term_aux(join));
  u32 g   = 0;
  if (stride == 0) {
    u32 rem = (u32)H[loc + ar + 1];
    g = a32_add(a32_at(H, H_CURSOR), rem);
  }
  for (u32 i = 0; i < ar; i += 1) {
    Term k = H[loc + i];
    if (term_tag(k) == TAG_TSK) {
      H[loc + i] = TERM_HOLE;
      Ring to;
      if (stride != 0) {
        to = ring_pick(base, stride, cur);
      } else {
        to = ring_flip(g & (u32)(LANES - 1));
        g += 1;
      }
      ring_push(H, to, k);
    }
  }
}

// Root
// ====

INLINE bool root_done(Corpus H) {
  return a32_load_acq(a32_at(H, H_ROOT_DONE)) != 0;
}

static u32 root_take(Corpus H, THR Term* v) {
  u32 n = a32_load_acq(a32_at(H, H_ROOT_DONE)) - 1;
  for (u32 j = 0; j < n; j += 1) {
    v[j] = H[H_ROOT_WORD + j];
  }
  a32_store(a32_at(H, H_ROOT_DONE), 0);
  return n;
}

// Spins
// =====

CONSTV u64 STAT_IMG[] = { 0 };
INLINE bool native_bool(Term t) { return t == 1 || (term_tag(t) == TAG_PAK && term_aux(t) == CID_TRUE); }
INLINE Term native_word(Env e, u32 x) {
  Term w = term_pak(CID_WNIL, 0);
  for (u32 i = 32; i > 0; i--) {
    Loc p = heap_alloc(e, 1);
    e.mem[p] = (x >> (i - 1)) & 1;
    e.mem[p + 1] = rfc_seal(e, w);
    w = term_ctr(CID_WCON, p);
  }
  return w;
}


// Work
// ====

// A host self-jump is a tail call: as a loop, MachineLICM hoisted eleven
// constants into symreg's entry (3.05 s against 2.51 s).
#if !DEVICE
#undef  WL_SPIN
#undef  WL_SPUN
#undef  WL_AGAIN
#define WL_SPIN
#define WL_SPUN
#define WL_AGAIN(F) __attribute__((musttail)) return WL_##F(WL_ALL)

typedef Reply (PRESERVE(preserve_none) *WlFn)(WL_SIG);
#define WL_X(F) WL_FN WL_##F(WL_SIG);
WL_TABLE WL_X(FID_ENTER)
#undef WL_X
#define WL_X(F) WL_##F,
static const WlFn wl_tab[] = { WL_TABLE };
#undef WL_X
#endif

static Reply work_loop(Env e, Stk sp, Term t, bool seq) {
  WL_BANK
  u32 rn = 0;
  r0 = t;
#if DEVICE
  Fid fid   = FID_ENTER;
  u32 wpoll = 0;
  for (;;) {
  if (err_spun(e.mem, &wpoll)) {
    return 0;
  }
  switch (fid) {
#else
  return WL_FID_ENTER(WL_ALL);
}
#endif

// Segments
// ========

  WL_CASE(FID_109_97_105_110_)
  {
    WL_OPEN
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_49_48_50_54_;
    WL_PUSHN(1);
    } else {
    u64 task_1067 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_50_54_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_50_54_, task_1067);
    WL_IDX = 0;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_49_48_54_53_;
    WL_PUSHN(1);
    } else {
    u64 task_1067 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_54_53_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_54_53_, task_1067);
    WL_IDX = 0;
    }
    WL_JMP(FID_73_79_46_98_105_110_100_);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_50_54_)
  {
    Term v_4294966271 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966271;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_50_55_;
    WL_PUSHN(2);
    } else {
    u64 task_1063 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_50_55_, WL_CONT, WL_IDX, 1);
    e.mem[task_1063 + 0] = v_4294966271;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_50_55_, task_1063);
    WL_IDX = 1;
    }
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_49_48_50_56_, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_50_55_)
  {
    WL_POPN(1);
    Term v_4294966271 = STK(0);
    Term v_4294966270 = r0;
    WL_OPEN
    { Term fn = v_4294966271; Term arg = v_4294966270;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_50_56_)
  {
    Term v_3469 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_49_48_51_49_;
    WL_PUSHN(1);
    } else {
    u64 task_1063 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_51_49_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_51_49_, task_1063);
    WL_IDX = 0;
    }
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_3469;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_53_51_;
    WL_PUSHN(2);
    } else {
    u64 task_1063 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_53_51_, WL_CONT, WL_IDX, 1);
    e.mem[task_1063 + 0] = v_3469;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_53_51_, task_1063);
    WL_IDX = 1;
    }
    WL_JMP(FID_73_79_46_98_105_110_100_);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_51_49_)
  {
    Term v_4294966266 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966266;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_51_50_;
    WL_PUSHN(2);
    } else {
    u64 task_1051 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_51_50_, WL_CONT, WL_IDX, 1);
    e.mem[task_1051 + 0] = v_4294966266;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_51_50_, task_1051);
    WL_IDX = 1;
    }
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_49_48_51_51_, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_51_50_)
  {
    WL_POPN(1);
    Term v_4294966266 = STK(0);
    Term v_4294966265 = r0;
    WL_OPEN
    { Term fn = v_4294966266; Term arg = v_4294966265;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_51_51_)
  {
    Term v_3470 = r0;
    WL_OPEN
    term_sink(e, v_3470);
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_49_48_51_54_;
    WL_PUSHN(1);
    } else {
    u64 task_1051 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_51_54_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_51_54_, task_1051);
    WL_IDX = 0;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_49_48_52_57_;
    WL_PUSHN(1);
    } else {
    u64 task_1051 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_52_57_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_52_57_, task_1051);
    WL_IDX = 0;
    }
    WL_JMP(FID_73_79_46_98_105_110_100_);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_51_54_)
  {
    Term v_4294966261 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966261;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_51_55_;
    WL_PUSHN(2);
    } else {
    u64 task_1047 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_51_55_, WL_CONT, WL_IDX, 1);
    e.mem[task_1047 + 0] = v_4294966261;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_51_55_, task_1047);
    WL_IDX = 1;
    }
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_49_48_51_56_, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_51_55_)
  {
    WL_POPN(1);
    Term v_4294966261 = STK(0);
    Term v_4294966260 = r0;
    WL_OPEN
    { Term fn = v_4294966261; Term arg = v_4294966260;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_51_56_)
  {
    Term v_3471 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_3471;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_52_49_;
    WL_PUSHN(2);
    } else {
    u64 task_1047 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_52_49_, WL_CONT, WL_IDX, 1);
    e.mem[task_1047 + 0] = v_3471;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_52_49_, task_1047);
    WL_IDX = 1;
    }
    WL_JMP(FID_73_79_46_112_114_105_110_116_);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_52_49_)
  {
    WL_POPN(1);
    Term v_3471 = STK(0);
    Term v_4294966256 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966256;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_52_50_;
    WL_PUSHN(2);
    } else {
    u64 task_1047 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_52_50_, WL_CONT, WL_IDX, 1);
    e.mem[task_1047 + 0] = v_4294966256;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_52_50_, task_1047);
    WL_IDX = 1;
    }
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_3471;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_52_53_;
    WL_PUSHN(2);
    } else {
    u64 task_1047 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_52_53_, WL_CONT, WL_IDX, 1);
    e.mem[task_1047 + 0] = v_3471;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_52_53_, task_1047);
    WL_IDX = 1;
    }
    WL_JMP(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_110_97_109_101_);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_52_50_)
  {
    WL_POPN(1);
    Term v_4294966256 = STK(0);
    Term v_4294966255 = r0;
    WL_OPEN
    { Term fn = v_4294966256; Term arg = v_4294966255;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_52_53_)
  {
    WL_POPN(1);
    Term v_3471 = STK(0);
    Term v_4294966252 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966252;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_52_54_;
    WL_PUSHN(2);
    } else {
    u64 task_1047 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_52_54_, WL_CONT, WL_IDX, 1);
    e.mem[task_1047 + 0] = v_4294966252;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_52_54_, task_1047);
    WL_IDX = 1;
    }
    r0 = v_3471;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_52_54_)
  {
    WL_POPN(1);
    Term v_4294966252 = STK(0);
    Term v_4294966251 = r0;
    WL_OPEN
    { Term fn = v_4294966252; Term arg = v_4294966251;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_52_57_)
  {
    Term v_4294966248 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966248;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_53_48_;
    WL_PUSHN(2);
    } else {
    u64 task_1051 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_53_48_, WL_CONT, WL_IDX, 1);
    e.mem[task_1051 + 0] = v_4294966248;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_53_48_, task_1051);
    WL_IDX = 1;
    }
    WL_JMP(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_110_);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_53_48_)
  {
    WL_POPN(1);
    Term v_4294966248 = STK(0);
    Term v_4294966247 = r0;
    WL_OPEN
    { Term fn = v_4294966248; Term arg = v_4294966247;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_53_51_)
  {
    WL_POPN(1);
    Term v_3469 = STK(0);
    Term v_4294966244 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966244;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_53_52_;
    WL_PUSHN(2);
    } else {
    u64 task_1063 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_53_52_, WL_CONT, WL_IDX, 1);
    e.mem[task_1063 + 0] = v_4294966244;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_53_52_, task_1063);
    WL_IDX = 1;
    }
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_3469;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_53_55_;
    WL_PUSHN(2);
    } else {
    u64 task_1063 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_53_55_, WL_CONT, WL_IDX, 1);
    e.mem[task_1063 + 0] = v_3469;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_53_55_, task_1063);
    WL_IDX = 1;
    }
    WL_JMP(FID_73_79_46_112_114_105_110_116_);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_53_52_)
  {
    WL_POPN(1);
    Term v_4294966244 = STK(0);
    Term v_4294966243 = r0;
    WL_OPEN
    { Term fn = v_4294966244; Term arg = v_4294966243;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_53_55_)
  {
    WL_POPN(1);
    Term v_3469 = STK(0);
    Term v_4294966240 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966240;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_53_56_;
    WL_PUSHN(2);
    } else {
    u64 task_1063 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_53_56_, WL_CONT, WL_IDX, 1);
    e.mem[task_1063 + 0] = v_4294966240;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_53_56_, task_1063);
    WL_IDX = 1;
    }
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_3469;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_54_49_;
    WL_PUSHN(2);
    } else {
    u64 task_1063 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_54_49_, WL_CONT, WL_IDX, 1);
    e.mem[task_1063 + 0] = v_3469;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_54_49_, task_1063);
    WL_IDX = 1;
    }
    WL_JMP(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_110_97_109_101_);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_53_56_)
  {
    WL_POPN(1);
    Term v_4294966240 = STK(0);
    Term v_4294966239 = r0;
    WL_OPEN
    { Term fn = v_4294966240; Term arg = v_4294966239;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_54_49_)
  {
    WL_POPN(1);
    Term v_3469 = STK(0);
    Term v_4294966236 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966236;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_54_50_;
    WL_PUSHN(2);
    } else {
    u64 task_1063 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_54_50_, WL_CONT, WL_IDX, 1);
    e.mem[task_1063 + 0] = v_4294966236;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_54_50_, task_1063);
    WL_IDX = 1;
    }
    r0 = v_3469;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_54_50_)
  {
    WL_POPN(1);
    Term v_4294966236 = STK(0);
    Term v_4294966235 = r0;
    WL_OPEN
    { Term fn = v_4294966236; Term arg = v_4294966235;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_54_53_)
  {
    Term v_4294966232 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294966232;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_49_48_54_54_;
    WL_PUSHN(2);
    } else {
    u64 task_1067 = task_node(e, FID_110_97_116_105_118_101_95_107_95_49_48_54_54_, WL_CONT, WL_IDX, 1);
    e.mem[task_1067 + 0] = v_4294966232;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_49_48_54_54_, task_1067);
    WL_IDX = 1;
    }
    WL_JMP(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_102_102_);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_49_48_54_54_)
  {
    WL_POPN(1);
    Term v_4294966232 = STK(0);
    Term v_4294966231 = r0;
    WL_OPEN
    { Term fn = v_4294966232; Term arg = v_4294966231;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_73_79_46_98_105_110_100_)
  {
    WL_OPEN
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_50_48_57_49_, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_48_57_49_)
  {
    Term v_180 = r0;
    WL_OPEN
    u64 cl_2109 = heap_alloc(e, cls_fit(1));
    e.mem[cl_2109 + 0] = v_180;
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_50_48_57_50_, cl_2109);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_48_57_50_)
  {
    Term v_180 = r0;
    Term v_181 = r1;
    WL_OPEN
    u64 cl_2108 = heap_alloc(e, cls_fit(2));
    e.mem[cl_2108 + 0] = v_180;
    e.mem[cl_2108 + 1] = v_181;
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_50_48_57_51_, cl_2108);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_48_57_51_)
  {
    Term v_180 = r0;
    Term v_181 = r1;
    Term v_183 = r2;
    WL_OPEN
    if (seq) {
    WL_ROOM(3);
    STK(0) = v_181;
    STK(1) = v_183;
    STK(2) = FID_110_97_116_105_118_101_95_107_95_50_48_57_54_;
    WL_PUSHN(3);
    } else {
    u64 task_2108 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_48_57_54_, WL_CONT, WL_IDX, 1);
    e.mem[task_2108 + 0] = v_181;
    e.mem[task_2108 + 1] = v_183;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_48_57_54_, task_2108);
    WL_IDX = 2;
    }
    r0 = v_180;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_48_57_54_)
  {
    WL_POPN(2);
    Term v_181 = STK(0);
    Term v_183 = STK(1);
    Term v_4294965201 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294965201;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_48_57_55_;
    WL_PUSHN(2);
    } else {
    u64 task_2108 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_48_57_55_, WL_CONT, WL_IDX, 1);
    e.mem[task_2108 + 0] = v_4294965201;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_48_57_55_, task_2108);
    WL_IDX = 1;
    }
    u64 cl_2107 = heap_alloc(e, cls_fit(2));
    e.mem[cl_2107 + 0] = v_181;
    e.mem[cl_2107 + 1] = v_183;
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_50_48_57_56_, cl_2107);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_48_57_55_)
  {
    WL_POPN(1);
    Term v_4294965201 = STK(0);
    Term v_4294965200 = r0;
    WL_OPEN
    { Term fn = v_4294965201; Term arg = v_4294965200;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_48_57_56_)
  {
    Term v_181 = r0;
    Term v_183 = r1;
    Term v_184 = r2;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_183;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_49_48_49_;
    WL_PUSHN(2);
    } else {
    u64 task_2107 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_48_49_, WL_CONT, WL_IDX, 1);
    e.mem[task_2107 + 0] = v_183;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_48_49_, task_2107);
    WL_IDX = 1;
    }
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_184;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_49_48_53_;
    WL_PUSHN(2);
    } else {
    u64 task_2107 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_48_53_, WL_CONT, WL_IDX, 1);
    e.mem[task_2107 + 0] = v_184;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_48_53_, task_2107);
    WL_IDX = 1;
    }
    r0 = v_181;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_48_49_)
  {
    WL_POPN(1);
    Term v_183 = STK(0);
    Term v_4294965196 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294965196;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_49_48_50_;
    WL_PUSHN(2);
    } else {
    u64 task_2103 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_48_50_, WL_CONT, WL_IDX, 1);
    e.mem[task_2103 + 0] = v_4294965196;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_48_50_, task_2103);
    WL_IDX = 1;
    }
    r0 = v_183;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_48_50_)
  {
    WL_POPN(1);
    Term v_4294965196 = STK(0);
    Term v_4294965195 = r0;
    WL_OPEN
    { Term fn = v_4294965196; Term arg = v_4294965195;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_48_53_)
  {
    WL_POPN(1);
    Term v_184 = STK(0);
    Term v_4294965192 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294965192;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_49_48_54_;
    WL_PUSHN(2);
    } else {
    u64 task_2107 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_48_54_, WL_CONT, WL_IDX, 1);
    e.mem[task_2107 + 0] = v_4294965192;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_48_54_, task_2107);
    WL_IDX = 1;
    }
    r0 = v_184;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_48_54_)
  {
    WL_POPN(1);
    Term v_4294965192 = STK(0);
    Term v_4294965191 = r0;
    WL_OPEN
    { Term fn = v_4294965192; Term arg = v_4294965191;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_36_100_105_114_101_99_116_46_73_79_46_98_105_110_100_)
  {
    Term v_180 = r0;
    Term v_181 = r1;
    Term v_183 = r2;
    WL_OPEN
    if (seq) {
    WL_ROOM(3);
    STK(0) = v_181;
    STK(1) = v_183;
    STK(2) = FID_110_97_116_105_118_101_95_107_95_50_49_49_50_;
    WL_PUSHN(3);
    } else {
    u64 task_2124 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_49_50_, WL_CONT, WL_IDX, 1);
    e.mem[task_2124 + 0] = v_181;
    e.mem[task_2124 + 1] = v_183;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_49_50_, task_2124);
    WL_IDX = 2;
    }
    r0 = v_180;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_49_50_)
  {
    WL_POPN(2);
    Term v_181 = STK(0);
    Term v_183 = STK(1);
    Term v_4294965185 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294965185;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_49_49_51_;
    WL_PUSHN(2);
    } else {
    u64 task_2124 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_49_51_, WL_CONT, WL_IDX, 1);
    e.mem[task_2124 + 0] = v_4294965185;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_49_51_, task_2124);
    WL_IDX = 1;
    }
    u64 cl_2123 = heap_alloc(e, cls_fit(2));
    e.mem[cl_2123 + 0] = v_181;
    e.mem[cl_2123 + 1] = v_183;
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_50_49_49_52_, cl_2123);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_49_51_)
  {
    WL_POPN(1);
    Term v_4294965185 = STK(0);
    Term v_4294965184 = r0;
    WL_OPEN
    { Term fn = v_4294965185; Term arg = v_4294965184;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_49_52_)
  {
    Term v_181 = r0;
    Term v_183 = r1;
    Term v_184 = r2;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_183;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_49_49_55_;
    WL_PUSHN(2);
    } else {
    u64 task_2123 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_49_55_, WL_CONT, WL_IDX, 1);
    e.mem[task_2123 + 0] = v_183;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_49_55_, task_2123);
    WL_IDX = 1;
    }
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_184;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_49_50_49_;
    WL_PUSHN(2);
    } else {
    u64 task_2123 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_50_49_, WL_CONT, WL_IDX, 1);
    e.mem[task_2123 + 0] = v_184;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_50_49_, task_2123);
    WL_IDX = 1;
    }
    r0 = v_181;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_49_55_)
  {
    WL_POPN(1);
    Term v_183 = STK(0);
    Term v_4294965180 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294965180;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_49_49_56_;
    WL_PUSHN(2);
    } else {
    u64 task_2119 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_49_56_, WL_CONT, WL_IDX, 1);
    e.mem[task_2119 + 0] = v_4294965180;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_49_56_, task_2119);
    WL_IDX = 1;
    }
    r0 = v_183;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_49_56_)
  {
    WL_POPN(1);
    Term v_4294965180 = STK(0);
    Term v_4294965179 = r0;
    WL_OPEN
    { Term fn = v_4294965180; Term arg = v_4294965179;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_50_49_)
  {
    WL_POPN(1);
    Term v_184 = STK(0);
    Term v_4294965176 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294965176;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_50_49_50_50_;
    WL_PUSHN(2);
    } else {
    u64 task_2123 = task_node(e, FID_110_97_116_105_118_101_95_107_95_50_49_50_50_, WL_CONT, WL_IDX, 1);
    e.mem[task_2123 + 0] = v_4294965176;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_50_49_50_50_, task_2123);
    WL_IDX = 1;
    }
    r0 = v_184;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_50_49_50_50_)
  {
    WL_POPN(1);
    Term v_4294965176 = STK(0);
    Term v_4294965175 = r0;
    WL_OPEN
    { Term fn = v_4294965176; Term arg = v_4294965175;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_102_102_)
  {
    WL_OPEN
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_51_49_52_56_, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_51_49_52_56_)
  {
    Term v_4294965170 = r0;
    WL_OPEN
    u64 nd_3149 = heap_alloc(e, cls_fit(1));
    e.mem[nd_3149 + 0] = rfc_seal(e, v_4294965170);
    r0 = term_ctr(CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_OFF, nd_3149);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_36_100_105_114_101_99_116_46_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_102_102_)
  {
    Term v_4294965170 = r0;
    WL_OPEN
    u64 nd_3150 = heap_alloc(e, cls_fit(1));
    e.mem[nd_3150 + 0] = rfc_seal(e, v_4294965170);
    r0 = term_ctr(CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_OFF, nd_3150);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_73_79_46_112_114_105_110_116_)
  {
    WL_OPEN
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_52_49_55_53_, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_52_49_55_53_)
  {
    Term v_4294964144 = r0;
    WL_OPEN
    u64 cl_4178 = heap_alloc(e, cls_fit(1));
    e.mem[cl_4178 + 0] = v_4294964144;
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_52_49_55_54_, cl_4178);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_52_49_55_54_)
  {
    Term v_4294964144 = r0;
    Term v_4294964142 = r1;
    WL_OPEN
    u64 nd_4177 = heap_alloc(e, cls_fit(2));
    e.mem[nd_4177 + 0] = rfc_seal(e, v_4294964144);
    e.mem[nd_4177 + 1] = rfc_seal(e, v_4294964142);
    r0 = term_ctr(CID_IO_PRINT, nd_4177);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_36_100_105_114_101_99_116_46_73_79_46_112_114_105_110_116_)
  {
    Term v_4294964144 = r0;
    Term v_4294964142 = r1;
    WL_OPEN
    u64 nd_4179 = heap_alloc(e, cls_fit(2));
    e.mem[nd_4179 + 0] = rfc_seal(e, v_4294964144);
    e.mem[nd_4179 + 1] = rfc_seal(e, v_4294964142);
    r0 = term_ctr(CID_IO_PRINT, nd_4179);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_110_97_109_101_)
  {
    WL_OPEN
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_53_50_48_53_, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_48_53_)
  {
    Term v_4294962091 = r0;
    WL_OPEN
    if ((term_aux(v_4294962091) == CID__CTOR_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_79_102_102_)) {
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_48_56_;
    WL_PUSHN(1);
    } else {
    u64 task_5227 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_48_56_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_48_56_, task_5227);
    WL_IDX = 0;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_50_54_;
    WL_PUSHN(1);
    } else {
    u64 task_5227 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_50_54_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_50_54_, task_5227);
    WL_IDX = 0;
    }
    r0 = 111ull;
    WL_RETN(1);
    } else {
    if ((term_aux(v_4294962091) == CID__CTOR_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_79_110_)) {
    Term fields[1];
    if (term_tag(v_4294962091) == TAG_PAK) { fields[0] = term_loc(v_4294962091); } else {
    spare_free(e, cls_fit(1), ctr_take(e, v_4294962091, 1, fields));
    }
    Term v_4294962068 = fields[0];
    term_sink(e, v_4294962068);
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_51_48_;
    WL_PUSHN(1);
    } else {
    u64 task_5242 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_51_48_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_51_48_, task_5242);
    WL_IDX = 0;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_52_49_;
    WL_PUSHN(1);
    } else {
    u64 task_5242 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_52_49_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_52_49_, task_5242);
    WL_IDX = 0;
    }
    r0 = 111ull;
    WL_RETN(1);
    } else {
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294962091;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_53_50_52_52_;
    WL_PUSHN(2);
    } else {
    u64 task_5246 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_52_52_, WL_CONT, WL_IDX, 1);
    e.mem[task_5246 + 0] = v_4294962091;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_52_52_, task_5246);
    WL_IDX = 1;
    }
    err_post(e.mem, ERR_FIDS); return 0;
    }
    }
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_48_56_)
  {
    Term v_4294962089 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294962089;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_53_50_48_57_;
    WL_PUSHN(2);
    } else {
    u64 task_5225 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_48_57_, WL_CONT, WL_IDX, 1);
    e.mem[task_5225 + 0] = v_4294962089;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_48_57_, task_5225);
    WL_IDX = 1;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_49_51_;
    WL_PUSHN(1);
    } else {
    u64 task_5225 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_49_51_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_49_51_, task_5225);
    WL_IDX = 0;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_50_52_;
    WL_PUSHN(1);
    } else {
    u64 task_5225 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_50_52_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_50_52_, task_5225);
    WL_IDX = 0;
    }
    r0 = 102ull;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_48_57_)
  {
    WL_POPN(1);
    Term v_4294962089 = STK(0);
    Term v_4294962088 = r0;
    WL_OPEN
    u64 nd_5210 = heap_alloc(e, cls_fit(2));
    e.mem[nd_5210 + 0] = rfc_seal(e, v_4294962089);
    e.mem[nd_5210 + 1] = rfc_seal(e, v_4294962088);
    r0 = term_ctr(CID_SCON, nd_5210);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_49_51_)
  {
    Term v_4294962084 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294962084;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_53_50_49_52_;
    WL_PUSHN(2);
    } else {
    u64 task_5223 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_49_52_, WL_CONT, WL_IDX, 1);
    e.mem[task_5223 + 0] = v_4294962084;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_49_52_, task_5223);
    WL_IDX = 1;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_49_56_;
    WL_PUSHN(1);
    } else {
    u64 task_5223 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_49_56_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_49_56_, task_5223);
    WL_IDX = 0;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_50_50_;
    WL_PUSHN(1);
    } else {
    u64 task_5223 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_50_50_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_50_50_, task_5223);
    WL_IDX = 0;
    }
    r0 = 102ull;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_49_52_)
  {
    WL_POPN(1);
    Term v_4294962084 = STK(0);
    Term v_4294962083 = r0;
    WL_OPEN
    u64 nd_5215 = heap_alloc(e, cls_fit(2));
    e.mem[nd_5215 + 0] = rfc_seal(e, v_4294962084);
    e.mem[nd_5215 + 1] = rfc_seal(e, v_4294962083);
    r0 = term_ctr(CID_SCON, nd_5215);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_49_56_)
  {
    Term v_4294962079 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294962079;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_53_50_49_57_;
    WL_PUSHN(2);
    } else {
    u64 task_5221 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_49_57_, WL_CONT, WL_IDX, 1);
    e.mem[task_5221 + 0] = v_4294962079;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_49_57_, task_5221);
    WL_IDX = 1;
    }
    r0 = term_pak(CID_SNIL, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_49_57_)
  {
    WL_POPN(1);
    Term v_4294962079 = STK(0);
    Term v_4294962078 = r0;
    WL_OPEN
    u64 nd_5220 = heap_alloc(e, cls_fit(2));
    e.mem[nd_5220 + 0] = rfc_seal(e, v_4294962079);
    e.mem[nd_5220 + 1] = rfc_seal(e, v_4294962078);
    r0 = term_ctr(CID_SCON, nd_5220);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_50_50_)
  {
    Term v_4294962074 = r0;
    WL_OPEN
    r0 = v_4294962074;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_50_52_)
  {
    Term v_4294962072 = r0;
    WL_OPEN
    r0 = v_4294962072;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_50_54_)
  {
    Term v_4294962070 = r0;
    WL_OPEN
    r0 = v_4294962070;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_51_48_)
  {
    Term v_4294962067 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294962067;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_53_50_51_49_;
    WL_PUSHN(2);
    } else {
    u64 task_5240 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_51_49_, WL_CONT, WL_IDX, 1);
    e.mem[task_5240 + 0] = v_4294962067;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_51_49_, task_5240);
    WL_IDX = 1;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_51_53_;
    WL_PUSHN(1);
    } else {
    u64 task_5240 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_51_53_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_51_53_, task_5240);
    WL_IDX = 0;
    }
    if (seq) {
    WL_ROOM(1);
    STK(0) = FID_110_97_116_105_118_101_95_107_95_53_50_51_57_;
    WL_PUSHN(1);
    } else {
    u64 task_5240 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_51_57_, WL_CONT, WL_IDX, 1);
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_51_57_, task_5240);
    WL_IDX = 0;
    }
    r0 = 110ull;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_51_49_)
  {
    WL_POPN(1);
    Term v_4294962067 = STK(0);
    Term v_4294962066 = r0;
    WL_OPEN
    u64 nd_5232 = heap_alloc(e, cls_fit(2));
    e.mem[nd_5232 + 0] = rfc_seal(e, v_4294962067);
    e.mem[nd_5232 + 1] = rfc_seal(e, v_4294962066);
    r0 = term_ctr(CID_SCON, nd_5232);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_51_53_)
  {
    Term v_4294962062 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294962062;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_53_50_51_54_;
    WL_PUSHN(2);
    } else {
    u64 task_5238 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_51_54_, WL_CONT, WL_IDX, 1);
    e.mem[task_5238 + 0] = v_4294962062;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_51_54_, task_5238);
    WL_IDX = 1;
    }
    r0 = term_pak(CID_SNIL, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_51_54_)
  {
    WL_POPN(1);
    Term v_4294962062 = STK(0);
    Term v_4294962061 = r0;
    WL_OPEN
    u64 nd_5237 = heap_alloc(e, cls_fit(2));
    e.mem[nd_5237 + 0] = rfc_seal(e, v_4294962062);
    e.mem[nd_5237 + 1] = rfc_seal(e, v_4294962061);
    r0 = term_ctr(CID_SCON, nd_5237);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_51_57_)
  {
    Term v_4294962057 = r0;
    WL_OPEN
    r0 = v_4294962057;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_52_49_)
  {
    Term v_4294962055 = r0;
    WL_OPEN
    r0 = v_4294962055;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_52_52_)
  {
    WL_POPN(1);
    Term v_4294962091 = STK(0);
    Term v_4294962053 = r0;
    WL_OPEN
    if (seq) {
    WL_ROOM(2);
    STK(0) = v_4294962053;
    STK(1) = FID_110_97_116_105_118_101_95_107_95_53_50_52_53_;
    WL_PUSHN(2);
    } else {
    u64 task_5246 = task_node(e, FID_110_97_116_105_118_101_95_107_95_53_50_52_53_, WL_CONT, WL_IDX, 1);
    e.mem[task_5246 + 0] = v_4294962053;
    WL_CONT = term_tsk(FID_110_97_116_105_118_101_95_107_95_53_50_52_53_, task_5246);
    WL_IDX = 1;
    }
    r0 = v_4294962091;
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_53_50_52_53_)
  {
    WL_POPN(1);
    Term v_4294962053 = STK(0);
    Term v_4294962052 = r0;
    WL_OPEN
    { Term fn = v_4294962053; Term arg = v_4294962052;
    Fid f = (Fid)term_aux(fn);
    if (!seq && fid_bangs(f)) {
      u32 war = fid_arity(f) - 1;
      Loc src = term_loc(fn);
      Loc dst = task_node(e, f, WL_CONT, WL_IDX, 0);
      for (u32 j = 0; j < war; ++j) e.mem[dst + j] = e.mem[src + j];
      e.mem[dst + war] = arg;
      spare_free(e, cls_fit(war), src);
      return term_tsk(f, dst);
    }
    r0 = fn; r1 = arg; WL_JMP(BEND_CLO_APPLY);
    }
    
  }}

  WL_CASE(FID_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_110_)
  {
    WL_OPEN
    r0 = term_clo(FID_110_97_116_105_118_101_95_107_95_54_50_55_48_, 0);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_110_97_116_105_118_101_95_107_95_54_50_55_48_)
  {
    Term v_4294962048 = r0;
    WL_OPEN
    u64 nd_6271 = heap_alloc(e, cls_fit(1));
    e.mem[nd_6271 + 0] = rfc_seal(e, v_4294962048);
    r0 = term_ctr(CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_ON, nd_6271);
    WL_RETN(1);
    
  }}

  WL_CASE(FID_36_100_105_114_101_99_116_46_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_116_97_103_46_111_110_)
  {
    Term v_4294962048 = r0;
    WL_OPEN
    u64 nd_6272 = heap_alloc(e, cls_fit(1));
    e.mem[nd_6272 + 0] = rfc_seal(e, v_4294962048);
    r0 = term_ctr(CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_ON, nd_6272);
    WL_RETN(1);
    
  }}



// A task enters through its words: a continuation's results ride r0.. and
// its parameters the stack; any other segment's parameters ride r0...
  WL_CASE(FID_ENTER)
  {
    Term t = r0;
    WL_OPEN
    Fid f   = (u32)term_aux(t);
    Loc a   = term_loc(t);
    u32 war = fid_arity(f);
    WL_FRAME(t)
    if (fid_seqk(f)) {
      u32 rw = fid_resw(f);
      WL_LOAD(a + war - rw, rw)
      WL_ARGS(a, war - rw + 1)
    } else {
      WL_LOAD(a, war)
    }
    heap_free(e, cls_fit(war + 2), a);
    WL_DYN(f);
  }}

  WL_CASE(FID_IO_EMIT)
  {
    Term x = r0;
    WL_OPEN
    Loc l = heap_alloc(e, 0);
    e.mem[l] = x;
    r0 = term_ctr(CID_EMIT, l);
    WL_RETN(1);
  }}

  WL_CASE(BEND_CLO_APPLY)
  {
    Term fun = r0;
    Term arg = r1;
    WL_OPEN
    Fid f    = (Fid)term_aux(fun);
    u32 war  = fid_arity(f) - 1;
    Loc a    = term_loc(fun);
    WL_LOAD(a, war)
    spare_free(e, cls_fit(war), a);
    WL_LAST(arg)
    WL_DYN(f);
  }}

  WL_CASE(FID_EXIT)
  {
    u32  n = rn;
    Term rv[WL_RESW];
    WL_SAVE(rv)
    WL_OPEN
    if (err_seen(e.mem)) {
      return 0;
    }
    sp -= 2 * LANE_STEP;
    Term cont = STK(0);
    u32  idx  = (u32)STK(1);
    if (cont != TERM_HOLE && fid_seqk((u32)term_aux(cont))) {
      Fid wf = (u32)term_aux(cont);
      Loc wa = term_loc(cont);
      u32 wn = fid_arity(wf);
      WL_FRAME(cont)
      WL_ARGS(wa, wn - n + 1)
      heap_free(e, cls_fit(wn + 2), wa);
      WL_TAKE(rv)
      WL_DYN(wf);
    }
    return task_deliver(e.mem, cont, idx, rv, n);
  }}

#if DEVICE
  default: {
    err_post(e.mem, ERR_FIDS);
    return 0;
  }
  }
  }
}
#endif

// Monk
// ====

// One turn on a ring: its head task below put0 runs (a growing lane skips
// a fork-free one). The host grows a row ring by ring and works a ring
// until it drains; a device lane does both.
INLINE u32 monk_step(Env e, Stk stk, Ring rg, u32 put0, bool seq, u32 base,
  u32 stride, Cur cur) {
  Corpus   H   = e.mem;
  DEV u32* get = ring_get(H, rg);
  if (*get == put0) {
    return 0;
  }
  DEV u32* lo = (DEV u32*)ring_slot(H, rg, *get);
  u32      hi = a32_load_acq(lo + 1);
  Term     t  = (((u64)hi << 32) | a32_load(lo)) & ~RFC_BIT;
  if ((hi >> 31) != ring_lap(*get) || (!seq && fid_nofk((u32)term_aux(t)))) {
    return 0;
  }
  a32_store(get, *get + 1);
  u32 spin = 0;
  for (;;) {
    Reply r = work_loop(e, stk, t, seq);
    if (r == 0) {
      return 2;
    }
    if ((u32)H[task_tail(r) + 1] == 0) {
      if (err_spun(H, &spin)) {
        return 2;
      }
      if (stride != 0 && fid_nofk((u32)term_aux(r))) {
        ring_push(H, ring_pick(base, stride, cur), r);
        return 2;
      }
      t      = r;
      seq    = false;
      stride = 0;
      continue;
    }
    task_deal(H, r, base, stride, cur);
    return 1;
  }
}

// Dev
// ===

// TG_HOLD words of threadgroup memory (lane 0's write keeps them) hold
// one group per Apple core: without them bitonic runs 1.35x, kmeans
// 1.19x, matmul 1.13x. A grow pass runs at most CUBE_T rounds, so a group
// that never fills still cuts at a kernel end.

#if DEVICE

INLINE void dev_cut(Env e) {
  if (err_seen(e.mem)) {
    return;
  }
  for (Cls c = 0; c < NCLS_ALL; c += 1) {
    u64 gen = (u64)KEEP(c) << c;
    while (ALC_LEN(e, c) >= gen) {
      Loc head = ALC_AT(e, c);
      Loc tail = head;
      for (u32 i = KEEP(c); --i;) {
        tail = e.mem[tail];
      }
      ALC_AT(e, c)    = e.mem[tail];
      ALC_LEN(e, c)  -= gen;
      e.mem[tail]     = 0;
      bank_push(e.mem, c, head);
    }
  }
}

// Pass 2, one group: each bank's [top, wr) slides onto rd, CUBE_T entries
// a step (loads, barrier, stores: rd <= top), off the host's pages.
INLINE void bank_pack(Corpus H, u32 lane) {
  for (Cls c = 0; c < NCLS_ALL; c += 1) {
    DEV Bank* b  = bank_at(H, c);
    u32       rd = b->rd;
    u32       n  = b->wr - b->top;
    for (u32 i = 0; i < n; i += CUBE_T) {
      Term v = i + lane < n ? H[b->off + b->top + i + lane] : 0;
      BAR();
      if (i + lane < n) {
        H[b->off + rd + i + lane] = v;
      }
    }
    BAR();
    if (lane == 0) {
      b->rd = b->wr = b->top = rd + n;
    }
  }
}

// One kernel, one pipeline: pass 0 grows the frontier (a task a lane a
// turn, votes between barriers), pass 1 works it (a lane drains its
// ring), pass 2 packs the banks; one call of monk_step, so the program
// compiles once.
#ifdef __METAL_VERSION__
kernel void bend_dev(Corpus H [[buffer(0)]], constant u32& pass [[buffer(1)]],
  threadgroup volatile u64* hold [[threadgroup(0)]],
  u32 grids [[threadgroups_per_grid]],
  u32 row [[threadgroup_position_in_grid]],
  u32 lane [[thread_position_in_threadgroup]]) {
#else
extern "C" __global__ void bend_dev(Corpus H, u32 pass) {
  extern __shared__ volatile u64 hold[];
  u32 grids = gridDim.x;
  u32 row   = blockIdx.x;
  u32 lane  = threadIdx.x;
#endif
  if (pass == 2) {
    bank_pack(H, lane);
    return;
  }
  u32  stride = grids == 1 ? CUBE_G : 1;
  u32  me     = row * CUBE_T + stride * lane;
  Ring rg     = pass ? ring_flip(me) : me;
  Env  e      = { H, H + ALC_OFF + me };
  Stk  stk    = (Stk)(H + STAK_OFF + me);
  if (lane == 0) {
    hold[0] = 0;
  }
  GA32 tg_cur, tg_grew, tg_has;
  g32_ini(&tg_cur);
  g32_ini(&tg_grew);
  g32_ini(&tg_has);
  BAR();
  u32 put0      = a32_load(ring_put(H, rg));
  u32 seen_has  = 0;
  u32 seen_grew = 0;
  for (u32 turn = 0; pass || turn < CUBE_T; turn += 1) {
    if (pass) {
      if (*ring_get(H, rg) == put0 || err_seen(H)) {
        break;
      }
    } else {
      put0 = a32_load(ring_put(H, rg));
      u32 vote = put0 != a32_load(ring_get(H, rg));
      if (lane == 0 && (err_seen(H) || root_done(H))) {
        vote = CUBE_T;
      }
      g32_add(&tg_has, vote);
      BAR();
      u32 has = g32_get(&tg_has);
      if (has - seen_has >= CUBE_T) {
        break;
      }
      seen_has = has;
    }
    u32 ran = monk_step(e, stk, rg, put0, pass, pass ? rg : row * CUBE_T,
      pass ? 0 : stride, &tg_cur);
    if (!pass) {
      if (ran == 1) {
        g32_add(&tg_grew, 1);
      }
      BARD();
      u32 grew = g32_get(&tg_grew);
      if (grew == seen_grew) {
        break;
      }
      seen_grew = grew;
    }
  }
  dev_cut(e);
}

#endif

// Window
// ======

// The Linux kit's fill, the Mac's window_msl in the runtime's dialect:
// a ! build carries window_dev in its cubin, a host build walks the
// pixels itself. An Image is a quadtree over 2^k x 2^k: a Qua at level
// i splits its square in four (tl, tr, bl, br), a Qua under the pixels
// follows tl, a Pix is 0xRRGGBB.
#if defined(__linux__) || defined(__CUDACC_RTC__)

INLINE u32 window_pix(Corpus H, Term t, u32 k, u32 x, u32 y) {
  for (u32 i = k; term_tag(t) == TAG_CTR;) {
    u32 j = 0;
    if (i > 0) {
      i -= 1;
      j = ((y >> i) & 1) * 2 + ((x >> i) & 1);
    }
    Loc l = term_rfc(t) ? H[term_loc(t)] >> 24 : term_loc(t);
    t = H[l + j];
  }
  return (u32)term_loc(t) & 0xFFFFFF;
}

#ifdef __CUDACC_RTC__
extern "C" __global__ void window_dev(Corpus H, Term root, u32 w, u32 h,
  u32 k, u32* out) {
  u32 x = blockIdx.x * blockDim.x + threadIdx.x;
  u32 y = blockIdx.y * blockDim.y + threadIdx.y;
  if (x < w && y < h) {
    out[y * w + x] = window_pix(H, root, k, x, y);
  }
}
#endif

#endif

#if !DEVICE

// Row
// ===

static void row_grow(Env e, Stk stk, u32 base, u32 stride, u32 want) {
  Corpus H = e.mem;
  u32 cur = 0;
  for (;;) {
    u32 put0[CUBE_T];
    u32 has = 0;
    for (u32 i = 0; i < CUBE_T; i += 1) {
      put0[i] = *ring_put(H, base + i * stride);
      has += put0[i] != *ring_get(H, base + i * stride);
    }
    if (root_done(H) || has >= want) {
      return;
    }
    u32 grew = 0;
    u32 ran  = 0;
    for (u32 i = 0; i < CUBE_T && ran != 2; i += 1) {
      ran   = monk_step(e, stk, base + i * stride, put0[i], false, base,
        stride, &cur);
      grew += ran == 1;
    }
    if (grew == 0) {
      return;
    }
  }
}

// Pool
// ====

static void* pool_try(void* at, u64 bytes) {
  return mmap(at, bytes, PROT_READ | PROT_WRITE,
    MAP_PRIVATE | MAP_ANON | MAP_NORESERVE, -1, 0);
}

static void* pool_mmap(u64 bytes) {
  void* p = pool_try(NULL, bytes);
  if (p == MAP_FAILED) {
    err_fail("reservation failed");
  }
  return p;
}

static Term* pool_stack(void) {
  u64   len = 1ull << 31;
  char* p   = pool_mmap(len + 16384 + SIGSTKSZ);
  if (mprotect(p + len, 16384, PROT_NONE) != 0) {
    err_fail("stack guard failed");
  }
  stack_t ss = { .ss_sp = p + len + 16384, .ss_size = SIGSTKSZ };
  sigaltstack(&ss, NULL);
  struct sigaction sa = { .sa_handler = err_trap, .sa_flags = SA_ONSTACK };
  sigaction(SIGSEGV, &sa, NULL);
  sigaction(SIGBUS, &sa, NULL);
  return (Term*)p;
}

static void* pool_work(void* arg) {
  Term* stk  = pool_stack();
  u64   seen = 0;
  for (;;) {
    pthread_mutex_lock(&pool_lock);
    while (atomic_load_explicit(&pool_tick, memory_order_acquire) == seen) {
      pthread_cond_wait(&pool_wake, &pool_lock);
    }
    pthread_mutex_unlock(&pool_lock);
    seen = atomic_load_explicit(&pool_tick, memory_order_acquire);
    Env e = { CORPUS, ALC[1 + (u32)(uintptr_t)arg] };
    for (;;) {
      u32 r = atomic_fetch_add_explicit(&pool_row, 1, memory_order_relaxed);
      if (r >= (pool_grow ? CUBE_G : LANES / LINE)) {
        break;
      }
      if (pool_grow) {
        row_grow(e, stk, r * CUBE_T, 1, CUBE_T);
      } else {
        for (u32 i = 0; i < LINE; i += 1) {
          Ring rg   = r * LINE + i;
          u32  put0 = a32_load(ring_put(e.mem, rg));
          while (*ring_get(e.mem, rg) != put0 && !err_seen(e.mem)) {
            monk_step(e, stk, rg, put0, true, rg, 0, NULL);
          }
        }
      }
    }
    u32 done = atomic_fetch_add_explicit(&pool_done, 1, memory_order_release);
    if (done + 1 == pool_size) {
      pthread_mutex_lock(&pool_lock);
      pthread_cond_broadcast(&pool_wake);
      pthread_mutex_unlock(&pool_lock);
    }
  }
}

OUTLINE void pool_open(void) {
  static bool up;
  if (up) {
    return;
  }
  up = true;
  for (u32 w = 0; w < pool_size; w += 1) {
    pthread_t tid;
    if (pthread_create(&tid, NULL, pool_work, (void*)(uintptr_t)w)) {
      err_fail("pthread_create");
    }
  }
}

// The CPUs this process may use: affinity mask under the cgroup quota
static int cpu_read(const char* path, long* a, long* b) {
  FILE* f = fopen(path, "r");
  int   n = f == NULL ? 0 : fscanf(f, "%ld %ld", a, b);
  if (f != NULL) {
    fclose(f);
  }
  return n;
}

static long cpu_count(void) {
  long n = sysconf(_SC_NPROCESSORS_ONLN);
#ifdef __linux__
  cpu_set_t set;
  if (sched_getaffinity(0, sizeof set, &set) == 0) {
    n = CPU_COUNT(&set);
  }
  long q = 0;
  long p = 0;
  if (cpu_read("/sys/fs/cgroup/cpu.max", &q, &p) != 2) {
    cpu_read("/sys/fs/cgroup/cpu/cpu.cfs_quota_us", &q, &p);
    cpu_read("/sys/fs/cgroup/cpu/cpu.cfs_period_us", &p, &p);
  }
  if (q > 0 && p > 0 && (q + p - 1) / p < n) {
    n = (q + p - 1) / p;
  }
#endif
  return n;
}

OUTLINE void pool_turn(bool grow) {
  pool_grow = grow;
  atomic_store_explicit(&pool_row, 0, memory_order_relaxed);
  atomic_store_explicit(&pool_done, 0, memory_order_relaxed);
  pthread_mutex_lock(&pool_lock);
  atomic_fetch_add_explicit(&pool_tick, 1, memory_order_release);
  pthread_cond_broadcast(&pool_wake);
  while (atomic_load_explicit(&pool_done, memory_order_acquire) < pool_size) {
    pthread_cond_wait(&pool_wake, &pool_lock);
  }
  pthread_mutex_unlock(&pool_lock);
}

// Gpu
// ===

// gpu_make compiles the device program and, given a path, writes it as
// <binary>.gpu (--gpu-build, run by bend -o): Metal's binary archive
// of the pipeline (keyed by the compiled function, so a wrong file
// misses), CUDA's cubin behind a hash of the text. A launch loads it,
// else notes and compiles (Metal's OS cache keeps that pipeline; CUDA
// writes the file).

static const char* gpu_path(void) {
  static char path[4096];
  u32 n = sizeof path - 8;
#ifdef __APPLE__
  _NSGetExecutablePath(path, &n);
#else
  path[readlink("/proc/self/exe", path, n)] = 0;
#endif
  return strcat(path, ".gpu");
}

static void gpu_note(const char* path) {
  fprintf(stderr, "bend: compiling the GPU program (%s is missing or"
    " stale)\n", path);
}

#if !BEND_CUDA
#define gpu_map pool_mmap
#endif

#if BEND_METAL || BEND_CUDA

static void gpu_kernel(u32 pass, u32 groups);

static void gpu_run(u32 f) {
  if (f < CUBE_T) {
    gpu_kernel(0, 1);
  }
  if (f < LANES) {
    gpu_kernel(0, CUBE_G);
  }
  gpu_kernel(1, CUBE_G);
  gpu_kernel(2, 1);
}

#endif

#if BEND_METAL

static bool gpu_probe(void) {
  return (gpu_dev = MTLCreateSystemDefaultDevice()) != nil;
}

static MTLComputePipelineDescriptor* gpu_desc(void) {
  NSError* err = nil;
  MTLCompileOptions* opts = [MTLCompileOptions new];
  opts.mathMode = MTLMathModeSafe;
  opts.preprocessorMacros = @{ @"CUBE_LOG": @(CUBE_LOG) };
  id<MTLLibrary> lib = [gpu_dev newLibraryWithSource:@(BEND_SRC) options:opts
    error:&err];
  if (!lib) {
    err_fail([[err localizedDescription] UTF8String]);
  }
  MTLComputePipelineDescriptor* d = [MTLComputePipelineDescriptor new];
  d.computeFunction = [lib newFunctionWithName:@"bend_dev"];
  return d;
}

static bool gpu_make(const char* path) {
  NSError* err = nil;
  id<MTLBinaryArchive> ar = [gpu_dev
    newBinaryArchiveWithDescriptor:[MTLBinaryArchiveDescriptor new] error:&err];
  if (![ar addComputePipelineFunctionsWithDescriptor:gpu_desc() error:&err]) {
    err_fail([[err localizedDescription] UTF8String]);
  }
  return [ar serializeToURL:[NSURL fileURLWithPath:@(path)] error:&err];
}

static id<MTLComputePipelineState> gpu_pipe(MTLComputePipelineDescriptor* d,
  id<MTLBinaryArchive> ar) {
  NSError* err = nil;
  d.binaryArchives = ar ? @[ar] : @[];
  id<MTLComputePipelineState> pso = [gpu_dev
    newComputePipelineStateWithDescriptor:d
    options:ar ? MTLPipelineOptionFailOnBinaryArchiveMiss : 0 reflection:nil
    error:&err];
  if (!pso && !ar) {
    err_fail([[err localizedDescription] UTF8String]);
  }
  return pso;
}

static u64 gpu_span(void) {
  u64 span = [gpu_dev recommendedMaxWorkingSetSize];
  u64 most = [gpu_dev maxBufferLength];
  span = span < most ? span : most;
  return span < (2ull << 30) ? span : 2ull << 30;
}

static void gpu_load(u64 bytes) {
  gpu_buf = [gpu_dev newBufferWithBytesNoCopy:CORPUS length:bytes
    options:MTLResourceStorageModeShared
      | MTLResourceHazardTrackingModeUntracked deallocator:nil];
  if (!gpu_buf) {
    err_fail("the GPU span is more than the device has");
  }
  @autoreleasepool {
    gpu_que = [gpu_dev newCommandQueue];
    const char* path = gpu_path();
    MTLBinaryArchiveDescriptor* ad = [MTLBinaryArchiveDescriptor new];
    ad.url = [NSURL fileURLWithPath:@(path)];
    MTLComputePipelineDescriptor* d = gpu_desc();
    id<MTLBinaryArchive> ar = [gpu_dev newBinaryArchiveWithDescriptor:ad
      error:nil];
    gpu_pso = ar ? gpu_pipe(d, ar) : nil;
    if (!gpu_pso) {
      gpu_note(path);
      gpu_pso = gpu_pipe(d, nil);
    }
  }
}

static void gpu_kernel(u32 pass, u32 groups) {
  [gpu_enc setComputePipelineState:gpu_pso];
  [gpu_enc setBuffer:gpu_buf offset:0 atIndex:0];
  [gpu_enc setBytes:&pass length:sizeof pass atIndex:1];
  [gpu_enc setThreadgroupMemoryLength:TG_HOLD * 8 atIndex:0];
  [gpu_enc dispatchThreadgroups:MTLSizeMake(groups, 1, 1)
    threadsPerThreadgroup:MTLSizeMake(CUBE_T, 1, 1)];
  [gpu_enc memoryBarrierWithScope:MTLBarrierScopeBuffers];
}

static void gpu_pass(u32 f) {
  @autoreleasepool {
    id<MTLCommandBuffer> cb = [gpu_que commandBuffer];
    gpu_enc = [cb computeCommandEncoder];
    gpu_run(f);
    [gpu_enc endEncoding];
    [cb commit];
    [cb waitUntilCompleted];
    if ([cb error]) {
      err_fail([[[cb error] localizedDescription] UTF8String]);
    }
  }
}

#elif BEND_CUDA

// the bag from the device: a group of 128 lanes per 64 KB of L2, a power of
// two from 16 to 128 groups. Apple keeps the 128 the bag was tuned on: on an
// M4 (10 cores) 32 groups ran bitonic 1.85 -> 1.29 s, but the light one-pass
// benches 1.25x, their lanes four times fewer.
static void gpu_shape(int units) {
  CUBE_LOG = 31 - CLZ(units < 16 ? 16 : units > 128 ? 128 : units);
}

static bool gpu_probe(void) {
  int       managed = 0;
  CUcontext ctx;
  // one stream, so one hardware queue: the default 8 each cost a channel
  // at context creation and teardown, about half of the startup
  setenv("CUDA_DEVICE_MAX_CONNECTIONS", "1", 0);
  if (cuInit(0) == CUDA_SUCCESS && cuDeviceGet(&gpu_dev, 0) == CUDA_SUCCESS) {
    cuDeviceGetAttribute(&managed,
      CU_DEVICE_ATTRIBUTE_CONCURRENT_MANAGED_ACCESS, gpu_dev);
  }
  int l2 = 1 << 23;
  cuDeviceGetAttribute(&l2, CU_DEVICE_ATTRIBUTE_L2_CACHE_SIZE, gpu_dev);
  gpu_shape(l2 >> 16);
  return managed != 0
    && cuDevicePrimaryCtxRetain(&ctx, gpu_dev) == CUDA_SUCCESS
    && cuCtxSetCurrent(ctx) == CUDA_SUCCESS;
}

static Corpus gpu_map(u64 bytes) {
  CUdeviceptr p = 0;
  if (cuMemAllocManaged(&p, bytes, CU_MEM_ATTACH_GLOBAL) != CUDA_SUCCESS) {
    err_fail("corpus reservation failed");
  }
#if CUDA_VERSION >= 13000
  cuMemAdvise(p, bytes, CU_MEM_ADVISE_SET_PREFERRED_LOCATION,
    (CUmemLocation){ CU_MEM_LOCATION_TYPE_DEVICE, gpu_dev });
#else
  cuMemAdvise(p, bytes, CU_MEM_ADVISE_SET_PREFERRED_LOCATION, gpu_dev);
#endif
  return (Corpus)(uintptr_t)p;
}

static u64 gpu_hash(void) {
  u64 key = 14695981039346656037ull ^ CUBE_LOG;
  for (const char* p = BEND_SRC; *p != 0; p += 1) {
    key = (key ^ (u8)*p) * 1099511628211ull;
  }
  return key;
}

static bool gpu_make(const char* path) {
  int cc[2] = {0, 0};
  cuDeviceGetAttribute(cc,
    CU_DEVICE_ATTRIBUTE_COMPUTE_CAPABILITY_MAJOR, gpu_dev);
  cuDeviceGetAttribute(cc + 1,
    CU_DEVICE_ATTRIBUTE_COMPUTE_CAPABILITY_MINOR, gpu_dev);
  char arch[40];
  char bag[24];
  snprintf(arch, sizeof arch, "--gpu-architecture=sm_%d%d", cc[0], cc[1]);
  snprintf(bag, sizeof bag, "-DCUBE_LOG=%u", CUBE_LOG);
  const char* opts[] = { arch, bag, "--fmad=false", "-default-device" };
  nvrtcProgram prog;
  if (nvrtcCreateProgram(&prog, BEND_SRC, "bend.cu", 0, NULL, NULL)
    != NVRTC_SUCCESS) {
    err_fail("cannot compile the CUDA library");
  }
  if (nvrtcCompileProgram(prog, 4, opts) != NVRTC_SUCCESS) {
    size_t n = 0;
    nvrtcGetProgramLogSize(prog, &n);
    char* log = calloc(n + 1, 1);
    if (log != NULL && nvrtcGetProgramLog(prog, log) == NVRTC_SUCCESS) {
      fprintf(stderr, "%s\n", log);
    }
    err_fail("cannot compile the CUDA library");
  }
  size_t len = 0;
  nvrtcGetCUBINSize(prog, &len);
  char* bin = malloc(len);
  if (bin == NULL || nvrtcGetCUBIN(prog, bin) != NVRTC_SUCCESS) {
    err_fail("cannot load the CUDA library");
  }
  nvrtcDestroyProgram(&prog);
  u64   key = gpu_hash();
  FILE* out = path == NULL ? NULL : fopen(path, "wb");
  bool  ok  = out != NULL && fwrite(&key, 8, 1, out) == 1
    && fwrite(bin, 1, len, out) == len && fclose(out) == 0;
  if (cuModuleLoadData(&gpu_lib, bin) != CUDA_SUCCESS) {
    err_fail("cannot load the CUDA library");
  }
  free(bin);
  return path == NULL || ok;
}

static u64 gpu_span(void) {
  size_t span = 0;
  cuDeviceTotalMem(&span, gpu_dev);
  return span;
}

static void gpu_load(u64 bytes) {
  const char* path = gpu_path();
  int         fd   = open(path, O_RDONLY);
  struct stat st   = { 0 };
  u64         key  = 0;
  char*       bin  = fd < 0 || fstat(fd, &st) != 0 || st.st_size <= 8 ? NULL
    : mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
  if (bin != NULL && bin != MAP_FAILED) {
    memcpy(&key, bin, 8);
  }
  if (key != gpu_hash()
    || cuModuleLoadData(&gpu_lib, bin + 8) != CUDA_SUCCESS) {
    gpu_note(path);
    gpu_make(path);
  }
  if (cuModuleGetFunction(&gpu_pso, gpu_lib, "bend_dev") != CUDA_SUCCESS) {
    err_fail("cannot load the GPU program");
  }
}

static void gpu_kernel(u32 pass, u32 groups) {
  void* args[] = { &CORPUS, &pass };
  if (cuLaunchKernel(gpu_pso, groups, 1, 1, CUBE_T, 1, 1, TG_HOLD * 8, NULL,
    args, NULL) != CUDA_SUCCESS) {
    err_fail("device launch failed");
  }
}

static void gpu_pass(u32 f) {
  gpu_run(f);
  if (cuCtxSynchronize() != CUDA_SUCCESS) {
    err_fail("device fault");
  }
}

#else

#define gpu_probe() false
#define gpu_make(p) true
#define gpu_span()  0
#define gpu_load(b)
#define gpu_pass(f)

#endif

// Cube
// ====

static void cube_run(Corpus H, bool gpu) {
  for (;;) {
    u32 f = a32_load(a32_at(H, H_CURSOR));
    a32_store(a32_at(H, H_CURSOR), 0);
    if (root_done(H)) {
      return;
    }
    if (f == 0) {
      err_fail("frontier drained without a result");
    }
    if (gpu) {
      gpu_pass(f);
    } else {
      // Each worker needs a row; a row has CUBE_T / LINE units.
      if (f < pool_size) {
        row_grow((Env){ H, ALC[0] }, io_stk, 0, CUBE_G, pool_size);
      }
      if (f < CUBE) {
        pool_turn(true);
      }
      pool_turn(false);
    }
    u32 ec = a32_load(a32_at(H, H_ERROR_CODE));
    if (ec != 0) {
      err_post(H, ec);
    }
  }
}

// Corpus
// ======

// The cores map 8 GiB at a high base and double it in place, a hint then
// a check (MAP_FIXED would replace a neighbour), so one base holds every
// Loc and a run pays for the room it reaches. The banks lie past the pages
// and move up at each step. The GPU maps its whole span once.

static u64 corpus_size;

static void* corpus_map(u64 size) {
  u64   hint = 1ull << 45;
  void* p    = pool_try((void*)hint, size);
  while (p != (void*)hint && hint > size) {
    if (p != MAP_FAILED) {
      munmap(p, size);
    }
    hint /= 2;
    p     = pool_try((void*)hint, size);
  }
  if (p == MAP_FAILED) {
    err_fail("reservation failed");
  }
  return p;
}

static void corpus_lay(Corpus H, u64 size) {
  u64 span = size / 8;
  u64 cap  = span > HEAP_OFF ? (span - HEAP_OFF) / (PAGE_LEN + 10) : 0;
  if (cap <= CUBE) {
    err_fail("the GPU span is under the rings, stacks and a page per lane");
  }
  cap = cap < ~0u ? cap : ~0u - 1;
  u64 at = HEAP_OFF + (cap << PAGE_BITS);
  for (u32 c = 0; c < NCLS_ALL; c += 1) {
    Bank* b = bank_at(H, c);
    memcpy(H + at, H + b->off, b->wr * sizeof(u64));
    b->off  = at;
    at     += 2 * (cap >> ((c < NCLS ? NCLS : c) - PAGE_BITS));
  }
  corpus_size = size;
  a32_store_rel(a32_at(H, H_CAP), (u32)cap);
}

static bool corpus_grow(Corpus H, u64 need) {
  bool ok = true;
  LOCK(bank_lock);
  while (ok && need > a32_load(a32_at(H, H_CAP))) {
    u64   more = corpus_size;
    char* at   = (char*)H + more;
    void* got  = io_gpu || more >= 1ull << 43 ? MAP_FAILED
      : pool_try(at, more);
    ok = got == at;
    if (ok) {
      corpus_lay(H, more * 2);
    } else if (got != MAP_FAILED) {
      munmap(got, more);
    }
  }
  UNLOCK(bank_lock);
  return ok;
}

static Corpus corpus_setup(bool gpu, long threads, u64 bytes) {
  io_gpu     = gpu;
  KEEP_WORDS = gpu ? CHUNK : CAP_WORDS;
  u64 dflt   = gpu ? gpu_span() : 1ull << 33;
  u64 size   = (gpu && bytes != 0 ? bytes : dflt) & ~16383ull;
  CORPUS     = gpu ? gpu_map(size) : corpus_map(size);
  Corpus H   = CORPUS;
#if BEND_CUDA
  if (gpu) {
    cuMemsetD8((CUdeviceptr)(uintptr_t)H, 0, STAK_OFF * 8);
    cuCtxSynchronize();
  }
#endif
  memcpy(H + STAT_OFF, STAT_IMG, STAT_LEN * sizeof(u64));
  corpus_lay(H, size);
  a32_store(a32_at(H, H_BUMP), 1);
  if (gpu) {
    gpu_load(size);
  }
  pool_size = threads < 1 ? 1 : threads < CUBE_T ? threads : CUBE_T;
  return H;
}

OUTLINE Term corpus_eval(Corpus H, Term t) {
  Env  e = { H, ALC[0] };
  Term rv[WL_RESW];
  for (;;) {
    Reply r = work_loop(e, io_stk, t, !BANGS
      && (pool_size == 1 || fid_nofk((u32)term_aux(t))));
    if (r == 0) {
      if (root_done(H)) {
        break;
      }
      err_fail("solo delivery lost");
    }
    if ((u32)H[task_tail(r) + 1] == 0) {
      t = r;
      if (io_gpu && fid_bangs((u32)term_aux(t))) {
        Loc  tl   = task_tail(t);
        Term cont = H[tl];
        u32  idx  = (u32)(H[tl + 1] >> 32) & 0xFFFF;
        H[tl]     = TERM_HOLE;
        a32_store(a32_at(H, H_CURSOR), 1);
        ring_push(H, 0, t);
        cube_run(H, true);
        Term p = task_deliver(H, cont, idx, rv, root_take(H, rv));
        if (root_done(H)) {
          break;
        }
        if (p == 0) {
          err_fail("seam delivery lost");
        }
        t = p;
      }
      continue;
    }
    task_deal(H, r, 0, 0, (Cur)0);
    pool_open();
    cube_run(H, false);
    break;
  }
  root_take(H, rv);
  return rv[0];
}

// Io
// ==

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/socket.h>

#define IO_READ 1
#define IO_TIME 2
#define IO_PARK TERM_HOLE

// A handle is its host value, a descriptor or a pointer, packed in one
// word (a pointer split over the aux and loc bits). Its type is a law of
// base, opaque and linear: a program cannot forge, copy or reuse one, so
// nothing stands between the value and the host.
#define io_hand(v)   term_make(TAG_PAK, (u64)(v) >> 40, (u64)(v) & LOC_MASK)
#define io_hand_v(t) (((u64)term_aux(t) << 40) | term_loc(t))

struct IoWork;
typedef void (*IoCall)(struct IoWork* w);
typedef Term (*IoPack)(Env e, struct IoWork* w);

// IoWork ::=
//   | IoWork(hand, made, word, size, data, text, code, call, pack)
typedef struct IoWork {
  intptr_t hand;
  intptr_t made;
  u32      word;
  u64      size;
  char*    data;
  char*    text;
  u32      code;
  IoCall   call;
  IoPack   pack;
} IoWork;

typedef Term (*Effect)(Env e, Term* f, IoWork* w);

// IoEff ::=
//   | IoEff(run, ask)
typedef struct {
  Effect run;
  u32    ask;
} IoEff;

static IoEff io_eff_rows[1 << 16];
static u32   io_live;

static u64 io_tick(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (u64)ts.tv_sec * 1000000000ull + (u64)ts.tv_nsec;
}

OUTLINE void* io_mem(void* mem) {
  if (mem == NULL) {
    err_fail("host allocation failed");
  }
  return mem;
}

static int io_sys_addr(const char* host, u32 port, struct sockaddr_in* at) {
  memset(at, 0, sizeof(*at));
  at->sin_family = AF_INET;
  at->sin_port   = htons((uint16_t)port);
  for (const char* p = host; *p != 0; p += 1) {
    bool zero = *p == '0' && p[1] >= '0' && p[1] <= '9';
    if ((p == host || p[-1] == '.') && zero) {
      return -1;
    }
  }
  return port > 65535 || inet_pton(AF_INET, host, &at->sin_addr) != 1
    ? -1 : 0;
}

// The program's arguments (IO.args).
static int    io_argc = 0;
static char** io_argv = NULL;

static void io_eff(u32 cid, Effect run, u32 need) {
  IoEff row = { run, need };
  io_eff_rows[cid] = row;
}

static u64 io_sys_end(IoWork* w, ssize_t n) {
  w->code = n < 0 ? (u32)errno : 0;
  return n < 0 ? 0 : (u64)n;
}

// A computation's activation for its whole life: cont over item is its
// next request; parked, work.word and time are its fd and deadline, evts
// what the fd must be ready for, and work.pack resumes it (io_exec runs
// cont, the request); work leads, so an effect's IoWork* is its activation.
// IoAct ::=
//   | IoAct(work, cont, item, time, evts, next)
typedef struct IoAct {
  IoWork        work;
  Term          cont;
  Term          item;
  u64           time;
  short         evts;
  struct IoAct* next;
} IoAct;

// IoQue ::=
//   | IoQue(head, last)
typedef struct {
  IoAct* head;
  IoAct* last;
} IoQue;

static IoQue io_runs;
static IoQue io_park;
static IoQue io_jobs;

static void io_push(IoQue* q, IoAct* a) {
  a->next = NULL;
  *(q->head == NULL ? &q->head : &q->last->next) = a;
  q->last = a;
}

static IoAct* io_pop(IoQue* q) {
  IoAct* a = q->head;
  q->head  = a->next;
  return a;
}

static void io_spawn(Term m) {
  IoAct* a = io_mem(calloc(1, sizeof(IoAct)));
  a->cont  = m;
  a->item  = term_clo(FID_IO_EMIT, 0);
  io_push(&io_runs, a);
  io_live += 1;
}

// Parks the effect's activation until fd is ready for evts (POLLIN or
// POLLOUT; 0 for no fd), or until time (a tick; 0 for no deadline),
// whichever comes first; the loop then calls more on its thread, whose
// value readies the activation, or IO_PARK, a re-park.
static Term io_wait_on(IoWork* w, int fd, short evts, u64 time, IoPack more) {
  IoAct* a     = (IoAct*)w;
  a->work.word = (u32)fd;
  a->work.pack = more;
  a->time      = time;
  a->evts      = evts;
  io_push(&io_park, a);
  return IO_PARK;
}

// the deadline a parked activation waits for (0 for none)
static u64 io_wait_time(IoWork* w) {
  return ((IoAct*)w)->time;
}

OUTLINE void io_out(FILE* h, const char* data, u64 len) {
  if (fwrite(data, 1, len, h) != len) {
    err_fail("a short write on a standard stream");
  }
}

OUTLINE void io_sync(void) {
  if (fflush(stdout) != 0) {
    err_fail("a short write on a standard stream");
  }
}

// the edge is UTF-8
static u64 io_utf8(char* buf, u64 c) {
  u64 k = c < 0x80 ? 1 : c < 0x800 ? 2 : c < 0x10000 ? 3 : 4;
  for (u64 i = k; i > 1; i -= 1) {
    buf[i - 1] = (char)(0x80 | (c & 0x3F));
    c >>= 6;
  }
  buf[0] = (char)(k == 1 ? c : (0xF00 >> k) | c);
  return k;
}

// io_cbuf writes a String (cons SCon) as UTF-8, or a List (cons Con) as
// its bytes, with no UTF-8: NULL if a value is past 255.
OUTLINE char* io_cbuf(Env e, Term s, u64* len, u64 cons) {
  u64   cap = 64;
  u64   n   = 0;
  u64   bad = 0;
  char* buf = io_mem(malloc(cap));
  while (term_aux(s) == cons) {
    Term fb[2];
    spare_free(e, cls_fit(2), ctr_take(e, s, 2, fb));
    if (n + 5 > cap) {
      cap *= 2;
      buf = io_mem(realloc(buf, cap));
    }
    if (cons == CID_SCON) {
      n += io_utf8(buf + n, fb[0]);
    } else {
      bad |= fb[0] > 255;
      buf[n++] = (char)fb[0];
    }
    s = fb[1];
  }
  buf[n] = 0;
  *len = n;
  if (bad) {
    free(buf);
    return NULL;
  }
  return buf;
}

#define io_cstr(e, s, len) io_cbuf(e, s, len, CID_SCON)

OUTLINE void io_errs(Env e, Term s) {
  u64   n    = 0;
  char* text = io_cstr(e, s, &n);
  io_sync();
  io_out(stderr, text, n);
  io_out(stderr, "\n", 1);
  free(text);
}

#define io_nul(s, n) (strlen(s) != (n))

#define io_seal(e, t, cid) (cid_hot(cid) ? rfc_seal(e, t) : (t))

static Term io_node(Env e, u64 cid, Term a, Term b) {
  Loc l = heap_alloc(e, 1);
  e.mem[l]     = io_seal(e, a, cid);
  e.mem[l + 1] = io_seal(e, b, cid);
  return term_ctr(cid, l);
}

// Bytes cross the IO boundary without UTF-8 decoding.
static Term io_list(Env e, const char* p, u64 n) {
  Term xs = term_pak(CID_NIL, 0);
  for (u64 i = n; i > 0; i -= 1) {
    xs = io_node(e, CID_CON, (uint8_t)p[i - 1], xs);
  }
  return xs;
}

// io_str decodes UTF-8 as WHATWG does: the lead byte sets the count of
// continuation bytes and the range of the second; a byte that breaks the
// sequence (or the end) yields one U+FFFD and is read again as a lead.
static Term io_str(Env e, const char* p, u64 n) {
  Term s    = term_pak(CID_SNIL, 0);
  Loc  hole = 0;
  u64  c = 0, need = 0, lo = 0x80, hi = 0xBF;
  for (u64 i = 0; i < n || need > 0; i += 1) {
    u64 b = i < n ? (uint8_t)p[i] : 0x100;
    if (need > 0 && (b < lo || b > hi)) {
      need = 0;
      c    = 0xFFFD;
      i   -= 1;
    } else if (need > 0) {
      lo = 0x80;
      hi = 0xBF;
      c  = (c << 6) | (b & 0x3F);
      if (--need > 0) {
        continue;
      }
    } else if (b < 0x80) {
      c = b;
    } else if (b < 0xC2 || b > 0xF4) {
      c = 0xFFFD;
    } else {
      need = b < 0xE0 ? 1 : b < 0xF0 ? 2 : 3;
      lo   = b == 0xE0 ? 0xA0 : b == 0xF0 ? 0x90 : 0x80;
      hi   = b == 0xED ? 0x9F : b == 0xF4 ? 0x8F : 0xBF;
      c    = b & (0x3F >> need);
      continue;
    }
    Loc  l = heap_alloc(e, 1);
    Term t = term_ctr(CID_SCON, l);
    e.mem[l] = c;
    if (hole == 0) {
      s = t;
    } else {
      e.mem[hole] = io_seal(e, t, CID_SCON);
    }
    hole = l + 1;
  }
  if (hole != 0) {
    e.mem[hole] = io_seal(e, term_pak(CID_SNIL, 0), CID_SCON);
  }
  return s;
}

#define io_tup(e, a, b) io_node(e, CID_TUPLE, a, b)
#define io_done(e, v)   io_box(e, CID_DONE, v)

static Term io_box(Env e, u64 cid, Term v) {
  Loc l = heap_alloc(e, 0);
  e.mem[l] = io_seal(e, v, cid);
  return term_ctr(cid, l);
}

static Term io_err(Env e, u32 code, const char* text) {
  const char* s = text != NULL ? text : strerror((int)code);
  return io_tup(e, code, io_str(e, s, strlen(s)));
}

static Term io_fail(Env e, u32 code, const char* text) {
  return io_box(e, CID_FAIL, io_err(e, code, text));
}

static lock           io_gate = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t io_bell = PTHREAD_COND_INITIALIZER;
static u32            io_busy;
static u32            io_size;
static int            io_wake_fd[2];

static void io_take(Env e) {
  IoAct*  acts[64];
  ssize_t n;
  while ((n = read(io_wake_fd[0], acts, sizeof acts)) > 0) {
    for (u32 i = 0; i < (u32)n / sizeof(IoAct*); i += 1) {
      IoAct* a = acts[i];
      a->item  = a->work.pack(e, &a->work);
      io_push(&io_runs, a);
      io_busy -= 1;
    }
  }
}

static void* io_help(void* arg) {
  for (;;) {
    pthread_mutex_lock(&io_gate);
    while (io_jobs.head == NULL) {
      pthread_cond_wait(&io_bell, &io_gate);
    }
    IoAct* a = io_pop(&io_jobs);
    pthread_mutex_unlock(&io_gate);
    a->work.call(&a->work);
    while (write(io_wake_fd[1], &a, sizeof a) != sizeof a) {
    }
  }
}

// A helper takes the effect's activation: call on its thread, then pack
// on the loop's, whose value readies the activation.
static Term io_work(IoWork* w, IoCall call, IoPack pack) {
  w->call  = call;
  w->pack  = pack;
  io_busy += 1;
  if (io_busy > io_size && io_size < IO_HELP) {
    pthread_t tid;
    if (pthread_create(&tid, NULL, io_help, NULL)) {
      err_fail("pthread_create");
    }
    pthread_detach(tid);
    io_size += 1;
  }
  pthread_mutex_lock(&io_gate);
  io_push(&io_jobs, (IoAct*)w);
  pthread_cond_signal(&io_bell);
  pthread_mutex_unlock(&io_gate);
  return IO_PARK;
}

// Runs the request in cont: the effect takes its fields (the node goes)
// and answers a value, which readies the activation, or IO_PARK, a moved.
static Term io_exec(Env e, IoWork* w) {
  IoAct* a = (IoAct*)w;
  Term   fs[256];
  u32    c = (u32)term_aux(a->cont);
  u32    n = cid_arity(c);
  spare_free(e, cls_fit(n), ctr_take(e, a->cont, n, fs));
  a->cont = fs[n - 1];
  return io_eff_rows[c].run(e, fs, w);
}

static void io_wait(Env e) {
  struct pollfd* fds = io_mem(malloc((io_live + 1) * sizeof *fds));
  u32 n    = 1;
  u64 soon = 0;
  int ms   = -1;
  fds[0].fd     = io_wake_fd[0];
  fds[0].events = POLLIN;
  for (IoAct* a = io_park.head; a != NULL; a = a->next) {
    if (a->time != 0) {
      soon = soon == 0 || a->time < soon ? a->time : soon;
    }
    if (a->evts != 0) {
      fds[n].fd     = (int)a->work.word;
      fds[n].events = a->evts;
      n += 1;
    }
  }
  if (soon != 0) {
    u64 now = io_tick();
    u64 gap = soon > now ? (soon - now) / 1000000 + 1 : 0;
    ms = gap > 0x7fffffff ? 0x7fffffff : (int)gap;
  }
  io_sync();
  while (poll(fds, n, ms) < 0) {
    if (errno != EINTR) {
      err_fail("the poller failed");
    }
  }
  if (fds[0].revents != 0) {
    io_take(e);
  }
  u64   now  = io_tick();
  u32   i    = 1;
  IoQue todo = io_park;
  io_park.head = NULL;
  io_park.last = NULL;
  while (todo.head != NULL) {
    IoAct* a   = io_pop(&todo);
    bool   due = (a->evts != 0 && fds[i].revents != 0)
      || (a->time != 0 && a->time <= now);
    i += a->evts != 0;
    if (!due) {
      io_push(&io_park, a);
      continue;
    }
    Term x = a->work.pack(e, &a->work);
    if (x != IO_PARK) {
      a->item = x;
      io_push(&io_runs, a);
    }
  }
  free(fds);
}

static int f32_text(char* buf, f32 v) {
  int n = 0;
  int p = 0;
  if (v != v) {
    return sprintf(buf, "nan");
  }
  for (; p < 9; p += 1) {
    n = snprintf(buf, 40, "%.*e", p, (double)v);
    if (strtof(buf, NULL) == v) {
      break;
    }
  }
  char* ep = strchr(buf, 'e');
  if (ep == NULL) {
    return n;
  }
  int ex = atoi(ep + 1);
  if (ex >= 21 || ex <= -7) {
    n = (int)(ep - buf) + sprintf(ep, "e%c%d", ex < 0 ? '-' : '+', abs(ex));
  } else if (ex <= p) {
    n = snprintf(buf, 40, "%.*f", p - ex, (double)v);
  } else {
    int s = *buf == '-';
    memmove(buf + s + 1, buf + s + 2, p);
    memset(buf + s + 1 + p, '0', ex - p);
    n = s + 1 + ex;
  }
  return n;
}

static Term f32_show(Env e, Term x) {
  char buf[40];
  return io_str(e, buf, f32_text(buf, f32_unbox(x)));
}

static Term f32_read(Env e, Term s) {
  u64 n = 0;
  char* text = io_cstr(e, s, &n);
  char* end;
  f32 v = strtof(text, &end);
  Term out = n > 0 && (u64)(end - text) == n && strpbrk(text, "xX(") == NULL
    ? io_box(e, CID_SOME, f32_rewrap(v)) : term_pak(CID_NONE, 0);
  free(text);
  return out;
}

// Show
// ====

#if MAIN_PURE

// A pure main's value, spelled as term_show spells it: d is a node of
// SHOW_DESC (see show_main), w the value's words. A boxed Data reads its
// arm by cid off a Term (packed, or a node), an inline one by tag off
// its words.
static void show_val(Env e, u32 d, const Term* w, char chain);

// char_show: an escape, a \u{hex}, else the code point in UTF-8
static void show_chr(u64 c, char q) {
  char b[4];
  int  k = c == 10 ? 'n' : c == 9 ? 't' : c == 13 ? 'r' : c == 0 ? '0'
    : c == 92 || c == (u64)q ? (int)c : 0;
  if (k != 0) {
    printf("\\%c", k);
  } else if (c < 32 || c == 127 || (c >= 0xD800 && c <= 0xDFFF)
    || c > 0x10FFFF) {
    printf("\\u{%llx}", (unsigned long long)c);
  } else {
    fwrite(b, 1, io_utf8(b, c), stdout);
  }
}

// The shortest text that reads back, as a literal: a point before an e
static void show_f32(u32 x) {
  char  buf[40];
  int   n  = f32_text(buf, f32_unbox(x));
  char* ep = memchr(buf, 'e', n);
  int   m  = ep == NULL ? n : (int)(ep - buf);
  buf[n] = 0;
  if (strpbrk(buf, ".ni") == NULL) {
    printf("%.*s.0%s", m, buf, buf + m);
  } else {
    fputs(buf, stdout);
  }
}

static void show_arr(Env e, u32 d, Term t, u32 lo, u32 c) {
  if (c > SHOW_DESC[d + 2]) {
    c -= 1;
    show_arr(e, d, t, lo, c);
    fputs(", ", stdout);
    show_arr(e, d, t, lo + (1u << c), c);
  } else {
    Term v[1u << c];
    for (u32 j = 0; j < 1u << c; j += 1) {
      v[j] = blk_read(e.mem, term_tag(t) == TAG_ARR, term_peek(e, t), lo + j);
    }
    show_val(e, SHOW_DESC[d + 1], v, 0);
  }
}

// chain is the bracket of the [a, b] or (a, b) this value continues, or
// 0: a Con or Nil spells a list, a Tuple a tuple, their tails continue
static void show_val(Env e, u32 d, const Term* w, char chain) {
  const u32* D = SHOW_DESC;
  Term one;
  char zs[4];
  u32  zn = 0;
  for (bool tail = true; tail;) switch (tail = false, D[d]) {
    case 0: printf("%u", (u32)w[0]); break;
    case 1: show_f32((u32)w[0]); break;
    case 2: printf("%llun", (unsigned long long)w[0]); break;
    case 3:
      putchar('\'');
      show_chr(D[d + 1] != 0 ? term_loc(w[0]) : w[0], '\'');
      putchar('\'');
      break;
    case 4:
      putchar('"');
      for (Term s = w[0]; term_aux(s) == CID_SCON;) {
        Loc l = term_peek(e, s);
        show_chr(e.mem[l], '"');
        s = e.mem[l + 1];
      }
      putchar('"');
      break;
    case 5: fputs("{==}", stdout); break;
    case 6:
      putchar('[');
      show_arr(e, d, w[0], 0, blk_cls(w[0]));
      putchar(']');
      break;
    default: {
      Term t   = w[0];
      bool box = D[d + 1] != 0;
      u32  key = box ? (u32)term_aux(t) : D[d + 2] > 1 ? (u32)t : 0;
      u32  a   = d + 3;
      for (u32 i = 0; box ? D[a + 1] != key : i != key; i += 1) {
        a += 3 + 2 * D[a + 2];
      }
      if (box) {
        one = term_loc(t);
        w   = term_tag(t) == TAG_PAK ? &one : e.mem + term_peek(e, t);
      }
      const char* k = SHOW_NAMES[D[a]];
      char o = '{';
      char z = '}';
      if (strcmp(k, "Con") == 0 || strcmp(k, "Nil") == 0) {
        o = '[';
        z = ']';
      } else if (strcmp(k, "Tuple") == 0) {
        o = '(';
        z = ')';
      }
      if (o == '{') {
        printf("%s{", k);
      } else if (chain != o) {
        putchar(o);
      }
      if (o == '{' || chain != o) {
        zs[zn++] = z;
      }
      for (u32 j = 0; j < D[a + 2]; j += 1) {
        if (o == '[' ? j == 0 && chain == o : j > 0) {
          fputs(", ", stdout);
        }
        if (j == 1 && o != '{') {
          tail  = true;
          chain = o;
          d     = D[a + 4 + 2 * j];
          w     = w + D[a + 3 + 2 * j];
        } else {
          show_val(e, D[a + 4 + 2 * j], w + D[a + 3 + 2 * j], 0);
        }
      }
    }
  }
  while (zn > 0) {
    putchar(zs[--zn]);
  }
}

#endif

// Current Base additions not yet implemented by this retained scheduler.
// Refuse on actual dispatch, before consuming any payload.
static const char* io_unavailable(u32 cid) {
  switch (cid) {
#ifdef CID_CHAN_TRY_SEND
    case CID_CHAN_TRY_SEND: return "native Chan.try_send is not implemented by the retained IO runtime";
#endif
#ifdef CID_CHAN_TRY_RECV
    case CID_CHAN_TRY_RECV: return "native Chan.try_recv is not implemented by the retained IO runtime";
#endif
#ifdef CID_TCP_TRY_ACCEPT
    case CID_TCP_TRY_ACCEPT: return "native TCP.try_accept is not implemented by the retained IO runtime";
#endif
#ifdef CID_TCP_TRY_SEND
    case CID_TCP_TRY_SEND: return "native TCP.try_send is not implemented by the retained IO runtime";
#endif
#ifdef CID_TCP_TRY_SEND_BYTES
    case CID_TCP_TRY_SEND_BYTES: return "native TCP.try_send_bytes is not implemented by the retained IO runtime";
#endif
#ifdef CID_TCP_TRY_RECV
    case CID_TCP_TRY_RECV: return "native TCP.try_recv is not implemented by the retained IO runtime";
#endif
#ifdef CID_TCP_TRY_RECV_BYTES
    case CID_TCP_TRY_RECV_BYTES: return "native TCP.try_recv_bytes is not implemented by the retained IO runtime";
#endif
#ifdef CID_UDP_TRY_SEND_TO
    case CID_UDP_TRY_SEND_TO: return "native UDP.try_send_to is not implemented by the retained IO runtime";
#endif
#ifdef CID_UDP_TRY_SEND_BYTES_TO
    case CID_UDP_TRY_SEND_BYTES_TO: return "native UDP.try_send_bytes_to is not implemented by the retained IO runtime";
#endif
#ifdef CID_UDP_TRY_RECV_FROM
    case CID_UDP_TRY_RECV_FROM: return "native UDP.try_recv_from is not implemented by the retained IO runtime";
#endif
#ifdef CID_UDP_TRY_RECV_BYTES_FROM
    case CID_UDP_TRY_RECV_BYTES_FROM: return "native UDP.try_recv_bytes_from is not implemented by the retained IO runtime";
#endif
#ifdef CID_UDP_SEND_BYTES_TO
    case CID_UDP_SEND_BYTES_TO: return "native UDP.send_bytes_to is not implemented by the retained IO runtime";
#endif
#ifdef CID_UDP_RECV_BYTES_FROM
    case CID_UDP_RECV_BYTES_FROM: return "native UDP.recv_bytes_from is not implemented by the retained IO runtime";
#endif
    default: return "an alien request";
  }
}

// The continuation applied to the item is the next request.
static int io_step(Env e, IoAct* a) {
  // Yield only after a completed effect: the activation owns its next item.
  u64 deadline = io_tick() + 4000000ull;
  for (;;) {
    Loc  ap  = task_node(e, BEND_CLO_APPLY, TERM_HOLE, 0, 0);
    e.mem[ap]     = a->cont;
    e.mem[ap + 1] = a->item;
    Term req = corpus_eval(e.mem, term_tsk(BEND_CLO_APPLY, ap));
    u32  c   = (u32)term_aux(req);
    Loc  at  = term_peek(e, req);
    if (c == CID_EMIT) {
      term_drop(e, req);
      free(a);
      io_live -= 1;
      return -1;
    }
    if (c == CID_HALT) {
      io_errs(e, e.mem[at + 1]);
      return (int)(u32)e.mem[at];
    }
    if (io_eff_rows[c].run == NULL) {
      err_fail(io_unavailable(c));
    }
    u32 need = io_eff_rows[c].ask;
    u32 word = (u32)(need & IO_READ ? io_hand_v(e.mem[at]) : e.mem[at]);
    a->cont  = req;
    if (need != 0) {
      io_wait_on(&a->work, (int)word, need & IO_READ ? POLLIN : 0,
        need & IO_TIME ? io_tick() + (u64)word * 1000000ull : 0, io_exec);
      return -1;
    }
    Term x = io_exec(e, &a->work);
    if (x == IO_PARK) {
      return -1;
    }
    a->item = x;
    if (io_tick() >= deadline) {
      io_push(&io_runs, a);
      return -1;
    }
  }
}

OUTLINE int io_loop(Corpus H) {
  Env e = { H, ALC[0] };
  io_stk = pool_stack();
  signal(SIGPIPE, SIG_IGN);
  if (pipe(io_wake_fd) | fcntl(io_wake_fd[0], F_SETFL, O_NONBLOCK)) {
    err_fail("the event loop failed to open");
  }
  Term m = corpus_eval(H, term_tsk(MAIN_FID, task_node(e, MAIN_FID,
    TERM_HOLE, 0, 0)));
#if MAIN_PURE
  show_val(e, 0, H + H_ROOT_WORD, 0);
  putchar('\n');
  return 0;
#endif
  io_spawn(m);
  for (u32 n = 0;; n += 1) {
    if (io_runs.head == NULL) {
      if (io_live == 0) {
        return 0;
      }
      if (io_park.head == NULL && io_busy == 0) {
        io_sync();
        fprintf(stderr, "bend: deadlock: every computation waits on a"
          " channel\n");
        return 1;
      }
      io_wait(e);
      continue;
    }
    if (io_busy != 0) {
      io_take(e);
    }
    int code = io_step(e, io_pop(&io_runs));
    if (code >= 0) {
      return code;
    }
  }
}

// Chan
// ====

// ChanRow ::=
//   | ChanRow(gen, next, room, size, head, live, shut, ring, wait)
typedef struct {
  u32   gen;
  u32   next;
  u32   room;
  u32   size;
  u32   head;
  u32   live;
  u32   shut;
  Term* ring;
  IoQue wait;
} ChanRow;

// A channel is Data: its handle is copied and may outlive the row, so it
// names the row by index and generation, a freed row waits on a list and
// comes back one generation up, and a stale copy finds no row (closed).
static ChanRow* chan_rows;
static u32      chan_len;
static u32      chan_idle = ~0u;

#define chan_some(e, v) io_box(e, CID_SOME, v)
#define chan_done(e)    io_done(e, term_pak(CID_UNIT, 0))

static Term chan_open(u32 room) {
  u32 i = chan_idle;
  if (i != ~0u) {
    chan_idle = chan_rows[i].next;
  } else {
    if (chan_len == 1u << 24) {
      err_fail("more than 16777216 channels at once");
    }
    if ((chan_len & (chan_len - 1)) == 0) {
      chan_rows = io_mem(realloc(chan_rows,
        (chan_len == 0 ? 1 : 2 * chan_len) * sizeof(ChanRow)));
    }
    i = chan_len;
    chan_len += 1;
    chan_rows[i].gen = 0;
  }
  ChanRow* row = &chan_rows[i];
  row->gen  += 1;
  row->room  = room;
  row->size  = 0;
  row->head  = 0;
  row->live  = 1;
  row->shut  = 0;
  row->ring  = room == 0 ? NULL : io_mem(malloc(room * sizeof(Term)));
  row->wait.head = NULL;
  row->wait.last = NULL;
  return io_hand(((u64)row->gen << 24) | i);
}

static ChanRow* chan_at(Term t) {
  u64      v   = io_hand_v(t);
  u32      i   = (u32)v & 0xFFFFFF;
  ChanRow* row = i < chan_len ? &chan_rows[i] : NULL;
  return row != NULL && row->live && row->gen == (u32)(v >> 24) ? row : NULL;
}

// Parks the effect's activation on row with item: a sent value, or
// TERM_HOLE for a receiver.
static Term chan_park(ChanRow* row, IoWork* w, Term item) {
  IoAct* a = (IoAct*)w;
  a->item  = item;
  io_push(&row->wait, a);
  return IO_PARK;
}

static Term chan_wake(ChanRow* row, Term x) {
  IoAct* a  = io_pop(&row->wait);
  Term item = a->item;
  a->item   = x;
  io_push(&io_runs, a);
  return item;
}

static Term chan_take(Env e, ChanRow* row) {
  Term v = row->ring[row->head];
  row->head = (row->head + 1) % row->room;
  row->size -= 1;
  if (row->wait.head != NULL) {
    Term item = chan_wake(row, chan_done(e));
    row->ring[(row->head + row->size) % row->room] = item;
    row->size += 1;
  }
  return v;
}

static void chan_free(ChanRow* row) {
  free(row->ring);
  row->live = 0;
  row->next = chan_idle;
  chan_idle = (u32)(row - chan_rows);
}

static void chan_shut(Env e, ChanRow* row) {
  row->shut = 1;
  while (row->wait.head != NULL) {
    Term item = row->wait.head->item;
    Term x = item == TERM_HOLE ? term_pak(CID_NONE, 0)
      : io_box(e, CID_FAIL, item);
    chan_wake(row, x);
  }
  if (row->size == 0) {
    chan_free(row);
  }
}

// Foreign C ABI: current helpers coexist with the retained runtime's API.
// This section is host-only; device code and prior runtime calls keep their
// original Env-based helper. Only mem is read by term_peek/rfc_view.
INLINE Loc term_peek_corpus(Corpus H, Term t) {
  Env e = { H, NULL };
  return term_peek(e, t);
}
#define term_peek(H, t) _Generic((H), Env: term_peek, default: term_peek_corpus)((H), (t))
// This runtime permits shared blocks, so always follow its redirect cell.
#define blk_loc(H, t) term_peek((H), (t))

// New foreign sources register immediate effects with two arguments; the
// third argument is retained for existing vendored readiness/timer effects.
static void io_eff_default(u32 cid, Effect run) {
  io_eff(cid, run, 0);
}
#define BEND_IO_EFF_PICK(_1, _2, _3, F, ...) F
#define io_eff(...) BEND_IO_EFF_PICK(__VA_ARGS__, io_eff, io_eff_default, 0)(__VA_ARGS__)

// Requests
// ========

#pragma push_macro("CID_OFF")
#define CID_OFF CID__CTOR_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_79_102_102_
#pragma push_macro("CID_ON")
#define CID_ON CID__CTOR_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_79_110_
#pragma push_macro("CID_TAG_OFF")
#define CID_TAG_OFF CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_OFF
#pragma push_macro("CID_TAG_ON")
#define CID_TAG_ON CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_ON
// Tag
// ===

// The macros are this module's spelling, from wherever the program sits.
Term tag_off_run(Env e, Term* f, IoWork* w) {
  return term_pak(CID__CTOR_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_79_102_102_, 0);
}

Term tag_on_run(Env e, Term* f, IoWork* w) {
  return term_pak(CID__CTOR_109_97_114_115_104_97_108_95_105_109_112_111_114_116_101_100_95_110_117_108_108_97_114_121_95_116_121_112_101_58_79_110_, 3);
}

static void __attribute__((constructor)) tag_use(void) {
  io_eff(CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_OFF, tag_off_run);
  io_eff(CID_MARSHAL_IMPORTED_NULLARY_TYPE_TAG_ON, tag_on_run);
}

#pragma pop_macro("CID_OFF")
#pragma pop_macro("CID_ON")
#pragma pop_macro("CID_TAG_OFF")
#pragma pop_macro("CID_TAG_ON")

// IO
// ==

void io_print(const char* data, uint64_t len) {
  io_out(stdout, data, len);
  io_out(stdout, "\n", 1);
}

Term io_print_run(Env e, Term* f, IoWork* w) {
  uint64_t n = 0;
  char* text = io_cstr(e, f[0], &n);
  io_print(text, n);
  free(text);
  return term_pak(CID_UNIT, 0);
}

static void __attribute__((constructor)) io_print_use(void) {
  io_eff(CID_IO_PRINT, io_print_run, 0);
}


// Cli
// ===

static void cli_fail(const char* msg, const char* arg) {
  fprintf(stderr, "bend: %s%s\n", msg, arg != NULL ? arg : "");
  exit(1);
}

// Main
// ====

// Deterministic syscall boundary for the exact staged tcp_send.c provider.
#include <assert.h>
static int test_mode, test_calls;
static ssize_t native_test_send(int fd, const void* data, size_t size, int flags) {
  (void)flags;
  assert(fd == 17);
  test_calls += 1;
  if (test_mode == 5) {
    return test_calls == 1 ? 1 : (ssize_t)size;
  }
  if (test_mode == 4 || test_calls > 1) {
    errno = EPIPE;
    return -1;
  }
  return test_mode == 0 ? 2 : 1;
}
#define send native_test_send
// Phase66: current Base blocking result ABI on the retained IoAct scheduler.
// Adapted from upstream b2111cf43244e65f76ddc278ee695e669f720cbf.
// Uses the retained selfhost runtime and its CID_* constructor ABI.
// TCP
// ===

// Sends what is left; a full socket (non-blocking, so EAGAIN) parks the
// computation until the socket is writable, and the loop resumes here.
static Term tcp_send_with(Env e, IoWork* w, IoPack more,
  Term (*make)(Env, const char*, u64)) {
  int fd = (int)w->hand;
  while (w->code == 0 && (u64)w->made < w->size) {
    ssize_t n = send(fd, w->data + w->made, w->size - (u64)w->made, 0);
    if (n < 0 && errno == EAGAIN) {
      return io_wait_on(w, fd, POLLOUT, 0, more);
    }
    w->made += io_sys_end(w, n);
  }
  Term r = w->code != 0 ? io_box(e, CID_FAIL, io_tup(e,
      io_err(e, w->code, NULL), make(e, w->data + w->made, w->size - (u64)w->made)))
    : io_done(e, term_pak(CID_UNIT, 0));
  free(w->data);
  return io_tup(e, io_hand(w->hand), r);
}

static Term tcp_send_more(Env e, IoWork* w) {
  return tcp_send_with(e, w, tcp_send_more, io_str);
}

#ifdef CID_TCP_SEND

Term tcp_send_run(Env e, Term* f, IoWork* w) {
  w->hand = (intptr_t)io_hand_v(f[0]);
  w->data = io_cstr(e, f[1], &w->size);
  w->made = 0;
  w->code = 0;
  return tcp_send_more(e, w);
}

static void __attribute__((constructor)) tcp_send_use(void) {
  io_eff(CID_TCP_SEND, tcp_send_run, 0);
}

#endif

#ifdef CID_TCP_SEND_BYTES

static Term tcp_send_bytes_more(Env e, IoWork* w) {
  return tcp_send_with(e, w, tcp_send_bytes_more, io_list);
}

// Validate before consuming: failure must return the exact original list.
Term tcp_send_bytes_run(Env e, Term* f, IoWork* w) {
  w->hand = (intptr_t)io_hand_v(f[0]);
  for (Term s = f[1]; term_aux(s) == CID_CON;) {
    Loc at = term_peek(e, s);
    if (e.mem[at] > 255) {
      return io_tup(e, f[0], io_box(e, CID_FAIL,
        io_tup(e, io_err(e, EINVAL, NULL), f[1])));
    }
    s = e.mem[at + 1];
  }
  w->data = io_cbuf(e, f[1], &w->size, CID_CON);
  w->made = 0;
  w->code = 0;
  return tcp_send_bytes_more(e, w);
}

static void __attribute__((constructor)) tcp_send_bytes_use(void) {
  io_eff(CID_TCP_SEND_BYTES, tcp_send_bytes_run, 0);
}

#endif
#undef send

static Term test_field(Env e, Term t, u32 index) {
  return e.mem[term_peek(e, t) + index];
}
static void test_items(Env e, Term t, u64 cons, const u32* items, u32 size) {
  for (u32 i = 0; i < size; i += 1) {
    assert(term_aux(t) == cons);
    assert(test_field(e, t, 0) == items[i]);
    t = test_field(e, t, 1);
  }
  assert(term_aux(t) == (cons == CID_CON ? CID_NIL : CID_SNIL));
}
static Term test_result(Env e, Term pair, u64 kind) {
  assert(term_aux(pair) == CID_TUPLE);
  assert(io_hand_v(test_field(e, pair, 0)) == 17);
  Term result = test_field(e, pair, 1);
  assert(term_aux(result) == kind);
  return test_field(e, result, 0);
}
static Term test_failure(Env e, Term pair, u32 code) {
  Term failure = test_result(e, pair, CID_FAIL);
  assert(term_aux(failure) == CID_TUPLE);
  Term error = test_field(e, failure, 0);
  assert(term_aux(error) == CID_TUPLE);
  assert(test_field(e, error, 0) == code);
  return test_field(e, failure, 1);
}
static Term test_send(Env e, int mode, bool bytes, Term data) {
  test_mode = mode;
  test_calls = 0;
  IoWork work = {0};
  Term fields[] = { io_hand(17), data };
  return bytes ? tcp_send_bytes_run(e, fields, &work) : tcp_send_run(e, fields, &work);
}
int main(void) {
  Corpus H = corpus_setup(false, 1, 0);
  Env e = { H, ALC[0] };
  u32 passed = 0;

  Term p = test_send(e, 0, false, io_str(e, "abcdef", 6));
  const u32 suffix[] = { 'c', 'd', 'e', 'f' };
  test_items(e, test_failure(e, p, EPIPE), CID_SCON, suffix, 4);
  assert(test_calls == 2); term_drop(e, p); passed += 1;

  const char raw[] = { 0, (char)255, 7, 8 };
  p = test_send(e, 1, true, io_list(e, raw, 4));
  const u32 bytes[] = { 255, 7, 8 };
  test_items(e, test_failure(e, p, EPIPE), CID_CON, bytes, 3);
  assert(test_calls == 2); term_drop(e, p); passed += 1;

  Term invalid = io_node(e, CID_CON, 1,
    io_node(e, CID_CON, 256, term_pak(CID_NIL, 0)));
  Loc original = term_peek(e, invalid);
  p = test_send(e, 2, true, invalid);
  const u32 bad[] = { 1, 256 };
  Term kept = test_failure(e, p, EINVAL);
  assert(term_peek(e, kept) == original);
  test_items(e, kept, CID_CON, bad, 2);
  assert(test_calls == 0); term_drop(e, p); passed += 1;

  p = test_send(e, 3, false, io_str(e, "\xc3\xa1z", 3));
  const u32 split_utf8[] = { 0xfffd, 'z' };
  test_items(e, test_failure(e, p, EPIPE), CID_SCON, split_utf8, 2);
  assert(test_calls == 2); term_drop(e, p); passed += 1;

  p = test_send(e, 4, false, io_str(e, "all", 3));
  const u32 complete[] = { 'a', 'l', 'l' };
  test_items(e, test_failure(e, p, EPIPE), CID_SCON, complete, 3);
  assert(test_calls == 1); term_drop(e, p); passed += 1;

  p = test_send(e, 5, false, io_str(e, "sent", 4));
  assert(term_aux(test_result(e, p, CID_DONE)) == CID_UNIT);
  assert(test_calls == 2); term_drop(e, p); passed += 1;

  p = test_send(e, 6, true, term_pak(CID_NIL, 0));
  assert(term_aux(test_result(e, p, CID_DONE)) == CID_UNIT);
  assert(test_calls == 0); term_drop(e, p); passed += 1;

  printf("native blocking ABI controls %u passed\n", passed);
  return 0;
}

int retained_bend_main(int argc, char** argv) {
  long thr = 0;
  int  gpu = -1;
  u64  mem = 0;
  io_argv = argv + 1;
  for (int i = 1; i < argc; i += 1) {
    const char* a = argv[i];
    const char* v = i + 1 < argc ? argv[i + 1] : NULL;
    if (strcmp(a, "--") == 0) {
      while (i + 1 < argc) {
        io_argv[io_argc++] = argv[++i];
      }
    } else if (strcmp(a, "--help") == 0) {
      printf(CLI_HELP, argv[0]);
      return 0;
    } else if (strcmp(a, "--gpu-build") == 0) {
      if (gpu_probe() && !gpu_make(gpu_path())) {
        cli_fail("cannot write ", gpu_path());
      }
      return 0;
    } else if (strcmp(a, "--threads") == 0) {
      char* end = NULL;
      thr = v != NULL ? strtol(v, &end, 10) : 0;
      if (thr < 1 || end == NULL || *end != '\0') {
        cli_fail("expected a thread count of 1 or more after --threads", NULL);
      }
      i += 1;
    } else if (strcmp(a, "--gpu") == 0) {
      char*  end = NULL;
      double n   = v != NULL ? strtod(v, &end) : 0;
      u64    mul = end == NULL ? 0 : strcmp(end, "GB") == 0 ? 1ull << 30
        : strcmp(end, "MB") == 0 ? 1ull << 20 : 0;
      if (v != NULL && strcmp(v, "off") == 0) {
        gpu = 0;
      } else if (v != NULL && (strcmp(v, "on") == 0 || (mul != 0 && n > 0))) {
        gpu = 1;
        mem = (u64)(n * (double)mul);
      } else {
        cli_fail("expected on, off or a size like 4GB after --gpu", NULL);
      }
      i += 1;
    } else {
      io_argv[io_argc++] = argv[i];
    }
  }
  bool dev = gpu != 0 && BANGS != 0 && gpu_probe();
  if (gpu == 1 && BANGS != 0 && !dev) {
    cli_fail("--gpu on, but this binary found no GPU device", NULL);
  }
  Corpus H  = corpus_setup(dev, thr > 0 ? thr : cpu_count(), mem);
  int code  = io_loop(H);
  io_sync();
  return code;
}

#endif
