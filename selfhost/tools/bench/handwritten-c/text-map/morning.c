#include "base.h"

char *bench_text(uint32_t a, uint32_t b) {
    (void)a; (void)b; /* Original p93.value ignores its arguments. */
    TMMap *map = tm_set(tm_set(NULL, tm_utf8("one"), 1), tm_utf8("two"), 2);
    TMStr *lookup = tm_utf8("two"); uint32_t got = tm_get(map, lookup, 0);
    tm_free(lookup); tm_map_free(map);
    TMStrings *parts = tm_split(tm_utf8("a,bb,ccc"), ',');
    TMStr *dash = tm_utf8("-"), *joined = tm_join(parts, dash); tm_free(dash);
    uint32_t n = (uint32_t)tm_length(joined);
    uint32_t x = UINT32_C(123) + UINT32_C(877) * UINT32_C(2);
    const char *choice = x < 2000 ? "lo" : x == 2000 ? "eq" : "hi";
    TMWords *list = tm_word(got, tm_word(3, tm_word(4, NULL)));
    uint32_t length = 0;
    while (list) { TMWords *next = list->next; ++length; free(list); list = next; }
    TMStrings *result_parts = tm_strings(joined,
        tm_strings(tm_show(n), tm_strings(tm_show(x),
        tm_strings(tm_show(UINT32_C(7) * UINT32_C(6)), tm_strings(tm_utf8(choice),
        tm_strings(tm_append(tm_utf8("hel"), tm_utf8("lo")), tm_strings(tm_show(length), NULL)))))));
    TMStr *space = tm_utf8(" "), *text = tm_join(result_parts, space); tm_free(space);
    char *result = tm_encode(text); tm_free(text); return result;
}
