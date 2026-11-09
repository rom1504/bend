#ifndef PHASE184_TEXT_MAP_BASE_H
#define PHASE184_TEXT_MAP_BASE_H
/* Owned codepoint lists and Base's 33-bit-per-codepoint crit-bit map.
   See NOTES.md for representation/ownership differences from Bend. */
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct TMStr { uint32_t chr; struct TMStr *next; } TMStr;
typedef struct TMStrings { TMStr *text; struct TMStrings *next; } TMStrings;
typedef struct TMWords { uint32_t value; struct TMWords *next; } TMWords;
typedef struct TMEntry { TMStr *key; uint32_t value; struct TMEntry *next; } TMEntry;
typedef struct TMMap {
    bool branch;
    size_t bit;
    TMStr *key;
    uint32_t value;
    struct TMMap *lo, *hi;
} TMMap;
typedef struct TMMaybe { bool found; uint32_t value; } TMMaybe;

static inline void *tm_alloc(size_t size) {
    void *p = malloc(size);
    if (!p) abort();
    return p;
}
static inline TMStr *tm_chr(uint32_t chr, TMStr *next) {
    TMStr *s = tm_alloc(sizeof *s); s->chr = chr; s->next = next; return s;
}
static inline void tm_free(TMStr *s) {
    while (s) { TMStr *next = s->next; free(s); s = next; }
}
static inline TMStr *tm_utf8(const char *text) {
    const unsigned char *p = (const unsigned char *)text;
    TMStr *s = NULL, **tail = &s;
    while (*p) {
        uint32_t cp = *p++;
        unsigned count = 0;
        if (cp >= 0xc0 && cp < 0xe0) { cp &= 31; count = 1; }
        else if (cp >= 0xe0 && cp < 0xf0) { cp &= 15; count = 2; }
        else if (cp >= 0xf0 && cp < 0xf8) { cp &= 7; count = 3; }
        else if (cp >= 0x80) abort();
        for (unsigned i = 0; i < count; ++i) {
            if ((*p & 0xc0) != 0x80) abort();
            cp = (cp << 6) | (*p++ & 63);
        }
        if (cp > 0x10ffff || (cp >= 0xd800 && cp <= 0xdfff)) abort();
        *tail = tm_chr(cp, NULL); tail = &(*tail)->next;
    }
    return s;
}
static inline size_t tm_length(const TMStr *s) {
    size_t n = 0; for (; s; s = s->next) ++n; return n;
}
static inline TMStr *tm_clone(const TMStr *s) {
    TMStr *r = NULL, **tail = &r;
    for (; s; s = s->next) { *tail = tm_chr(s->chr, NULL); tail = &(*tail)->next; }
    return r;
}
/* Both arguments are uniquely owned and consumed. */
static inline TMStr *tm_append(TMStr *a, TMStr *b) {
    TMStr *r = a, **tail = &r;
    while (*tail) tail = &(*tail)->next;
    *tail = b; return r;
}
static inline int tm_compare(const TMStr *a, const TMStr *b) {
    while (a && b) {
        if (a->chr != b->chr) return a->chr < b->chr ? -1 : 1;
        a = a->next; b = b->next;
    }
    return a ? 1 : b ? -1 : 0;
}
static inline bool tm_equals_utf8(const TMStr *s, const char *expected) {
    TMStr *e = tm_utf8(expected); bool yes = tm_compare(s, e) == 0; tm_free(e); return yes;
}
static inline TMStr *tm_show(uint32_t n) {
    TMStr *s = NULL;
    do { s = tm_chr(48 + n % 10, s); n /= 10; } while (n);
    return s;
}
/* Match current Base U32.read, including its quotient overflow/digit guard. */
static inline TMMaybe tm_read(const TMStr *s) {
    if (!s) return (TMMaybe){false, 0};
    uint32_t acc = 0;
    for (; s; s = s->next) {
        uint32_t n = acc * UINT32_C(10) + (s->chr - UINT32_C(48));
        if (n / 10 != acc) return (TMMaybe){false, 0};
        acc = n;
    }
    return (TMMaybe){true, acc};
}
static inline uint64_t tm_nat_read(const TMStr *s) {
    if (!s) return 0;
    while (s && s->chr == 48) s = s->next;
    uint64_t acc = 0;
    for (; s; s = s->next) {
        uint32_t d = s->chr - UINT32_C(48);
        if (d >= 10 || acc > (UINT64_C(281474976710655) - d) / 10) return 0;
        acc = acc * 10 + d;
    }
    return acc;
}
static inline char *tm_encode(const TMStr *s) {
    size_t bytes = 0;
    for (const TMStr *p = s; p; p = p->next) {
        size_t n = p->chr < 0x80 ? 1 : p->chr < 0x800 ? 2 : p->chr < 0x10000 ? 3 : 4;
        if (bytes > SIZE_MAX - n - 1) abort();
        bytes += n;
    }
    char *result = tm_alloc(bytes + 1); unsigned char *out = (unsigned char *)result;
    for (; s; s = s->next) {
        uint32_t c = s->chr;
        if (c < 0x80) *out++ = (unsigned char)c;
        else if (c < 0x800) { *out++ = (unsigned char)(0xc0 | (c >> 6)); *out++ = (unsigned char)(0x80 | (c & 63)); }
        else if (c < 0x10000) { *out++ = (unsigned char)(0xe0 | (c >> 12)); *out++ = (unsigned char)(0x80 | ((c >> 6) & 63)); *out++ = (unsigned char)(0x80 | (c & 63)); }
        else { *out++ = (unsigned char)(0xf0 | (c >> 18)); *out++ = (unsigned char)(0x80 | ((c >> 12) & 63)); *out++ = (unsigned char)(0x80 | ((c >> 6) & 63)); *out++ = (unsigned char)(0x80 | (c & 63)); }
    }
    *out = 0; return result;
}
static inline TMStrings *tm_strings(TMStr *text, TMStrings *next) {
    TMStrings *p = tm_alloc(sizeof *p); p->text = text; p->next = next; return p;
}
static inline TMStrings *tm_split(TMStr *s, uint32_t separator) {
    if (!s) return tm_strings(NULL, NULL);
    TMStrings *parts = tm_split(s->next, separator);
    if (s->chr == separator) { free(s); return tm_strings(NULL, parts); }
    s->next = parts->text; parts->text = s;
    return parts;
}
static inline TMStr *tm_join(TMStrings *parts, const TMStr *separator) {
    if (!parts) return NULL;
    TMStr *head = parts->text; TMStrings *next = parts->next; free(parts);
    if (!next) return head;
    TMStr *rest = tm_join(next, separator);
    return tm_append(head, tm_append(tm_clone(separator), rest));
}
static inline TMWords *tm_word(uint32_t value, TMWords *next) {
    TMWords *p = tm_alloc(sizeof *p); p->value = value; p->next = next; return p;
}
static inline TMEntry *tm_entry(TMStr *key, uint32_t value, TMEntry *next) {
    TMEntry *p = tm_alloc(sizeof *p); p->key = key; p->value = value; p->next = next; return p;
}
static inline bool tm_bit(const TMStr *key, size_t position) {
    size_t index = position / 33, offset = position % 33;
    while (key && index) { key = key->next; --index; }
    return key && (offset == 0 || ((key->chr >> (32 - offset)) & 1) != 0);
}
static inline size_t tm_diff(const TMStr *a, const TMStr *b) {
    size_t position = 0;
    while (a && b) {
        if (a->chr != b->chr) {
            uint32_t x = a->chr ^ b->chr; size_t bits = 0;
            while (x) { ++bits; x >>= 1; }
            return position + 33 - bits;
        }
        position += 33; a = a->next; b = b->next;
    }
    return position;
}
static inline TMMap *tm_leaf(TMStr *key, uint32_t value) {
    TMMap *m = tm_alloc(sizeof *m); *m = (TMMap){false, 0, key, value, NULL, NULL}; return m;
}
static inline const TMMap *tm_seek(const TMMap *m, const TMStr *key) {
    while (m && m->branch) m = tm_bit(key, m->bit) ? m->hi : m->lo;
    return m;
}
static inline TMMap *tm_set(TMMap *m, TMStr *key, uint32_t value) {
    const TMMap *found = tm_seek(m, key);
    if (!found) return tm_leaf(key, value);
    if (tm_compare(key, found->key) == 0) {
        /* Preserve Base's separate seek and put descents. */
        TMMap *p = m;
        while (p->branch) p = tm_bit(key, p->bit) ? p->hi : p->lo;
        p->value = value; tm_free(key); return m;
    }
    size_t bit = tm_diff(key, found->key);
    TMMap **slot = &m;
    while ((*slot)->branch && (*slot)->bit < bit)
        slot = tm_bit(key, (*slot)->bit) ? &(*slot)->hi : &(*slot)->lo;
    TMMap *leaf = tm_leaf(key, value), *branch = tm_alloc(sizeof *branch);
    bool high = tm_bit(key, bit);
    *branch = (TMMap){true, bit, NULL, 0, high ? *slot : leaf, high ? leaf : *slot};
    *slot = branch; return m;
}
static inline TMMaybe tm_lookup(const TMMap *m, const TMStr *key) {
    const TMMap *p = tm_seek(m, key);
    return p && tm_compare(key, p->key) == 0 ? (TMMaybe){true, p->value} : (TMMaybe){false, 0};
}
static inline uint32_t tm_get(const TMMap *m, const TMStr *key, uint32_t fallback) {
    TMMaybe got = tm_lookup(m, key); return got.found ? got.value : fallback;
}
static inline TMMap *tm_pop(TMMap *m, const TMStr *key, TMMaybe *value) {
    if (!m) { *value = (TMMaybe){false, 0}; return NULL; }
    if (!m->branch) {
        if (tm_compare(key, m->key) != 0) { *value = (TMMaybe){false, 0}; return m; }
        *value = (TMMaybe){true, m->value}; tm_free(m->key); free(m); return NULL;
    }
    bool high = tm_bit(key, m->bit);
    TMMap **slot = high ? &m->hi : &m->lo;
    *slot = tm_pop(*slot, key, value);
    if (*slot) return m;
    TMMap *rest = high ? m->lo : m->hi; free(m); return rest;
}
static inline TMMap *tm_del(TMMap *m, const TMStr *key) { TMMaybe ignored; return tm_pop(m, key, &ignored); }
static inline void tm_map_free(TMMap *m) {
    if (!m) return;
    if (m->branch) { tm_map_free(m->lo); tm_map_free(m->hi); }
    else tm_free(m->key);
    free(m);
}
/* Consume the tree, constructing ordered entries by high-then-low prepend. */
static inline TMEntry *tm_to_list_go(TMMap *m, TMEntry *tail) {
    if (!m) return tail;
    TMEntry *r;
    if (m->branch) r = tm_to_list_go(m->lo, tm_to_list_go(m->hi, tail));
    else r = tm_entry(m->key, m->value, tail);
    free(m); return r;
}
static inline TMMap *tm_from_list(TMEntry *entries, TMMap *m) {
    while (entries) {
        TMEntry *next = entries->next; m = tm_set(m, entries->key, entries->value); free(entries); entries = next;
    }
    return m;
}
static inline TMMap *tm_union(TMMap *left, TMMap *right) { return tm_from_list(tm_to_list_go(right, NULL), left); }
static inline TMStrings *tm_keys_go(TMMap *m, TMStrings *tail) {
    if (!m) return tail;
    TMStrings *r = m->branch ? tm_keys_go(m->lo, tm_keys_go(m->hi, tail)) : tm_strings(m->key, tail);
    free(m); return r;
}
static inline TMWords *tm_values_go(TMMap *m, TMWords *tail) {
    if (!m) return tail;
    TMWords *r;
    if (m->branch) r = tm_values_go(m->lo, tm_values_go(m->hi, tail));
    else { r = tm_word(m->value, tail); tm_free(m->key); }
    free(m); return r;
}
#endif
