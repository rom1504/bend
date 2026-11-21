#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>

typedef uint64_t W;
enum { NIL = 17, CON = 18 };
#define LOCATION ((UINT64_C(1)<<40)-1)
#define RAW(cid) ((UINT64_C(2)<<56)|((W)(cid)<<40))
#define RFC (UINT64_C(1)<<63)
#define EMPTY ((UINT64_C(1)<<56)|((W)NIL<<40))
/* This selected program's 52 static words round up to 128 ABI words. */
#define DYNAMIC UINT64_C(51413632)
extern W p198_reverse_original(void *,W,W);
#ifdef P198_EVENTS
static W events[5];
#define EVENT(i) (events[i]++)
__attribute__((destructor)) static void show_events(void) {
  fprintf(stderr,"ev %" PRIu64 " %" PRIu64 " %" PRIu64 " %" PRIu64 " %" PRIu64 "\n",
          events[0],events[1],events[2],events[3],events[4]);
}
#else
#define EVENT(i) ((void)0)
#endif

W p198_reverse(void *state,W xs,W acc) {
    EVENT(0);
    if (acc != EMPTY) { EVENT(3); return p198_reverse_original(state,xs,acc); }
    W *const heap=*(W **)state;
    W loc=xs & LOCATION;
    if ((xs & ~LOCATION)==RAW(CON) && loc>=DYNAMIC) {
        W next=heap[loc+1];
        heap[loc+1]=acc;
        acc=xs;
        xs=next;
        EVENT(1);
        while ((xs & ~LOCATION)==(RAW(CON)|RFC)) {
            W wrapper=xs & LOCATION;
            if (wrapper<DYNAMIC) break;
            W cell=heap[wrapper];
            W data=cell>>24;
            if ((cell & UINT64_C(0xffffff))!=1 || data<DYNAMIC || data==(acc&LOCATION)) break;
            next=heap[data+1];
            heap[wrapper]=((acc&LOCATION)<<24)|1;
            heap[data+1]=xs;
            acc=RAW(CON)|data;
            xs=next;
            EVENT(2);
        }
    }
    if (xs==EMPTY) { EVENT(4); return acc; }
    EVENT(3);
    return p198_reverse_original(state,xs,acc);
}
