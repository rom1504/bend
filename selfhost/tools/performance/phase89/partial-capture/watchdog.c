/* Disposable Linux/glibc diagnostic. No compiler/runtime source changes.
   Start after all preload constructors; ordinary-thread exit flushes samplers. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/syscall.h>
#include <time.h>
#include <unistd.h>

typedef int (*Main)(int, char **, char **);
typedef int (*Start)(Main, int, char **, void (*)(void), void (*)(void),
                     void (*)(void), void *);
static Main target_main;
static unsigned seconds = 60;
/* 0: target running; 1: watchdog owns exit; 2: ordinary main returned. */
static _Atomic unsigned exit_owner;

static void *watchdog(void *unused) {
  (void)unused;
  struct timespec remaining = {(time_t)seconds, 0};
  while (nanosleep(&remaining, &remaining)) {
    if (errno != EINTR) _exit(125);
  }
  unsigned expected = 0;
  if (atomic_compare_exchange_strong(&exit_owner, &expected, 1)) {
    fprintf(stderr, "BEND_CAPTURE_STOP seconds=%u exit=77 tid=%ld\n",
            seconds, syscall(SYS_gettid));
    /* Deliberately NOT _exit: existing sampler destructor writes raw evidence.
       This is an ordinary thread, not a signal handler. An outer guard remains. */
    exit(77);
  }
  return NULL;
}

static int wrapped_main(int argc, char **argv, char **envp) {
  const char *text = getenv("BEND_CAPTURE_SECONDS");
  if (text) {
    char *end;
    errno = 0;
    unsigned long value = strtoul(text, &end, 10);
    if (errno || !*text || *end || value < 1 || value > 120) _exit(125);
    seconds = (unsigned)value;
  }
  pthread_t thread;
  if (pthread_create(&thread, NULL, watchdog, NULL) || pthread_detach(thread))
    _exit(125);
  int result = target_main(argc, argv, envp);
  unsigned expected = 0;
  if (!atomic_compare_exchange_strong(&exit_owner, &expected, 2)) {
    /* The watchdog already owns exit; avoid concurrent ordinary CRT exit. */
    for (;;) pause();
  }
  return result;
}

int __libc_start_main(Main main, int argc, char **argv, void (*init)(void),
                      void (*fini)(void), void (*rtld_fini)(void), void *stack_end) {
  Start next = (Start)dlsym(RTLD_NEXT, "__libc_start_main");
  if (!next) _exit(125);
  target_main = main;
  return next(wrapped_main, argc, argv, init, fini, rtld_fini, stack_end);
}
