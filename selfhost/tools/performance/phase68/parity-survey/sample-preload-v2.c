/* Linux/x86-64 main-thread CPU sampling; diagnostics only, never clean timing. */
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <limits.h>
#include <signal.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>
#include <sys/types.h>
#include <time.h>
#include <ucontext.h>
#include <unistd.h>

#if !defined(__linux__) || !defined(__x86_64__)
#error "This diagnostic sampler requires Linux x86-64."
#endif
#if ATOMIC_INT_LOCK_FREE != 2
#error "Signal-safe lock-free unsigned counters are required."
#endif

enum { SAMPLE_CAPACITY = 100000 };
static uintptr_t sample_pc[SAMPLE_CAPACITY];
static _Atomic unsigned sample_count, dropped, overruns, closing;
static timer_t sample_timer;
static int output_fd = -1, sample_signal;
static long initial_tid, period_us;
static struct timespec cpu_start, process_start, wall_start;

static void fail(const char *message) {
  dprintf(STDERR_FILENO, "bend-sample: %s (errno=%d: %s)\n",
          message, errno, strerror(errno));
  _exit(125);
}

static uint64_t nanos(struct timespec t) {
  return (uint64_t)t.tv_sec * UINT64_C(1000000000) + (uint64_t)t.tv_nsec;
}

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
  /* Keep the timer signal blocked: a queued notification must not hit SIG_DFL. */
}
