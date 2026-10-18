/* Context-load diagnostic: assertions only, no runtime behavior changes. */
#include <stddef.h>
_Static_assert(sizeof(void *) == 8 && sizeof(Corpus) == 8 && sizeof(Env) == 16,
  "context-call ABI requires two 64-bit Env pointers");
_Static_assert(offsetof(NxRt, env) + offsetof(Env, mem) == 0,
  "context-call heap pointer offset differs");
_Static_assert(offsetof(NxRt, env) + offsetof(Env, alc) == 8,
  "context-call allocator pointer offset differs");
