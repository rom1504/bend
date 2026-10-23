/* Generic sequential native Bend CPU sampling. Physical PC and optional
 * dispatch context are separate observations, never a logical call stack.
 * Derived from the qualified Phase68 v3 sampler; original remains unchanged. */
#define _GNU_SOURCE
#include <errno.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <inttypes.h>
#include <limits.h>
#include <link.h>
#include <pthread.h>
#include <signal.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <ucontext.h>
#include <unistd.h>

#ifdef BEND_PROFILE_UNWIND_TABLE
#include BEND_PROFILE_UNWIND_TABLE
#endif

#if !defined(__linux__) || !defined(__x86_64__)
#error "This diagnostic sampler requires Linux x86-64."
#endif
#if ATOMIC_INT_LOCK_FREE != 2
#error "Signal-safe lock-free unsigned counters are required."
#endif

enum { SAMPLE_CAPACITY = 100000 };
static uintptr_t sample_pc[SAMPLE_CAPACITY];
static uint32_t sample_dispatch[SAMPLE_CAPACITY];
static uint32_t (*dispatch_get)(void);
static int context_fd = -1;
#ifdef BEND_PROFILE_UNWIND_TABLE
static int callers_fd = -1;
static uintptr_t sample_caller[SAMPLE_CAPACITY];
static uint32_t sample_rule[SAMPLE_CAPACITY];
static uintptr_t unwind_base, stack_low, stack_high;
static unsigned unwind_found;
#endif
static _Atomic unsigned sample_count, dropped, overruns, closing;
static timer_t sample_timer;
static int output_fd = -1, sample_signal;
static long initial_tid, period_us;
static struct timespec cpu_start, process_start, wall_start;

_Noreturn static void fail(const char *message) {
  dprintf(STDERR_FILENO, "bend-sample: %s (errno=%d: %s)\n",
          message, errno, strerror(errno));
  _exit(125);
}

static uint64_t nanos(struct timespec t) {
  return (uint64_t)t.tv_sec * UINT64_C(1000000000) + (uint64_t)t.tv_nsec;
}

#ifdef BEND_PROFILE_UNWIND_TABLE
static int find_unwind_object(struct dl_phdr_info *info, size_t size, void *unused) {
  (void)size; (void)unused;
  const char *path = info->dlpi_name && *info->dlpi_name ? info->dlpi_name : "/proc/self/exe";
  struct stat st;
  if (!stat(path, &st) && (uint64_t)st.st_dev == BEND_UNWIND_OBJECT_DEVICE &&
      (uint64_t)st.st_ino == BEND_UNWIND_OBJECT_INODE) {
    unwind_base = info->dlpi_addr;
    unwind_found++;
  }
  return 0;
}

/* One physical return address, only under an exact prevalidated ELF CFI rule.
 * No heuristic stack scan, allocator, symbol lookup, or unwind library in the
 * handler. Unsupported instructions/rules remain explicit unknown samples. */
static void sample_physical_caller(unsigned index, ucontext_t *state) {
  sample_rule[index] = UINT32_MAX;
  uintptr_t pc = (uintptr_t)state->uc_mcontext.gregs[REG_RIP];
  uintptr_t sp = (uintptr_t)state->uc_mcontext.gregs[REG_RSP];
  if (pc < unwind_base || sp < stack_low || sp >= stack_high) return;
  pc -= unwind_base;
  size_t low = 0, high = BEND_UNWIND_ROW_COUNT;
  while (low < high) {
    size_t mid = low + (high - low) / 2;
    if (BEND_UNWIND_ROWS[mid].start <= pc) low = mid + 1; else high = mid;
  }
  if (!low || pc >= BEND_UNWIND_ROWS[low - 1].end) return;
  const BendUnwindRow *row = &BEND_UNWIND_ROWS[low - 1];
  if (row->cfa <= 0 || (uintptr_t)row->cfa > stack_high - sp) return;
  uintptr_t cfa = sp + (uintptr_t)row->cfa, slot;
  if (row->ra < 0) {
    /* Table generator bounds offsets to signed32, excluding INT_MIN. */
    uintptr_t magnitude = (uintptr_t)(-row->ra);
    if (magnitude > cfa - stack_low) return;
    slot = cfa - magnitude;
  } else {
    if ((uintptr_t)row->ra > stack_high - cfa) return;
    slot = cfa + (uintptr_t)row->ra;
  }
  if (slot < sp || slot > stack_high - sizeof(uintptr_t) || slot % sizeof(uintptr_t)) return;
  uintptr_t caller = *(const uintptr_t *)slot;
  if (!caller) return;
  sample_caller[index] = caller;
  sample_rule[index] = (uint32_t)(low - 1);
}
#endif

static void sample_handler(int number, siginfo_t *info, void *context) {
  int saved_errno = errno;
  if (number == sample_signal && info->si_code == SI_TIMER &&
      !atomic_load_explicit(&closing, memory_order_relaxed)) {
    if (info->si_overrun > 0)
      atomic_fetch_add_explicit(&overruns, (unsigned)info->si_overrun,
                                memory_order_relaxed);
    unsigned index = atomic_load_explicit(&sample_count, memory_order_relaxed);
    if (index < SAMPLE_CAPACITY) {
      ucontext_t *state = context;
      sample_pc[index] = (uintptr_t)state->uc_mcontext.gregs[REG_RIP];
      if (context_fd >= 0) sample_dispatch[index] = dispatch_get ? dispatch_get() : UINT32_MAX;
#ifdef BEND_PROFILE_UNWIND_TABLE
      if (callers_fd >= 0) sample_physical_caller(index, state);
#endif
      atomic_store_explicit(&sample_count, index + 1, memory_order_release);
    } else {
      atomic_fetch_add_explicit(&dropped, 1, memory_order_relaxed);
    }
  }
  errno = saved_errno;
}

__attribute__((constructor)) static void start_sampling(void) {
  const char *path = getenv("BEND_SAMPLE_OUT");
  if (!path || !*path) { errno = 0; fail("BEND_SAMPLE_OUT must name a fresh file"); }
  const char *period = getenv("BEND_SAMPLE_PERIOD_US");
  period_us = 1000;
  if (period) {
    char *end = NULL;
    errno = 0;
    period_us = strtol(period, &end, 10);
    if (errno || !end || *end || period_us < 250 || period_us > 100000) {
      errno = 0; fail("BEND_SAMPLE_PERIOD_US must be an integer from 250 to 100000");
    }
  }
  initial_tid = syscall(SYS_gettid);
  if (initial_tid != (long)getpid()) {
    errno = 0; fail("sampler must be loaded on the process main thread");
  }
  sample_signal = SIGRTMIN + 6;
  if (sample_signal > SIGRTMAX) { errno = 0; fail("reserved realtime signal unavailable"); }
  struct sigaction previous;
  if (sigaction(sample_signal, NULL, &previous)) fail("read signal disposition");
  if (previous.sa_handler != SIG_DFL) {
    errno = 0; fail("reserved realtime signal already has a handler/disposition");
  }
  sigset_t current;
  if (sigprocmask(SIG_SETMASK, NULL, &current)) fail("read signal mask");
  if (sigismember(&current, sample_signal)) {
    errno = 0; fail("reserved realtime signal is blocked");
  }
  output_fd = open(path, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0600);
  if (output_fd < 0) fail("create fresh sample output");
  char executable[PATH_MAX];
  ssize_t length = readlink("/proc/self/exe", executable, sizeof executable - 1);
  if (length < 0 || length == sizeof executable - 1) fail("read executable path");
  executable[length] = 0;
  if (dprintf(output_fd,
      "BEND_MAIN_CPU_SAMPLES_V1\nexe\t%s\npid\t%ld\ntid\t%ld\n"
      "period_us\t%ld\ncapacity\t%d\nsignal\t%d\n",
      executable, (long)getpid(), initial_tid, period_us, SAMPLE_CAPACITY,
      sample_signal) < 0) fail("write sample header");
  const char *context_path = getenv("BEND_SAMPLE_CONTEXT_OUT");
  if (context_path && *context_path) {
    context_fd = open(context_path, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (context_fd < 0) fail("create fresh dispatch-context output");
    /* Lookup is outside the handler. The optional runtime getter is a single
       lock-free atomic load, authenticated by the diagnostic runtime receipt. */
    dispatch_get = (uint32_t (*)(void))dlsym(RTLD_DEFAULT, "bend_profile_dispatch_get");
  }
  const char *callers_path = getenv("BEND_SAMPLE_CALLERS_OUT");
  if (callers_path && *callers_path) {
#ifdef BEND_PROFILE_UNWIND_TABLE
    dl_iterate_phdr(find_unwind_object, NULL);
    if (unwind_found != 1) fail("exact unwind object is not uniquely loaded");
    pthread_attr_t attributes;
    void *stack = NULL;
    size_t stack_size = 0;
    if (pthread_getattr_np(pthread_self(), &attributes) ||
        pthread_attr_getstack(&attributes, &stack, &stack_size) ||
        pthread_attr_destroy(&attributes)) fail("read sampled thread stack bounds");
    stack_low = (uintptr_t)stack;
    stack_high = stack_low + stack_size;
    if (stack_high <= stack_low) fail("invalid sampled thread stack bounds");
    callers_fd = open(callers_path, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0600);
    if (callers_fd < 0) fail("create fresh physical-callers output");
#else
    fail("physical callers requested without a compiled unwind table");
#endif
  }
  struct sigaction action;
  memset(&action, 0, sizeof action);
  action.sa_sigaction = sample_handler;
  action.sa_flags = SA_SIGINFO | SA_RESTART;
  sigemptyset(&action.sa_mask);
  if (sigaction(sample_signal, &action, NULL)) fail("install sample signal");
  struct sigevent event;
  memset(&event, 0, sizeof event);
  event.sigev_notify = SIGEV_THREAD_ID;
  event.sigev_signo = sample_signal;
  event._sigev_un._tid = (pid_t)initial_tid;
  if (timer_create(CLOCK_THREAD_CPUTIME_ID, &event, &sample_timer))
    fail("create main-thread CPU timer");
  if (clock_gettime(CLOCK_THREAD_CPUTIME_ID, &cpu_start) ||
      clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &process_start) ||
      clock_gettime(CLOCK_MONOTONIC, &wall_start)) fail("read start clocks");
  struct itimerspec timer;
  memset(&timer, 0, sizeof timer);
  timer.it_interval.tv_sec = period_us / 1000000;
  timer.it_interval.tv_nsec = (period_us % 1000000) * 1000;
  timer.it_value = timer.it_interval;
  if (timer_settime(sample_timer, 0, &timer, NULL)) fail("arm sample timer");
}

__attribute__((destructor)) static void stop_sampling(void) {
  if (output_fd < 0) return;
  atomic_store_explicit(&closing, 1, memory_order_release);
  sigset_t blocked;
  sigemptyset(&blocked);
  sigaddset(&blocked, sample_signal);
  if (sigprocmask(SIG_BLOCK, &blocked, NULL)) fail("block sample signal");
  if (timer_delete(sample_timer)) fail("delete sample timer");
  struct timespec cpu_end, process_end, wall_end;
  if (clock_gettime(CLOCK_THREAD_CPUTIME_ID, &cpu_end) ||
      clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &process_end) ||
      clock_gettime(CLOCK_MONOTONIC, &wall_end)) fail("read end clocks");
  struct sigaction action;
  if (sigaction(sample_signal, NULL, &action)) fail("read final signal disposition");
  unsigned count = atomic_load_explicit(&sample_count, memory_order_acquire);
  long final_tid = syscall(SYS_gettid);
  if (dprintf(output_fd,
      "final_tid\t%ld\nmain_thread_cpu_ns\t%" PRIu64 "\nprocess_cpu_ns\t%" PRIu64 "\nwall_ns\t%" PRIu64
      "\nsamples\t%u\ndropped\t%u\noverruns\t%u\nhandler_intact\t%d\nMAPS\n",
      final_tid, nanos(cpu_end) - nanos(cpu_start), nanos(process_end) - nanos(process_start),
      nanos(wall_end) - nanos(wall_start),
      count, atomic_load_explicit(&dropped, memory_order_relaxed),
      atomic_load_explicit(&overruns, memory_order_relaxed),
      action.sa_sigaction == sample_handler) < 0) fail("write sample metrics");
  int maps = open("/proc/self/maps", O_RDONLY | O_CLOEXEC);
  if (maps < 0) fail("open process maps");
  char buffer[8192];
  ssize_t size;
  while ((size = read(maps, buffer, sizeof buffer)) > 0) {
    ssize_t offset = 0;
    while (offset < size) {
      ssize_t written = write(output_fd, buffer + offset, (size_t)(size - offset));
      if (written < 0 && errno == EINTR) continue;
      if (written <= 0) fail("write process maps");
      offset += written;
    }
  }
  if (size < 0) fail("read process maps");
  if (close(maps)) fail("close process maps");
  if (dprintf(output_fd, "PCS\n") < 0) fail("write sample marker");
  for (unsigned index = 0; index < count; index++)
    if (dprintf(output_fd, "%" PRIxPTR "\n", sample_pc[index]) < 0)
      fail("write sample PC");
  if (dprintf(output_fd, "END\n") < 0 || close(output_fd)) fail("finish sample output");
  output_fd = -1;
  if (context_fd >= 0) {
    if (dprintf(context_fd, "BEND_DISPATCH_SAMPLES_V1\ncontext_available\t%d\nsamples\t%u\nIDS\n",
                dispatch_get != NULL, count) < 0) fail("write dispatch-context header");
    for (unsigned index = 0; index < count; index++)
      if (dprintf(context_fd, "%" PRIu32 "\n", sample_dispatch[index]) < 0)
        fail("write dispatch-context ID");
    if (dprintf(context_fd, "END\n") < 0 || close(context_fd)) fail("finish dispatch-context output");
    context_fd = -1;
  }
#ifdef BEND_PROFILE_UNWIND_TABLE
  if (callers_fd >= 0) {
    if (dprintf(callers_fd, "BEND_PHYSICAL_CALLERS_V1\nunwind_id\t%s\nobject_sha256\t%s\n"
                "samples\t%u\nROWS\n", BEND_UNWIND_ID, BEND_UNWIND_OBJECT_SHA256, count) < 0)
      fail("write physical-callers header");
    for (unsigned index = 0; index < count; index++)
      if (dprintf(callers_fd, "%" PRIu32 "\t%" PRIxPTR "\n", sample_rule[index], sample_caller[index]) < 0)
        fail("write physical caller");
    if (dprintf(callers_fd, "END\n") < 0 || close(callers_fd)) fail("finish physical-callers output");
    callers_fd = -1;
  }
#endif
  /* Keep the timer signal blocked: a queued notification must not hit SIG_DFL. */
}
