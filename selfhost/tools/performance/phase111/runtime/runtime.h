#ifndef P111_RUNTIME_H
#define P111_RUNTIME_H
#include <stdint.h>
#include <stddef.h>

#define P111_ABI_VERSION UINT64_C(11101)
#define P111_REG_CAP 256u
#define P111_RESULT_CAP 256u
#define P111_STOP UINT32_MAX
#define P111_SEQUENTIAL UINT64_C(1)

typedef struct { uint64_t *mem; uint64_t *alc; } P111Env;
typedef struct P111State {
  P111Env e;
  uint64_t *sp;
  uint32_t seq, rn, next, reserved;
  uint64_t regs[P111_REG_CAP];
} P111State;
typedef uint64_t (*P111Segment)(P111State *state);

/* Every descriptor field occupies one eight-byte slot on admitted x86-64.
 * Arrays have the explicitly named element widths. The descriptor and every
 * referenced object stay alive until program exit; no ownership is implied
 * by pointers in this metadata. Program segments exclude four runtime FIDs:
 * IO_EMIT=count, CLO_APPLY=count+1, EXIT=count+2, ENTER=count+3. */
typedef struct P111Program {
  uint64_t abi_version;          /*   0 */
  uint64_t descriptor_bytes;     /*   8: sizeof(P111Program) = 192 */
  uint64_t segment_count;        /*  16 */
  uint64_t constructor_count;    /*  24 */
  uint64_t main_fid;             /*  32 */
  uint64_t main_pure;            /*  40: zero or one */
  uint64_t register_width;       /*  48: maximum actual input/output width */
  uint64_t result_width;         /*  56: maximum actual result width */
  uint64_t static_words;         /*  64 */
  uint64_t show_words;           /*  72 */
  uint64_t show_name_count;      /*  80 */
  uint64_t capabilities;         /*  88: P111_SEQUENTIAL in ABI v1 */
  const P111Segment *segments;   /*  96: segment_count function pointers */
  const uint8_t *fid_arity;      /* 104: segment_count entries */
  const uint8_t *fid_flags;      /* 112: segment_count entries, old bits */
  const uint8_t *fid_results;    /* 120: segment_count continuation widths */
  const uint8_t *cid_arity;      /* 128: constructor_count entries */
  const uint8_t *cid_hot;        /* 136: constructor_count entries */
  const char *const *cid_names;  /* 144: constructor_count UTF-8 names */
  const uint64_t *static_image;  /* 152: static_words physical Term words */
  const uint32_t *show_desc;     /* 160: show_words, original show format */
  const char *const *show_names; /* 168: show_name_count strings */
  uint64_t effect_count;        /* 176 */
  const char *const *effects;    /* 184: requested effect-constructor names */
} P111Program;

_Static_assert(sizeof(void *) == 8, "Phase111 requires 64-bit pointers");
_Static_assert(sizeof(P111Env) == 16, "Env ABI");
_Static_assert(offsetof(P111State, sp) == 16, "state stack ABI");
_Static_assert(offsetof(P111State, seq) == 24, "state sequence ABI");
_Static_assert(offsetof(P111State, rn) == 28, "state result-count ABI");
_Static_assert(offsetof(P111State, next) == 32, "state transition ABI");
_Static_assert(offsetof(P111State, regs) == 40, "state register ABI");
_Static_assert(sizeof(P111State) == 2088, "state size ABI");
_Static_assert(sizeof(P111Program) == 192, "descriptor size ABI");
_Static_assert(offsetof(P111Program, segments) == 96, "descriptor pointer ABI");
_Static_assert(offsetof(P111Program, effects) == 184, "descriptor effect ABI");

int p111_rt_main(int argc, char **argv, const P111Program *program);
uint64_t p111_rt_keep(P111State *, uint64_t term);
uint64_t p111_rt_sink(P111State *, uint64_t term);
uint64_t p111_rt_ctor(P111State *, uint32_t cid, const uint64_t *fields, uint32_t count);
uint64_t p111_rt_take(P111State *, uint64_t term, uint64_t *out, uint32_t count);
uint64_t p111_rt_closure(P111State *, uint32_t fid, const uint64_t *fields, uint32_t count);
uint64_t p111_rt_tag(P111State *, uint64_t term);
uint64_t p111_rt_frame(P111State *, uint32_t next_fid, const uint64_t *captures, uint32_t count);
uint64_t p111_rt_jump(P111State *, uint32_t fid, const uint64_t *args, uint32_t count);
uint64_t p111_rt_return(P111State *, const uint64_t *values, uint32_t count);
uint64_t p111_rt_apply(P111State *, uint64_t closure, uint64_t argument);
uint64_t p111_rt_stack_pop(P111State *, uint32_t count);
uint64_t p111_rt_stack_get(P111State *, uint32_t index);
uint64_t p111_rt_reg_get(P111State *, uint32_t index);
uint64_t p111_rt_fail(P111State *, uint32_t code);
#endif
