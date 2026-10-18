/* Finite public-ABI bank/continuation controls; never linked into production. */
#include "runtime.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SENTINEL UINT64_C(0xdecafbad12345678)
static const char *chosen;
static uint32_t width = 2, input_count;
static void expect(int ok, const char *message) {
  if (!ok) { fprintf(stderr, "bank-control: %s\n", message); exit(2); }
}
static void seed_unused(P111State *s) {
  for (uint32_t i = width; i < 256; ++i) s->regs[i] = SENTINEL;
}
static void check_unused(P111State *s) {
  for (uint32_t i = width; i < 256; ++i)
    expect(s->regs[i] == SENTINEL, "outside logical bank changed");
}
static uint64_t finish(P111State *s) {
  uint64_t zero = 0;
  printf("%s:ok\n", chosen);
  uint64_t reply = p111_rt_return(s, &zero, 1);
  check_unused(s);
  return reply;
}
static uint64_t continuation(P111State *s) {
  check_unused(s);
  if (!strcmp(chosen, "io2")) {
    expect(s->rn == 1 && p111_rt_tag(s, s->regs[0]) == 12, "builtin IO Emit result");
    uint64_t unit[1]; p111_rt_take(s, s->regs[0], unit, 1);
    expect(p111_rt_tag(s, unit[0]) == 7, "builtin IO payload");
    p111_rt_sink(s, unit[0]);
  } else {
    expect(s->rn == 3 && s->regs[0] == 11 && s->regs[1] == 22 && s->regs[2] == 33,
      "three incoming continuation results");
    p111_rt_stack_pop(s, 1);
    expect(p111_rt_stack_get(s, 0) == 999, "continuation capture survives");
  }
  return finish(s);
}
static uint64_t worker(P111State *s) {
  check_unused(s);
  if (!strcmp(chosen, "results3")) {
    uint64_t results[3] = {11, 22, 33};
    return p111_rt_return(s, results, 3);
  }
  for (uint32_t i = 0; i < input_count; ++i)
    expect(p111_rt_reg_get(s, i) == i + 1, "wide argument value");
  return finish(s);
}
static uint64_t entry(P111State *s) {
  seed_unused(s);
  if (!strcmp(chosen, "scalar2")) return finish(s);
  if (!strcmp(chosen, "direct17") || !strcmp(chosen, "input255")) {
    uint64_t args[255];
    for (uint32_t i = 0; i < input_count; ++i) args[i] = i + 1;
    return p111_rt_jump(s, 1, args, input_count);
  }
  if (!strcmp(chosen, "capture17")) {
    uint64_t captures[16];
    for (uint32_t i = 0; i < 16; ++i) captures[i] = i + 1;
    uint64_t closure = p111_rt_closure(s, 1, captures, 16);
    return p111_rt_apply(s, closure, 17);
  }
  if (!strcmp(chosen, "io2")) {
    p111_rt_frame(s, 2, NULL, 0);
    uint64_t closure = (UINT64_C(3) << 56) | (UINT64_C(3) << 40);
    uint64_t unit = p111_rt_ctor(s, 7, NULL, 0);
    return p111_rt_apply(s, closure, unit); /* FID_IO_EMIT = segment_count = 3 */
  }
  if (!strcmp(chosen, "results3")) {
    uint64_t capture = 999;
    p111_rt_frame(s, 2, &capture, 1);
    return p111_rt_jump(s, 1, NULL, 0);
  }
  if (!strcmp(chosen, "result256")) {
    uint64_t values[256];
    for (uint32_t i = 0; i < 256; ++i) values[i] = i + 1;
    printf("%s:ok\n", chosen);
    return p111_rt_return(s, values, 256);
  }
  if (!strcmp(chosen, "getter-at-width")) return p111_rt_reg_get(s, width);
  if (!strcmp(chosen, "return-over-width")) {
    uint64_t values[] = {1, 2}; return p111_rt_return(s, values, 2);
  }
  if (!strcmp(chosen, "closure-zero-arity"))
    return p111_rt_apply(s, UINT64_C(3) << 56, 0);
  if (!strcmp(chosen, "closure-fid-outside"))
    return p111_rt_apply(s, (UINT64_C(3) << 56) | (UINT64_C(7) << 40), 0);
  fputs("bank-control: descriptor rejection unexpectedly entered\n", stderr);
  exit(3);
}

static const P111Segment segments[] = {entry, worker, continuation};
static uint8_t arity[] = {0, 0, 0}, flags[] = {2, 2, 2}, results[] = {0, 0, 0};
static const uint8_t ctor_arity[] = {0,2,0,2,0,2,2,0,0,1,1,1,1,2,0,0,0,0};
static const uint8_t ctor_hot[] = {0,1,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,0};
static const char *const ctor_names[] = {
  "SNil","SCon","WNil","WCon","Nil","Con","Tuple","Unit",
  "None","Some","Fail","Done","Emit","Halt","True","LT","EQ","GT"};
static const uint64_t static_image[] = {0};
static uint32_t show[519] = {0};
static const char *const show_names[] = {"Words"};
static P111Program program = {
  P111_ABI_VERSION,sizeof(P111Program),3,18,0,1,2,1,0,1,1,P111_SEQUENTIAL,
  segments,arity,flags,results,ctor_arity,ctor_hot,ctor_names,static_image,
  show,show_names,0,NULL
};
int main(int argc, char **argv) {
  if (argc != 2) return 2;
  chosen = argv[1];
  if (!strcmp(chosen, "direct17") || !strcmp(chosen, "capture17")) {
    input_count = width = 17; program.register_width = 17; arity[1] = 17;
  } else if (!strcmp(chosen, "input255")) {
    input_count = width = 255; program.register_width = 255; arity[1] = 255;
  } else if (!strcmp(chosen, "io2")) {
    arity[2] = 1; results[2] = 1;
  } else if (!strcmp(chosen, "results3")) {
    width = 4; program.register_width = 4; program.result_width = 3;
    arity[2] = 4; results[2] = 3;
  } else if (!strcmp(chosen, "result256")) {
    width = 256; program.result_width = 256; program.show_words = 519;
    /* One unboxed product, 256 scalar fields. Observe every EXIT/root word. */
    show[0] = 7; show[1] = 0; show[2] = 1;
    show[3] = 0; show[4] = 0; show[5] = 256;
    for (uint32_t i = 0; i < 256; ++i) { show[6 + 2*i] = i; show[7 + 2*i] = 518; }
    show[518] = 0;
  } else if (!strcmp(chosen, "descriptor-width257")) {
    program.register_width = 257;
  } else if (!strcmp(chosen, "descriptor-arity-over-width")) {
    arity[1] = 3;
  }
  char *runtime_argv[] = {argv[0], "--threads", "1", "--gpu", "off", NULL};
  return p111_rt_main(5, runtime_argv, &program);
}
