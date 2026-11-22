#include "runtime.h"
#include <stdio.h>
#include <string.h>

extern int __real_p111_rt_main(int argc, char **argv, const P111Program *program);
extern uint64_t __real_p111_rt_return(P111State *, const uint64_t *, uint32_t);

static P111Program *g_prog = NULL;
static uint32_t g_mnode_cid = UINT32_MAX;
static int g_mnode_returns = 0;
static int g_armed = 0;
static int g_violations = 0;

uint64_t __wrap_p111_rt_return(P111State *s, const uint64_t *vals, uint32_t count) {
  if (g_prog && count == 1 && vals) {
    uint64_t v = vals[0];
    uint32_t cid = (uint32_t)((v >> 40) & 0xffffu);
    if (((v >> 56) & 0x7fu) == 2u && cid == g_mnode_cid) {
      g_mnode_returns++;
      if (!g_armed && g_mnode_returns == 2) {
        ((uint8_t *)g_prog->cid_hot)[g_mnode_cid] = 1;
        g_armed = 1;
        fprintf(stderr, "[HOOK] Armed cid_hot[MNode=%u]=1 after 3rd MNode return!\n", g_mnode_cid);
      } else if (g_armed) {
        /* This is Map.del's returned MNode while cid_hot[MNode]==1! Inspect its children directly! */
        uint64_t loc = v & UINT64_C(0xffffffffff);
        uint64_t *mem = (uint64_t *)s->e.mem;
        if ((v >> 63) == 0) {
          for (int i = 1; i <= 2; i++) {
            uint64_t ch = mem[loc + i];
            fprintf(stderr, "[HOOK] Post-Map.del MNode child[%d]: tag=0x%02lx cid=%lu\n",
                    i, (unsigned long)(ch >> 56), (unsigned long)((ch >> 40) & 0xffffu));
            if (((ch >> 56) & 0x7fu) == 2u && (ch >> 63) == 0) {
              g_violations++;
            }
          }
        }
      }
    }
  }
  return __real_p111_rt_return(s, vals, count);
}

int __wrap_p111_rt_main(int argc, char **argv, const P111Program *program) {
  g_prog = (P111Program *)program;
  for (uint64_t i = 0; i < program->constructor_count; i++) {
    if (program->cid_names[i] && strcmp(program->cid_names[i], "MNode") == 0) g_mnode_cid = (uint32_t)i;
  }
  int rc = __real_p111_rt_main(argc, argv, program);
  fprintf(stderr, "[HOOK] mnode_returns=%d armed=%d violations=%d\n", g_mnode_returns, g_armed, g_violations);
  return rc;
}
