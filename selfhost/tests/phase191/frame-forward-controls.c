#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>

#define DECLARE(name) extern uint64_t p191ff_##name(uint64_t, uint64_t)
DECLARE(identity); DECLARE(transfer); DECLARE(narrow); DECLARE(clobber);
DECLARE(alias); DECLARE(overlap); DECLARE(flags); DECLARE(label); DECLARE(call);

int main(void) {
  const uint64_t values[] = {0, 1, UINT64_MAX, UINT64_C(0x8000000000000000),
    UINT64_C(0x123456789abcdef0), UINT32_MAX, UINT64_C(0xffffffff00000000),
    UINT64_C(0x0102030405060708)};
  for (unsigned i = 0; i < 8; ++i) for (unsigned j = 0; j < 8; ++j) {
    const uint64_t a = values[i], b = values[j];
    const uint64_t got[] = {p191ff_identity(a,b), p191ff_transfer(a,b),
      p191ff_narrow(a,b), p191ff_clobber(a,b), p191ff_alias(a,b),
      p191ff_overlap(a,b), p191ff_flags(a,b), p191ff_label(a,b), p191ff_call(a,b)};
    const uint64_t want[] = {a, a, (uint32_t)a, a, b,
      (a & ~UINT64_C(0xff00)) | ((b & UINT64_C(0xff)) << 8), a < b, b ? b : a, a};
    for (unsigned k = 0; k < 9; ++k) if (got[k] != want[k]) {
      fprintf(stderr,"frame-forward case=%u i=%u j=%u got=%" PRIu64 " want=%" PRIu64 "\n", k,i,j,got[k],want[k]);
      return 1;
    }
  }
  puts("frame-forward-runtime=1");
  return 0;
}
