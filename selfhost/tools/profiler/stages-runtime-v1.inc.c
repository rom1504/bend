/* Versioned sequential stage observer. Generated map binds exact FIDs/spec.
 * No signal handler changes; clocks run only at selected dispatch entries. */
#include <dlfcn.h>
#include <time.h>
#include <sys/syscall.h>
#include <unistd.h>
#include "stages-map-v1.h"
static FILE *bgs_file;
static long bgs_tid;
static const P111Segment *bgs_functions;
static uint32_t (*bgs_ordinal)(void);
static uint32_t bgs_next,bgs_bad,bgs_error,bgs_counts[BGS_COUNT];
static uint32_t bgs_samples[BGS_COUNT][8];
static uint64_t bgs_wall[BGS_COUNT][8],bgs_cpu[BGS_COUNT][8],bgs_thread[BGS_COUNT][8];
static uint64_t bgs_clock(clockid_t clock) {
  struct timespec t;
  if(clock_gettime(clock,&t)||t.tv_sec<0||t.tv_nsec<0||t.tv_nsec>=1000000000L){bgs_error=1;return 0;}
  return (uint64_t)t.tv_sec*UINT64_C(1000000000)+(uint64_t)t.tv_nsec;
}
static inline void bend_stages_v1_enter(uint32_t fid) {
  if(!bgs_file||fid>BGS_MAX_FID)return;
  uint32_t rank=bgs_rank[fid];if(!rank)return;
  if(syscall(SYS_gettid)!=bgs_tid)bp_die("stage marker executed on another thread");
  uint32_t at=rank-1,n=bgs_counts[at];
  if(n==UINT32_MAX){bgs_error=1;return;}
  ++bgs_counts[at];
  if(!n&&bgs_order[at]) {if(bgs_order[at]!=bgs_next+1)bgs_bad=1;else ++bgs_next;}
  if(n&&bgs_mode[at]==0)bgs_bad=1;
  if(n<8) {
    bgs_wall[at][n]=bgs_clock(CLOCK_MONOTONIC);
    bgs_cpu[at][n]=bgs_clock(CLOCK_PROCESS_CPUTIME_ID);
    bgs_thread[at][n]=bgs_clock(CLOCK_THREAD_CPUTIME_ID);
    bgs_samples[at][n]=bgs_ordinal();
    if(bgs_samples[at][n]==UINT32_MAX)bgs_error=1;
  }
}
static void bend_stages_v1_finish(void) {
  if(!bgs_file)return;
  uint64_t wall=bgs_clock(CLOCK_MONOTONIC),cpu=bgs_clock(CLOCK_PROCESS_CPUTIME_ID),thread=bgs_clock(CLOCK_THREAD_CPUTIME_ID);
  uint32_t sample=bgs_ordinal();if(sample==UINT32_MAX)bgs_error=1;
  fprintf(bgs_file,"{\"schema\":\"bend-native-stage-observations-v1\",\"specSha256\":\"%s\",\"complete\":%s,\"sequentialOnly\":true,\"expectedSegments\":%u,\"requiredObservedInOrder\":%u,\"badOrderOrDuplicate\":%s,\"clockError\":%s,\"finish\":{\"wallNs\":%" PRIu64 ",\"cpuNs\":%" PRIu64 ",\"threadNs\":%" PRIu64 ",\"sampleOrdinal\":%u},\"markers\":[",BGS_SPEC_SHA256,bgs_next==BGS_REQUIRED&&!bgs_bad&&!bgs_error?"true":"false",BGS_SEGMENTS,bgs_next,bgs_bad?"true":"false",bgs_error?"true":"false",wall,cpu,thread,sample);
  for(uint32_t i=0;i<BGS_COUNT;++i) {
    fprintf(bgs_file,"%s{\"label\":\"%s\",\"fid\":%u,\"address\":\"0x%" PRIxPTR "\",\"multiplicity\":\"%s\",\"entries\":%u,\"truncated\":%s,\"observations\":[",i?",":"",bgs_labels[i],bgs_fids[i],(uintptr_t)bgs_functions[bgs_fids[i]],bgs_modes[i],bgs_counts[i],bgs_counts[i]>8?"true":"false");
    for(uint32_t j=0;j<bgs_counts[i]&&j<8;++j)fprintf(bgs_file,"%s{\"wallNs\":%" PRIu64 ",\"cpuNs\":%" PRIu64 ",\"threadNs\":%" PRIu64 ",\"sampleOrdinal\":%u}",j?",":"",bgs_wall[i][j],bgs_cpu[i][j],bgs_thread[i][j],bgs_samples[i][j]);
    fputs("]}",bgs_file);
  }
  fputs("]}\n",bgs_file);int failed=ferror(bgs_file);if(fclose(bgs_file))failed=1;bgs_file=NULL;
  if(failed)bp_die("stage sidecar write failed");
}
static void bend_stages_v1_initialize(uint32_t segments,const P111Segment *functions) {
  const char *sample=getenv("BEND_SAMPLE_OUT");if(!sample||!*sample)return;
  if(segments!=BGS_SEGMENTS||!functions)bp_die("stage object differs");
  bgs_tid=syscall(SYS_gettid);if(bgs_tid!=(long)getpid())bp_die("stage initialization must run on sampled main thread");
  const char *counters=getenv("BEND_PROFILE_COUNTERS");
  if((counters&&strcmp(counters,"0"))||getenv("BEND_PROFILE_EVENTS_OUT"))bp_die("stage counters must be disabled");
  bgs_ordinal=(uint32_t(*)(void))dlsym(RTLD_DEFAULT,"bend_sample_delivered_count");
  if(!bgs_ordinal||bgs_ordinal()==UINT32_MAX)bp_die("stage ordinal sampler missing");
  char path[4096];int n=snprintf(path,sizeof(path),"%s.stages-v1.json",sample);
  if(n<0||(size_t)n>=sizeof(path))bp_die("stage sidecar path too long");
  bgs_file=fopen(path,"wx");if(!bgs_file)bp_die("stage sidecar must be fresh");bgs_functions=functions;
  if(atexit(bend_stages_v1_finish))bp_die("stage exit registration failed");
}
