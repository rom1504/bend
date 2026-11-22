#define _GNU_SOURCE
#include <dlfcn.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <ucontext.h>
#include <unistd.h>

#define MAX_SAMPLES (1 << 20)

typedef struct {
  uint64_t rip;
  uint64_t ret0;
  uint32_t tick;
  uint32_t pad;
} Sample;

static Sample g_samples[MAX_SAMPLES];
static volatile uint32_t g_count = 0;
static volatile uint32_t g_ticks = 0;
static volatile uint32_t g_max_ticks = 0;
static const char *g_out_path = NULL;
static volatile int g_dumped = 0;

static void dump_samples(void) {
  if (__sync_lock_test_and_set(&g_dumped, 1)) return;
  if (!g_out_path) return;
  FILE *f = fopen(g_out_path, "wb");
  if (!f) return;
  uint32_t n = g_count;
  if (n > MAX_SAMPLES) n = MAX_SAMPLES;
  fwrite(g_samples, sizeof(Sample), n, f);
  fclose(f);
}

static void on_sigprof(int sig, siginfo_t *info, void *uctx) {
  (void)sig; (void)info;
  ucontext_t *uc = (ucontext_t *)uctx;
  uint32_t tick = ++g_ticks;
  uint32_t idx = g_count;
  if (idx < MAX_SAMPLES) {
    g_samples[idx].rip = (uint64_t)uc->uc_mcontext.gregs[REG_RIP];
    uint64_t rbp = (uint64_t)uc->uc_mcontext.gregs[REG_RBP];
    uint64_t rsp = (uint64_t)uc->uc_mcontext.gregs[REG_RSP];
    uint64_t ret0 = 0;
    if (rsp > 0x10000 && (rsp & 7) == 0) {
      ret0 = *(uint64_t *)rsp;
    }
    (void)rbp;
    g_samples[idx].ret0 = ret0;
    g_samples[idx].tick = tick;
    g_samples[idx].pad = 0;
    g_count = idx + 1;
  }
  if (g_max_ticks > 0 && tick >= g_max_ticks) {
    struct itimerval zero = {{0, 0}, {0, 0}};
    setitimer(ITIMER_PROF, &zero, NULL);
    dump_samples();
    _exit(0);
  }
}

static void on_term(int sig) {
  (void)sig;
  dump_samples();
  _exit(0);
}

__attribute__((constructor))
static void prof_init(void) {
  g_out_path = getenv("PROF_OUT");
  if (!g_out_path) return;
  const char *max_s = getenv("PROF_SECONDS");
  if (max_s) {
    int sec = atoi(max_s);
    if (sec > 0) g_max_ticks = (uint32_t)(sec * 999);
  }
  atexit(dump_samples);
  signal(SIGTERM, on_term);
  signal(SIGINT, on_term);

  struct sigaction sa;
  sa.sa_sigaction = on_sigprof;
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_SIGINFO | SA_RESTART;
  sigaction(SIGPROF, &sa, NULL);

  struct itimerval it;
  it.it_interval.tv_sec = 0;
  it.it_interval.tv_usec = 1001;
  it.it_value.tv_sec = 0;
  it.it_value.tv_usec = 1001;
  setitimer(ITIMER_PROF, &it, NULL);
}
