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
