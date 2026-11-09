/* Handwritten translation of native45 coverage-unicode-text-{16,64}.bend.
   Retains the complete repeat -> code-point split -> join computation. */
#include <stdint.h>
#include <stdlib.h>

typedef struct Text {
  uint32_t codepoint;
  struct Text *next;
} Text;

typedef struct Parts {
  Text *head;
  struct Parts *next;
} Parts;

static Text *text_cons(uint32_t codepoint, Text *next) {
  Text *node = malloc(sizeof *node);
  if (!node) abort();
  node->codepoint = codepoint;
  node->next = next;
  return node;
}

static void text_free(Text *text) {
  while (text) {
    Text *next = text->next;
    free(text);
    text = next;
  }
}

/* A kept left argument is copied, and the owned right argument is its tail. */
static Text *append_copy(const Text *left, Text *right) {
  Text *head = NULL;
  Text **end = &head;
  for (; left; left = left->next) {
    *end = text_cons(left->codepoint, NULL);
    end = &(*end)->next;
  }
  *end = right;
  return head;
}

/* Reuse the nodes of a uniquely owned left argument during String.append. */
static Text *append_owned(Text *left, Text *right) {
  if (!left) return right;
  Text *end = left;
  while (end->next) end = end->next;
  end->next = right;
  return left;
}

static Text *word_show(uint32_t word) {
  if (!word) return text_cons(UINT32_C(48), NULL);
  Text *digits = NULL;
  do {
    digits = text_cons(UINT32_C(48) + word % UINT32_C(10), digits);
    word /= UINT32_C(10);
  } while (word);
  return digits;
}

static Parts *parts_cons(Text *head, Parts *next) {
  Parts *node = malloc(sizeof *node);
  if (!node) abort();
  node->head = head;
  node->next = next;
  return node;
}

/* The fixture's right-fold split: even an empty input yields one empty part. */
static Parts *split(uint32_t separator, Text *text) {
  if (!text) return parts_cons(NULL, NULL);
  Parts *rest = split(separator, text->next);
  if (text->codepoint == separator) {
    free(text);
    return parts_cons(NULL, rest);
  }
  text->next = rest->head;
  rest->head = text;
  return rest;
}

static Text *join(uint32_t separator, Parts *parts) {
  if (!parts) return NULL;
  Text *head = parts->head;
  Parts *next = parts->next;
  free(parts);
  if (!next) return head;
  Text *tail = join(separator, next);
  return append_owned(head, text_cons(separator, tail));
}

/* UTF-8 is the external driver contract, not the algorithm's character unit. */
static char *utf8_take(Text *text) {
  size_t bytes = 0;
  for (const Text *node = text; node; node = node->next) {
    uint32_t cp = node->codepoint;
    size_t width = cp < UINT32_C(0x80) ? 1 : cp < UINT32_C(0x800) ? 2
                 : cp < UINT32_C(0x10000) ? 3 : 4;
    if (cp > UINT32_C(0x10ffff) || (cp >= UINT32_C(0xd800) && cp <= UINT32_C(0xdfff))
        || bytes > SIZE_MAX - width - 1) abort();
    bytes += width;
  }
  char *result = malloc(bytes + 1);
  if (!result) abort();
  unsigned char *at = (unsigned char *)result;
  while (text) {
    uint32_t cp = text->codepoint;
    if (cp < UINT32_C(0x80)) {
      *at++ = (unsigned char)cp;
    } else if (cp < UINT32_C(0x800)) {
      *at++ = (unsigned char)(UINT32_C(0xc0) | (cp >> 6));
      *at++ = (unsigned char)(UINT32_C(0x80) | (cp & UINT32_C(0x3f)));
    } else if (cp < UINT32_C(0x10000)) {
      *at++ = (unsigned char)(UINT32_C(0xe0) | (cp >> 12));
      *at++ = (unsigned char)(UINT32_C(0x80) | ((cp >> 6) & UINT32_C(0x3f)));
      *at++ = (unsigned char)(UINT32_C(0x80) | (cp & UINT32_C(0x3f)));
    } else {
      *at++ = (unsigned char)(UINT32_C(0xf0) | (cp >> 18));
      *at++ = (unsigned char)(UINT32_C(0x80) | ((cp >> 12) & UINT32_C(0x3f)));
      *at++ = (unsigned char)(UINT32_C(0x80) | ((cp >> 6) & UINT32_C(0x3f)));
      *at++ = (unsigned char)(UINT32_C(0x80) | (cp & UINT32_C(0x3f)));
    }
    Text *next = text->next;
    free(text);
    text = next;
  }
  *at = 0;
  return result;
}

char *bench_text(uint32_t size, uint32_t seed) {
  /* The fixture's input block is alpha,beta,apple,CJK,decimal-seed, . */
  static const uint32_t prefix[] = {0x03b1, 44, 0x03b2, 44, 0x1f34e, 44, 0x4e2d, 44};
  Text *block = append_owned(word_show(seed), text_cons(UINT32_C(44), NULL));
  for (size_t i = sizeof prefix / sizeof prefix[0]; i; --i)
    block = text_cons(prefix[i - 1], block);
  Text *text = NULL;
  while (size) {
    text = append_copy(block, text);
    --size;
  }
  text_free(block);
  return utf8_take(join(UINT32_C(124), split(UINT32_C(44), text)));
}
