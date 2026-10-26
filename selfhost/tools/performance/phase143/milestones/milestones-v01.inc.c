/* Opt-in, sequential diagnostic milestones. No compiler or source semantics.
 * Included after bp_die; generated map is bound to one exact program object. */
#include <time.h>
#include "milestones-map.h"
static FILE *bm_file;
static uint32_t bm_next, bm_bad_order, bm_clock_error;
static uint32_t bm_counts[BM_COUNT];
static uint64_t bm_wall[BM_COUNT], bm_cpu[BM_COUNT], bm_wall_start, bm_cpu_start;
static const P111Segment *bm_functions;

static int bm_clock(clockid_t clock, uint64_t *value) {
  struct timespec now;
  if (clock_gettime(clock, &now) || now.tv_sec < 0 || now.tv_nsec < 0 ||
      now.tv_nsec >= 1000000000L) return 0;
  *value = (uint64_t)now.tv_sec * UINT64_C(1000000000) + (uint64_t)now.tv_nsec;
  return 1;
}

static inline void bend_milestone_enter(uint32_t fid) {
  if (!bm_file || fid > BM_MAX_FID) return;
  uint32_t rank = bm_rank[fid];
  if (!rank) return;
  uint32_t at = rank - 1;
  if (bm_counts[at] != UINT32_MAX) ++bm_counts[at];
  if (at != bm_next || bm_counts[at] != 1) { bm_bad_order = 1; return; }
  if (!bm_clock(CLOCK_MONOTONIC, &bm_wall[at]) ||
      !bm_clock(CLOCK_PROCESS_CPUTIME_ID, &bm_cpu[at])) {
    bm_clock_error = 1; return;
  }
  ++bm_next;
}

static void bend_milestone_finish(void) {
  if (!bm_file) return;
  uint64_t wall = 0, cpu = 0;
  if (!bm_clock(CLOCK_MONOTONIC, &wall) || !bm_clock(CLOCK_PROCESS_CPUTIME_ID, &cpu))
    bm_clock_error = 1;
  int complete = bm_next == BM_COUNT && !bm_bad_order && !bm_clock_error;
  fprintf(bm_file,"{\n\"schema\":\"bend-dispatch-milestones-v1\",\"complete\":%s,"
    "\"sequentialOnly\":true,\"expectedSegmentCount\":%u,\"expectedMarkers\":%u,"
    "\"observedInOrder\":%u,\"badOrderOrDuplicate\":%s,\"clockError\":%s,"
    "\"wallStartNs\":%" PRIu64 ",\"cpuStartNs\":%" PRIu64 ","
    "\"wallFinishNs\":%" PRIu64 ",\"cpuFinishNs\":%" PRIu64 ",\n\"rows\":[\n",
    complete ? "true":"false",BM_SEGMENTS,BM_COUNT,bm_next,
    bm_bad_order ? "true":"false",bm_clock_error ? "true":"false",
    bm_wall_start,bm_cpu_start,wall,cpu);
  for (uint32_t i=0;i<BM_COUNT;++i) {
    fprintf(bm_file,"%s{\"label\":\"%s\",\"fid\":%u,\"segmentAddress\":\"0x%" PRIxPTR
      "\",\"entries\":%u,\"wallNs\":%" PRIu64 ",\"cpuNs\":%" PRIu64 "}",
      i ? ",\n":"",bm_labels[i],bm_fids[i],(uintptr_t)bm_functions[bm_fids[i]],
      bm_counts[i],bm_wall[i],bm_cpu[i]);
  }
  fputs("\n],\"scope\":\"Direct dispatch entries only; missing, repeated or reordered markers invalidate stage attribution. No private/inlined boundary is inferred.\"}\n",bm_file);
  int failed=ferror(bm_file);if(fclose(bm_file))failed=1;bm_file=NULL;
  if(failed)bp_die("milestone sidecar could not be completed");
}

static void bend_milestone_initialize(uint32_t segments,const P111Segment *functions) {
  const char *path=getenv("BEND_MILESTONES_OUT");
  if(!path || !*path)return;
  if(segments!=BM_SEGMENTS || !functions)bp_die("milestone program segment count mismatch");
  const char *counters=getenv("BEND_PROFILE_COUNTERS");
  if((counters && strcmp(counters,"0")) || getenv("BEND_PROFILE_EVENTS_OUT"))
    bp_die("milestones require disabled event counters");
  bm_file=fopen(path,"wx");if(!bm_file)bp_die("milestone path must be fresh and writable");
  bm_functions=functions;
  if(!bm_clock(CLOCK_MONOTONIC,&bm_wall_start) || !bm_clock(CLOCK_PROCESS_CPUTIME_ID,&bm_cpu_start))
    bm_clock_error=1;
  if(atexit(bend_milestone_finish))bp_die("could not register milestone output");
}
