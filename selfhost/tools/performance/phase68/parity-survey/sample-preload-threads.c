/* Linux/x86-64 bounded CPU sampling of main and intercepted pthreads. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <limits.h>
#include <pthread.h>
#include <signal.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>
#include <time.h>
#include <ucontext.h>
#include <unistd.h>

#if !defined(__linux__) || !defined(__x86_64__)
#error "This diagnostic sampler requires Linux x86-64."
#endif
#if ATOMIC_INT_LOCK_FREE != 2
#error "Signal-safe lock-free unsigned counters are required."
#endif

enum { MAX_THREADS = 32, THREAD_CAPACITY = 25000 };
typedef struct {
  uintptr_t pc[THREAD_CAPACITY];
  _Atomic unsigned count, dropped, overruns, ready, ended;
  timer_t timer;
  clockid_t clock;
  uint64_t cpu_start, cpu_end;
  long tid;
  void *(*entry)(void *);
  void *argument;
} SampleThread;
static SampleThread threads[MAX_THREADS];
static __thread SampleThread *local_thread __attribute__((tls_model("initial-exec")));
static _Atomic unsigned next_thread = 1, closing, initialized, overflow;
static int (*next_pthread_create)(pthread_t *, const pthread_attr_t *,
                                  void *(*)(void *), void *);
static int output_fd = -1, sample_signal;
static long initial_tid, period_us;
static struct timespec process_start, wall_start;

static _Noreturn void fail(const char *message) {
  dprintf(STDERR_FILENO, "bend-sample-threads: %s (errno=%d: %s)\n",
          message, errno, strerror(errno));
  _exit(125);
}

static uint64_t nanos(struct timespec time) {
  return (uint64_t)time.tv_sec * UINT64_C(1000000000) + (uint64_t)time.tv_nsec;
}

static void sample_handler(int number, siginfo_t *info, void *context) {
  int saved_errno = errno;
  SampleThread *thread = local_thread;
  if (thread && number == sample_signal && info->si_code == SI_TIMER &&
      !atomic_load_explicit(&closing, memory_order_relaxed)) {
    if (info->si_overrun > 0)
      atomic_fetch_add_explicit(&thread->overruns, (unsigned)info->si_overrun,
                                memory_order_relaxed);
    unsigned index = atomic_load_explicit(&thread->count, memory_order_relaxed);
    if (index < THREAD_CAPACITY) {
      ucontext_t *state = context;
      thread->pc[index] = (uintptr_t)state->uc_mcontext.gregs[REG_RIP];
      atomic_store_explicit(&thread->count, index + 1, memory_order_release);
    } else {
      atomic_fetch_add_explicit(&thread->dropped, 1, memory_order_relaxed);
    }
  }
  errno = saved_errno;
}

static void start_thread(SampleThread *thread) {
  local_thread = thread;
  thread->tid = syscall(SYS_gettid);
  sigset_t mask;
  if (pthread_sigmask(SIG_SETMASK, NULL, &mask)) fail("read thread signal mask");
  if (sigismember(&mask, sample_signal)) {
    errno = 0; fail("reserved realtime signal blocked in sampled thread");
  }
  int code = pthread_getcpuclockid(pthread_self(), &thread->clock);
  if (code) { errno = code; fail("get thread CPU clock"); }
  struct timespec start;
  if (clock_gettime(thread->clock, &start)) fail("read thread start CPU clock");
  thread->cpu_start = nanos(start);
  struct sigevent event;
  memset(&event, 0, sizeof event);
  event.sigev_notify = SIGEV_THREAD_ID;
  event.sigev_signo = sample_signal;
  event._sigev_un._tid = (pid_t)thread->tid;
  if (timer_create(CLOCK_THREAD_CPUTIME_ID, &event, &thread->timer))
    fail("create thread CPU timer");
  struct itimerspec timer;
  memset(&timer, 0, sizeof timer);
  timer.it_interval.tv_sec = period_us / 1000000;
  timer.it_interval.tv_nsec = (period_us % 1000000) * 1000;
  timer.it_value = timer.it_interval;
  if (timer_settime(thread->timer, 0, &timer, NULL)) fail("arm thread CPU timer");
  atomic_store_explicit(&thread->ready, 1, memory_order_release);
}

static void stop_thread(void *argument) {
  SampleThread *thread = argument;
  struct itimerspec zero = {0};
  /* Never delete here: main may concurrently disarm the same stable timer ID. */
  if (timer_settime(thread->timer, 0, &zero, NULL) &&
      !atomic_load_explicit(&closing, memory_order_acquire))
    fail("disarm exiting thread timer");
  struct timespec end;
  if (clock_gettime(CLOCK_THREAD_CPUTIME_ID, &end)) fail("read exiting thread CPU clock");
  thread->cpu_end = nanos(end);
  atomic_store_explicit(&thread->ended, 1, memory_order_release);
}

static void *thread_entry(void *argument) {
  SampleThread *thread = argument;
  start_thread(thread);
  void *result;
  pthread_cleanup_push(stop_thread, thread);
  result = thread->entry(thread->argument);
  pthread_cleanup_pop(1);
  return result;
}

int pthread_create(pthread_t *id, const pthread_attr_t *attributes,
                   void *(*entry)(void *), void *argument) {
  if (!atomic_load_explicit(&initialized, memory_order_acquire)) {
    errno = 0; fail("pthread_create called before sampler constructor completed");
  }
  if (atomic_load_explicit(&closing, memory_order_acquire))
    return next_pthread_create(id, attributes, entry, argument);
  unsigned index = atomic_fetch_add_explicit(&next_thread, 1, memory_order_relaxed);
  if (index >= MAX_THREADS) {
    atomic_fetch_add_explicit(&overflow, 1, memory_order_relaxed);
    return next_pthread_create(id, attributes, entry, argument);
  }
  threads[index].entry = entry;
  threads[index].argument = argument;
  return next_pthread_create(id, attributes, thread_entry, &threads[index]);
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
  if (initial_tid != (long)getpid()) { errno = 0; fail("load sampler on main thread"); }
  sample_signal = SIGRTMIN + 6;
  if (sample_signal > SIGRTMAX) { errno = 0; fail("reserved signal unavailable"); }
  struct sigaction previous;
  if (sigaction(sample_signal, NULL, &previous)) fail("read signal disposition");
  if (previous.sa_handler != SIG_DFL) { errno = 0; fail("reserved signal occupied"); }
  next_pthread_create = (int (*)(pthread_t *, const pthread_attr_t *,
                                void *(*)(void *), void *))dlsym(RTLD_NEXT, "pthread_create");
  if (!next_pthread_create) { errno = 0; fail("resolve original pthread_create"); }
  output_fd = open(path, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0600);
  if (output_fd < 0) fail("create fresh sample output");
  char executable[PATH_MAX];
  ssize_t length = readlink("/proc/self/exe", executable, sizeof executable - 1);
  if (length < 0 || length == sizeof executable - 1) fail("read executable path");
  executable[length] = 0;
  if (dprintf(output_fd,
      "BEND_MAIN_CPU_SAMPLES_V1\nexe\t%s\npid\t%ld\ntid\t%ld\n"
      "period_us\t%ld\ncapacity\t%d\nsignal\t%d\n"
      "sampler_scope\tall_created_threads\nmax_threads\t%d\nthread_capacity\t%d\n",
      executable, (long)getpid(), initial_tid, period_us,
      MAX_THREADS * THREAD_CAPACITY, sample_signal, MAX_THREADS, THREAD_CAPACITY) < 0)
    fail("write sample header");
  struct sigaction action;
  memset(&action, 0, sizeof action);
  action.sa_sigaction = sample_handler;
  action.sa_flags = SA_SIGINFO | SA_RESTART;
  sigemptyset(&action.sa_mask);
  if (sigaction(sample_signal, &action, NULL)) fail("install sample signal");
  if (clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &process_start) ||
      clock_gettime(CLOCK_MONOTONIC, &wall_start)) fail("read start clocks");
  start_thread(&threads[0]);
  atomic_store_explicit(&initialized, 1, memory_order_release);
}

__attribute__((destructor)) static void stop_sampling(void) {
  if (output_fd < 0) return;
  atomic_store_explicit(&closing, 1, memory_order_release);
  sigset_t blocked;
  sigemptyset(&blocked);
  sigaddset(&blocked, sample_signal);
  if (pthread_sigmask(SIG_BLOCK, &blocked, NULL)) fail("block main sample signal");
  unsigned allocated = atomic_load_explicit(&next_thread, memory_order_acquire);
  unsigned limit = allocated < MAX_THREADS ? allocated : MAX_THREADS;
  unsigned counts[MAX_THREADS] = {0};
  unsigned count = 0, lost = 0, delayed = 0, ready = 0, ended = 0, clock_failures = 0;
  unsigned disarm_failures = 0;
  uint64_t sampled_cpu = 0, main_cpu = 0;
  struct itimerspec zero = {0};
  for (unsigned index = 0; index < limit; index++) {
    SampleThread *thread = &threads[index];
    if (!atomic_load_explicit(&thread->ready, memory_order_acquire)) continue;
    ready++;
    /* Threads may remain live forever in the native pool. Do not join/free them.
       CPU timers may have expired with a dead thread; record disarm failures. */
    if (timer_settime(thread->timer, 0, &zero, NULL)) disarm_failures++;
    uint64_t end_ns = 0;
    if (atomic_load_explicit(&thread->ended, memory_order_acquire)) {
      ended++;
      end_ns = thread->cpu_end;
    } else {
      struct timespec now;
      if (!clock_gettime(thread->clock, &now)) end_ns = nanos(now);
      else if (atomic_load_explicit(&thread->ended, memory_order_acquire)) {
        ended++;
        end_ns = thread->cpu_end;
      } else clock_failures++;
    }
    uint64_t elapsed = end_ns >= thread->cpu_start ? end_ns - thread->cpu_start : 0;
    sampled_cpu += elapsed;
    if (!index) main_cpu = elapsed;
    counts[index] = atomic_load_explicit(&thread->count, memory_order_acquire);
    count += counts[index];
    lost += atomic_load_explicit(&thread->dropped, memory_order_relaxed);
    delayed += atomic_load_explicit(&thread->overruns, memory_order_relaxed);
  }
  struct timespec process_end, wall_end;
  if (clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &process_end) ||
      clock_gettime(CLOCK_MONOTONIC, &wall_end)) fail("read end clocks");
  struct sigaction action;
  if (sigaction(sample_signal, NULL, &action)) fail("read final signal disposition");
  if (dprintf(output_fd,
      "final_tid\t%ld\nmain_thread_cpu_ns\t%" PRIu64 "\nprocess_cpu_ns\t%" PRIu64
      "\nsampled_thread_cpu_ns\t%" PRIu64 "\nwall_ns\t%" PRIu64
      "\nthreads_allocated\t%u\nthreads_ready\t%u\nthreads_ended\t%u\n"
      "thread_overflow\t%u\nthread_clock_failures\t%u\ntimer_disarm_failures\t%u\n"
      "samples\t%u\ndropped\t%u\noverruns\t%u\nhandler_intact\t%d\nMAPS\n",
      syscall(SYS_gettid), main_cpu, nanos(process_end) - nanos(process_start),
      sampled_cpu, nanos(wall_end) - nanos(wall_start), allocated, ready, ended,
      atomic_load_explicit(&overflow, memory_order_relaxed), clock_failures, disarm_failures,
      count, lost, delayed, action.sa_sigaction == sample_handler) < 0)
    fail("write sample metrics");
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
  if (size < 0 || close(maps)) fail("read/close process maps");
  if (dprintf(output_fd, "PCS\n") < 0) fail("write sample marker");
  for (unsigned index = 0; index < limit; index++)
    for (unsigned position = 0; position < counts[index]; position++)
      if (dprintf(output_fd, "%" PRIxPTR "\n", threads[index].pc[position]) < 0)
        fail("write sample PC");
  if (dprintf(output_fd, "END\n") < 0 || close(output_fd)) fail("finish sample output");
  output_fd = -1;
  /* No timer deletion, handler restoration or storage release: another thread
     may be finishing a notification. Process exit reclaims the bounded state. */
}
