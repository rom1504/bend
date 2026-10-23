/* Independent late-emission ABI fixture, not the production runtime.
 * Link the QBE module exported by p128bf_oracle_module and this file only.
 * The helper spy verifies fallback dispatch; it deliberately does not reproduce
 * the production helper's fail-stop malformed-term behavior. */
#include "../../../phase111/runtime/runtime.h"
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

typedef uint64_t (*Read)(P111State *, uint64_t, uint64_t *);
#define DECL(n) extern uint64_t p128bf_width_##n(P111State *, uint64_t, uint64_t *)
DECL(0); DECL(1); DECL(2); DECL(3); DECL(4); DECL(5); DECL(6); DECL(7); DECL(8);
extern uint64_t p128bf_mismatched_count(P111State *, uint64_t, uint64_t *);
static const Read widths[] = {p128bf_width_0,p128bf_width_1,p128bf_width_2,
  p128bf_width_3,p128bf_width_4,p128bf_width_5,p128bf_width_6,p128bf_width_7,p128bf_width_8};

static struct {
  unsigned calls;
  P111State *state;
  uint64_t word, *out;
  uint32_t cid, count;
} spy;

/* Intentionally no heap reads and no scratch writes: a bad fast-path guard
 * cannot accidentally get the right answer through an imitation helper. */
uint64_t p118_rt_borrow_fields(P111State *state, uint64_t word, uint64_t *out,
                              uint32_t cid, uint32_t count) {
  ++spy.calls;
  spy.state = state; spy.word = word; spy.out = out;
  spy.cid = cid; spy.count = count;
  return UINT64_C(0xfedcba9800000000) | count;
}

static unsigned checks, failures;
static void expect(int ok, const char *kind, unsigned width, unsigned detail) {
  ++checks;
  if (!ok) {
    ++failures;
    fprintf(stderr,"FAIL %s width=%u detail=%u\n",kind,width,detail);
  }
}

static uint64_t term(unsigned tag, unsigned cid, unsigned rfc, uint64_t loc) {
  return ((uint64_t)rfc << 63) | ((uint64_t)tag << 56) |
    ((uint64_t)cid << 40) | loc;
}

static void valid(unsigned width, unsigned mode, unsigned refcount) {
  uint64_t heap[1024], before[1024], storage[12], expected[12];
  /* Payload at512 makes the RFC header's high32 nonzero. At16 exercises
   * the same raw layout used by low-address immutable/static data. */
  const unsigned location = mode == 0 ? 16 : 512;
  const unsigned header = 7;
  for (unsigned i = 0; i < 1024; ++i)
    heap[i] = UINT64_C(0xa11ce56789abcdef) ^ (UINT64_C(0x102030405060708) * i);
  for (unsigned i = 0; i < width; ++i)
    heap[location+i] = UINT64_C(0xf000000080000001) ^ (UINT64_C(0x0102030405060709) * i);
  heap[header] = ((uint64_t)location << 24) | refcount;
  memcpy(before,heap,sizeof heap);
  for (unsigned i = 0; i < 12; ++i) storage[i] = UINT64_C(0x77eeddaa00000000) | i;
  memcpy(expected,storage,sizeof storage);
  for (unsigned i = 0; i < width; ++i) expected[2+i] = heap[location+i];
  P111State state = {0};
  state.e.mem = heap;
  state.seq = 1; state.rn = 17; state.next = 29;
  P111State original = state;
  memset(&spy,0,sizeof spy);
  uint64_t word = term(2,0,mode == 2,mode == 2 ? header : location);
  uint64_t status = widths[width](&state,word,storage+2);
  unsigned detail = mode * 100 + (refcount == 0xffffff ? 99 : refcount);
  expect(spy.calls == 0,"valid-bypasses-helper",width,detail);
  expect(status == width,"valid-exact-status",width,detail);
  expect(memcmp(storage,expected,sizeof storage) == 0,"valid-fields-and-canaries",width,detail);
  expect(memcmp(heap,before,sizeof heap) == 0,"valid-heap-header-unchanged",width,detail);
  expect(memcmp(&state,&original,sizeof state) == 0,"valid-state-unchanged",width,detail);
}

static void fallback(Read read, unsigned count, uint64_t word, unsigned detail) {
  uint64_t storage[12], before[12];
  for (unsigned i = 0; i < 12; ++i) storage[i] = UINT64_C(0x12345678abcdef00) | i;
  memcpy(before,storage,sizeof storage);
  /* A mistaken heap/header/payload dereference fails this fixture. The spy
   * itself does not inspect mem; no production invalid pointer is created. */
  P111State state = {0};
  P111State original = state;
  memset(&spy,0,sizeof spy);
  uint64_t status = read(&state,word,storage+2);
  expect(spy.calls == 1,"fallback-once",count,detail);
  expect(spy.state == &state && spy.word == word && spy.out == storage+2 &&
         spy.cid == 0 && spy.count == count,"fallback-exact-arguments",count,detail);
  expect(status == (UINT64_C(0xfedcba9800000000) | count),"fallback-exact-result",count,detail);
  expect(memcmp(storage,before,sizeof storage) == 0,"fallback-scratch-unchanged",count,detail);
  expect(memcmp(&state,&original,sizeof state) == 0,"fallback-state-unchanged",count,detail);
}

int main(void) {
  _Static_assert(offsetof(P111State,e.mem) == 0,"borrow template heap ABI");
  for (unsigned width = 2; width <= 8; ++width) {
    valid(width,0,0); valid(width,1,0);
    valid(width,2,1); valid(width,2,2); valid(width,2,0xffffff);
    for (unsigned rfc = 0; rfc <= 1; ++rfc) {
      fallback(widths[width],width,term(1,0,rfc,123),10+rfc); /* PAK tag */
      fallback(widths[width],width,term(0,0,rfc,123),20+rfc);
      fallback(widths[width],width,term(127,0,rfc,123),30+rfc);
      fallback(widths[width],width,term(2,1,rfc,123),40+rfc); /* wrong CID */
      fallback(widths[width],width,term(2,65535,rfc,123),50+rfc);
    }
  }
  fallback(widths[0],0,term(2,0,0,123),60);
  fallback(widths[1],1,term(1,0,0,123),61); /* packed stays original */
  fallback(widths[1],1,term(2,0,1,123),62); /* boxed width1 too */
  fallback(p128bf_mismatched_count,3,term(2,0,0,123),63);
  printf("{\"checks\":%u,\"failures\":%u,\"fixture\":\"phase128-borrow-field-late-abi\"}\n",checks,failures);
  return failures != 0;
}
