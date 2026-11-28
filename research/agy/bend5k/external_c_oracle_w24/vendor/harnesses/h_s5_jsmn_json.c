/* Harness for unmodified zserge/jsmn (jsmn.h) JSON tokenizer */
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define JSMN_STATIC
#include "../jsmn/jsmn.h"

static const char SAMPLE_JSON[] =
  "{\"service\":\"bend5k-oracle\",\"version\":24,\"active\":true,\"ratio\":null,"
  "\"metrics\":[10,20,30,40,50,60,70,80,90,100],"
  "\"items\":["
    "{\"id\":1,\"name\":\"crc32\",\"tags\":[\"bit\",\"crypto\",\"embench\"],\"ok\":true},"
    "{\"id\":2,\"name\":\"gemm\",\"tags\":[\"f32\",\"blas\",\"polybench\"],\"ok\":true},"
    "{\"id\":3,\"name\":\"jsmn\",\"tags\":[\"json\",\"parser\",\"c\"],\"ok\":false},"
    "{\"id\":4,\"name\":\"huff\",\"tags\":[\"codec\",\"tree\",\"bits\"],\"ok\":true}"
  "],"
  "\"nested\":{\"a\":{\"b\":{\"c\":[1,2,3,\"hello\\nworld\",true,false,null]}}}}";

int main(void) {
  const uint32_t ROUNDS = 4000;
  size_t len = strlen(SAMPLE_JSON);
  char buf[512];
  memcpy(buf, SAMPLE_JSON, len + 1);
  jsmntok_t toks[128];

  uint32_t acc = 2166136261u;
  for (uint32_t r = 0; r < ROUNDS; r++) {
    /* vary one digit inside version number so compiler cannot hoist jsmn_parse */
    buf[38] = (char)('0' + (r % 10));
    jsmn_parser p;
    jsmn_init(&p);
    int n = jsmn_parse(&p, buf, len, toks, 128);
    acc = (acc ^ (uint32_t)n) * 16777619u;
    for (int i = 0; i < n; i++) {
      acc = (acc ^ (uint32_t)toks[i].type) * 16777619u;
      acc = (acc ^ (uint32_t)toks[i].start) * 16777619u;
      acc = (acc ^ (uint32_t)toks[i].end) * 16777619u;
      acc = (acc ^ (uint32_t)toks[i].size) * 16777619u;
    }
  }
  printf("%u\n", acc);
  return 0;
}
