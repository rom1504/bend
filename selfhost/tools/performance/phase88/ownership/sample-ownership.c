/* Phase88 derivative of Phase68 all-thread sampler. Compiler binary unchanged.
   Adds exact IO.now phase clocks and CFI-bounded physical ownership callers.
   Generate unwind-table.h for the EXACT target before compiling this library. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <limits.h>
#include <link.h>
#include "unwind-table.h"
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
  uint64_t mono[THREAD_CAPACITY];
  uintptr_t caller[THREAD_CAPACITY][3];
  uintptr_t stack_low, stack_high;
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

static uintptr_t p88_image_base;
static int (*p88_clock)(clockid_t, struct timespec *);
enum { P88_MARKS = 64 };
typedef struct { uint64_t mono, cpu; long tid; _Atomic unsigned ready; } P88Mark;
static P88Mark p88_marks[P88_MARKS];
static _Atomic unsigned p88_mark_count;

/* Intercept only the already-existing IO.now effect's monotonic reads. The
   sampler's own clock reads and IO scheduler clocks do not become phase marks. */
int clock_gettime(clockid_t clock, struct timespec *value) {
  int result = p88_clock ? p88_clock(clock, value)
                        : (int)syscall(SYS_clock_gettime, clock, value);
  int saved_errno = errno;
  uintptr_t caller = (uintptr_t)__builtin_return_address(0);
  if (!result && clock == CLOCK_MONOTONIC &&
      atomic_load_explicit(&initialized, memory_order_acquire) &&
      !atomic_load_explicit(&closing, memory_order_relaxed) &&
      caller >= p88_image_base + P88_NOW_START &&
      caller < p88_image_base + P88_NOW_END) {
    unsigned index = atomic_fetch_add_explicit(&p88_mark_count, 1, memory_order_relaxed);
    if (index < P88_MARKS) {
      struct timespec cpu;
      P88Mark *mark = &p88_marks[index];
      mark->mono = (uint64_t)value->tv_sec * UINT64_C(1000000000) + value->tv_nsec;
      mark->cpu = !p88_clock(CLOCK_PROCESS_CPUTIME_ID, &cpu)
        ? (uint64_t)cpu.tv_sec * UINT64_C(1000000000) + cpu.tv_nsec : 0;
      mark->tid = syscall(SYS_gettid);
      atomic_store_explicit(&mark->ready, 1, memory_order_release);
    }
  }
  errno = saved_errno;
  return result;
}

static int p88_find_image(struct dl_phdr_info *info, size_t size, void *unused) {
  (void)size; (void)unused;
  if (!info->dlpi_name || !info->dlpi_name[0]) {
    p88_image_base = info->dlpi_addr;
    return 1;
  }
  return 0;
}

static const P88Unwind *p88_row(uintptr_t pc) {
  if (pc < p88_image_base) return NULL;
  pc -= p88_image_base;
  size_t low = 0, high = sizeof(p88_unwind)/sizeof(p88_unwind[0]);
  while (low < high) {
    size_t mid = low + (high - low)/2;
    if (p88_unwind[mid].start <= pc) low = mid + 1; else high = mid;
  }
  if (!low || pc >= p88_unwind[low-1].end) return NULL;
  return &p88_unwind[low-1];
}

/* No heuristic stack scanning and no signal-time allocator/unwind library.
   Only prevalidated rsp-based CFI rows are accepted. Each return-slot read is
   bounded by the interrupted pthread's known stack mapping. */
static void p88_callers(SampleThread *thread, unsigned index, ucontext_t *state) {
  uintptr_t pc = (uintptr_t)state->uc_mcontext.gregs[REG_RIP];
  uintptr_t sp = (uintptr_t)state->uc_mcontext.gregs[REG_RSP];
  for (unsigned depth = 0; depth < 3; depth++) {
    const P88Unwind *row = p88_row(pc);
    if (!row || sp < thread->stack_low || sp >= thread->stack_high ||
        row->cfa < 0 || (uintptr_t)row->cfa > thread->stack_high - sp) break;
    uintptr_t cfa = sp + (uintptr_t)row->cfa;
    uintptr_t slot = (uintptr_t)((intptr_t)cfa + row->ra);
    if (slot < thread->stack_low || slot > thread->stack_high - sizeof(uintptr_t) ||
        slot % sizeof(uintptr_t)) break;
    uintptr_t address = *(const uintptr_t *)slot;
    if (!address || cfa <= sp) break;
    thread->caller[index][depth] = address;
    pc = address - 1;
    sp = cfa;
  }
}

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
      struct timespec mono;
      thread->mono[index] = !clock_gettime(CLOCK_MONOTONIC, &mono) ? nanos(mono) : 0;
      p88_callers(thread, index, state);
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
  pthread_attr_t attributes;
  void *stack = NULL;
  size_t stack_size = 0;
  if (pthread_getattr_np(pthread_self(), &attributes) ||
      pthread_attr_getstack(&attributes, &stack, &stack_size) ||
      pthread_attr_destroy(&attributes)) fail("read interrupted thread stack bounds");
  thread->stack_low = (uintptr_t)stack;
  thread->stack_high = (uintptr_t)stack + stack_size;
  if (thread->stack_high <= thread->stack_low) fail("invalid thread stack bounds");
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
  p88_clock = (int (*)(clockid_t, struct timespec *))dlsym(RTLD_NEXT, "clock_gettime");
  if (!p88_clock) fail("resolve original clock_gettime");
  if (dl_iterate_phdr(p88_find_image, NULL) != 1) fail("find main ELF load base");
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
      "BEND_OWNERSHIP_CPU_SAMPLES_V1\nexe\t%s\npid\t%ld\ntid\t%ld\n"
      "period_us\t%ld\ncapacity\t%d\nsignal\t%d\n"
      "sampler_scope\tall_created_threads\nmax_threads\t%d\nthread_capacity\t%d\n",
      executable, (long)getpid(), initial_tid, period_us,
      MAX_THREADS * THREAD_CAPACITY, sample_signal, MAX_THREADS, THREAD_CAPACITY) < 0)
    fail("write sample header");
  if (dprintf(output_fd, "target_sha256\t%s\nphysical_caller_limit\t3\n", P88_BINARY_SHA) < 0)
    fail("write target identity");
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
  if (dprintf(output_fd, "SAMPLES\n") < 0) fail("write sample marker");
  for (unsigned index = 0; index < limit; index++) {
    SampleThread *thread = &threads[index];
    for (unsigned position = 0; position < counts[index]; position++)
      if (dprintf(output_fd, "%ld\t%" PRIu64 "\t%" PRIxPTR "\t%" PRIxPTR
          "\t%" PRIxPTR "\t%" PRIxPTR "\n", thread->tid, thread->mono[position],
          thread->pc[position], thread->caller[position][0],
          thread->caller[position][1], thread->caller[position][2]) < 0)
        fail("write timed sample");
  }
  unsigned marks = atomic_load_explicit(&p88_mark_count, memory_order_acquire);
  if (marks > P88_MARKS) fail("phase mark capacity exhausted");
  if (dprintf(output_fd, "MARKS\n") < 0) fail("write phase marker");
  for (unsigned index = 0; index < marks; index++) {
    P88Mark *mark = &p88_marks[index];
    if (!atomic_load_explicit(&mark->ready, memory_order_acquire)) fail("incomplete phase mark");
    if (dprintf(output_fd, "%u\t%ld\t%" PRIu64 "\t%" PRIu64 "\n",
        index, mark->tid, mark->mono, mark->cpu) < 0) fail("write phase clock");
  }
  if (dprintf(output_fd, "END\n") < 0 || close(output_fd)) fail("finish sample output");
  output_fd = -1;
  /* No timer deletion, handler restoration or storage release: another thread
     may be finishing a notification. Process exit reclaims the bounded state. */
}
