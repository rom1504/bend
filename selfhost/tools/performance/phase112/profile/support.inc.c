/* Appended after the pinned runtime, so descriptor metadata is still visible.
 * Plain counters are valid only for the unchanged sequential CPU contract. */
#include <inttypes.h>

static void p112_json_string(const char *text) {
  fputc('"', stderr);
  for (const unsigned char *p = (const unsigned char *)text; *p; ++p) {
    if (*p == '"' || *p == '\\') { fputc('\\', stderr); fputc(*p, stderr); }
    else if (*p < 32) fprintf(stderr, "\\u%04x", (unsigned)*p);
    else fputc(*p, stderr);
  }
  fputc('"', stderr);
}

static void p112_dump(void) {
  uint64_t rows = 0;
  const P111Program *program = p111_program_active;
  fprintf(stderr, "P112_PROFILE {\"type\":\"meta\",\"version\":1,"
    "\"sourceSha256\":\"%s\",\"heapRc\":%s,\"abi\":%u,"
    "\"segments\":%" PRIu64 ",\"constructors\":%" PRIu64 ",\"transportWidth\":%u}\n",
    P112_SOURCE_SHA, P112_HEAP_RC ? "true" : "false", P111_ABI_VERSION,
    program->segment_count, program->constructor_count, p111_transport_words);
  for (size_t i = 0; i < P112_C_COUNT; ++i) {
    /* Include zeros so absent observations cannot masquerade as missing hooks. */
    fprintf(stderr, "P112_PROFILE {\"type\":\"counter\",\"name\":\"%s\",\"count\":%" PRIu64 "}\n",
      p112_counter_names[i], p112_counters[i]);
    ++rows;
  }
  for (size_t h = 0; h < sizeof(p112_histograms)/sizeof(P112Hist); ++h) {
    const P112Hist *hist = &p112_histograms[h];
    for (uint32_t i = 0; i < hist->count; ++i) if (hist->bins[i]) {
      fprintf(stderr, "P112_PROFILE {\"type\":\"histogram\",\"name\":\"%s\","
        "\"index\":%u,\"count\":%" PRIu64, hist->name, i, hist->bins[i]);
      if (!strcmp(hist->kind, "cid") && i < program->constructor_count) {
        fputs(",\"symbol\":", stderr); p112_json_string(program->cid_names[i]);
      }
      fputs("}\n", stderr);
      ++rows;
    }
  }
  fprintf(stderr, "P112_PROFILE {\"type\":\"end\",\"rows\":%" PRIu64 ",\"invalid\":%" PRIu64 "}\n",
    rows, p112_invalid);
}

static void p112_start(void) {
  if (atexit(p112_dump) != 0) err_fail("phase112: diagnostic registration failed");
}
