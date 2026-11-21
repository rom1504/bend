/* Diagnostic for sequential compiler executions under the repository CPU guard. */
#define _POSIX_C_SOURCE 200809L
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "dimensions.h"

uint64_t p203_counts[P203_COUNTERS];
unsigned char p203_seen[P203_STAGES];
static struct {
  unsigned id;
  uint64_t wall, cpu, totals[P203_COUNTERS];
} events[P203_STAGES];
static unsigned used;

static uint64_t nanos(clockid_t id) {
  struct timespec now;
  if (clock_gettime(id, &now)) abort();
  return (uint64_t)now.tv_sec * 1000000000u + now.tv_nsec;
}
void p203_mark(unsigned id) {
  if (id >= P203_STAGES || used >= P203_STAGES || p203_seen[id]) abort();
  p203_seen[id] = 1;
  events[used].id = id;
  events[used].wall = nanos(CLOCK_MONOTONIC);
  events[used].cpu = nanos(CLOCK_PROCESS_CPUTIME_ID);
  memcpy(events[used].totals, p203_counts, sizeof p203_counts);
  ++used;
}
__attribute__((constructor)) static void start(void) { p203_mark(0); }
__attribute__((destructor)) static void finish(void) {
  p203_mark(P203_STAGES - 1);
  const char *path = getenv("BEND_PHASE203_OBSERVATIONS");
  if (!path) abort();
  FILE *f = fopen(path, "wx");
  if (!f) abort();
  for (unsigned i = 0; i < used; ++i) {
    fprintf(f,"%u %" PRIu64 " %" PRIu64,events[i].id,events[i].wall,events[i].cpu);
    for (unsigned k = 0; k < P203_COUNTERS; ++k)
      if (events[i].totals[k]) fprintf(f," %u=%" PRIu64,k,events[i].totals[k]);
    fputc('\n',f);
  }
  if (fclose(f)) abort();
}
