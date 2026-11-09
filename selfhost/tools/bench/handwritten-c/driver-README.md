# Shared handwritten-C driver

Compile `driver.c` separately from the selected kernel and link without LTO.
For a numeric result it imports `uint32_t bench_u32(uint32_t,uint32_t)`.
Define `P184_TEXT_RESULT` when compiling the driver for
`char *bench_text(uint32_t,uint32_t)`: every result must be a malloc-owned,
NUL-terminated string. The driver frees every result, including the initial
printed value and every warmup/measured call. Kernels need no volatile accesses.

The two invocation forms are:

```text
PROGRAM --value A B
PROGRAM EXPECTED_FILE REPS WARMUPS A B
```

`--value` calls the kernel once and prints its actual result plus a newline.
Normal mode reads the entire expected file at runtime, removes exactly one
final newline if present, and preserves all remaining whitespace. Embedded NUL
bytes are rejected. Text results compare with `strcmp`; numeric expected values,
counts and arguments must contain only decimal digits and fit U32. Empty numeric
values, signs, whitespace, junk and overflow are errors; zero counts are valid.
There is no compiled-in expected result or argument-specific shortcut.

Normal mode prints the initial actual result and newline, then the number of
correct warmup calls. It records `CLOCK_MONOTONIC` floored to milliseconds,
performs all requested measured calls with individual result comparisons, prints
the number correct, records another floored timestamp, and prints the difference.
For text kernels, result allocation and freeing occur inside each invocation's
measured cycle. Expected-file reading and initial/warmup calls precede the timer.
The measured correct-count print precedes the final timestamp, matching native45.
Stdout retains ordinary buffering with no intermediate flush; the final close
happens after timing. A multiline text value therefore occupies multiple lines.

Incorrect results reduce the printed correct counts, as in the native45 driver;
the benchmark harness must reject those observations. Invalid arguments, file,
clock or output failures, and NULL text results produce a failing process status.
This is a C11 source using the POSIX monotonic-clock API on the benchmark host.
The driver has been prepared without compiling or executing targets; root owns
numeric/text protocol checks and subsequent benchmark qualification.
