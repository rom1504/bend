#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static inline uint32_t prng(uint32_t x) {
    uint32_t b = x ^ (x << 13);
    uint32_t d = b ^ (b >> 17);
    return d ^ (d << 5);
}

static inline float fl(uint32_t n, uint32_t d) {
    return (float)n / (float)d;
}

int main(void) {
    const uint32_t N = 16384u;
    const uint32_t STEPS = 200u;

    float *px = (float *)malloc(N * sizeof(float));
    float *py = (float *)malloc(N * sizeof(float));
    float *vx = (float *)malloc(N * sizeof(float));
    float *vy = (float *)malloc(N * sizeof(float));

    for (uint32_t i = 0; i < N; i++) {
        px[i] = fl(prng((i + 1u) * 2654435761u + 11u) & 1023u, 512u) - 1.0f;
        py[i] = fl(prng((i + 1u) * 2654435761u + 23u) & 1023u, 512u) - 1.0f;
        vx[i] = fl(prng((i + 1u) * 2654435761u + 37u) & 1023u, 512u) - 1.0f;
        vy[i] = fl(prng((i + 1u) * 2654435761u + 53u) & 1023u, 512u) - 1.0f;
    }

    const float dt = fl(1u, 32u);
    const float damp = fl(255u, 256u);
    const float k = fl(1u, 16u);

    for (uint32_t t = 0; t < STEPS; t++) {
        float gx = fl(t & 7u, 32u);
        float gy = fl((t + 3u) & 7u, 32u);
        for (uint32_t i = 0; i < N; i++) {
            float x = px[i];
            float y = py[i];
            float ux = vx[i];
            float uy = vy[i];
            float nvx = ux * damp + (gx - k * x) * dt;
            float nvy = uy * damp + (gy - k * y) * dt;
            px[i] = x + nvx * dt;
            py[i] = y + nvy * dt;
            vx[i] = nvx;
            vy[i] = nvy;
        }
    }

    uint32_t h = 2166136261u;
    for (uint32_t i = 0; i < N; i++) {
        uint32_t qx = (uint32_t)((px[i] + 32.0f) * 1024.0f);
        uint32_t qy = (uint32_t)((py[i] + 32.0f) * 1024.0f);
        h = ((h * 2654435761u) ^ qx) * 16777619u ^ qy;
    }
    printf("%u\n", h);
    free(px);
    free(py);
    free(vx);
    free(vy);
    return 0;
}
