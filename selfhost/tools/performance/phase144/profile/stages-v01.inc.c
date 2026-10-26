/* Sequential diagnostic phase boundaries, tied to an exact immutable object.
 * The sampler getter adds no work to the asynchronous signal handler. */
#include <dlfcn.h>
#include <time.h>
#include "stages-map.h"
static FILE *bs_file;
static uint32_t bs_next,bs_bad,bs_error,bs_counts[BS_COUNT],bs_samples[BS_COUNT];
static uint64_t bs_wall[BS_COUNT],bs_cpu[BS_COUNT],bs_thread[BS_COUNT];
static const P111Segment *bs_functions;
static uint32_t (*bs_sample_count)(void);
static uint64_t bs_clock(clockid_t clock) {
  struct timespec t;
  if(clock_gettime(clock,&t) || t.tv_sec<0 || t.tv_nsec<0 || t.tv_nsec>=1000000000L) {bs_error=1;return 0;}
  return (uint64_t)t.tv_sec*UINT64_C(1000000000)+(uint64_t)t.tv_nsec;
}
static inline void bend_stage_enter(uint32_t fid) {
  if(!bs_file || fid>BS_MAX_FID)return;
  uint32_t rank=bs_rank[fid];if(!rank)return;
  uint32_t at=rank-1;
  if(bs_counts[at]!=UINT32_MAX)++bs_counts[at];
  if(bs_counts[at]>1) {if(!bs_first_only[at])bs_bad=1;return;}
  if(at!=bs_next) {bs_bad=1;return;}
  bs_wall[at]=bs_clock(CLOCK_MONOTONIC);
  bs_cpu[at]=bs_clock(CLOCK_PROCESS_CPUTIME_ID);
  bs_thread[at]=bs_clock(CLOCK_THREAD_CPUTIME_ID);
  bs_samples[at]=bs_sample_count();
  if(bs_samples[at]==UINT32_MAX)bs_error=1;
  ++bs_next;
}
static void bend_stage_finish(void) {
  if(!bs_file)return;
  uint64_t wall=bs_clock(CLOCK_MONOTONIC),cpu=bs_clock(CLOCK_PROCESS_CPUTIME_ID),thread=bs_clock(CLOCK_THREAD_CPUTIME_ID);
  uint32_t samples=bs_sample_count();if(samples==UINT32_MAX)bs_error=1;
  fprintf(bs_file,"{\"schema\":\"bend-sampled-dispatch-stages-v1\",\"complete\":%s,\"sequentialOnly\":true,\"expectedSegments\":%u,\"observedInOrder\":%u,\"badOrderOrDuplicate\":%s,\"clockError\":%s,\"finishWallNs\":%" PRIu64 ",\"finishCpuNs\":%" PRIu64 ",\"finishThreadNs\":%" PRIu64 ",\"finishSampleOrdinal\":%u,\"rows\":[",
    bs_next==BS_COUNT&&!bs_bad&&!bs_error?"true":"false",BS_SEGMENTS,bs_next,bs_bad?"true":"false",bs_error?"true":"false",wall,cpu,thread,samples);
  for(uint32_t i=0;i<BS_COUNT;++i)fprintf(bs_file,"%s{\"label\":\"%s\",\"fid\":%u,\"address\":\"0x%" PRIxPTR "\",\"entries\":%u,\"firstEntryBoundary\":%s,\"wallNs\":%" PRIu64 ",\"cpuNs\":%" PRIu64 ",\"threadNs\":%" PRIu64 ",\"sampleOrdinal\":%u}",i?",":"",bs_labels[i],bs_fids[i],(uintptr_t)bs_functions[bs_fids[i]],bs_counts[i],bs_first_only[i]?"true":"false",bs_wall[i],bs_cpu[i],bs_thread[i],bs_samples[i]);
  fputs("]}\n",bs_file);int failed=ferror(bs_file);if(fclose(bs_file))failed=1;bs_file=NULL;
  if(failed)bp_die("stage sidecar write failed");
}
static void bend_stage_initialize(uint32_t segments,const P111Segment *functions) {
  const char *sample=getenv("BEND_SAMPLE_OUT");if(!sample||!*sample)return;
  if(segments!=BS_SEGMENTS||!functions)bp_die("stage object differs");
  const char *counters=getenv("BEND_PROFILE_COUNTERS");
  if((counters&&strcmp(counters,"0"))||getenv("BEND_PROFILE_EVENTS_OUT"))bp_die("stage counters must be disabled");
  bs_sample_count=(uint32_t(*)(void))dlsym(RTLD_DEFAULT,"bend_sample_delivered_count");
  if(!bs_sample_count||bs_sample_count()==UINT32_MAX)bp_die("stage ordinal sampler missing");
  char path[4096];int n=snprintf(path,sizeof(path),"%s.stages.json",sample);
  if(n<0||(size_t)n>=sizeof(path))bp_die("stage sidecar path too long");
  bs_file=fopen(path,"wx");if(!bs_file)bp_die("stage sidecar must be fresh");bs_functions=functions;
  if(atexit(bend_stage_finish))bp_die("stage exit registration failed");
}
