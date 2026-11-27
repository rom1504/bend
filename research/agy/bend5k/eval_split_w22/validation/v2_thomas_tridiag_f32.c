#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline float fl(uint32_t n, uint32_t d) {
    return (float)n / (float)d;
}

int main(int argc, char **argv) {
    int large = (argc > 1 && strcmp(argv[1], "large") == 0);
    uint32_t N = large ? 4096u : 2048u;
    uint32_t STEPS = large ? 960u : 1500u;

    float *a = (float *)malloc(N * sizeof(float));
    float *b = (float *)malloc(N * sizeof(float));
    float *c = (float *)malloc(N * sizeof(float));
    float *cp = (float *)malloc(N * sizeof(float));
    float *dp = (float *)malloc(N * sizeof(float));

    float neg_alpha = fl(0u, 1u) - fl(1u, 4u);
    for (uint32_t i = 0; i < N; i++) {
        a[i] = (i == 0u) ? 0.0f : neg_alpha;
        b[i] = fl(3u, 2u) + fl((i & 7u) + 1u, 64u);
        c[i] = (i == N - 1u) ? 0.0f : neg_alpha;
        cp[i] = 0.0f;
        dp[i] = fl((i * 17u) & 255u, 256u) - fl(1u, 2u);
    }

    for (uint32_t step = 0; step < STEPS; step++) {
        float drive = fl((step & 7u) + 1u, 64u) - fl(1u, 16u);
        // Forward elimination
        float b0 = b[0];
        float c0 = c[0];
        float d0 = dp[0] + drive;
        float prev_cp = c0 / b0;
        float prev_dp = d0 / b0;
        cp[0] = prev_cp;
        dp[0] = prev_dp;

        for (uint32_t i = 1u; i < N; i++) {
            float ai = a[i];
            float denom = b[i] - ai * prev_cp;
            float ncp = c[i] / denom;
            float ndp = ((dp[i] + drive) - ai * prev_dp) / denom;
            cp[i] = ncp;
            dp[i] = ndp;
            prev_cp = ncp;
            prev_dp = ndp;
        }

        // Back substitution (in-place into dp)
        float x_next = prev_dp;
        for (uint32_t k = 1u; k < N; k++) {
            uint32_t i = (N - 1u) - k;
            float xi = dp[i] - cp[i] * x_next;
            dp[i] = xi;
            x_next = xi;
        }
    }

    uint32_t h = 2166136261u;
    for (uint32_t i = 0; i < N; i++) {
        uint32_t q = (uint32_t)((dp[i] + 16.0f) * 65536.0f);
        h = (h * 2654435761u) ^ q;
    }
    printf("%u\n", h);
    free(a); free(b); free(c); free(cp); free(dp);
    return 0;
}
