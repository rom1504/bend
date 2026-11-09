// Compile separately from the selected kernel, without LTO.
#define _POSIX_C_SOURCE 200809L
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifdef P184_TEXT_RESULT
extern char *bench_text(uint32_t a, uint32_t b);
#else
extern uint32_t bench_u32(uint32_t a, uint32_t b);
#endif

static void fail(const char *message) {
  fprintf(stderr, "handwritten-c driver: %s\n", message);
  exit(EXIT_FAILURE);
}

static uint32_t parse_u32(const char *text) {
  uint32_t value = 0u;
  if (*text == '\0') fail("expected a decimal U32");
  for (const unsigned char *p = (const unsigned char *)text; *p; ++p) {
    if (*p < '0' || *p > '9') fail("expected decimal digits only");
    uint32_t digit = (uint32_t)(*p - '0');
    if (value > (UINT32_MAX - digit) / 10u) fail("decimal value exceeds UINT32_MAX");
    value = value * 10u + digit;
  }
  return value;
}

static char *read_expected(const char *name) {
  FILE *file = fopen(name, "rb");
  if (!file) fail("cannot open expected-output file");
  size_t capacity = 4096u, length = 0u;
  char *text = malloc(capacity);
  if (!text) { fclose(file); fail("cannot allocate expected-output buffer"); }
  for (;;) {
    if (length == capacity - 1u) {
      if (capacity > SIZE_MAX / 2u) {
        free(text); fclose(file); fail("expected-output file is too large");
      }
      capacity *= 2u;
      char *larger = realloc(text, capacity);
      if (!larger) { free(text); fclose(file); fail("cannot grow expected-output buffer"); }
      text = larger;
    }
    size_t got = fread(text + length, 1u, capacity - length - 1u, file);
    length += got;
    if (ferror(file)) { free(text); fclose(file); fail("cannot read expected-output file"); }
    if (feof(file)) break;
  }
  if (fclose(file) != 0) { free(text); fail("cannot close expected-output file"); }
  // Remove one optional output terminator, retaining all other whitespace.
  if (length != 0u && text[length - 1u] == '\n') --length;
  if (memchr(text, '\0', length)) { free(text); fail("expected output contains a NUL byte"); }
  text[length] = '\0';
  return text;
}

static uint64_t monotonic_ms(void) {
  struct timespec stamp;
  if (clock_gettime(CLOCK_MONOTONIC, &stamp) != 0) fail("CLOCK_MONOTONIC failed");
  if (stamp.tv_sec < 0 || stamp.tv_nsec < 0 || stamp.tv_nsec >= 1000000000L)
    fail("invalid monotonic timestamp");
  uintmax_t seconds = (uintmax_t)stamp.tv_sec;
  uint64_t fraction = (uint64_t)stamp.tv_nsec / 1000000u;
  if (seconds > (UINT64_MAX - fraction) / 1000u) fail("monotonic milliseconds overflow");
  return (uint64_t)seconds * 1000u + fraction;
}

static void print_value(uint32_t a, uint32_t b) {
#ifdef P184_TEXT_RESULT
  char *value = bench_text(a, b);
  if (!value) fail("bench_text returned NULL");
  int status = printf("%s\n", value);
  free(value);
#else
  uint32_t value = bench_u32(a, b);
  int status = printf("%" PRIu32 "\n", value);
#endif
  if (status < 0) fail("cannot write initial result");
}

#ifdef P184_TEXT_RESULT
static uint32_t run_calls(uint32_t count, uint32_t a, uint32_t b, const char *expected) {
#else
static uint32_t run_calls(uint32_t count, uint32_t a, uint32_t b, uint32_t expected) {
#endif
  uint32_t correct = 0u;
  for (uint32_t i = 0u; i < count; ++i) {
#ifdef P184_TEXT_RESULT
    char *value = bench_text(a, b);
    if (!value) fail("bench_text returned NULL");
    if (strcmp(value, expected) == 0) ++correct;
    free(value);
#else
    uint32_t value = bench_u32(a, b);
    if (value == expected) ++correct;
#endif
  }
  return correct;
}

int main(int argc, char **argv) {
  if (argc == 4 && strcmp(argv[1], "--value") == 0) {
    uint32_t a = parse_u32(argv[2]), b = parse_u32(argv[3]);
    print_value(a, b);
    return fclose(stdout) == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
  }
  if (argc != 6 || strcmp(argv[1], "--value") == 0)
    fail("usage: PROGRAM --value A B | PROGRAM EXPECTED_FILE REPS WARMUPS A B");
  uint32_t repetitions = parse_u32(argv[2]), warmups = parse_u32(argv[3]);
  uint32_t a = parse_u32(argv[4]), b = parse_u32(argv[5]);
  char *expected_text = read_expected(argv[1]);
#ifdef P184_TEXT_RESULT
  const char *expected = expected_text;
#else
  uint32_t expected = parse_u32(expected_text);
#endif
  print_value(a, b);
  uint32_t warm_correct = run_calls(warmups, a, b, expected);
  if (printf("%" PRIu32 "\n", warm_correct) < 0) fail("cannot write warmup count");
  uint64_t begin = monotonic_ms();
  uint32_t correct = run_calls(repetitions, a, b, expected);
  if (printf("%" PRIu32 "\n", correct) < 0) fail("cannot write measured count");
  uint64_t end = monotonic_ms();
  if (end < begin) fail("monotonic clock moved backwards");
  if (printf("%" PRIu64 "\n", end - begin) < 0) fail("cannot write elapsed milliseconds");
  free(expected_text);
  // Normal stdio buffering throughout; close only after the final timestamp.
  return fclose(stdout) == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
