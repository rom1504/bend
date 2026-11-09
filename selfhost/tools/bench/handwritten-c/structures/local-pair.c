/* local-pair.bend p93.value invokes pair(a), not bench(a,b)/batch(a,b). */
#include <stdint.h>
#include <stdlib.h>

typedef struct {
    uint32_t *a, *b, *previous, *current;
} Dp;

static uint32_t *zero_words(size_t count) {
    uint32_t *words = calloc(count, sizeof *words);
    if (words == NULL) abort();
    return words;
}

static uint32_t prng(uint32_t value) {
    value ^= value << 13;
    value ^= value >> 17;
    value ^= value << 5;
    return value;
}

static void generate(uint32_t *words, uint32_t seed) {
    for (uint32_t i = 0; i < UINT32_C(256); ++i) {
        seed = prng(seed);
        words[i] = seed & UINT32_C(3);
    }
}

static uint32_t minimum(uint32_t a, uint32_t b) {
    return a < b ? a : b;
}

static void row(Dp *state, uint32_t index) {
    uint32_t ai = state->a[index];
    state->current[0] = index + UINT32_C(1);
    for (uint32_t j = 0; j < UINT32_C(256); ++j) {
        uint32_t cost = (uint32_t)(ai != state->b[j]);
        uint32_t diagonal = state->previous[j];
        uint32_t above = state->previous[j + UINT32_C(1)];
        uint32_t left = state->current[j];
        state->current[j + UINT32_C(1)] = minimum(
            minimum(above + UINT32_C(1), left + UINT32_C(1)), diagonal + cost);
    }
    uint32_t *previous = state->previous;
    state->previous = state->current;
    state->current = previous;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
    (void)b;
    uint32_t seed = (uint32_t)((a + UINT32_C(1)) * UINT32_C(2654435761));
    Dp state;
    state.a = zero_words(256);
    generate(state.a, seed);
    state.b = zero_words(256);
    generate(state.b, (uint32_t)(seed * UINT32_C(340573321)));
    state.previous = zero_words(512);
    for (uint32_t i = 0; i < UINT32_C(257); ++i) state.previous[i] = i;
    state.current = zero_words(512);
    for (uint32_t i = 0; i < UINT32_C(256); ++i) row(&state, i);
    uint32_t distance = state.previous[256];
    free(state.a);
    free(state.b);
    free(state.previous);
    free(state.current);
    return (uint32_t)((distance * UINT32_C(2654435761)) ^ (a + UINT32_C(1)));
}
