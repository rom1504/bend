#include <stdint.h>

uint32_t bench_u32(uint32_t n, uint32_t seed) {
    uint32_t counts[257] = {0};
    const uint32_t stride = 2*seed+1;
    for (uint32_t i=0; i<n; ++i, seed+=stride) ++counts[seed%257];
    uint32_t h=0;
    for (uint32_t k=0; k<257; ++k)
        for (uint32_t j=0; j<counts[k]; ++j) h=h*10+k;
    return h;
}
