/* Public argv adapter only. Link with -Wl,--wrap=main. The generated main and
 * runtime object remain byte-for-byte unchanged. Root qualification must test
 * help/version/options, no-overwrite and effect-provider integrity. */
#include <stdio.h>
#include <stdlib.h>

extern int __real_main(int argc, char **argv);

int __wrap_main(int argc, char **argv) {
  char **args = calloc((size_t)argc + 7, sizeof(char *));
  if (!args) {
    fputs("bend: cannot allocate argument vector\n", stderr);
    return 1;
  }
  args[0] = argv[0];
  args[1] = "--threads"; args[2] = "1";
  args[3] = "--gpu"; args[4] = "off"; args[5] = "--";
  args[6] = argv[0];
  for (int i = 1; i < argc; ++i) args[i + 6] = argv[i];
  int result = __real_main(argc + 6, args);
  free(args);
  return result;
}
