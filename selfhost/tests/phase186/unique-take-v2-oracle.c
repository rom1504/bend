/* Reuse every v1 observation unchanged, then check all destination aliases
 * against the same independent state/cache oracle on success and every miss. */
#define main p186uv_original_main
#include "unique-take-oracle.c"
#undef main
extern uint64_t p186uv_word(State *,uint64_t,uint64_t *);
extern uint64_t p186uv_buffer(State *,uint64_t,uint64_t *);
extern uint64_t p186uv_state(State *,uint64_t,uint64_t *);
int main(void) {
  int result=p186uv_original_main();
  if(result)return result;
  unsigned old_checks=checks;
  size_t bytes=(BASE+1024)*sizeof(uint64_t);
  uint64_t *mem=mmap(NULL,bytes,PROT_NONE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  if(mem==MAP_FAILED || mprotect(mem+BASE-512,3*4096,PROT_READ|PROT_WRITE)){perror("sparse corpus");return 2;}
  Take funcs[3]={p186uv_word,p186uv_buffer,p186uv_state};
  for(unsigned f=0;f<3;++f)for(unsigned route=0;route<=8;++route)
    for(unsigned edge=0;edge<2;++edge)for(unsigned alias=0;alias<4;++alias)
      test(funcs[f],mem,2,129,7,edge?32766:0,route,alias);
  munmap(mem,bytes);
  printf("unique-take-v2 aliases: checks=%u failures=%u\n",checks-old_checks,failures);
  return failures?1:0;
}
