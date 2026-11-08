#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#define WL_PORTABLE 1
#define BEND_CPROC 0
#define BEND_METAL 0
#define BEND_CUDA 0
#include "runtime.h"

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
#if !WL_PORTABLE && __has_attribute(preserve_none) && __has_attribute(preserve_most) \
  && defined(__OPTIMIZE__)
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
#if WL_PORTABLE
// Segment transitions return to one invocation-local dispatcher. Ordinary
// segment returns keep their original scheduler Reply meaning.
#define WL_FN      static __attribute__((noinline)) Reply
// WL_CASE opens the function; the emitted block captures incoming arguments
// before WL_OPEN resets the same local register bank for outgoing values.
#define WL_CASE(F) WL_FN WL_##F(WlState* wl) { \
  Env e = wl->e; Stk sp = wl->sp; u32 seq = wl->seq; u32 rn = wl->rn; \
  WL_BANK WL_READ_STATE(wl->regs)
#define WL_OPEN    rn = 0; WL_INIT_BANK
#define WL_JMP(F)  do { \
  wl->e = e; wl->sp = sp; wl->seq = seq; wl->rn = rn; \
  WL_WRITE_STATE(wl->regs) \
  wl->next = (F); return 0; \
} while (0)
#define WL_DYN(F) WL_JMP(F)
#else
#define WL_FN      static PRESERVE(preserve_none) __attribute__((noinline)) Reply
#define WL_CASE(F) WL_FN WL_##F(WL_SIG)
#define WL_OPEN    { WL_BANK u32 rn;
#define WL_JMP(F)  __attribute__((musttail)) return WL_##F(WL_ALL)
#define WL_DYN(F)  __attribute__((musttail)) return wl_tab[F](WL_ALL)
#endif
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

typedef P111Env Env;

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
#if BEND_CPROC
_Alignas(128) static u64 ALC[CUBE_T + 1][3 * ALC_WORDS];
#else
static u64    ALC[CUBE_T + 1][3 * ALC_WORDS] __attribute__((aligned(128)));
#endif
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
  "usage: %s [+RTS options -RTS] [arguments]\n"
  "  --threads N       worker threads, 1 to 128 (default: the CPU count)\n"
  "  --gpu on|off|4GB  run ! calls on the GPU, over this much of its memory\n"
  "                    (default: on if present, over 2GB on Metal)\n"
  "  --gpu-build       write the GPU program and exit\n"
  "  --help            show this text\n"
  "  --RTS             pass the remaining arguments literally\n";

#endif

// Tables
// ======

/* Program-dependent tables move into the authenticated QBE descriptor. */
static const P111Program *p111_program_active;
static uint32_t p182_exit_cid = UINT32_MAX;
/* Logical transport width only. Physical banks and WL_RESW stay at 256 so the
 * public state and corpus/static layout remain ABI-identical. Bound once before
 * any segment runs; stale slots above this width never carry live arguments. */
static uint32_t p111_transport_words;
static uint32_t p111_core_cids[18];
static const char *const p111_core_names[18] = {
  "SNil", "SCon", "WNil", "WCon", "Nil", "Con", "Tuple", "Unit",
  "None", "Some", "Fail", "Done", "Emit", "Halt", "True", "LT", "EQ", "GT"
};
#define CID_SNIL p111_core_cids[0]
#define CID_SCON p111_core_cids[1]
#define CID_WNIL p111_core_cids[2]
#define CID_WCON p111_core_cids[3]
#define CID_NIL p111_core_cids[4]
#define CID_CON p111_core_cids[5]
#define CID_TUPLE p111_core_cids[6]
#define CID_UNIT p111_core_cids[7]
#define CID_NONE p111_core_cids[8]
#define CID_SOME p111_core_cids[9]
#define CID_FAIL p111_core_cids[10]
#define CID_DONE p111_core_cids[11]
#define CID_EMIT p111_core_cids[12]
#define CID_HALT p111_core_cids[13]
#define CID_TRUE p111_core_cids[14]
#define CID_LT p111_core_cids[15]
#define CID_EQ p111_core_cids[16]
#define CID_GT p111_core_cids[17]
#define CID_ARITY_T (p111_program_active->cid_arity)
#define CID_HOT_T (p111_program_active->cid_hot)
#define FID_IO_EMIT ((u32)p111_program_active->segment_count)
#define BEND_CLO_APPLY (FID_IO_EMIT + 1u)
#define FID_EXIT (FID_IO_EMIT + 2u)
#define FID_ENTER (FID_IO_EMIT + 3u)
#define MAIN_FID ((u32)p111_program_active->main_fid)
#define MAIN_PURE (p111_program_active->main_pure != 0)
#define BANGS 0
#define WL_WIDTH P111_REG_CAP
#define WL_RESW P111_RESULT_CAP
#define STAT_LEN (p111_program_active->static_words)
#define STAT_IMG (p111_program_active->static_image)
#define SHOW_DESC (p111_program_active->show_desc)
#define SHOW_NAMES (p111_program_active->show_names)

#define WL_BANK const bool p118_live_bank = (p111_program_active->capabilities & UINT64_C(4)) != 0; Term p118_local_regs[P111_REG_CAP]; Term *p111_regs = p118_live_bank ? wl->regs : p118_local_regs;
#define r0 p111_regs[0]
#define r1 p111_regs[1]
#define WL_INIT_BANK if (!p118_live_bank) memset(p111_regs, 0, sizeof(Term) * p111_transport_words);
#define WL_READ_STATE(V) if (!p118_live_bank) memcpy(p111_regs, (V), sizeof(Term) * p111_transport_words);
#define WL_WRITE_STATE(V) if (!p118_live_bank) memcpy((V), p111_regs, sizeof(Term) * p111_transport_words);
#define WL_LOAD(A,N) do { u32 p111_n = (N); \
  if (p111_n > p111_transport_words) { err_post(e.mem, ERR_FIDS); return 0; } \
  for (u32 p111_j = 0; p111_j < p111_n; ++p111_j) \
    p111_regs[p111_j] = e.mem[(A) + p111_j]; } while (0);
#define WL_LAST(X) do { \
  if (war >= p111_transport_words) { err_post(e.mem, ERR_FIDS); return 0; } \
  p111_regs[war] = (X); } while (0);
#define WL_SAVE(V) memcpy((V), p111_regs, sizeof(Term) * (p118_live_bank ? n : p111_transport_words));
#define WL_TAKE(V) memcpy(p111_regs, (V), sizeof(Term) * (p118_live_bank ? n : p111_transport_words));

static inline u32 p111_fid_arity(u32 fid) {
  return fid < FID_IO_EMIT ? p111_program_active->fid_arity[fid]
    : fid == FID_IO_EMIT ? 1u : fid == BEND_CLO_APPLY ? 2u : 0u;
}
static inline u32 p111_fid_flags(u32 fid) {
  return fid < FID_IO_EMIT ? p111_program_active->fid_flags[fid]
    : fid == FID_IO_EMIT ? 2u : 0u;
}
static inline u32 p111_fid_results(u32 fid) {
  return fid < FID_IO_EMIT ? p111_program_active->fid_results[fid] : 0u;
}


#if WL_PORTABLE && !DEVICE
#ifndef WL_WIDTH
#error WL_PORTABLE requires Bend-generated register transport metadata
#endif
// No pointers to this frame escape work_loop. Stale register words are copied
// as transport only; they are not roots and acquire no ownership obligations.
typedef P111State WlState;
#define WL_STOP (~(u32)0)
#endif

#define TAB_AT(T, S, I) T[S < I ? S : I]

// Fid
// ===

#define fid_arity(x) p111_fid_arity(x)

#define fid_bangs(x) ((bool)(p111_fid_flags(x) & 1))

#define fid_nofk(x) ((bool)(p111_fid_flags(x) & 2))

#define fid_seqk(x) (fid_resw(x) != 0)

#define fid_resw(x) p111_fid_results(x)

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
#ifdef __METAL_VERSION__
#define U32_QUO(a, b) \
  ((a) / 2 / (b) * 2 + ((a) - (a) / 2 / (b) * 2 * (b) >= (b)))
#else
#define U32_QUO(a, b) ((a) / (b))
#endif

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

#if BEND_CPROC
// cproc/QBE has no C inliner. These pure extracts evaluate their argument once,
// including the original parameter conversion, and retain exact result types.
#define term_tag(t) ((u64)(((Term)(t) >> 56) & 0x7f))
#define term_rfc(t) ((bool)(((Term)(t) & RFC_BIT) != 0))
#define term_aux(t) ((u64)(((Term)(t) >> 40) & 0xFFFF))
#define term_loc(t) ((Loc)((Term)(t) & LOC_MASK))
#else
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
#endif

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

/* Phase144 experiment: one Bend heap mutator, not one host thread.
 * Mode 0 preserves atomic RFC operations. Mode 1 is valid only for the pinned
 * sequential ABI and fixed audited effect providers. IO workers operate on
 * detached host buffers; only the event loop packs values into the Bend heap.
 * Unknown runtime/provider changes require a new admission audit.
 */
#ifndef P144_SINGLE_MUTATOR_RFC
#define P144_SINGLE_MUTATOR_RFC 0
#endif
#if P144_SINGLE_MUTATOR_RFC != 0 && P144_SINGLE_MUTATOR_RFC != 1
#error "P144_SINGLE_MUTATOR_RFC must be 0 or 1"
#endif
#if P144_SINGLE_MUTATOR_RFC && (DEVICE || BEND_METAL || BEND_CUDA || BANGS)
#error "Phase144 serial RFC requires the sequential host-only runtime"
#endif

INLINE u32 p144_rfc_add(DEV u32* p, u32 k) {
#if P144_SINGLE_MUTATOR_RFC
  u32 old;
  memcpy(&old, p, sizeof old);
  u32 next = old + k;
  memcpy(p, &next, sizeof next);
  return old;
#else
  return a32_add(p, k);
#endif
}

INLINE u32 p144_rfc_sub(DEV u32* p, u32 k) {
#if P144_SINGLE_MUTATOR_RFC
  u32 old;
  memcpy(&old, p, sizeof old);
  u32 next = old - k;
  memcpy(p, &next, sizeof next);
  return old;
#else
  return a32_sub_rel(p, k);
#endif
}

INLINE void rfc_bump(Env e, Loc r, u32 k) {
  u32 c = p144_rfc_add(a32_at(e.mem, r), k);
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

#if BEND_CPROC
#define blk_cls(t) ((Cls)((u32)term_aux((Term)(t)) & 31))
#else
INLINE Cls blk_cls(Term t) {
  return (u32)term_aux(t) & 31;
}
#endif

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
      if ((p144_rfc_sub(p, 1) & RFC_CNT) != 1) {
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

#ifndef NATIVE_SCALAR_ARRAYS
#define NATIVE_SCALAR_ARRAYS ((p111_program_active->capabilities & UINT64_C(2)) != 0)
#endif
#ifndef NATIVE_UNSHARED_ARRAYS
#define NATIVE_UNSHARED_ARRAYS 0
#endif

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
  if (term_tag(a) == TAG_BUF) return blk_read(e.mem, false, at, 0);
  return term_rfc(a) ? blk_keep(e, at) : e.mem[at];
}

// Packed arrays use adjacent U32 slots; uniform arrays use each word's low half.
// Existing a32 operations provide a single atomic update for every backend.
INLINE u64 array_atomic(Env e, Term a, u32 i, u32 v, u32 x, u32 op) {
  Loc loc = term_peek(e, a);
  u32 at = blk_at(a, i, 0);
  DEV u32* p = a32_at(e.mem, loc) + (term_tag(a) == TAG_BUF ? at : 2 * at);
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

// The checked compiler may select one scalar layout for all reachable arrays.
// Raw/unknown programs retain the uniform word ABI. Handle sharing is independent.
INLINE Term native_array_get(Env e, Term a, u32 i) {
  u32 at = blk_at(a, i, 0);
  Loc loc = NATIVE_UNSHARED_ARRAYS ? term_loc(a) : term_peek(e, a);
  return NATIVE_SCALAR_ARRAYS ? blk_read(e.mem, false, loc, at) : blk_keep(e, loc + at);
}

INLINE Term native_array_swap(Env e, Term a, u32 i, Term value) {
  u32 at = blk_at(a, i, 0);
  Loc loc = NATIVE_UNSHARED_ARRAYS ? term_loc(a) : term_peek(e, a);
  Term old = blk_read(e.mem, !NATIVE_SCALAR_ARRAYS, loc, at);
  blk_write(e.mem, !NATIVE_SCALAR_ARRAYS, loc, at, NATIVE_SCALAR_ARRAYS ? value : rfc_seal(e, value));
  return old;
}

INLINE void native_array_set(Env e, Term a, u32 i, Term value) {
  u32 at = blk_at(a, i, 0);
  Loc loc = NATIVE_UNSHARED_ARRAYS ? term_loc(a) : term_peek(e, a);
  if (!NATIVE_SCALAR_ARRAYS) term_sink(e, blk_read(e.mem, true, loc, at));
  blk_write(e.mem, !NATIVE_SCALAR_ARRAYS, loc, at, NATIVE_SCALAR_ARRAYS ? value : rfc_seal(e, value));
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

// Work
// ====

/* Ordinary ABI dispatcher; scheduler Reply and next-FID remain separate. */
typedef Reply (*WlFn)(WlState *state);
WL_FN WL_FID_ENTER(WlState *state);
WL_FN WL_FID_IO_EMIT(WlState *state);
WL_FN WL_BEND_CLO_APPLY(WlState *state);
WL_FN WL_FID_EXIT(WlState *state);

static Reply work_loop(Env e, Stk sp, Term t, bool seq) {
  WlState state = {0};
  state.e = e;
  state.sp = sp;
  state.seq = seq;
  state.next = FID_ENTER;
  state.regs[0] = t;
  for (;;) {
    Fid next = state.next;
    state.next = P111_STOP;
    WlFn run;
    if (next < FID_IO_EMIT) run = p111_program_active->segments[next];
    else if (next == FID_IO_EMIT) run = WL_FID_IO_EMIT;
    else if (next == BEND_CLO_APPLY) run = WL_BEND_CLO_APPLY;
    else if (next == FID_EXIT) run = WL_FID_EXIT;
    else if (next == FID_ENTER) run = WL_FID_ENTER;
    else { err_post(state.e.mem, ERR_FIDS); return 0; }
    Reply reply = run(&state);
    if (state.next == P111_STOP) return reply;
  }
}


// Segments
// ========

// A task enters through its words: a continuation's results ride r0.. and
// its parameters the stack; any other segment's parameters ride r0...
  WL_CASE(FID_ENTER)
  {
    Term t = r0;
    WL_OPEN
    Fid f   = (u32)term_aux(t);
    Loc a   = term_loc(t);
    u32 war = fid_arity(f);
    if (f > BEND_CLO_APPLY || war > p111_transport_words || fid_resw(f) > war) {
      err_post(e.mem, ERR_FIDS); return 0;
    }
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
    u32 p111_arity = fid_arity(f);
    if (term_tag(fun) != TAG_CLO || f > FID_IO_EMIT || p111_arity == 0 || p111_arity > p111_transport_words) {
      err_post(e.mem, ERR_FIDS); return 0;
    }
    u32 war = p111_arity - 1;
    Loc a    = term_loc(fun);
    WL_LOAD(a, war)
    spare_free(e, cls_fit(war), a);
    WL_LAST(arg)
    WL_DYN(f);
  }}

  WL_CASE(FID_EXIT)
  {
    u32  n = rn;
    if (n > p111_program_active->result_width) { err_post(e.mem, ERR_FIDS); return 0; }
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
      if (wn > p111_transport_words || n > wn) { err_post(e.mem, ERR_FIDS); return 0; }
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
#if P144_SINGLE_MUTATOR_RFC
  err_fail("phase144 serial RFC runtime refuses compute workers");
#endif
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
  if (STAT_LEN) memcpy(H + STAT_OFF, STAT_IMG, STAT_LEN * sizeof(u64));
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
  c = c > 0x10FFFF || (c >= 0xD800 && c <= 0xDFFF) ? 0xFFFD : c;
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
    buf[n] = 0;
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

#if 1

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
#ifdef CID_WINDOW_FULLSCREEN
    case CID_WINDOW_FULLSCREEN: return "native Window.fullscreen is not implemented by the retained IO runtime";
#endif
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
      u32 code = (u32)e.mem[at];
      if (code > 255) err_fail("exit code must be in 0..255");
      return (int)code;
    }
    if (c == p182_exit_cid) {
      u32 code = (u32)(term_tag(req) == TAG_PAK ? term_loc(req) : e.mem[at]);
      if (code > 255) err_fail("exit code must be in 0..255");
      return (int)code;
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
if (MAIN_PURE) {
    show_val(e, 0, H + H_ROOT_WORD, 0);
    putchar('\n');
    return 0;
  }
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

/* Generated by phase111/runtime/effects/prepare.py; include once at Requests. */
/* IDs are installed after the descriptor; no .init_array registration. */
static uint32_t p111_effect_cids[22];
static int p111_effects_bound;

/* /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs/args.c SHA256 7209a5fa11396fa8b0667a6738c913c40f554797e442c847a25e13a5f69676e0 */
// IO
// ==

Term io_args_run(Env e, Term* f, IoWork* w) {
  Term xs = term_pak(p111_effect_cids[16], 0);
  for (int i = io_argc; i > 0; i -= 1) {
    const char* a = io_argv[i - 1];
    xs = io_node(e, p111_effect_cids[0], io_str(e, a, strlen(a)), xs);
  }
  return xs;
}

Term io_args_bytes_run(Env e, Term* f, IoWork* w) {
  Term xs = term_pak(p111_effect_cids[16], 0);
  for (int i = io_argc; i > 0; i -= 1) {
    const char* a = io_argv[i - 1];
    xs = io_node(e, p111_effect_cids[0], io_list(e, a, strlen(a)), xs);
  }
  return xs;
}

static void io_args_use(void) {
  if (p111_effect_cids[9] != UINT32_MAX)
    io_eff(p111_effect_cids[9], io_args_run, 0);
  if (p111_effect_cids[18] != UINT32_MAX)
    io_eff(p111_effect_cids[18], io_args_bytes_run, 0);
}

/* /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs/print.c SHA256 709500d2ace6e2eaeec0f5f1e4373d4ec5e402b3c1e289bd70dfef7e2a635b26 */
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
  return term_pak(p111_effect_cids[17], 0);
}

static void io_print_use(void) {
  if (p111_effect_cids[11] != UINT32_MAX)
    io_eff(p111_effect_cids[11], io_print_run, 0);
}

/* /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs/now.c SHA256 da5fde65701c4fadc7560625c9615b4d60b2eefbd7b6bbe1aedda61887b825b9 */
// IO
// ==

Term io_now_run(Env e, Term* f, IoWork* w) {
  return (Term)(io_tick() / 1000000);
}

static void io_now_use(void) {
  if (p111_effect_cids[10] != UINT32_MAX)
    io_eff(p111_effect_cids[10], io_now_run, 0);
}

/* /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs/print_err.c SHA256 72781d2adc88a4791d5530c9deff20824c38d5aa1ba43fb05aaa6a697e19f4b6 */
// IO
// ==

Term io_print_err_run(Env e, Term* f, IoWork* w) {
  io_errs(e, f[0]);
  return term_pak(p111_effect_cids[17], 0);
}

static void io_print_err_use(void) {
  if (p111_effect_cids[12] != UINT32_MAX)
    io_eff(p111_effect_cids[12], io_print_err_run, 0);
}

/* /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs/file_open.c SHA256 f42a8bcc142b9003c7f6ca99287ca09c14f9efcbe15dea929c90c2fa062746e7 */
// File
// ====

static int file_open_mode(const char* mode) {
  if (strcmp(mode, "r") == 0) {
    return O_RDONLY;
  }
  if (strcmp(mode, "r+") == 0) {
    return O_RDWR;
  }
  if (strcmp(mode, "w") == 0) {
    return O_WRONLY | O_CREAT | O_TRUNC;
  }
  if (strcmp(mode, "a") == 0) {
    return O_WRONLY | O_CREAT | O_APPEND;
  }
  if (strcmp(mode, "x") == 0) {
    return O_WRONLY | O_CREAT | O_EXCL;
  }
  return -1;
}

static void file_open_call(IoWork* w) {
  int fd;
  do {
    fd = open(w->data, (int)w->word, 0644);
  } while (fd < 0 && errno == EINTR);
  w->made = (intptr_t)io_sys_end(w, fd);
}

static Term file_open_pack(Env e, IoWork* w) {
  free(w->data);
  return w->code != 0 ? io_fail(e, w->code, NULL)
    : io_done(e, io_hand(w->made));
}

static Term file_open_start(Env e, Term* f, IoWork* w, u64 cons) {
  uint64_t mn = 0;
  w->data = io_cbuf(e, f[0], &w->size, cons);
  char* mode = io_cstr(e, f[1], &mn);
  int flags = io_nul(mode, mn) ? -1 : file_open_mode(mode);
  free(mode);
  w->word = (uint32_t)flags;
  w->code = w->data == NULL ? EINVAL : io_nul(w->data, w->size) ? EILSEQ
    : flags < 0 ? EINVAL : 0;
  if (w->code != 0) {
    return file_open_pack(e, w);
  }
  return io_work(w, file_open_call, file_open_pack);
}

Term file_open_run(Env e, Term* f, IoWork* w) {
  return file_open_start(e, f, w, CID_SCON);
}

Term file_open_bytes_run(Env e, Term* f, IoWork* w) {
  return file_open_start(e, f, w, p111_effect_cids[0]);
}

static void file_open_use(void) {
  if (p111_effect_cids[2] != UINT32_MAX)
    io_eff(p111_effect_cids[2], file_open_run, 0);
  if (p111_effect_cids[19] != UINT32_MAX)
    io_eff(p111_effect_cids[19], file_open_bytes_run, 0);
}

/* /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs/file_read.c SHA256 6af44266ca83ab55b2dd3bf20c17eea6bfb7a7a678908cfbf3579adef31fb678 */
// Adapted from upstream b2111cf43244e65f76ddc278ee695e669f720cbf.
// Uses the retained selfhost runtime and its CID_* constructor ABI.
// File
// ====

// Adapted from upstream 9a4223d577ba56a0cb53d1fd952d2b481c38930f.
// Retains the local Env/CID_* effect ABI and ownership-aware result packing.
// File
// ====

// read(2) answers what is there, not what was asked: a pipe, a terminal
// and a short read all stop before max. Fill the buffer or reach EOF, so
// a caller that asked for n bytes gets n unless the file ends first; a
// line stops after its '\n', read a byte at a time so nothing past it
// leaves the file. An error after some bytes answers them (a pipe has
// already given them up); at reads at w->made and leaves the position.
static void file_read_fill(IoWork* w, int at, int line) {
  int fd  = (int)w->hand;
  u64 got = 0;
  w->code = 0;
  do {
    u64     want = line && got < w->word ? 1 : w->word - got;
    ssize_t n;
    do {
      n = at ? pread(fd, w->data + got, want, (off_t)(w->made + got))
             : read(fd, w->data + got, want);
    } while (n < 0 && errno == EINTR);
    if (n <= 0) {
      w->size = got > 0 ? got : io_sys_end(w, n);
      return;
    }
    got += (u64)n;
  } while (got < w->word && !(line && w->data[got - 1] == '\n'));
  w->size = got;
}

static void file_read_call(IoWork* w) {
  file_read_fill(w, 0, 0);
}

static Term file_read_start(Term file, u64 max, IoWork* w,
  IoCall call, IoPack pack) {
  w->hand = (intptr_t)io_hand_v(file);
  w->word = max < INT32_MAX ? max : INT32_MAX;
  w->data = io_mem(malloc(w->word + 1));
  return io_work(w, call, pack);
}

#if 1

static Term file_read_pack(Env e, IoWork* w) {
  Term r = w->code ? io_fail(e, w->code, NULL)
    : io_done(e, io_str(e, w->data, w->size));
  free(w->data);
  return io_tup(e, io_hand(w->hand), r);
}

#endif

#if 1

Term file_read_run(Env e, Term* f, IoWork* w) {
  return file_read_start(f[0], f[1], w, file_read_call, file_read_pack);
}

static void file_read_use(void) {
  if (p111_effect_cids[3] != UINT32_MAX)
    io_eff(p111_effect_cids[3], file_read_run, 0);
}

#endif

#if 1

static void file_read_line_call(IoWork* w) {
  file_read_fill(w, 0, 1);
}

Term file_read_line_run(Env e, Term* f, IoWork* w) {
  return file_read_start(f[0], f[1], w, file_read_line_call, file_read_pack);
}

static void file_read_line_use(void) {
  if (p111_effect_cids[20] != UINT32_MAX)
    io_eff(p111_effect_cids[20], file_read_line_run, 0);
}

#endif

#if 1

static Term file_read_bytes_pack(Env e, IoWork* w) {
  Term r = w->code ? io_fail(e, w->code, NULL)
    : io_done(e, io_list(e, w->data, w->size));
  free(w->data);
  return io_tup(e, io_hand(w->hand), r);
}

#endif

#if 1

Term file_read_bytes_run(Env e, Term* f, IoWork* w) {
  return file_read_start(f[0], f[1], w, file_read_call, file_read_bytes_pack);
}

static void file_read_bytes_use(void) {
  if (p111_effect_cids[5] != UINT32_MAX)
    io_eff(p111_effect_cids[5], file_read_bytes_run, 0);
}

#endif

#if 1

// The bytes at an offset, as file_read_bytes gives them; the position of
// the file does not move.
static void file_read_at_call(IoWork* w) {
  file_read_fill(w, 1, 0);
}

Term file_read_at_run(Env e, Term* f, IoWork* w) {
  w->made = (intptr_t)f[1];
  return file_read_start(f[0], f[2], w, file_read_at_call, file_read_bytes_pack);
}

static void file_read_at_use(void) {
  if (p111_effect_cids[4] != UINT32_MAX)
    io_eff(p111_effect_cids[4], file_read_at_run, 0);
}

#endif

/* /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs/file_size.c SHA256 09906f3839f0f0fba1eea944c948e35f8e03627dc2b78e8debb43e0556f5d5d8 */
// File
// ====

#include <sys/stat.h>

// The size in bytes, as the host reports it; a file past 4 GiB fails
// with EOVERFLOW.
static void file_size_call(IoWork* w) {
  struct stat st;
  int n = fstat((int)w->hand, &st);
  io_sys_end(w, n);
  if (n == 0) {
    w->code = st.st_size > (off_t)UINT32_MAX ? EOVERFLOW : 0;
    w->word = (u32)st.st_size;
  }
}

static Term file_size_pack(Env e, IoWork* w) {
  Term r = w->code ? io_fail(e, w->code, NULL) : io_done(e, w->word);
  return io_tup(e, io_hand(w->hand), r);
}

Term file_size_run(Env e, Term* f, IoWork* w) {
  w->hand = (intptr_t)io_hand_v(f[0]);
  return io_work(w, file_size_call, file_size_pack);
}

static void file_size_use(void) {
  if (p111_effect_cids[6] != UINT32_MAX)
    io_eff(p111_effect_cids[6], file_size_run, 0);
}

/* /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs/file_write.c SHA256 565dff20204e1e535e188b983cda6d6001d0e5dc37cfdf981960c07a9e154ee2 */
// Adapted from upstream b2111cf43244e65f76ddc278ee695e669f720cbf.
// Uses the retained selfhost runtime and its CID_* constructor ABI.
// File
// ====

// Adapted from upstream 9a4223d577ba56a0cb53d1fd952d2b481c38930f.
// Retains the local Env/CID_* effect ABI and ownership-aware result packing.
// File
// ====

static void file_write_fill(IoWork* w, int at_offset) {
  int fd = (int)w->hand;
  ssize_t n = 0;
  for (uint64_t at = 0; n >= 0 && at < w->size; at += (uint64_t)n) {
    do {
      n = at_offset ? pwrite(fd, w->data + at, w->size - at, (off_t)(w->made + at))
                    : write(fd, w->data + at, w->size - at);
    } while (n < 0 && errno == EINTR);
    // no progress would retry forever (#1445)
    if (n == 0) {
      w->code = EIO;
      return;
    }
  }
  io_sys_end(w, n);
}

static void file_write_call(IoWork* w) {
  file_write_fill(w, 0);
}

static Term file_write_pack(Env e, IoWork* w) {
  Term r = w->code ? io_fail(e, w->code, NULL)
    : io_done(e, term_pak(p111_effect_cids[17], 0));
  free(w->data);
  return io_tup(e, io_hand(w->hand), r);
}

#if 1

Term file_write_run(Env e, Term* f, IoWork* w) {
  w->hand = (intptr_t)io_hand_v(f[0]);
  w->data = io_cstr(e, f[1], &w->size);
  return io_work(w, file_write_call, file_write_pack);
}

static void file_write_use(void) {
  if (p111_effect_cids[7] != UINT32_MAX)
    io_eff(p111_effect_cids[7], file_write_run, 0);
}

#endif

#if 1

// A value past 255 fails with EINVAL before any byte is written.
Term file_write_bytes_run(Env e, Term* f, IoWork* w) {
  w->hand = (intptr_t)io_hand_v(f[0]);
  w->data = io_cbuf(e, f[1], &w->size, p111_effect_cids[0]);
  w->code = w->data == NULL ? EINVAL : 0;
  return w->code ? file_write_pack(e, w)
    : io_work(w, file_write_call, file_write_pack);
}

static void file_write_bytes_use(void) {
  if (p111_effect_cids[8] != UINT32_MAX)
    io_eff(p111_effect_cids[8], file_write_bytes_run, 0);
}

#endif

#if 1

static void file_write_at_call(IoWork* w) {
  file_write_fill(w, 1);
}

Term file_write_at_run(Env e, Term* f, IoWork* w) {
  w->hand = (intptr_t)io_hand_v(f[0]);
  w->made = (intptr_t)f[1];
  w->data = io_cbuf(e, f[2], &w->size, p111_effect_cids[0]);
  int flags = fcntl((int)w->hand, F_GETFL);
  w->code = w->data == NULL || (flags >= 0 && (flags & O_APPEND)) ? EINVAL : 0;
  return w->code ? file_write_pack(e, w)
    : io_work(w, file_write_at_call, file_write_pack);
}

static void file_write_at_use(void) {
  if (p111_effect_cids[21] != UINT32_MAX)
    io_eff(p111_effect_cids[21], file_write_at_run, 0);
}

#endif

/* /home/ai/bend2/build/publish/bend/selfhost/build/phase90/runtime-accessor-transport02/effs/file_close.c SHA256 befd465a31b88936d772222d26b1019ea7330e59e6327d8ba90584c85e8b2fb3 */
// File
// ====

Term file_close_run(Env e, Term* f, IoWork* w) {
  close((int)io_hand_v(f[0]));
  return term_pak(p111_effect_cids[17], 0);
}

static void file_close_use(void) {
  if (p111_effect_cids[1] != UINT32_MAX)
    io_eff(p111_effect_cids[1], file_close_run, 0);
}

/* /home/ai/bend2/build/publish/bend/selfhost/src/host/native-os.c SHA256 45aabbcc21ddd18d2f77b15d6d53fc06d5cc553f96d6a46398449c025cae3e89 */
// Linux host effects. Compiler policy and expected asset identities stay in Bend.
// read/path: Result<U32 & String, String>; publish: Result<U32 & String, Unit>.
// io_cstr consumes arguments; only the IO loop touches Bend values. Helpers own
// malloc buffers until pack. Read rejects invalid UTF-8 so io_str is lossless.
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/random.h>
#include <sys/stat.h>
#include <unistd.h>

typedef struct {
  char *path, *hash, *data;
  uint64_t size;
  uint32_t limit;
  const char *error;
} NativeHostWork;

static uint32_t nh_rotr(uint32_t x, unsigned n) {
  return (x >> n) | (x << (32 - n));
}

static void nh_sha_block(uint32_t h[8], const unsigned char *p) {
  static const uint32_t k[64] = {
    0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
    0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
    0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
    0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
    0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
    0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
    0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
    0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
  };
  uint32_t s[64];
  for (unsigned i = 0; i < 16; ++i)
    s[i] = (uint32_t)p[4*i]<<24 | (uint32_t)p[4*i+1]<<16 |
           (uint32_t)p[4*i+2]<<8 | p[4*i+3];
  for (unsigned i = 16; i < 64; ++i) {
    uint32_t x = s[i-15], y = s[i-2];
    s[i] = s[i-16] + (nh_rotr(x,7)^nh_rotr(x,18)^(x>>3)) + s[i-7] +
           (nh_rotr(y,17)^nh_rotr(y,19)^(y>>10));
  }
  uint32_t a=h[0],b=h[1],c=h[2],d=h[3],e=h[4],f=h[5],g=h[6],v=h[7];
  for (unsigned i = 0; i < 64; ++i) {
    uint32_t t = v + (nh_rotr(e,6)^nh_rotr(e,11)^nh_rotr(e,25)) +
                 ((e&f)^(~e&g)) + k[i] + s[i];
    uint32_t u = (nh_rotr(a,2)^nh_rotr(a,13)^nh_rotr(a,22)) + ((a&b)^(a&c)^(b&c));
    v=g; g=f; f=e; e=d+t; d=c; c=b; b=a; a=t+u;
  }
  h[0]+=a; h[1]+=b; h[2]+=c; h[3]+=d; h[4]+=e; h[5]+=f; h[6]+=g; h[7]+=v;
}

static void nh_sha256(const char *data, size_t size, char out[65]) {
  uint32_t h[8] = {0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
                   0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19};
  size_t full = size & ~(size_t)63, rest = size - full;
  for (size_t i = 0; i < full; i += 64) nh_sha_block(h, (const unsigned char *)data+i);
  unsigned char tail[128] = {0};
  memcpy(tail, data+full, rest); tail[rest] = 0x80;
  size_t width = rest < 56 ? 64 : 128;
  uint64_t bits = (uint64_t)size * 8;
  for (unsigned i = 0; i < 8; ++i) tail[width-1-i] = (unsigned char)(bits >> (8*i));
  nh_sha_block(h, tail);
  if (width == 128) nh_sha_block(h, tail+64);
  static const char hex[] = "0123456789abcdef";
  for (unsigned i = 0; i < 64; ++i) out[i] = hex[(h[i/8] >> (28-4*(i%8))) & 15];
  out[64] = 0;
}

static int nh_utf8(const char *text, size_t size) {
  unsigned need=0, lo=0x80, hi=0xbf;
  for (size_t i=0; i<size; ++i) {
    unsigned b=(unsigned char)text[i];
    if (need) { if (b<lo || b>hi) return 0; --need; lo=0x80; hi=0xbf; }
    else if (b>=0x80) {
      if (b<0xc2 || b>0xf4) return 0;
      need=b<0xe0 ? 1 : b<0xf0 ? 2 : 3;
      lo=b==0xe0 ? 0xa0 : b==0xf0 ? 0x90 : 0x80;
      hi=b==0xed ? 0x9f : b==0xf4 ? 0x8f : 0xbf;
    }
  }
  return need==0;
}

static Term nh_pack(Env e, IoWork *w) {
  NativeHostWork *x=(NativeHostWork *)w->data;
  Term result=w->code ? io_fail(e,w->code,x->error) :
    io_done(e,w->word==2 ? term_pak(p111_effect_cids[17],0) : io_str(e,x->data,x->size));
  free(x->path); free(x->hash); free(x->data); free(x);
  return result;
}

static NativeHostWork *nh_begin(Env e, Term path, IoWork *w, uint32_t op) {
  NativeHostWork *x=io_mem(calloc(1,sizeof *x));
  uint64_t size=0;
  x->path=io_cstr(e,path,&size);
  w->data=(char *)x; w->word=op; w->code=io_nul(x->path,size) ? EILSEQ : 0;
  return x;
}

static void nh_read_call(IoWork *w) {
  NativeHostWork *x=(NativeHostWork *)w->data;
  int fd=open(x->path,O_RDONLY|O_CLOEXEC|O_NOFOLLOW|O_NONBLOCK);
  if (fd<0) { w->code=errno; return; }
  struct stat before,after;
  if (fstat(fd,&before)<0) w->code=errno;
  else if (!S_ISREG(before.st_mode)) w->code=EINVAL;
  else if (before.st_size<0 || (uint64_t)before.st_size>x->limit ||
           (uint64_t)before.st_size>=SIZE_MAX) w->code=EFBIG;
  if (!w->code) {
    size_t size=(size_t)before.st_size, at=0;
    x->data=malloc(size+1);
    if (!x->data) w->code=ENOMEM;
    while (!w->code && at<size) {
      size_t count=size-at; if (count>1048576) count=1048576;
      ssize_t n=read(fd,x->data+at,count);
      if (n<0 && errno==EINTR) continue;
      if (n<=0) w->code=n<0 ? errno : EIO; else at+=(size_t)n;
    }
    if (!w->code) {
      char extra; ssize_t n;
      do { n=read(fd,&extra,1); } while (n<0 && errno==EINTR);
      if (n!=0) w->code=n<0 ? errno : EFBIG;
      else if (fstat(fd,&after)<0) w->code=errno;
      else if (before.st_size!=after.st_size ||
        before.st_mtim.tv_sec!=after.st_mtim.tv_sec || before.st_mtim.tv_nsec!=after.st_mtim.tv_nsec ||
        before.st_ctim.tv_sec!=after.st_ctim.tv_sec || before.st_ctim.tv_nsec!=after.st_ctim.tv_nsec) w->code=ESTALE;
      x->size=size; x->data[size]=0;
    }
  }
  if (close(fd)<0 && !w->code) w->code=errno; // Do not retry close on Linux.
  if (!w->code && x->hash[0]) {
    char actual[65]; nh_sha256(x->data,(size_t)x->size,actual);
    if (memcmp(actual,x->hash,64)) { w->code=EBADMSG; x->error="SHA-256 mismatch"; }
  }
  if (!w->code && !nh_utf8(x->data,(size_t)x->size)) w->code=EILSEQ;
}

Term native_host_read_run(Env e, Term *f, IoWork *w) {
  NativeHostWork *x=nh_begin(e,f[0],w,0);
  uint64_t n=0; x->hash=io_cstr(e,f[1],&n); x->limit=(uint32_t)f[2];
  if (n!=0 && n!=64) w->code=EINVAL;
  for (uint64_t i=0; i<n && !w->code; ++i)
    if (!((x->hash[i]>='0' && x->hash[i]<='9') || (x->hash[i]>='a' && x->hash[i]<='f'))) w->code=EINVAL;
  return w->code ? nh_pack(e,w) : io_work(w,nh_read_call,nh_pack);
}

static void nh_path_call(IoWork *w) {
  NativeHostWork *x=(NativeHostWork *)w->data;
  if (x->path[0]) x->data=realpath(x->path,NULL);
  else {
    x->data=malloc(PATH_MAX+1);
    if (!x->data) { w->code=ENOMEM; return; }
    ssize_t n=readlink("/proc/self/exe",x->data,PATH_MAX);
    if (n<0) { w->code=errno; return; }
    if (n==PATH_MAX) { w->code=ENAMETOOLONG; return; }
    x->data[n]=0;
    char *slash=strrchr(x->data,'/');
    if (!slash) { w->code=EINVAL; return; }
    slash[slash==x->data ? 1 : 0]=0;
  }
  if (!x->data) { w->code=errno; return; }
  x->size=strlen(x->data);
  if (!nh_utf8(x->data,(size_t)x->size)) w->code=EILSEQ;
}

Term native_host_path_run(Env e, Term *f, IoWork *w) {
  nh_begin(e,f[0],w,1);
  return w->code ? nh_pack(e,w) : io_work(w,nh_path_call,nh_pack);
}

static void nh_publish_call(IoWork *w) {
  NativeHostWork *x=(NativeHostWork *)w->data;
  char *slash=strrchr(x->path,'/'), *name=slash ? slash+1 : x->path;
  if (!*name) { w->code=EINVAL; return; }
  const char *dir=".";
  if (slash) { *slash=0; dir=slash==x->path ? "/" : x->path; }
  int parent=open(dir,O_RDONLY|O_DIRECTORY|O_CLOEXEC);
  if (parent<0) { w->code=errno; return; }
  int fd=-1; char temp[64]={0};
  for (unsigned attempt=0; attempt<64; ++attempt) {
    uint64_t random; size_t at=0;
    while (at<sizeof random) {
      ssize_t n=getrandom((char *)&random+at,sizeof random-at,0);
      if (n<0 && errno==EINTR) continue;
      if (n<=0) { w->code=n<0 ? errno : EIO; break; } at+=(size_t)n;
    }
    if (w->code) break;
    snprintf(temp,sizeof temp,".bend-native-%ld-%016llx",(long)getpid(),(unsigned long long)random);
    if (strcmp(temp,name)==0) continue;
    fd=openat(parent,temp,O_WRONLY|O_CREAT|O_EXCL|O_CLOEXEC,0600);
    if (fd>=0) break;
    if (errno!=EEXIST) { w->code=errno; break; }
  }
  if (fd<0) { if (!w->code) w->code=EEXIST; close(parent); return; }
  struct stat made;
  int known=fstat(fd,&made)==0;
  if (!known) w->code=errno;
  for (uint64_t at=0; !w->code && at<x->size;) {
    size_t count=(size_t)(x->size-at); if (count>1048576) count=1048576;
    ssize_t n=write(fd,x->data+at,count);
    if (n<0 && errno==EINTR) continue;
    if (n<=0) w->code=n<0 ? errno : EIO; else at+=(uint64_t)n;
  }
  if (!w->code && fsync(fd)<0) w->code=errno;
  // Keep the inode, not its mutable directory entry, through writer close.
  char proc[64]; int held=-1, published=0;
  if (!w->code) {
    snprintf(proc,sizeof proc,"/proc/self/fd/%d",fd);
    held=open(proc,O_PATH|O_CLOEXEC);
    if (held<0) w->code=errno;
  }
  if (close(fd)<0 && !w->code) w->code=errno;
  if (!w->code) {
    snprintf(proc,sizeof proc,"/proc/self/fd/%d",held);
    if (linkat(AT_FDCWD,proc,parent,name,AT_SYMLINK_FOLLOW)<0) w->code=errno;
    else published=1;
  }
  if (held>=0 && close(held)<0 && !w->code) w->code=errno;
  struct stat current;
  int cleanup=0;
  if (fstatat(parent,temp,&current,AT_SYMLINK_NOFOLLOW)<0) {
    if (errno!=ENOENT) cleanup=errno;
  } else if (!known || current.st_dev!=made.st_dev || current.st_ino!=made.st_ino) cleanup=ESTALE;
  else if (unlinkat(parent,temp,0)<0) cleanup=errno;
  if (!w->code) w->code=cleanup;
  if (close(parent)<0 && !w->code) w->code=errno;
  if (published && w->code) x->error="output published; temporary cleanup failed";
}

Term native_host_publish_run(Env e, Term *f, IoWork *w) {
  NativeHostWork *x=nh_begin(e,f[0],w,2);
  x->data=io_cstr(e,f[1],&x->size);
  if (x->size>67108864) w->code=EFBIG;
  return w->code ? nh_pack(e,w) : io_work(w,nh_publish_call,nh_pack);
}

static void native_host_use(void) {
  if (p111_effect_cids[15] != UINT32_MAX)
    io_eff(p111_effect_cids[15], native_host_read_run, 0);
  if (p111_effect_cids[13] != UINT32_MAX)
    io_eff(p111_effect_cids[13], native_host_path_run, 0);
  if (p111_effect_cids[14] != UINT32_MAX)
    io_eff(p111_effect_cids[14], native_host_publish_run, 0);
}

static void p111_effects_bind(uint32_t (*lookup)(void *, const char *), void *context) {
  if (lookup == NULL || p111_effects_bound) err_fail("phase111: invalid effect binding lifecycle");
  uint32_t ids[22];
  ids[0] = lookup(context, "Con");
  if (ids[0] != UINT32_MAX && ids[0] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[1] = lookup(context, "File.close");
  if (ids[1] != UINT32_MAX && ids[1] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[2] = lookup(context, "File.open");
  if (ids[2] != UINT32_MAX && ids[2] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[3] = lookup(context, "File.read");
  if (ids[3] != UINT32_MAX && ids[3] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[4] = lookup(context, "File.read_at");
  if (ids[4] != UINT32_MAX && ids[4] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[5] = lookup(context, "File.read_bytes");
  if (ids[5] != UINT32_MAX && ids[5] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[6] = lookup(context, "File.size");
  if (ids[6] != UINT32_MAX && ids[6] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[7] = lookup(context, "File.write");
  if (ids[7] != UINT32_MAX && ids[7] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[8] = lookup(context, "File.write_bytes");
  if (ids[8] != UINT32_MAX && ids[8] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[9] = lookup(context, "IO.args");
  if (ids[9] != UINT32_MAX && ids[9] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[10] = lookup(context, "IO.now");
  if (ids[10] != UINT32_MAX && ids[10] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[11] = lookup(context, "IO.print");
  if (ids[11] != UINT32_MAX && ids[11] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[12] = lookup(context, "IO.print_err");
  if (ids[12] != UINT32_MAX && ids[12] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[13] = lookup(context, "NativeHost.path");
  if (ids[13] != UINT32_MAX && ids[13] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[14] = lookup(context, "NativeHost.publish");
  if (ids[14] != UINT32_MAX && ids[14] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[15] = lookup(context, "NativeHost.read");
  if (ids[15] != UINT32_MAX && ids[15] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[16] = lookup(context, "Nil");
  if (ids[16] != UINT32_MAX && ids[16] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[17] = lookup(context, "Unit");
  if (ids[17] != UINT32_MAX && ids[17] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[18] = lookup(context, "IO.args_bytes");
  if (ids[18] != UINT32_MAX && ids[18] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[19] = lookup(context, "File.open_bytes");
  if (ids[19] != UINT32_MAX && ids[19] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[20] = lookup(context, "File.read_line");
  if (ids[20] != UINT32_MAX && ids[20] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  ids[21] = lookup(context, "File.write_at");
  if (ids[21] != UINT32_MAX && ids[21] >= (1u << 16)) err_fail("phase111: effect CID out of range");
  if ((ids[9] != UINT32_MAX || ids[18] != UINT32_MAX || ids[19] != UINT32_MAX) && (ids[0] == UINT32_MAX || ids[16] == UINT32_MAX)) err_fail("phase111: active provider lacks value CID");
  if ((ids[11] != UINT32_MAX) && (ids[17] == UINT32_MAX)) err_fail("phase111: active provider lacks value CID");
  if ((ids[12] != UINT32_MAX) && (ids[17] == UINT32_MAX)) err_fail("phase111: active provider lacks value CID");
  if ((ids[7] != UINT32_MAX || ids[8] != UINT32_MAX || ids[21] != UINT32_MAX) && (ids[0] == UINT32_MAX || ids[17] == UINT32_MAX)) err_fail("phase111: active provider lacks value CID");
  if ((ids[1] != UINT32_MAX) && (ids[17] == UINT32_MAX)) err_fail("phase111: active provider lacks value CID");
  if ((ids[13] != UINT32_MAX || ids[14] != UINT32_MAX || ids[15] != UINT32_MAX) && (ids[17] == UINT32_MAX)) err_fail("phase111: active provider lacks value CID");
  for (uint32_t i = 0; i < 22u; ++i) {
    for (uint32_t j = 0; j < i; ++j)
      if (ids[i] != UINT32_MAX && ids[i] == ids[j]) err_fail("phase111: semantic CID alias");
  }
  if (ids[9] != UINT32_MAX && io_eff_rows[ids[9]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[11] != UINT32_MAX && io_eff_rows[ids[11]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[10] != UINT32_MAX && io_eff_rows[ids[10]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[12] != UINT32_MAX && io_eff_rows[ids[12]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[2] != UINT32_MAX && io_eff_rows[ids[2]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[3] != UINT32_MAX && io_eff_rows[ids[3]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[5] != UINT32_MAX && io_eff_rows[ids[5]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[4] != UINT32_MAX && io_eff_rows[ids[4]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[6] != UINT32_MAX && io_eff_rows[ids[6]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[7] != UINT32_MAX && io_eff_rows[ids[7]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[8] != UINT32_MAX && io_eff_rows[ids[8]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[1] != UINT32_MAX && io_eff_rows[ids[1]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[15] != UINT32_MAX && io_eff_rows[ids[15]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[13] != UINT32_MAX && io_eff_rows[ids[13]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[14] != UINT32_MAX && io_eff_rows[ids[14]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[18] != UINT32_MAX && io_eff_rows[ids[18]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[19] != UINT32_MAX && io_eff_rows[ids[19]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[20] != UINT32_MAX && io_eff_rows[ids[20]].run != NULL) err_fail("phase111: duplicate effect row");
  if (ids[21] != UINT32_MAX && io_eff_rows[ids[21]].run != NULL) err_fail("phase111: duplicate effect row");
  for (uint32_t i = 0; i < 22u; ++i) p111_effect_cids[i] = ids[i];
  io_args_use();
  io_print_use();
  io_now_use();
  io_print_err_use();
  file_open_use();
  file_read_use();
  file_read_line_use();
  file_read_bytes_use();
  file_read_at_use();
  file_size_use();
  file_write_use();
  file_write_at_use();
  file_write_bytes_use();
  file_close_use();
  native_host_use();
  p111_effects_bound = 1;
}


/* Scalar public boundary over the retained production ownership operations. */
static void p111_require(bool condition, const char *message) {
  if (!condition) err_fail(message);
}

static uint32_t p111_lookup_cid(void *context, const char *name) {
  const P111Program *program = context;
  for (u32 i = 0; i < program->constructor_count; ++i)
    if (strcmp(program->cid_names[i], name) == 0) return i;
  return UINT32_MAX;
}

static void p111_bind(const P111Program *program) {
  p111_require(p111_program_active == NULL, "phase111: one program per process");
  p111_require(program && program->abi_version == P111_ABI_VERSION &&
    program->descriptor_bytes == sizeof(P111Program), "phase111: descriptor ABI mismatch");
  p111_require((program->capabilities == 1 || program->capabilities == 3 || program->capabilities == 5 || program->capabilities == 7 || program->capabilities == 9 || program->capabilities == 11 || program->capabilities == 13 || program->capabilities == 15), "phase111: unsupported capabilities");
  p111_require(program->segment_count > 0 && program->segment_count <= 65532 &&
    program->constructor_count > 0 && program->constructor_count <= 65536,
    "phase111: program identifier capacity exceeded");
  p111_require(program->main_fid < program->segment_count && program->main_pure <= 1 &&
    program->register_width >= 2 && program->register_width <= P111_REG_CAP &&
    program->result_width >= 1 && program->result_width <= P111_RESULT_CAP,
    "phase111: program entry or width mismatch");
  p111_require(program->segments && program->fid_arity && program->fid_flags &&
    program->fid_results && program->cid_arity && program->cid_hot && program->cid_names,
    "phase111: missing program tables");
  p111_require(program->static_words < (UINT64_C(1) << 30) - STAT_OFF &&
    (!program->static_words || program->static_image), "phase111: static image exceeds initial corpus");
  p111_require(!program->main_pure || (program->show_words && program->show_desc &&
    (!program->show_name_count || program->show_names)), "phase111: missing pure result readback");
  p111_require(!program->effect_count || program->effects, "phase111: missing effects table");
  for (u32 i = 0; i < program->segment_count; ++i) {
    p111_require(program->segments[i] && program->fid_arity[i] <= program->register_width &&
      program->fid_results[i] <= program->result_width &&
      program->fid_results[i] <= program->fid_arity[i] && (program->fid_flags[i] & ~3u) == 0,
      "phase111: invalid segment metadata");
  }
  p111_require(program->fid_arity[program->main_fid] == 0 &&
    program->fid_results[program->main_fid] == 0, "phase111: main must be a closed ordinary segment");
  for (u32 i = 0; i < program->constructor_count; ++i) {
    p111_require(program->cid_names[i] && program->cid_names[i][0] && program->cid_hot[i] <= 1,
      "phase111: invalid constructor metadata");
  }
  p111_program_active = program;
  /* Binding validated both widths against the fixed capacities above. Include
   * two runtime apply arguments even for programs whose own arity is smaller.
   * Incoming continuation widths are bounded by both arity and result_width. */
  p111_transport_words = (u32)(program->register_width > program->result_width
    ? program->register_width : program->result_width);
  if (p111_transport_words < 2) p111_transport_words = 2;
  for (u32 i = 0; i < 18; ++i) {
    p111_core_cids[i] = p111_lookup_cid((void *)program, p111_core_names[i]);
    p111_require(p111_core_cids[i] != UINT32_MAX, "phase111: missing core constructor identity");
  }
  p111_effects_bind(p111_lookup_cid, (void *)program);
  p182_exit_cid = p111_lookup_cid((void *)program, "Exit");
  for (u64 i = 0; i < program->effect_count; ++i) {
    p111_require(program->effects[i] != NULL, "phase111: missing effect name");
    u32 cid = p111_lookup_cid((void *)program, program->effects[i]);
    p111_require(cid != UINT32_MAX && io_eff_rows[cid].run != NULL,
      "phase111: foreign provider unavailable");
  }
}

uint64_t p111_rt_keep(P111State *state, uint64_t term) { return term_keep(state->e, term); }
uint64_t p111_rt_sink(P111State *state, uint64_t term) { term_sink(state->e, term); return 0; }
uint64_t p111_rt_tag(P111State *state, uint64_t term) { (void)state; return term_aux(term); }

uint64_t p111_rt_ctor(P111State *state, uint32_t cid, const uint64_t *fields, uint32_t count) {
  p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
    "phase111: constructor arity mismatch");
  if (!count) return term_pak(cid, 0);
  p111_require(fields != NULL, "phase111: missing constructor fields");
  Env e = state->e;
  Loc at = heap_alloc(e, cls_fit(count));
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = fields[i];
  } else {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, fields[i]);
  }
  return term_ctr(cid, at);
}

uint64_t p111_rt_take(P111State *state, uint64_t term, uint64_t *out, uint32_t count) {
  u32 cid = (u32)term_aux(term);
  p111_require(cid < p111_program_active->constructor_count && count == cid_arity(cid),
    "phase111: take arity mismatch");
  if (!count) return 0;
  p111_require(out != NULL, "phase111: missing take outputs");
  if (count == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term);
  else {
    p111_require(term_tag(term) == TAG_CTR, "phase111: expected constructor owner");
    spare_free(state->e, cls_fit(count), ctr_take(state->e, term, count, out));
  }
  return count;
}

uint64_t p111_rt_closure(P111State *state, uint32_t fid, const uint64_t *fields, uint32_t count) {
  p111_require(fid < FID_IO_EMIT && count < 255 && count + 1 == fid_arity(fid),
    "phase111: closure capture arity mismatch");
  if (!count) return term_clo(fid, 0);
  p111_require(fields != NULL, "phase111: missing closure captures");
  Loc at = heap_alloc(state->e, cls_fit(count));
  for (u32 i = 0; i < count; ++i) state->e.mem[at + i] = fields[i];
  return term_clo(fid, at);
}

uint64_t p111_rt_frame(P111State *state, uint32_t next_fid, const uint64_t *captures, uint32_t count) {
  p111_require(next_fid < FID_IO_EMIT && count < P111_REG_CAP && (!count || captures),
    "phase111: invalid continuation frame");
  for (u32 i = 0; i < count; ++i) state->sp[i] = captures[i];
  state->sp[count] = next_fid;
  state->sp += count + 1;
  return 0;
}

static void p111_set_regs(P111State *state, const uint64_t *values, uint32_t count) {
  p111_require(count <= p111_transport_words && (!count || values), "phase111: invalid register transfer");
  if (count) memmove(state->regs, values, count * sizeof(uint64_t));
  if (!(p111_program_active->capabilities & UINT64_C(4))) memset(state->regs + count, 0, (p111_transport_words - count) * sizeof(uint64_t));
}

uint64_t p111_rt_jump(P111State *state, uint32_t fid, const uint64_t *args, uint32_t count) {
  p111_require(fid < FID_IO_EMIT && count == fid_arity(fid), "phase111: direct jump arity mismatch");
  p111_set_regs(state, args, count);
  state->rn = 0;
  state->next = fid;
  return 0;
}

uint64_t p111_rt_return(P111State *state, const uint64_t *values, uint32_t count) {
  p111_require(count <= p111_program_active->result_width, "phase111: return width mismatch");
  p111_set_regs(state, values, count);
  state->rn = count;
  state->next = (u32)*--state->sp;
  return 0;
}

uint64_t p111_rt_apply(P111State *state, uint64_t closure, uint64_t argument) {
  u32 fid = (u32)term_aux(closure);
  p111_require(state->seq && term_tag(closure) == TAG_CLO && fid <= FID_IO_EMIT && fid_arity(fid),
    "phase111: invalid sequential closure apply");
  uint64_t args[2] = {closure, argument};
  p111_set_regs(state, args, 2);
  state->rn = 0;
  state->next = BEND_CLO_APPLY;
  return 0;
}

uint64_t p111_rt_stack_pop(P111State *state, uint32_t count) { state->sp -= count; return 0; }
uint64_t p111_rt_stack_get(P111State *state, uint32_t index) { return state->sp[index]; }
uint64_t p111_rt_reg_get(P111State *state, uint32_t index) {
  p111_require(index < p111_transport_words, "phase111: invalid register index");
  return state->regs[index];
}
uint64_t p111_rt_fail(P111State *state, uint32_t code) { err_post(state->e.mem, code); return 0; }


/* Finite source-audited primitive switch, never a C-program-body parser. */
#include "primitives.h"

static bool p111_native_bool(Term t) {
  return t == 1 || (term_tag(t) == TAG_PAK && term_aux(t) == CID_TRUE);
}

static Term p111_native_word(Env e, u32 x) {
  Term w = term_pak(CID_WNIL, 0);
  for (u32 i = 32; i > 0; i--) {
    Loc p = heap_alloc(e, 1);
    e.mem[p] = (x >> (i - 1)) & 1;
    e.mem[p + 1] = rfc_seal(e, w);
    w = term_ctr(CID_WCON, p);
  }
  return w;
}

static Term p111_tuple(Env e, Term first, Term second) {
  Loc at = heap_alloc(e, cls_fit(2));
  e.mem[at] = rfc_seal(e, first);
  e.mem[at + 1] = rfc_seal(e, second);
  return term_ctr(CID_TUPLE, at);
}

static void p111_primitive_arity(u32 actual, u32 expected) {
  if (actual != expected) err_fail("phase111: primitive arity mismatch");
}

uint64_t p111_rt_op(P111State *state, uint32_t op, const uint64_t *args, uint32_t count) {
  Env e = state->e;
  switch (op) {
    case P111_OP_U32_ADD: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], +, args[1]);
    }
    case P111_OP_U32_SUB: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], -, args[1]);
    }
    case P111_OP_U32_AND: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], &, args[1]);
    }
    case P111_OP_U32_OR: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], |, args[1]);
    }
    case P111_OP_U32_XOR: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], ^, args[1]);
    }
    case P111_OP_U32_MUL: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], *, args[1]);
    }
    case P111_OP_U32_IS_EQ: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], ==, args[1]);
    }
    case P111_OP_U32_IS_NE: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], !=, args[1]);
    }
    case P111_OP_U32_IS_LT: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], <, args[1]);
    }
    case P111_OP_U32_IS_LE: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], <=, args[1]);
    }
    case P111_OP_U32_IS_GT: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], >, args[1]);
    }
    case P111_OP_U32_IS_GE: {
      p111_primitive_arity(count, 2);
      return U32_BIN(args[0], >=, args[1]);
    }
    case P111_OP_U32_INC: {
      p111_primitive_arity(count, 1);
      return U32_BIN(args[0], +, 1);
    }
    case P111_OP_U32_SHL: {
      p111_primitive_arity(count, 1);
      return U32_BIN(args[0], <<, 1);
    }
    case P111_OP_U32_SHR: {
      p111_primitive_arity(count, 1);
      return U32_BIN(args[0], >>, 1);
    }
    case P111_OP_U32_SHLN: {
      p111_primitive_arity(count, 2);
      return (args[1] >= 32 ? 0 : U32_BIN(args[0], <<, args[1]));
    }
    case P111_OP_U32_SHRN: {
      p111_primitive_arity(count, 2);
      return (args[1] >= 32 ? 0 : U32_BIN(args[0], >>, args[1]));
    }
    case P111_OP_U32_DIV: {
      p111_primitive_arity(count, 2);
      return ((u32)(args[1]) == 0 ? 0 : (u64)U32_QUO((u32)(args[0]), (u32)(args[1])));
    }
    case P111_OP_U32_MOD: {
      p111_primitive_arity(count, 2);
      return ((u32)(args[1]) == 0 ? args[0] : U32_BIN(args[0], -, U32_QUO((u32)(args[0]), (u32)(args[1])) * args[1]));
    }
    case P111_OP_U32_NOT: {
      p111_primitive_arity(count, 1);
      return ((u64)~(u32)(args[0]));
    }
    case P111_OP_U32_IS_ZERO: {
      p111_primitive_arity(count, 1);
      return U32_BIN(args[0], ==, 0);
    }
    case P111_OP_U32_CMP: {
      p111_primitive_arity(count, 2);
      Term cmp = (U32_BIN(args[0], >, args[1]) + U32_BIN(args[0], >=, args[1]));
      return term_pak(cmp == 0 ? CID_LT : cmp == 1 ? CID_EQ : CID_GT, 0);
    }
    case P111_OP_U32_TO_F32: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)(u32)(args[0]));
    }
    case P111_OP_U32_TO_NAT: {
      p111_primitive_arity(count, 1);
      return ((u64)args[0]);
    }
    case P111_OP_U32_FROM_NAT: {
      p111_primitive_arity(count, 1);
      return ((u64)(u32)(args[0]));
    }
    case P111_OP_F32_ADD: {
      p111_primitive_arity(count, 2);
      return f32_rewrap(f32_unbox(args[0]) + f32_unbox(args[1]));
    }
    case P111_OP_F32_SUB: {
      p111_primitive_arity(count, 2);
      return f32_rewrap(f32_unbox(args[0]) - f32_unbox(args[1]));
    }
    case P111_OP_F32_MUL: {
      p111_primitive_arity(count, 2);
      return f32_rewrap(f32_unbox(args[0]) * f32_unbox(args[1]));
    }
    case P111_OP_F32_DIV: {
      p111_primitive_arity(count, 2);
      return f32_rewrap(f32_unbox(args[0]) / f32_unbox(args[1]));
    }
    case P111_OP_F32_IS_EQ: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) == f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_NE: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) != f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_LT: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) < f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_LE: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) <= f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_GT: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) > f32_unbox(args[1])));
    }
    case P111_OP_F32_IS_GE: {
      p111_primitive_arity(count, 2);
      return ((u64)(f32_unbox(args[0]) >= f32_unbox(args[1])));
    }
    case P111_OP_F32_SQRT: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)sqrt(f32_unbox(args[0])));
    }
    case P111_OP_F32_EXP: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)exp(f32_unbox(args[0])));
    }
    case P111_OP_F32_LOG: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)log(f32_unbox(args[0])));
    }
    case P111_OP_F32_LOG2: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)log2(f32_unbox(args[0])));
    }
    case P111_OP_F32_LOG10: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)log10(f32_unbox(args[0])));
    }
    case P111_OP_F32_SIN: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)sin(f32_unbox(args[0])));
    }
    case P111_OP_F32_COS: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)cos(f32_unbox(args[0])));
    }
    case P111_OP_F32_TAN: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)tan(f32_unbox(args[0])));
    }
    case P111_OP_F32_ASIN: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)asin(f32_unbox(args[0])));
    }
    case P111_OP_F32_ACOS: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)acos(f32_unbox(args[0])));
    }
    case P111_OP_F32_ATAN: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)atan(f32_unbox(args[0])));
    }
    case P111_OP_F32_SINH: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)sinh(f32_unbox(args[0])));
    }
    case P111_OP_F32_COSH: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)cosh(f32_unbox(args[0])));
    }
    case P111_OP_F32_TANH: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)tanh(f32_unbox(args[0])));
    }
    case P111_OP_F32_FLOOR: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)floor(f32_unbox(args[0])));
    }
    case P111_OP_F32_CEIL: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)ceil(f32_unbox(args[0])));
    }
    case P111_OP_F32_TRUNC: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)trunc(f32_unbox(args[0])));
    }
    case P111_OP_F32_ABS: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)fabs(f32_unbox(args[0])));
    }
    case P111_OP_F32_POW: {
      p111_primitive_arity(count, 2);
      return f32_rewrap((f32)pow(f32_unbox(args[0]), f32_unbox(args[1])));
    }
    case P111_OP_F32_ATAN2: {
      p111_primitive_arity(count, 2);
      return f32_rewrap((f32)atan2(f32_unbox(args[0]), f32_unbox(args[1])));
    }
    case P111_OP_F32_MOD: {
      p111_primitive_arity(count, 2);
      return f32_rewrap((f32)fmod(f32_unbox(args[0]), f32_unbox(args[1])));
    }
    case P111_OP_F32_NEG: {
      p111_primitive_arity(count, 1);
      return f32_rewrap(-f32_unbox(args[0]));
    }
    case P182_OP_F32_FROM_NAT: {
      p111_primitive_arity(count, 1);
      return f32_rewrap((f32)args[0]);
    }
    case P111_OP_F32_TO_U32: {
      p111_primitive_arity(count, 1);
      return f32_to_u32(args[0]);
    }
    case P111_OP_F32_BITS: {
      p111_primitive_arity(count, 1);
      return args[0];
    }
    case P111_OP_F32_SHOW: {
      p111_primitive_arity(count, 1);
      return f32_show(e, args[0]);
    }
    case P111_OP_F32_READ: {
      p111_primitive_arity(count, 1);
      return f32_read(e, args[0]);
    }
    case P111_OP_NAT_ADD: {
      p111_primitive_arity(count, 2);
      return nat_chk(e, args[0] + args[1]);
    }
    case P111_OP_NAT_SUB: {
      p111_primitive_arity(count, 2);
      return (args[0] < args[1] ? 0 : args[0] - args[1]);
    }
    case P111_OP_NAT_MUL: {
      p111_primitive_arity(count, 2);
      return nat_mul(e, args[0], args[1]);
    }
    case P111_OP_NAT_DOUBLE: {
      p111_primitive_arity(count, 1);
      return nat_chk(e, args[0] + args[0]);
    }
    case P111_OP_NAT_CMP: {
      p111_primitive_arity(count, 2);
      Term cmp = ((args[0] > args[1]) + (args[0] >= args[1]));
      return term_pak(cmp == 0 ? CID_LT : cmp == 1 ? CID_EQ : CID_GT, 0);
    }
    case P111_OP_NAT_IS_LT: {
      p111_primitive_arity(count, 2);
      return (args[0] < args[1]);
    }
    case P111_OP_BOOL_OR: {
      p111_primitive_arity(count, 2);
      return (p111_native_bool(args[0]) | p111_native_bool(args[1]));
    }
    case P111_OP_BOOL_XOR: {
      p111_primitive_arity(count, 2);
      return (p111_native_bool(args[0]) ^ p111_native_bool(args[1]));
    }
    /* Additional owned results from nc_intrinsic_value/nc_array_value. */
    case P111_OP_NAT_DIVMOD: {
      p111_primitive_arity(count, 2);
      Term a = args[0], b = args[1];
      return p111_tuple(e, b == 0 ? 0 : a / b, b == 0 ? a : a % b);
    }
    case P111_OP_ARRAY_NEW: {
      p111_primitive_arity(count, 2);
      Term init[1] = {args[1]};
      return blk_new(e, !NATIVE_SCALAR_ARRAYS, args[0], 0, 1, init);
    }
    case P111_OP_ARRAY_GET: {
      p111_primitive_arity(count, 2);
      Term got = native_array_get(e, args[0], args[1]);
      return p111_tuple(e, args[0], got);
    }
    case P111_OP_ARRAY_SET: {
      p111_primitive_arity(count, 3);
      native_array_set(e, args[0], args[1], args[2]);
      return args[0];
    }
    case P111_OP_ARRAY_SWAP: {
      p111_primitive_arity(count, 3);
      Term old = native_array_swap(e, args[0], args[1], args[2]);
      return p111_tuple(e, args[0], old);
    }
    case P111_OP_ARRAY_SIZE: {
      p111_primitive_arity(count, 1);
      return p111_tuple(e, args[0], 1ull << blk_cls(args[0]));
    }
    case P111_OP_ARRAY_CLONE: {
      p111_primitive_arity(count, 1);
      Term copy = blk_copy(e, args[0]);
      return p111_tuple(e, args[0], copy);
    }
    case P111_OP_ARRAY_ATOMIC_ADD:
    case P111_OP_ARRAY_ATOMIC_MIN:
    case P111_OP_ARRAY_ATOMIC_MAX:
    case P111_OP_ARRAY_ATOMIC_AND:
    case P111_OP_ARRAY_ATOMIC_OR:
    case P111_OP_ARRAY_ATOMIC_XOR:
    case P111_OP_ARRAY_ATOMIC_EXCH:
    case P111_OP_ARRAY_ATOMIC_CAS:
    case P111_OP_ARRAY_ATOMIC_FADD: {
      p111_primitive_arity(count, op == P111_OP_ARRAY_ATOMIC_CAS ? 4 : 3);
      /* This contiguous catalogue order is exactly nc_atomic's 1..9. */
      u32 atomic_op = op - P111_OP_ARRAY_ATOMIC_ADD + 1;
      Term old = array_atomic(e, args[0], args[1], args[2],
        op == P111_OP_ARRAY_ATOMIC_CAS ? args[3] : 0, atomic_op);
      return p111_tuple(e, args[0], old);
    }
    default:
      err_fail("phase111: unknown primitive ID");
      return 0;
  }
}

static u32 p111_special_arity(u32 kind) {
  switch (kind) {
    case P111_SPECIAL_FALSE:
    case P111_SPECIAL_TRUE:
    case P111_SPECIAL_ZERO: return 0;
    case P111_SPECIAL_SUCC:
    case P111_SPECIAL_CHR:
    case P111_SPECIAL_U32:
    case P111_SPECIAL_F32:
    case P111_SPECIAL_ALEAF: return 1;
    case P111_SPECIAL_ANODE: return 2;
    default:
      err_fail("phase111: unknown special constructor ID");
      return 0;
  }
}

uint64_t p111_rt_special_ctor(P111State *state, uint32_t kind,
                             const uint64_t *args, uint32_t count) {
  Env e = state->e;
  p111_primitive_arity(count, p111_special_arity(kind));
  switch (kind) {
    case P111_SPECIAL_FALSE:
    case P111_SPECIAL_ZERO: return 0;
    case P111_SPECIAL_TRUE: return 1;
    case P111_SPECIAL_SUCC: return nat_chk(e, args[0] + 1);
    case P111_SPECIAL_CHR: return args[0];
    case P111_SPECIAL_U32:
    case P111_SPECIAL_F32: return term_word(e, args[0]);
    case P111_SPECIAL_ALEAF: {
      Term init[1] = {args[0]};
      return blk_new(e, !NATIVE_SCALAR_ARRAYS, 0, 0, 1, init);
    }
    case P111_SPECIAL_ANODE: return blk_node(e, args[0], args[1]);
    default:
      err_fail("phase111: unknown special constructor ID");
      return 0;
  }
}

uint64_t p111_rt_special_test(P111State *state, uint32_t kind, uint64_t term) {
  (void)state;
  switch (kind) {
    case P111_SPECIAL_FALSE: return !p111_native_bool(term);
    case P111_SPECIAL_TRUE: return p111_native_bool(term);
    case P111_SPECIAL_ZERO: return term == 0;
    case P111_SPECIAL_SUCC: return term != 0;
    case P111_SPECIAL_CHR:
    case P111_SPECIAL_U32:
    case P111_SPECIAL_F32: return 1;
    case P111_SPECIAL_ALEAF: return blk_cls(term) == 0;
    case P111_SPECIAL_ANODE: return blk_cls(term) != 0;
    default:
      err_fail("phase111: unknown special constructor ID");
      return 0;
  }
}

uint64_t p111_rt_special_take(P111State *state, uint32_t kind, uint64_t term,
                             uint64_t *out, uint32_t count) {
  Env e = state->e;
  p111_primitive_arity(count, p111_special_arity(kind));
  switch (kind) {
    case P111_SPECIAL_FALSE:
    case P111_SPECIAL_TRUE:
    case P111_SPECIAL_ZERO: break;
    case P111_SPECIAL_SUCC: out[0] = term - 1; break;
    case P111_SPECIAL_CHR: out[0] = term; break;
    case P111_SPECIAL_U32:
    case P111_SPECIAL_F32: out[0] = p111_native_word(e, (u32)term); break;
    case P111_SPECIAL_ALEAF:
      out[0] = blk_leaf(e, term);
      blk_free(e, term);
      break;
    case P111_SPECIAL_ANODE:
      /* The low half borrows the parent; the high half releases its shell. */
      out[0] = blk_half(e, term, 0);
      out[1] = blk_half(e, term, 1);
      break;
    default:
      err_fail("phase111: unknown special constructor ID");
      return 0;
  }
  return count;
}


// Cli
// ===

static void cli_fail(const char* msg, const char* arg) {
  fprintf(stderr, "bend: %s%s\n", msg, arg != NULL ? arg : "");
  exit(1);
}

// Main
// ====

int p111_rt_main(int argc, char** argv, const P111Program *program) {
  p111_bind(program);
  long thr = 1;
  int  gpu = 0;
  u64  mem = 0;
  char* env = strdup(getenv("BENDRTS") != NULL ? getenv("BENDRTS") : "");
  if (env == NULL) cli_fail("cannot allocate runtime options", NULL);
  char** rts = malloc(((size_t)argc + strlen(env) + 1) * sizeof(char*));
  if (rts == NULL) cli_fail("cannot allocate runtime options", NULL);
  int nr = 0;
  bool in = false;
  for (char* word = strtok(env, " \t\n"); word != NULL; word = strtok(NULL, " \t\n")) {
    rts[nr++] = word;
  }
  rts[nr++] = NULL;
  io_argv = argv;
  io_argc = argc > 0;
  for (int i = 1; i < argc; ++i) {
    char* a = argv[i];
    if (strcmp(a, "--RTS") == 0) {
      while (++i < argc) io_argv[io_argc++] = argv[i];
    } else if (strcmp(a, "+RTS") == 0 || strcmp(a, "-RTS") == 0) {
      in = a[0] == '+';
      rts[nr++] = NULL;
    } else if (in) {
      rts[nr++] = a;
    } else {
      io_argv[io_argc++] = a;
    }
  }
  for (int i = 0; i < nr; ++i) {
    const char* a = rts[i];
    const char* v = i + 1 < nr ? rts[i + 1] : NULL;
    if (a == NULL) {
      continue;
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
      if (thr < 1 || v == NULL || *v == 0 || v[strspn(v, "0123456789")] != 0) {
        cli_fail("expected a thread count of 1 or more after --threads", NULL);
      }
      i += 1;
    } else if (strcmp(a, "--gpu") == 0) {
      char*  end = NULL;
      double n   = v != NULL ? strtod(v, &end) : 0;
      u64    mul = end == NULL ? 0 : strcmp(end, "GB") == 0 ? 1ull << 30
        : strcmp(end, "MB") == 0 ? 1ull << 20 : 0;
      mem = (u64)(n * (double)mul);
      if (v != NULL && strcmp(v, "off") == 0) {
        gpu = 0;
      } else if (v != NULL && (strcmp(v, "on") == 0
        || (mem >= 16384 && end == v + strspn(v, "0123456789.")))) {
        gpu = 1;
      } else {
        cli_fail("expected on, off or a size like 4GB after --gpu", NULL);
      }
      i += 1;
    } else {
      cli_fail("unknown runtime option ", a);
    }
  }
  free(rts);
  free(env);
  if (thr != 1 || gpu != 0) cli_fail("Phase111 ABI v1 requires --threads 1 --gpu off", NULL);
  bool dev = false;
  if (gpu == 1 && BANGS != 0 && !dev) {
    cli_fail("--gpu on, but this binary found no GPU device", NULL);
  }
  Corpus H  = corpus_setup(dev, thr > 0 ? thr : cpu_count(), mem);
  int code  = io_loop(H);
  io_sync();
  return code;
}

#endif

_Static_assert(STAT_OFF == UINT64_C(51413504), "static image base ABI");

/* Additive profile11301. Append to the exact runtime04 translation unit.
 * State ABI11101, array layout flags and all underlying operations are unchanged.
 * This replaces only the temporary Tuple carrier. Input and output fields each
 * retain their ordinary ownership credits; no borrowed array payload escapes.
 */
uint64_t p113_rt_array_pair(P111State *state, uint32_t op,
                         const uint64_t *args, uint32_t count,
                         uint64_t *out, uint32_t out_count) {
  uint32_t arity = 0;
  switch (op) {
    case P111_OP_ARRAY_GET: arity = 2; break;
    case P111_OP_ARRAY_SWAP: arity = 3; break;
    case P111_OP_ARRAY_SIZE:
    case P111_OP_ARRAY_CLONE: arity = 1; break;
    default: err_fail("phase113: unsupported array pair operation"); return 0;
  }
  p111_require(count == arity, "phase113: array pair argument count mismatch");
  p111_require(out_count == 2, "phase113: array pair output count mismatch");
  p111_require(state != NULL && args != NULL && out != NULL,
               "phase113: array pair missing state or buffer");
  /* Snapshot input words before output stores, including permitted buffer alias.
   * The authenticated compiler uses distinct local input/output buffers. */
  Env e = state->e;
  Term array = args[0];
  uint32_t index = arity > 1 ? (uint32_t)args[1] : 0;
  Term value = arity > 2 ? args[2] : 0;
  Term second = 0;
  switch (op) {
    case P111_OP_ARRAY_GET: second = native_array_get(e, array, index); break;
    case P111_OP_ARRAY_SWAP: second = native_array_swap(e, array, index, value); break;
    case P111_OP_ARRAY_SIZE: second = 1ull << blk_cls(array); break;
    case P111_OP_ARRAY_CLONE: second = blk_copy(e, array); break;
    default: err_fail("phase113: impossible array pair operation"); return 0;
  }
  out[0] = array;
  out[1] = second;
  return 0;
}


/* Constant-count counterparts preserve every original public contract. */
#define P118_SIZED(N) \
uint64_t p118_p111_rt_ctor##N(P111State *state, uint32_t cid, const uint64_t *fields, uint32_t count) { \
  p111_require(count == N && cid < p111_program_active->constructor_count && N == cid_arity(cid), "phase118: constructor arity mismatch"); \
  p111_require(fields != NULL, "phase118: missing constructor fields"); \
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(N)); \
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = fields[i]; \
  } else { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, fields[i]); \
  } \
  return term_ctr(cid, at); \
} \
uint64_t p118_p111_rt_take##N(P111State *state, uint64_t term, uint64_t *out, uint32_t count) { \
  u32 cid = (u32)term_aux(term); \
  p111_require(count == N && cid < p111_program_active->constructor_count && N == cid_arity(cid), "phase118: take arity mismatch"); \
  p111_require(out != NULL, "phase118: missing take outputs"); \
  if (N == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term); \
  else { \
    p111_require(term_tag(term) == TAG_CTR, "phase118: expected constructor owner"); \
    spare_free(state->e, cls_fit(N), ctr_take(state->e, term, N, out)); \
  } \
  return N; \
}
P118_SIZED(1)
P118_SIZED(2)
P118_SIZED(3)
P118_SIZED(4)
#undef P118_SIZED

/* Private destination contract. Only the checked constructor-tail producer may
 * call these operations. A raw root and its current raw parent remain private;
 * no partial node is observable by source code. Links use ordinary rfc_seal.
 * This does not infer unique input ownership or reuse input storage. */
static void p118_destination_fill(P111State *state, Term parent, Term value) {
  u32 cid = (u32)term_aux(parent);
  p111_require(term_tag(parent) == TAG_CTR && !term_rfc(parent) &&
    cid < p111_program_active->constructor_count && cid_arity(cid) >= 2 &&
    cid_arity(cid) <= 8 && term_loc(parent) >= HEAP_OFF,
    "phase118: invalid private destination");
  Loc slot = term_loc(parent) + cid_arity(cid) - 1;
  p111_require(state->e.mem[slot] == TERM_HOLE, "phase118: destination already initialized");
  state->e.mem[slot] = ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid))
    ? value : rfc_seal(state->e, value);
}

uint64_t p118_rt_extend(P111State *state, uint64_t parent, uint32_t cid,
                        const uint64_t *prefix, uint32_t count) {
  p111_require(cid < p111_program_active->constructor_count && count >= 1 &&
    count <= 7 && count + 1 == cid_arity(cid) && prefix,
    "phase118: invalid constructor-tail prefix");
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(count + 1));
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = prefix[i];
  } else {
    for (u32 i = 0; i < count; ++i) e.mem[at + i] = rfc_seal(e, prefix[i]);
  }
  e.mem[at + count] = TERM_HOLE;
  Term node = term_ctr(cid, at);
  if (parent) p118_destination_fill(state, parent, node);
  return node;
}

uint64_t p118_rt_finish(P111State *state, uint64_t root, uint64_t parent, uint64_t result) {
  if (!parent) {
    p111_require(!root, "phase118: empty destination root mismatch");
    return result;
  }
  p111_require(root && term_tag(root) == TAG_CTR && !term_rfc(root), "phase118: missing destination root");
  p118_destination_fill(state, parent, result);
  return root;
}

/* Copy borrowed field views without transferring ownership. The original owned
 * root stays live until the certified observer returns it to its caller. */
uint64_t p118_rt_borrow_fields(P111State *state, uint64_t term, uint64_t *out,
                               uint32_t cid, uint32_t count) {
  p111_require(cid < p111_program_active->constructor_count &&
    term_aux(term) == cid && count == cid_arity(cid) && (!count || out),
    "phase118: borrowed constructor mismatch");
  if (!count) return 0;
  if (count == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term);
  else {
    p111_require(term_tag(term) == TAG_CTR, "phase118: expected borrowed constructor");
    Loc at = term_peek(state->e, term);
    for (u32 i = 0; i < count; ++i) out[i] = state->e.mem[at + i];
  }
  return count;
}


/* Exact constant-prefix copies of allocation-only p118_rt_extend. Count is
 * encoded in the helper symbol. No ownership/sealing/parent protocol changes. */
#define P118_EXTEND(N) \
uint64_t p118_rt_extend##N(P111State *state, uint64_t parent, uint32_t cid, const uint64_t *prefix) { \
  p111_require(cid < p111_program_active->constructor_count && N >= 1 && \
    N <= 7 && N + 1 == cid_arity(cid) && prefix, \
    "phase118: invalid constructor-tail prefix"); \
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(N + 1)); \
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = prefix[i]; \
  } else { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, prefix[i]); \
  } \
  e.mem[at + N] = TERM_HOLE; \
  Term node = term_ctr(cid, at); \
  if (parent) p118_destination_fill(state, parent, node); \
  return node; \
}
P118_EXTEND(1)
P118_EXTEND(2)
P118_EXTEND(3)
P118_EXTEND(4)
P118_EXTEND(5)
P118_EXTEND(6)
P118_EXTEND(7)
#undef P118_EXTEND


/* Typed variant: exact checked append equations and closed constructor layout
 * are authenticated by p125p_admitted. Dynamic ownership checks remain here.
 * Only that source factory may issue this distinct import. */
/* Additive, sequential owned-append operation. Invoked only for the checked
 * structural append identity. Failure is observationally read-only; the caller
 * still owns both original operands and uses its original complete worker.
 * Success returns the owning nonzero List Term; zero means refusal. Heads are never copied or dropped.
 * V2 also accepts RFC cells with an acquired exact count of one, along an
 * already uniquely owned path. Wrappers and heads remain untouched. */
uint64_t p125_rt_concat_typed(P111State *state, uint64_t left, uint64_t right,
                       uint32_t empty_cid, uint32_t link_cid) {
  Term nil = term_pak(empty_cid, 0), node = left;
  Loc last = 0;
  Env e = state->e;
  while (node != nil) {
    if (term_loc(node) < HEAP_OFF) return 0;
    if (term_rfc(node)) {
      u64 cell = rfc_view(e, term_loc(node));
      if ((cell & RFC_CNT) != 1) return 0;
      last = cell >> 24;
      /* A heap wrapper can refer to a static constructor. */
      if (last < HEAP_OFF) return 0;
    } else {
      last = term_loc(node);
    }
    node = e.mem[last + 1];
  }
  if (!last) {
    return right;
  }
  /* No mutation/ownership change before the entire spine was authenticated.
   * Match the ordinary constructor's publication/sealing rule exactly. */
  e.mem[last + 1] = ((p111_program_active->capabilities & UINT64_C(8)) &&
                    !cid_hot(link_cid)) ? right : rfc_seal(e, right);
  return left;
}

/* Post-verification ABIs. p111v_counted_call proves ctor metadata and buffer
 * capacity; take input shape remains dynamic and retains its original checks.
 * Allocations, fields, publication, reference counts and reclamation are exact
 * copies of the selected Phase118 runtime, not its earlier unconditional seal. */
#define P125_VERIFIED(N) \
uint64_t p125_rt_ctor##N(P111State *state, uint32_t cid, const uint64_t *fields) { \
  Env e = state->e; Loc at = heap_alloc(e, cls_fit(N)); \
  if ((p111_program_active->capabilities & UINT64_C(8)) && !cid_hot(cid)) { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = fields[i]; \
  } else { \
    for (u32 i = 0; i < N; ++i) e.mem[at + i] = rfc_seal(e, fields[i]); \
  } \
  return term_ctr(cid, at); \
} \
uint64_t p125_rt_take##N(P111State *state, uint64_t term, uint64_t *out) { \
  u32 cid = (u32)term_aux(term); \
  p111_require(cid < p111_program_active->constructor_count && N == cid_arity(cid), "phase118: take arity mismatch"); \
  if (N == 1 && term_tag(term) == TAG_PAK) out[0] = term_loc(term); \
  else { \
    p111_require(term_tag(term) == TAG_CTR, "phase118: expected constructor owner"); \
    spare_free(state->e, cls_fit(N), ctr_take(state->e, term, N, out)); \
  } \
  return N; \
}
P125_VERIFIED(1)
P125_VERIFIED(2)
P125_VERIFIED(3)
P125_VERIFIED(4)
#undef P125_VERIFIED

/* Additive helper for a source-certified Nat.divmod product. Exact arithmetic
 * copied from P111_OP_NAT_DIVMOD; no Tuple allocation or ownership operation.
 * The checked import proves a writable local buffer of at least16 bytes.
 * Both operands are full uint64_t values. A zero divisor is valid Bend input. */
uint64_t p126_rt_nat_divmod(P111State *state, uint64_t a, uint64_t b,
                          uint64_t *out) {
  (void)state;
  p111_require(out != NULL, "phase126: missing Nat.divmod product output");
  out[0] = b == 0 ? 0 : a / b;
  out[1] = b == 0 ? a : a % b;
  return 0;
}

/* Additive sequential-runtime helper. No ownership transition occurs here.
 * Decline aliased nontrivial RFC roots: count>1 independently is insufficient
 * when two adapter-owned aliases could consume the final two references. */
uint64_t p118_rt_borrow_scalar_safe(P111State *state, Term first, Term second,
                                  uint32_t count) {
  p111_require(count == 1 || count == 2, "phase118: scalar root count");
  Env e = state->e;
  if (count == 2 && !term_triv(first) && !term_triv(second) &&
      term_rfc(first) && term_rfc(second) &&
      term_loc(first) == term_loc(second)) return 0;
  if (!term_triv(first) &&
      (!term_rfc(first) || (rfc_view(e, term_loc(first)) & RFC_CNT) <= 1)) return 0;
  if (count == 2 && !term_triv(second) &&
      (!term_rfc(second) || (rfc_view(e, term_loc(second)) & RFC_CNT) <= 1)) return 0;
  return 1;
}
