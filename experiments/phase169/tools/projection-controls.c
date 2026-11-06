/* Valid published Data only. Original take/load/sink/return versus private
 * projection; no forged counts, unsafe inputs, failure or signal probes. */
#include "runtime.c"
static const uint8_t arities[]={0,1,2,3,4,5,6,7,8,9};
static const uint8_t hot[]={1,1,1,1,1,1,1,1,1,1};
static const P111Program program={.constructor_count=10,.static_words=128,
  .cid_arity=arities,.cid_hot=hot,.capabilities=5};
#define CHECK(x) do { if (!(x)) {fprintf(stderr,"projection control line %d\n",__LINE__);return 2;} } while(0)
enum {WORDS=8192};
static int run(unsigned n,unsigned index,unsigned mask,unsigned mode,
               unsigned duplicate,unsigned fast,Term *snapshot) {
  size_t size=(HEAP_OFF+WORDS)*sizeof(Term);
  Term *H=mmap(NULL,size,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  CHECK(H!=MAP_FAILED);
  P111State state={.e={H,H+HEAP_OFF+7500}};
  /* Pristine independent free blocks; all objects and RFC cells are then made
   * by the ordinary runtime constructor/publication/keep APIs. */
  for(unsigned cls=0;cls<=4;++cls)
    for(unsigned j=0;j<32;++j) heap_free(state.e,cls,HEAP_OFF+64+cls*1024+j*(1u<<cls));
  Term fields[32],answer[32],shared=0;
  unsigned owning=0;
  for(unsigned j=0;j<n;++j) if(j==index || (mask&(1u<<j))) ++owning;
  if(duplicate) {
    Term word=71;
    shared=p111_rt_ctor(&state,1,&word,1);
    if(owning>1) shared=p111_rt_keep(&state,shared);
    for(unsigned j=2;j<owning;++j) shared=p111_rt_keep(&state,shared);
  }
  for(unsigned j=0;j<n;++j) {
    Term word=71+j;
    fields[j]=(j==index || (mask&(1u<<j)))
      ? (duplicate?shared:p111_rt_ctor(&state,1,&word,1)) : (Term)(100+j);
  }
  Term parent=p111_rt_ctor(&state,n,fields,n);
  if(mode==1) parent=rfc_seal(state.e,parent);
  if(mode==2) parent=p111_rt_keep(&state,parent);
  unsigned kind=n<=4?n:0;
  Term selected=fast?p169_rt_project(&state,parent,n,index,mask,kind)
                    :p169_project_previous(&state,parent,n,index,mask,kind);
  /* Observe the full ordinary runtime state before consuming the retained root. */
  memcpy(snapshot,H+HEAP_OFF,WORDS*sizeof(Term));
  snapshot[WORDS]=selected;
  if(mode==2) {
    CHECK(p111_rt_take(&state,parent,answer,n)==n);
    for(unsigned j=0;j<n;++j) p111_rt_sink(&state,answer[j]);
  }
  CHECK(p111_rt_take(&state,selected,answer,1)==1);
  CHECK(answer[0]==(duplicate?71:71+index));
  memcpy(snapshot+WORDS+1,H+HEAP_OFF,WORDS*sizeof(Term));
  CHECK(munmap(H,size)==0);
  return 0;
}
int main(void) {
  p111_program_active=&program;KEEP_WORDS=4096;
  const unsigned shapes[][3]={{8,0,50},{9,1,509},{4,1,13},{2,1,1}};
  size_t size=(2*WORDS+1)*sizeof(Term);
  Term *a=malloc(size),*b=malloc(size);CHECK(a&&b);
  unsigned rows=0;
  for(unsigned s=0;s<4;++s) for(unsigned mode=0;mode<3;++mode)
    for(unsigned duplicate=0;duplicate<2;++duplicate) {
      CHECK(run(shapes[s][0],shapes[s][1],shapes[s][2],mode,duplicate,0,a)==0);
      CHECK(run(shapes[s][0],shapes[s][1],shapes[s][2],mode,duplicate,1,b)==0);
      CHECK(memcmp(a,b,size)==0);++rows;
    }
  /* Ordinary immutable static node and packed single-field value. */
  size_t bytes=(HEAP_OFF+WORDS)*sizeof(Term);
  Term *H=mmap(NULL,bytes,PROT_READ|PROT_WRITE,MAP_PRIVATE|MAP_ANONYMOUS,-1,0);
  CHECK(H!=MAP_FAILED);P111State state={.e={H,H+HEAP_OFF+7500}};
  H[HEAP_OFF-16]=41;H[HEAP_OFF-15]=42;
  Term static_node=term_ctr(2,HEAP_OFF-16),packed=term_pak(1,43);
  CHECK(p169_project_previous(&state,static_node,2,1,1,2)==42);
  CHECK(p169_rt_project(&state,static_node,2,1,1,2)==42);
  CHECK(H[HEAP_OFF-16]==41 && H[HEAP_OFF-15]==42);
  CHECK(p169_project_previous(&state,packed,1,0,0,1)==43);
  CHECK(p169_rt_project(&state,packed,1,0,0,1)==43);
  CHECK(munmap(H,bytes)==0);free(a);free(b);
  printf("projection: %u complete-state rows + static + packed PASS\n",rows);
  return 0;
}
