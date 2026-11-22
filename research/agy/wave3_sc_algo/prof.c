#define _GNU_SOURCE
#include <signal.h>
#include <sys/time.h>
#include <ucontext.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>

static int out_fd = -1;
static struct timespec t0;
static uint64_t buf[512];
static int buf_n = 0;

static void flush_buf(void) {
    if (out_fd >= 0 && buf_n > 0) {
        ssize_t r = write(out_fd, buf, (size_t)buf_n * sizeof(uint64_t));
        (void)r;
        buf_n = 0;
    }
}

static void handler(int sig, siginfo_t *info, void *uctx) {
    (void)sig; (void)info;
    ucontext_t *uc = (ucontext_t *)uctx;
    uint64_t pc = (uint64_t)uc->uc_mcontext.gregs[REG_RIP];
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    uint64_t ms = (uint64_t)(ts.tv_sec - t0.tv_sec) * 1000ULL +
                  (uint64_t)(ts.tv_nsec - t0.tv_nsec) / 1000000ULL;
    buf[buf_n++] = ms;
    buf[buf_n++] = pc;
    if (buf_n >= 32) flush_buf();
}

__attribute__((destructor))
static void fini(void) {
    struct itimerval it = {{0, 0}, {0, 0}};
    setitimer(ITIMER_PROF, &it, NULL);
    flush_buf();
    if (out_fd >= 0) close(out_fd);
}

__attribute__((constructor))
static void init(void) {
    const char *path = getenv("PROF_OUT");
    if (!path) return;
    out_fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (out_fd < 0) return;
    clock_gettime(CLOCK_MONOTONIC, &t0);
    struct sigaction sa;
    sa.sa_sigaction = handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_SIGINFO | SA_RESTART;
    sigaction(SIGPROF, &sa, NULL);
    struct itimerval it;
    it.it_interval.tv_sec = 0;
    it.it_interval.tv_usec = 10000; // 10ms = 100 Hz
    it.it_value.tv_sec = 0;
    it.it_value.tv_usec = 10000;
    setitimer(ITIMER_PROF, &it, NULL);
}
