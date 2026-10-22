/* Independent calibration derived from Phase112's three-segment ABI control.
 * Adds sized ctor/take and one extend1/finish without changing result45. */
#include "runtime.h"
#include "primitives.h"
#include <stdio.h>
#include <stdlib.h>

extern uint64_t p118_p111_rt_ctor2(P111State *, uint32_t, const uint64_t *, uint32_t);
extern uint64_t p118_p111_rt_take2(P111State *, uint64_t, uint64_t *, uint32_t);
extern uint64_t p118_rt_extend1(P111State *, uint64_t, uint32_t, const uint64_t *);
extern uint64_t p118_rt_finish(P111State *, uint64_t, uint64_t, uint64_t);

static void expect(int good) {
  if (!good) { fputs("p125-counter-control: wrong value\n", stderr); exit(2); }
}
static uint64_t first(P111State *s) {
  uint64_t operands[] = {7, 5};
  uint64_t sum = p111_rt_op(s, P111_OP_U32_ADD, operands, 2);
  expect(sum == 12);
  p111_rt_sink(s, p111_rt_keep(s, sum));
  uint64_t values[] = {sum, 3}, fields[2];
  uint64_t tuple = p111_rt_ctor(s, 6, values, 2);
  expect(p111_rt_tag(s, tuple) == 6);
  p111_rt_take(s, tuple, fields, 2);
  expect(fields[0] == 12 && fields[1] == 3);
  tuple = p118_p111_rt_ctor2(s, 6, values, 2);
  p118_p111_rt_take2(s, tuple, fields, 2);
  expect(fields[0] == 12 && fields[1] == 3);
  uint64_t prefix[] = {41}, list_fields[2];
  uint64_t nil = p111_rt_ctor(s, 4, NULL, 0);
  uint64_t node = p118_rt_extend1(s, 0, 5, prefix);
  node = p118_rt_finish(s, node, node, nil);
  p118_p111_rt_take2(s, node, list_fields, 2);
  expect(list_fields[0] == 41 && p111_rt_tag(s, list_fields[1]) == 4);
  uint64_t capture = 9;
  p111_rt_frame(s, 2, &capture, 1);
  return p111_rt_jump(s, 1, fields, 2);
}
static uint64_t second(P111State *s) {
  uint64_t values[] = {p111_rt_reg_get(s, 0), p111_rt_reg_get(s, 1)};
  uint64_t result = p111_rt_op(s, P111_OP_U32_MUL, values, 2);
  expect(result == 36);
  return p111_rt_return(s, &result, 1);
}
static uint64_t continuation(P111State *s) {
  expect(s->rn == 1);
  uint64_t result = p111_rt_reg_get(s, 0);
  p111_rt_stack_pop(s, 1);
  uint64_t capture = p111_rt_stack_get(s, 0);
  expect(result == 36 && capture == 9);
  result += capture;
  return p111_rt_return(s, &result, 1);
}
static const P111Segment segments[] = {first, second, continuation};
static const uint8_t arity[] = {0,2,2}, flags[] = {2,2,3}, results[] = {0,0,1};
static const uint8_t ctor_arity[] = {0,2,0,2,0,2,2,0,0,1,1,1,1,2,0,0,0,0};
static const uint8_t ctor_hot[] = {0,1,0,1,0,1,1,0,0,1,1,1,1,1,0,0,0,0};
static const char *const ctor_names[] = {
  "SNil","SCon","WNil","WCon","Nil","Con","Tuple","Unit",
  "None","Some","Fail","Done","Emit","Halt","True","LT","EQ","GT"};
static const uint64_t static_image[] = {0};
static const uint32_t show[] = {0};
static const char *const show_names[] = {"U32"};
static const P111Program program = {
  P111_ABI_VERSION,sizeof(P111Program),3,18,0,1,2,1,0,1,1,P111_SEQUENTIAL,
  segments,arity,flags,results,ctor_arity,ctor_hot,ctor_names,static_image,
  show,show_names,0,NULL
};
int main(int argc, char **argv) {
  (void)argc;
  char *runtime_argv[] = {argv[0], "--threads", "1", "--gpu", "off", NULL};
  return p111_rt_main(5, runtime_argv, &program);
}
