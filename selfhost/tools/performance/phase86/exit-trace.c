// Diagnostic-only LD_PRELOAD interposer; leaves compiler bytes unchanged.
// Preserve failing exit status. Never use this image in timing comparisons.
#define _GNU_SOURCE
#include <execinfo.h>
#include <stdio.h>
#include <sys/syscall.h>
#include <unistd.h>

__attribute__((noreturn)) void _exit(int status) {
  void *frames[64];
  int count = backtrace(frames, 64);
  fprintf(stderr, "phase86 diagnostic _exit status=%d frames=%d\n", status, count);
  backtrace_symbols_fd(frames, count, STDERR_FILENO);
  syscall(SYS_exit_group, status);
  __builtin_unreachable();
}
