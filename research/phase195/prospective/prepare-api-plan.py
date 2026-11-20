import pathlib,json,subprocess,os
os.sched_setaffinity(0,{0});r=pathlib.Path.cwd();p=r/'research/phase195/prospective'
(p/'remainder-hook.bend').write_text('''@unsafe
def x185_function_place(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  x186_function_memory(symbol,params,setup,x185_prepare_body(params,setup,
    x185_scratch_body(params,setup,x195rem_body(params,setup,body))),ids)
''')
base='''def p195rc_v(name: String) -> N111Value: N111Local{name}
def p195rc_c(value: U32) -> N111Value: N111Const{value,0}
def p195rc_call(name: String, symbol: String, state: String, op: U32, buffer: String, count: U32) -> N111Stmt:
  N111Call{name,N111U64{},symbol,[N111Arg{N111Ptr{},p195rc_v(state)},N111Arg{N111U32{},p195rc_c(op)},N111Arg{N111Ptr{},p195rc_v(buffer)},N111Arg{N111U32{},p195rc_c(count)}]}
def p195rc_facts(d: U32) -> List<&2,X185ScratchCell>:
  [X185ScratchCell{"private",0,N111U64{},p195rc_v("n")},X185ScratchCell{"private",8,N111U64{},p195rc_c(d)}]
def p195rc_count(stmt: N111Stmt, facts: List<&2,X185ScratchCell>, expected: U32) -> Bool:
  U32.is_eq(nt_count(N111Stmt,x195rem_scalar(stmt,facts)),expected)
def p195rc_row(name: String, good: Bool) -> String:
  "rem-" ++ name ++ "=" ++ nt_choose(String,good,u => "1",u => "0")
'''
labels=[];exprs=[]
def row(label,expr):labels.append('rem-'+label);exprs.append('p195rc_row("'+label+'",'+expr+')')
call=lambda name='out',symbol='p111_rt_op',state='state',op=19,buffer='private',count=2:f'p195rc_call("{name}","{symbol}","{state}",{op},"{buffer}",{count})'
for d in [6,10,26,80]:row('admit-'+str(d),f'p195rc_count({call()},p195rc_facts({d}),5)')
for d in [0,1,7]:row('refuse-'+str(d),f'p195rc_count({call()},p195rc_facts({d}),1)')
for label,kwargs in [('symbol',{'symbol':'p195rc_runtime'}),('state',{'state':'other'}),('op',{'op':18}),('arity',{'count':1}),('buffer-state',{'buffer':'state'}),('destination-alias',{'name':'n'})]:row(label,f'p195rc_count({call(**kwargs)},p195rc_facts(26),1)')
row('unknown-facts',f'p195rc_count({call()},[],1)')
row('unknown-divisor',f'p195rc_count({call()},[X185ScratchCell{{"private",0,N111U64{{}},p195rc_v("n")}},X185ScratchCell{{"private",8,N111U64{{}},p195rc_v("salt")}}],1)')
row('wrong-width',f'p195rc_count({call()},[X185ScratchCell{{"private",0,N111U32{{}},p195rc_v("n")}},X185ScratchCell{{"private",8,N111U64{{}},p195rc_c(26)}}],1)')
row('high-divisor-bits',f'p195rc_count({call()},[X185ScratchCell{{"private",0,N111U64{{}},p195rc_v("n")}},X185ScratchCell{{"private",8,N111U64{{}},N111Const{{26,1}}}}],1)')
base+='@unsafe\ndef p195rc_controls() -> List<&2,String>:\n  ['+',\n   '.join(exprs)+']\n'
ds=[6,10,26,7,0,1,97,80,4294967295,26]
base+='''@unsafe
def p195rc_rows(+d: U32, +name: String, symbol: String) -> List<&2,P113DStmt>:
  [P113DScalar{N111Alloca{"private",16,8}},
   P113DScalar{N111Store{N111U64{},p195rc_v("private"),0,p195rc_v("n")}},
   P113DScalar{N111Store{N111U64{},p195rc_v("private"),8,p195rc_c(d)}},
   P113DScalar{p195rc_call(name,symbol,"state",19,"private",2)},
   P113DScalar{N111Bin{"answer",N111U64{},"add",p195rc_v(name),p195rc_v("salt")}},P113DResult{[p195rc_v("answer")]}]
@unsafe
def p195rc_pair(+d: U32, +mode: U32, +name: String) -> X181Output:
  x181_program_join(x181_function("p195rc_old_" ++ U32.show(mode),["state","n","salt"],p195rc_rows(d,name,"p195rc_runtime"),N111Ids{missing(),missing()}),
    x181_function("p195rc_new_" ++ U32.show(mode),["state","n","salt"],p195rc_rows(d,name,"p111_rt_op"),N111Ids{missing(),missing()}))
@unsafe
def p195rc_emit() -> X181Output:
'''
s='X181Output{[],""}'
for i,d in reversed(list(enumerate(ds))):s=f'x181_program_join(p195rc_pair({d},{i},"'+('n' if i==9 else 'out')+'"),'+s+')'
base+='  '+s+'\n';(p/'remainder-controls.bend').write_text(base)
c='''#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "../../../selfhost/src/runtime/qbe/runtime.h"
extern uint64_t p111_rt_op(P111State *,uint32_t,const uint64_t *,uint32_t);
__attribute__((noinline)) uint64_t p195rc_runtime(P111State*s,uint32_t op,const uint64_t*a,uint32_t n){return p111_rt_op(s,op,a,n);}
typedef uint64_t(*worker)(P111State*,uint64_t,uint64_t);
'''
for i in range(10):c+=f'extern uint64_t p195rc_old_{i}(P111State*,uint64_t,uint64_t),p195rc_new_{i}(P111State*,uint64_t,uint64_t);\n'
c+='static worker old[10]={'+','.join(f'p195rc_old_{i}' for i in range(10))+'};\n'
c+='static worker newer[10]={'+','.join(f'p195rc_new_{i}' for i in range(10))+'};\n'
c+='static uint32_t divisor[10]={'+','.join(str(d)+'u' for d in ds)+'};\n'
c+='''int main(void){
 uint32_t rng=19526u,edge[8]={0,1,25,26,27,0x7fffffffu,0x80000000u,0xffffffffu};unsigned checks=0,failures=0;
 for(unsigned i=0;i<264;i++){rng=rng*1664525u+1013904223u;uint32_t n=i<8?edge[i]:rng;
  uint64_t raw=((i&1)?UINT64_C(0xfedcba98)<<32:0)|n,salt=UINT64_C(0xf123456789abcdef);
  for(unsigned m=0;m<10;m++){P111State a={0},b={0},zero={0};uint32_t d=divisor[m];
   uint64_t want=(d?(uint64_t)(n%d):raw)+salt;
   uint64_t x=old[m](&a,raw,salt),y=newer[m](&b,raw,salt);
   int ok=x==want&&y==want&&!memcmp(&a,&zero,sizeof a)&&!memcmp(&b,&zero,sizeof b);
   checks++;if(!ok){if(failures<5)fprintf(stderr,"mode=%u n=%llu expected=%llu old=%llu new=%llu\\n",m,(unsigned long long)raw,(unsigned long long)want,(unsigned long long)x,(unsigned long long)y);failures++;}
  }
 }
 printf("phase195 remainder controls: checks=%u failures=%u\\n",checks,failures);return failures?1:0;
}
''';(p/'remainder-controls.c').write_text(c)
driver=(r/'selfhost/tests/phase195/float/sqrt-driver.mjs').read_text();a=driver.index('const specs=');b=driver.index('const groups=',a)
spec={'controls':'p195rc_controls','emit':'p195rc_emit','outputs':1,'fixture':'research/phase195/prospective/remainder-controls.bend','observer':'research/phase195/prospective/remainder-controls.c','expected':'phase195 remainder controls: checks=2640 failures=0\n','labels':labels}
driver=driver[:a]+'const specs='+json.dumps({'remainder':spec})+';\n'+driver[b:]
driver=driver.replace("'../../../tools/build/hosted.mjs'","'../../../selfhost/tools/build/hosted.mjs'").replace("??'sqrt'","??'remainder'").replace("kind:'phase195-sqrt-controls'","kind:'phase195-remainder-controls'")
a=driver.index("  scope:'");b=driver.index("'};",a)
driver=driver[:a]+"  scope:'Finite constant-remainder admission and independent unsigned arithmetic/ABI observations. Both object routes share Bend selection; no timing or general correctness claim."+driver[b:]
(p/'remainder-driver.mjs').write_text(driver)
source='selfhost/build/phase195/remainder-api-source01';out='selfhost/build/phase195/remainder-api01'
prep=['python3','-B','selfhost/tests/phase190/prepare-api.py','--parent-source','selfhost/build/phase195/combined-api-source01/compiler.bend','--assets','selfhost/build/phase194/assets.json','--out',source]
for f in ['constant-remainder.bend','remainder-hook.bend','remainder-controls.bend']:prep+=['--module',str((p/f).relative_to(r))]
prep+=['--replace','x185_function_place','--export','p195rc_controls','--export','p195rc_emit']
acquire=['python3','-B','selfhost/tests/phase195/job.py','--rss-mib','3072','remainder-api01','120','96','selfhost/.assets/bin/bun','selfhost/tools/build/hosted.mjs','acquire','--source',source+'/compiler.bend','--exports',source+'/exports.json','--out',out,'--engine','selfhost/.assets/bin/bun','--upstream','selfhost/.bootstrap/upstream-phase182']
controls=['python3','-B','selfhost/tests/phase195/job.py','--rss-mib','3072','remainder-controls01','120','96','selfhost/.assets/bin/bun','research/phase195/prospective/remainder-driver.mjs','--api',out+'/report.json','--assets','selfhost/build/phase194/assets.json','--out','selfhost/build/phase195/remainder-controls01','--seconds','110','--source-manifest',source+'/manifest.json']
for name,argv in [('prepare',prep),('acquire',acquire),('controls',controls)]: (p/(name+'-argv.json')).write_text(json.dumps(argv,indent=2)+'\n')
subprocess.run(prep,check=True)
print('Prepared source only; acquisition/control argv unexecuted.')
