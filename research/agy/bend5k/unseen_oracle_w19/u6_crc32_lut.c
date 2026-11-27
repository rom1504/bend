#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static const uint32_t CRC_NIB[16] = {
    0u, 498536548u, 997073096u, 651767980u,
    1994146192u, 1802195444u, 1303535960u, 1342533948u,
    3988292384u, 4027552580u, 3604390888u, 3412177804u,
    2607071920u, 2261957332u, 2685067896u, 3183342108u
};

int main(void) {
    uint32_t *buf = (uint32_t *)malloc(65536 * sizeof(uint32_t));
    for (uint32_t i = 0; i < 65536; i++) {
        buf[i] = prng(((i + 1u) * 2654435761u) + 42u) & 255u;
    }
    uint32_t crc = 4294967295u;
    for (uint32_t r = 0; r < 200; r++) {
        for (uint32_t i = 0; i < 65536; i++) {
            uint32_t c0 = crc ^ buf[i];
            uint32_t c1 = (c0 >> 4) ^ CRC_NIB[c0 & 15u];
            crc = (c1 >> 4) ^ CRC_NIB[c1 & 15u];
        }
    }
    printf("%u\n", crc ^ 4294967295u);
    free(buf);
    return 0;
}
