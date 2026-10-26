"""Source-only same-ABI small-transfer experiment, preserving serial RFC gates."""
import argparse,hashlib,json,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[6];HERE=Path(__file__).resolve().parent
BASE=ROOT/'selfhost/build/phase144/serial-rfc01'
OLD='  if (count) memmove(state->regs, values, count * sizeof(uint64_t));'
NEW='''  if (count) {
#if P144_SMALL_REG_COPY
    if (count == 1) {
      uint64_t word;
      memcpy(&word, values, sizeof word);
      state->regs[0] = word;
    } else if (count == 2) {
      uint64_t pair[2];
      memcpy(pair, values, sizeof pair);
      state->regs[0] = pair[0];
      state->regs[1] = pair[1];
    } else {
      memmove(state->regs, values, count * sizeof(uint64_t));
    }
#else
    memmove(state->regs, values, count * sizeof(uint64_t));
#endif
  }'''
PREFIX='''/* Phase144 opt-in: exact 8/16-byte copies; local snapshots retain memmove
 * overlap semantics. ABI, admission, ownership and serial RFC gates unchanged. */
#ifndef P144_SMALL_REG_COPY
#define P144_SMALL_REG_COPY 0
#endif
#if P144_SMALL_REG_COPY != 0 && P144_SMALL_REG_COPY != 1
#error "P144_SMALL_REG_COPY must be 0 or 1"
#endif
'''
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def verify(p):assert pin(p['file'])==p,p['file']
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase144')
manifest=json.loads((BASE/'manifest.json').read_text());built=json.loads((BASE/'build.json').read_text());n2file=ROOT/'selfhost/build/phase134/p144-final03-n2/report.json';n2=json.loads(n2file.read_text())
assert built['complete'] and n2['complete'] and n2['runtime']==built['variants']['serial-rfc']['object']
assert manifest['outputs'][0]['sha256']=='aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333'
inputs=[pin(__file__),pin(HERE/'copy-controls-v01.c'),pin(BASE/'manifest.json'),pin(BASE/'build.json'),*manifest['outputs'],pin(n2file),n2['object'],n2['binary'],n2['runtime'],pin('/usr/bin/x86_64-linux-gnu-gcc-10')]
for x in inputs:verify(x)
s=(BASE/'runtime.c').read_text();anchor='static void p111_set_regs(P111State *state, const uint64_t *values, uint32_t count) {'
assert s.count(OLD)==s.count(anchor)==1
candidate=s.replace(anchor,PREFIX+anchor).replace(OLD,NEW)
assert candidate.replace(PREFIX,'',1).replace(NEW,OLD,1)==s
out.mkdir(parents=True);(out/'runtime.c').write_text(candidate)
for name in ['runtime.h','primitives.h']:shutil.copyfile(BASE/name,out/name)
shutil.copyfile(HERE/'copy-controls-v01.c',out/'copy-controls-v01.c')
gcc='/usr/bin/x86_64-linux-gnu-gcc-10';jobs=[];modeproducts={}
# Independent count formula matches the enumerated test matrix, before execution.
observations=0
for width in [2,26,256]:
 for caps in [1,5]:
  observations+=1
  for count in range(width+1):
   observations+=8
   observations+=sum(0<=40+off and 40+off+count*8<=2088 for off in [-16,-8,-1,0,1,8,16])
observations+=6
for mode,label in [(0,'baseline'),(1,'candidate')]:
 flags=['-O2','-std=gnu11','-ffp-contract=off','-DP144_SINGLE_MUTATOR_RFC=1',f'-DP144_SMALL_REG_COPY={mode}']
 control=out/(label+'-controls');obj=out/(label+'.o');binary=out/(label+'-compiler')
 jobs.append(dict(label=label+'-compile-controls',argv=[gcc,*flags,'-I',str(out),str(out/'copy-controls-v01.c'),'-pthread','-lm','-o',str(control)],exit=0,stdout='',stderr='',product=str(control)))
 for what,code,stdout,stderr in [('copy',0,f'p144 small copies: {observations} PASS\n',''),('null1',1,'','bend: phase111: invalid register transfer\n'),('null2',1,'','bend: phase111: invalid register transfer\n'),('wide',1,'','bend: phase111: invalid register transfer\n'),('pool',1,'','bend: phase144 serial RFC runtime refuses compute workers\n')]:
  jobs.append(dict(label=label+'-'+what,argv=[str(control),what],exit=code,stdout=stdout,stderr=stderr))
 jobs.append(dict(label=label+'-compile-runtime',argv=[gcc,*flags,'-c',str(out/'runtime.c'),'-o',str(obj)],exit=0,stdout='',stderr='',product=str(obj)))
 jobs.append(dict(label=label+'-link-compiler',argv=[gcc,'-no-pie',n2['object']['file'],str(obj),'-pthread','-lm','-o',str(binary)],exit=0,stdout='',stderr='',product=str(binary)))
 modeproducts[label]=dict(object=str(obj),binary=str(binary),control=str(control))
r=dict(kind='phase144-small-transfer-source-plan',complete=True,targetsRun=False,qualified=False,selected=False,inputs=inputs,outputs=[pin(out/f) for f in ['runtime.c','runtime.h','primitives.h','copy-controls-v01.c']],parentRuntime=n2['runtime'],compilerObject=n2['object'],compilerBuild=pin(n2file),commands=jobs,variants=modeproducts,controlObservationsPerMode=observations,scope='Only p111_set_regs copy implementation changes under explicit compile-time opt-in. All entry checks and trailing clear, runtime ABI, serial RFC mode and worker refusal remain byte-identical. No compiler source/QBE/object regeneration.')
(out/'manifest.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(dict(manifest=pin(out/'manifest.json'),observations=observations,commands=len(jobs))))
