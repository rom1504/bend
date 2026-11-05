#!/usr/bin/env python3
"""Private reversible instrumentation of two frozen generated-C artifacts."""
import argparse,hashlib,json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.dont_write_bytecode=True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,write_json,fresh_output,run

def digest(s):return hashlib.sha256(s.encode()).hexdigest()
def region(text,signature):
 require(text.count(signature)==1,'Ambiguous function '+signature)
 start=text.index(signature);i=start+len(signature);depth=1;mode='code'
 while i<len(text):
  c=text[i];n=text[i:i+2]
  if mode=='line':
   if c=='\n':mode='code'
  elif mode=='block':
   if n=='*/':mode='code';i+=1
  elif mode in ['"',"'"]:
   if c=='\\':i+=1
   elif c==mode:mode='code'
  elif n=='//':mode='line';i+=1
  elif n=='/*':mode='block';i+=1
  elif c in ['"',"'"]:mode=c
  elif c=='{':depth+=1
  elif c=='}':
   depth-=1
   if depth==0:return start,i+1
  i+=1
 raise ValueError('Unclosed C function')

def observer(labels,timers,markers):
 # Bend execution-thread observations; called at normal bend_thread return.
 names=lambda xs:','.join(json.dumps(x) for x in xs) or '"unused"'
 return '''#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <stdint.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define P162_N '''+str(len(labels))+'''
#define P162_T '''+str(max(1,len(timers)))+'''
#define P162_M '''+str(max(1,len(markers)))+'''
static const char *p162_names[P162_N]={'''+names(labels)+'''};
static const char *p162_tnames[P162_T]={'''+names(timers)+'''};
static const char *p162_mnames[P162_M]={'''+names(markers)+'''};
static _Thread_local uint64_t p162_values[P162_N];
typedef struct {uint64_t cpu,wall,v[P162_N];} P162Snap;
static _Thread_local struct {uint64_t calls,cpu,wall,done,v[P162_N];} p162_t[P162_T];
static _Thread_local struct {uint64_t calls,order;P162Snap s;} p162_m[P162_M];
static _Thread_local uint64_t p162_order;
static uint64_t p162_ns(clockid_t id){struct timespec t;if(clock_gettime(id,&t))abort();return(uint64_t)t.tv_sec*1000000000ull+t.tv_nsec;}
static inline void p162_count(unsigned i,uint64_t n){p162_values[i]+=n;}
static P162Snap p162_snapshot(void){P162Snap s;s.cpu=p162_ns(CLOCK_PROCESS_CPUTIME_ID);s.wall=p162_ns(CLOCK_MONOTONIC);for(unsigned i=0;i<P162_N;i++)s.v[i]=p162_values[i];return s;}
static P162Snap p162_begin(unsigned id){p162_t[id].calls++;return p162_snapshot();}
static void p162_end(unsigned id,P162Snap s){P162Snap e=p162_snapshot();p162_t[id].cpu+=e.cpu-s.cpu;p162_t[id].wall+=e.wall-s.wall;for(unsigned i=0;i<P162_N;i++)p162_t[id].v[i]+=e.v[i]-s.v[i];}
static void p162_mark(unsigned id){if(!p162_m[id].calls++){p162_m[id].s=p162_snapshot();p162_m[id].order=++p162_order;}}
static void p162_print_values(FILE*f,uint64_t*v){fputs("{",f);for(unsigned i=0;i<P162_N;i++)fprintf(f,"%s\\\"%s\\\":%"PRIu64,i?",":"",p162_names[i],v[i]);fputs("}",f);}
static void p162_dump(void){const char*path=getenv("P162_DIAG_OUT");if(!path)return;FILE*f=fopen(path,"wx");if(!f)abort();fputs("{\\\"schema\\\":1,\\\"scope\\\":\\\"Bend execution-thread logical sites; gc requested words, not resident bytes\\\",\\\"total\\\":",f);p162_print_values(f,p162_values);fputs(",\\\"timers\\\":[",f);
 for(unsigned j=0;j<'''+str(len(timers))+''';j++){fprintf(f,"%s{\\\"label\\\":\\\"%s\\\",\\\"calls\\\":%"PRIu64",\\\"done\\\":%"PRIu64",\\\"cpuNs\\\":%"PRIu64",\\\"wallNs\\\":%"PRIu64",\\\"counts\\\":",j?",":"",p162_tnames[j],p162_t[j].calls,p162_t[j].done,p162_t[j].cpu,p162_t[j].wall);p162_print_values(f,p162_t[j].v);fputs("}",f);}fputs("],\\\"markers\\\":[",f);
 for(unsigned j=0;j<'''+str(len(markers))+''';j++){fprintf(f,"%s{\\\"label\\\":\\\"%s\\\",\\\"calls\\\":%"PRIu64",\\\"order\\\":%"PRIu64",\\\"cpuNs\\\":%"PRIu64",\\\"wallNs\\\":%"PRIu64",\\\"counts\\\":",j?",":"",p162_mnames[j],p162_m[j].calls,p162_m[j].order,p162_m[j].s.cpu,p162_m[j].s.wall);p162_print_values(f,p162_m[j].s.v);fputs("}",f);}fputs("]}\\n",f);if(fclose(f))abort();}
'''

def prepare(role,out):
 path=ROOT/'experiments/phase162'/('bendc-frontend-hooks.json' if role=='bendc' else 'ours-c02-operation-hooks.json')
 proposal=json.loads(path.read_text());runtime=ROOT/'selfhost/build/phase159/refill-prepare01/bendrt.h'
 if role=='bendc':
  for row in proposal['inputs']:require(pin(ROOT/row['path'])['sha256']==row['sha256'],'Input differs')
  source=ROOT/'selfhost/build/phase157/vendor/seed/bendc.c';hooks=proposal['counterHooks'];timers=proposal['stageWrappers'];markers=[]
  parent=ROOT/'selfhost/build/phase160/capped-seed01/report.json'
 else:
  source=ROOT/proposal['source']['file'];require(pin(source)['sha256']==proposal['source']['sha256'],'Input differs')
  hooks=[dict(h,file='seed') for h in proposal['hooks']];timers=[];markers=proposal['markers']+proposal['alternativeCandidateMarkers']
  parent=ROOT/'selfhost/build/phase160/request-c02/report.json'
 labels=['gc_alloc_calls','gc_requested_words','gc_refill_calls','gc_collection_calls']+list(dict.fromkeys(h['label'] for h in hooks))
 tlabels=[t['label'] for t in timers];mlabels=list(dict.fromkeys(m['label'] for m in markers))
 texts={'seed':source.read_text(),'runtime':runtime.read_text()};groups={}
 for typ,rows in [('counter',hooks),('timer',timers),('marker',markers)]:
  for row in rows:groups.setdefault((row.get('file','seed'),row['symbol']),[]).append((typ,row))
 edits={key:[] for key in texts};receipts=[]
 for (file,symbol),items in groups.items():
  first=items[0][1];sig=first.get('signature',first.get('function',{}).get('signature'));start,end=region(texts[file],sig);old=texts[file][start:end];body=old
  for typ,row in items:
   expected=row.get('functionSha256',row.get('function',{}).get('sha256'))
   observed=digest(old if 'functionSha256' in row else old+'\n');require(observed==expected,'Function identity differs '+symbol)
   if typ=='counter':
    needle=row['needle'];require(body.count(needle)==1,'Counter anchor ambiguous '+symbol)
    body=body.replace(needle,needle+f'\np162_count({labels.index(row["label"])},1);\n',1)
   elif typ=='marker':
    body=body.replace(sig,sig+f'\np162_mark({mlabels.index(row["label"])});\n',1)
   elif typ=='timer':
    idx=tlabels.index(row['label']);args=','.join('a'+str(i) for i in range(row['arity']));impl=symbol+'_p162_impl';implsig=sig.replace(symbol,impl,1)
    header=implsig[:-1]+';\n'+sig+'\nP162Snap p162_s=p162_begin('+str(idx)+');\nV p162_r='+impl+'('+args+');\np162_end('+str(idx)+',p162_s);\n'
    if row['label']!='report':header+='p162_t['+str(idx)+'].done += IS_N(p162_r,1);\n'
    body=header+'return p162_r;\n}\n'+body.replace(sig,implsig,1)
  edits[file].append((start,end,body));receipts.append(dict(file=file,symbol=symbol,originalSha256=digest(old),instrumentedSha256=digest(body),sites=len(items)))
 for file in texts:
  for start,end,body in sorted(edits[file],reverse=True):texts[file]=texts[file][:start]+body+texts[file][end:]
 runtimeedits=[('static inline V *gc_alloc_x(size_t w, int atomic, int hole) {','\np162_count(0,1);p162_count(1,w);\n'),('__attribute__((noinline)) static V *gc_refill(GcCache *k, int atomic, unsigned c) {','\np162_count(2,1);\n'),('__attribute__((noinline)) static void gc_collect_locked(void) {','\np162_count(3,1);\n')]
 for needle,add in runtimeedits:require(texts['runtime'].count(needle)==1,'Runtime anchor differs');texts['runtime']=texts['runtime'].replace(needle,needle+add,1)
 needle='  fflush(stdout);\n  return NULL;';require(texts['runtime'].count(needle)==1,'Worker return anchor ambiguous');texts['runtime']=texts['runtime'].replace(needle,'  p162_dump();\n'+needle,1)
 out=fresh_output(out,ROOT);(out/'program.c').write_text('#include "observer.h"\n'+texts['seed']);(out/'bendrt.h').write_text(texts['runtime']);(out/'observer.h').write_text(observer(labels,tlabels,mlabels))
 d=json.loads(parent.read_text());cmd=list(d['process']['command']);originalsource=str(source) if role=='ours' else 'selfhost/build/phase157/vendor/seed/bendc.c'
 require(originalsource in cmd,'Parent source absent');cmd[cmd.index(originalsource)]=str(out/'program.c');cmd[cmd.index('-o')+1]=str(out/'program');cmd[cmd.index('-I'):cmd.index('-I')]=['-I',str(out)]
 inputs=[pin(x) for x in [__file__,path,source,runtime,parent,ROOT/cmd[0],out/'program.c',out/'bendrt.h',out/'observer.h']]
 write_json(out/'plan.json',dict(complete=True,executed=False,role=role,inputs=inputs,command=cmd,sites=receipts,counters=labels,timers=tlabels,markers=mlabels,runtimeEdits=[dict(needle=x,insertion=y) for x,y in runtimeedits],scope='Diagnostic-only additive counters and pure-return wrappers; parent algorithms/runtime policy unchanged. Complete clean-output gates required. Bend execution thread only.'))

p=argparse.ArgumentParser();p.add_argument('action',choices=['prepare','build']);p.add_argument('--role',choices=['ours','bendc']);p.add_argument('--out',type=Path,required=True);p.add_argument('--prep',type=Path);a=p.parse_args()
if a.action=='prepare':require(a.role is not None,'Role required');prepare(a.role,a.out)
else:
 prep=a.prep.resolve();plan=json.loads((prep/'plan.json').read_text());out=fresh_output(a.out,ROOT)
 for row in plan['inputs']:verify(row)
 result=run(plan['command'],cwd=ROOT,stdout=out/'stdout',stderr=out/'stderr',seconds=180)
 report=dict(complete=result['complete'],plan=pin(prep/'plan.json'),process=result,inputs=plan['inputs'])
 if result['complete']:report['binary']=pin(prep/'program')
 write_json(out/'report.json',report);require(report['complete'],'Diagnostic C compilation failed')
print(json.dumps(dict(complete=True,action=a.action)))
