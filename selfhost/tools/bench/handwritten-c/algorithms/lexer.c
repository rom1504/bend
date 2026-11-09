/* Same linked-character generator and three-mode lexer as native45. */
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct LexChar {
  uint32_t value;
  struct LexChar *next;
} LexChar;

static LexChar *lex_cons(uint32_t value, LexChar *next) {
  LexChar *node = malloc(sizeof(*node));
  if (!node)
    abort();
  *node = (LexChar){value, next};
  return node;
}

static uint32_t lex_prng(uint32_t x) {
  uint32_t b = x ^ (x << 13u);
  uint32_t d = b ^ (b >> 17u);
  return d ^ (d << 5u);
}

static LexChar *lex_template(void) {
  static const char text[] = "i = ( n o i ) o ( n o i ) o ( n o i ) ;";
  LexChar *list = NULL;
  for (size_t i = sizeof(text) - 1u; i != 0u; --i)
    list = lex_cons((unsigned char)text[i - 1u], list);
  return list;
}

static LexChar *lex_ident(uint32_t n, uint32_t seed, LexChar *rest) {
  if (n == 0u)
    return rest;
  uint32_t next = lex_prng(seed);
  return lex_cons(97u + next % 26u, lex_ident(n - 1u, next, rest));
}

static LexChar *lex_number(uint32_t n, uint32_t seed, LexChar *rest) {
  if (n == 0u)
    return rest;
  uint32_t next = lex_prng(seed);
  return lex_cons(48u + next % 10u, lex_number(n - 1u, next, rest));
}

static LexChar *lex_generate(LexChar *tpl, uint32_t seed, uint32_t k) {
  if (!tpl)
    return NULL;
  uint32_t c = tpl->value;
  LexChar *tail = tpl->next;
  free(tpl);
  uint32_t t = lex_prng(seed ^ (k * UINT32_C(2654435761)));
  LexChar *rest = lex_generate(tail, seed, k + 1u);
  switch (c) {
  case 'i': return lex_ident(1u + (t & 7u), t, rest);
  case 'n': return lex_number(1u + t % 6u, t, rest);
  case 'o': return lex_cons((uint32_t)(unsigned char)"+-*/"[t & 3u], rest);
  default: return lex_cons(c, rest);
  }
}

static uint32_t lex_mix(uint32_t acc, uint32_t kind, uint32_t payload) {
  return (acc * UINT32_C(2654435761)) ^ (kind * 40503u + payload);
}

static uint32_t lex_fnv(uint32_t hash, uint32_t c) {
  return (hash ^ c) * UINT32_C(16777619);
}

static uint32_t lex_consume(LexChar *text) {
  enum { GAP, IDENTIFIER, NUMBER } mode = GAP;
  uint32_t payload = 0u, acc = 0u;
  while (text) {
    uint32_t c = text->value;
    LexChar *tail = text->next;
    free(text);
    text = tail;
    int letter = c >= 97u && c <= 122u;
    int digit = c >= 48u && c <= 57u;
    if (mode == IDENTIFIER && letter) {
      payload = lex_fnv(payload, c);
      continue;
    }
    if (mode == NUMBER && digit) {
      payload = payload * 10u + (c - 48u);
      continue;
    }
    if (mode == IDENTIFIER)
      acc = lex_mix(acc, 1u, payload);
    else if (mode == NUMBER)
      acc = lex_mix(acc, 2u, payload);
    if (letter) {
      mode = IDENTIFIER;
      payload = lex_fnv(UINT32_C(2166136261), c);
    } else if (digit) {
      mode = NUMBER;
      payload = c - 48u;
    } else {
      mode = GAP;
      if (c != 32u)
        acc = lex_mix(acc, 3u, c);
    }
  }
  if (mode == IDENTIFIER)
    return lex_mix(acc, 1u, payload);
  if (mode == NUMBER)
    return lex_mix(acc, 2u, payload);
  return acc;
}

static uint32_t lex_line(uint32_t index) {
  uint32_t seed = lex_prng((index + 1u) * UINT32_C(2654435761));
  return lex_consume(lex_generate(lex_template(), seed, 0u));
}

static uint32_t lex_batch(uint32_t depth, uint32_t index) {
  if (depth == 0u)
    return lex_line(index);
  uint32_t next = depth - 1u;
  uint32_t offset = next < 32u ? UINT32_C(1) << next : 0u;
  uint32_t left = lex_batch(next, index);
  uint32_t right = lex_batch(next, index + offset);
  return left + right;
}

uint32_t bench_u32(uint32_t a, uint32_t b) {
  return lex_batch(a, b);
}
