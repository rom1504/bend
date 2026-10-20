/* Supplement to the immutable first runtime fixture. Shared array handles
 * observe mutation through both references; cloning is a different operation. */
#define main phase113_baseline_unused_main
#include "array-pair-boundary.c"
#undef main

static void handle_alias(P111State *s, int flat, int alias_first) {
  uint64_t a = p111_rt_keep(s, array(s, 1));
  uint64_t alias = a; /* both credits use the returned RFC word */
  uint64_t args[] = {a, 1, text(s, replacement, 2)}, out[2];
  pair(s, flat, P111_OP_ARRAY_SWAP, args, 3, out);
  a = out[0];
  uint64_t old = out[1];
  if (alias_first) {
    alias = get(s, flat, alias, 1, replacement, 2);
    p111_rt_sink(s, alias);
    a = get(s, flat, a, 1, replacement, 2);
    a = get(s, flat, a, 0, seed, 3);
    p111_rt_sink(s, a);
  } else {
    a = get(s, flat, a, 1, replacement, 2);
    p111_rt_sink(s, a);
    alias = get(s, flat, alias, 1, replacement, 2);
    alias = get(s, flat, alias, 0, seed, 3);
    p111_rt_sink(s, alias);
  }
  consume(s, old, seed, 3); /* old String survives both array handle releases */
}
static uint64_t handle_segment(P111State *s) {
  int alias_first;
  if (!strcmp(chosen, "handle-alias-first")) alias_first = 1;
  else if (!strcmp(chosen, "handle-original-first")) alias_first = 0;
  else {
    fputs("phase113-boundary: unknown shared-handle case\n", stderr);
    exit(2);
  }
  handle_alias(s, 0, alias_first);
  handle_alias(s, 1, alias_first);
  printf("%s:ok\n", chosen);
  uint64_t zero = 0;
  return p111_rt_return(s, &zero, 1);
}
static const P111Segment handle_segments[] = {handle_segment};
static const P111Program handle_program = {
  P111_ABI_VERSION,sizeof(P111Program),1,18,0,1,2,1,0,1,1,P111_SEQUENTIAL,
  handle_segments,arity,flags,results,ctor_arity,ctor_hot,ctor_names,static_image,
  show,show_names,0,NULL
};
int main(int argc, char **argv) {
  if (argc != 2) {
    fputs("usage: array-shared-handle CASE\n", stderr);
    return 2;
  }
  chosen = argv[1];
  char *runtime_argv[] = {argv[0], "--threads", "1", "--gpu", "off", NULL};
  return p111_rt_main(5, runtime_argv, &handle_program);
}
