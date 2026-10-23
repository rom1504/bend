/* Sequential diagnostic only; stdout and normal return status are unchanged. */
#include <inttypes.h>
static void p126c_string(const char *text) {
  fputc('"', stderr);
  for (const unsigned char *p = (const unsigned char *)text; *p; ++p) {
    if (*p == '"' || *p == '\\') { fputc('\\', stderr); fputc(*p, stderr); }
    else if (*p < 32) fprintf(stderr, "\\u%04x", (unsigned)*p);
    else fputc(*p, stderr);
  }
  fputc('"', stderr);
}
static void p126c_dump(int status) {
  const P111Program *program = p111_program_active;
  fprintf(stderr,"P126_RESHAPE_COUNTS {\"version\":1,\"normalReturn\":true,\"status\":%d,\"parentSourceSha256\":\"%s\",\"overflowOrInvalid\":%" PRIu64,
    status,P126C_SOURCE_SHA,p126c_invalid);
  for (size_t i=0;i<P126C_COUNT;i++) fprintf(stderr,",\"%s\":%" PRIu64,p126c_names[i],p126c_counts[i]);
  fputs(",\"constructors\":[",stderr);
  int first=1;
  for (uint32_t i=0;i<program->constructor_count;i++) {
    if (!p126c_ctor[i] && !p126c_take[i] && !p126c_reuse[i]) continue;
    if (!first) fputc(',',stderr); first=0;
    fprintf(stderr,"{\"cid\":%u,\"name\":",i);p126c_string(program->cid_names[i]);
    fprintf(stderr,",\"allocated\":%" PRIu64 ",\"takes\":%" PRIu64 ",\"reusedShells\":%" PRIu64 "}",p126c_ctor[i],p126c_take[i],p126c_reuse[i]);
  }
  fputs("]}\n",stderr);
}
