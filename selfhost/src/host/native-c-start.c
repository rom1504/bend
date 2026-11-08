/* Image startup only: preserve all public arguments for the Bend CLI.
 * The generated runtime compacts argv in place, so use a writable copy. */
#define main bend_runtime_main
#include BEND_IMAGE_C
#undef main

#ifndef BEND_RUNTIME_RTS
#define BEND_RUNTIME_RTS 0
#endif

int main(int argc, char **argv) {
  size_t extra = BEND_RUNTIME_RTS ? 7 : (BEND_NATIVE_HOST ? 6 : 5);
  char **args = calloc((size_t)argc + extra + 1, sizeof(char *));
  if (!args) { fputs("bend: cannot allocate argument vector\n", stderr); return 1; }
  args[0] = argv[0];
  if (BEND_RUNTIME_RTS) {
    args[1] = "+RTS"; args[2] = "--threads"; args[3] = "1";
    args[4] = "--gpu"; args[5] = "off"; args[6] = "-RTS";
    args[7] = "--RTS";
    /* The new runtime retains argv[0] itself; do not add a second copy. */
  } else {
    args[1] = "--threads"; args[2] = "1";
    args[3] = "--gpu"; args[4] = "off"; args[5] = "--";
    if (BEND_NATIVE_HOST) args[6] = argv[0];
  }
  for (int i = 1; i < argc; ++i) args[i + extra] = argv[i];
  int status = bend_runtime_main(argc + (int)extra, args);
  free(args);
  return status;
}
