#include <stdint.h>

uint32_t bench_u32(uint32_t n, uint32_t seed) {
    uint32_t end = seed + n, value = end;
    while (n--) {
        --end;
        switch (end % 3) {
        case 0: value += end * 3; break;
        case 1: value *= end % 5 + 1; break;
        default: value -= end + 7; break;
        }
    }
    return value;
}
