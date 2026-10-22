/* Diagnostic report only. Original runtime stdout and exit code stay intact. */
#include <inttypes.h>
static void p125_json_string(const char *text) {
  fputc('"', stderr);
  for (const unsigned char *p = (const unsigned char *)text; *p; ++p) {
    if (*p == '"' || *p == '\\') { fputc('\\', stderr); fputc(*p, stderr); }
    else if (*p < 32) fprintf(stderr, "\\u%04x", (unsigned)*p);
    else fputc(*p, stderr);
  }
  fputc('"', stderr);
}

static void p125_dump(int status) {
  const P111Program *program = p111_program_active;
  fprintf(stderr, "P125_COUNTS {\"version\":1,\"normalReturn\":true,\"status\":%d,"
    "\"parentSourceSha256\":\"%s\",\"overflowOrInvalid\":%" PRIu64,
    status, P125_SOURCE_SHA, p125_invalid);
  for (size_t i = 0; i < P125_C_COUNT; ++i)
    fprintf(stderr, ",\"%s\":%" PRIu64, p125_names[i], p125_counts[i]);
  fputs(",\"constructors\":[", stderr);
  int first = 1;
  for (uint32_t i = 0; i < program->constructor_count; ++i) {
    if (!p125_ctor[i] && !p125_take[i]) continue;
    if (!first) fputc(',', stderr);
    first = 0;
    fprintf(stderr, "{\"cid\":%u,\"name\":", i);
    p125_json_string(program->cid_names[i]);
    fprintf(stderr, ",\"allocated\":%" PRIu64 ",\"takes\":%" PRIu64 "}",
      p125_ctor[i], p125_take[i]);
  }
  fputs("],\"extendByPrefix\":[", stderr);
  for (uint32_t i = 0; i < 8; ++i)
    fprintf(stderr, "%s%" PRIu64, i ? "," : "", p125_extend[i]);
  fputs("]}\n", stderr);
}
