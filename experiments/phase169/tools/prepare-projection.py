#!/usr/bin/env python3
"""Private saved-QBE ceiling experiment. Data only; never compiler implementation."""
import argparse, hashlib, importlib.util, json, re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('census',HERE/'projection-census.py')
census=importlib.util.module_from_spec(spec);spec.loader.exec_module(census)
def pin(p):
 p=Path(p).resolve();d=p.read_bytes();return dict(file=str(p),bytes=len(d),sha256=hashlib.sha256(d).hexdigest())
def verify(p):
 a=pin(p['file']);assert all(a[k]==p[k] for k in ('bytes','sha256'))
def private_buffer(body,buffer):
 lines=[x.strip() for x in body.splitlines()];aliases={buffer}
 if lines.count(buffer+' =l alloc8 2048')!=1:return False
 for line in lines:
  m=re.fullmatch(r'(%\w+) =l add (%\w+), \d+',line)
  if m and m[2] in aliases:aliases.add(m[1])
 for line in lines:
  if not (set(re.findall(r'%\w+',line)) & aliases):continue
  if line==buffer+' =l alloc8 2048':continue
  m=re.fullmatch(r'%\w+ =l (?:add|loadl) (%\w+)(?:, \d+)?',line)
  if m and m[1] in aliases:continue
  m=re.fullmatch(r'%\w+ =l call \$(?:p111_rt_take|p125_rt_take[1-4])\(l %state, l %\w+, l (%\w+)(?:, w \d+)?\)',line)
  if m and m[1]==buffer:continue
  return False
 return True
def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
 out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
 report_path=ROOT/'selfhost/build/phase169/checker-baseline-machine01/report.json'
 report=json.loads(report_path.read_text());assert report['complete']
 for key in ('sourceIR','binary','object','runtime'):verify(report[key])
 source=Path(report['sourceIR']['file']);text=source.read_text();assert 'p169_rt_project' not in text
 edits=[]
 for fn in re.finditer(r'((?:export )?function [^\n]+\{\n)(.*?)(^\}\n)',text,re.M|re.S):
  body=fn[2];owner=re.search(r'\$(\S+)\(',fn[1])[1]
  for block in re.finditer(r'(^@[^\n]+\n)(.*?)(?=^@|\Z)',body,re.M|re.S):
   lines=[x.strip() for x in block[2].splitlines() if x.strip()]
   found=census.inspect(owner,block[1].strip(),lines)
   if not found or not found['ascendingSinks']:continue
   call=re.fullmatch(r'%\w+ =l call \$(p111_rt_take|p125_rt_take[1-4])\(l %state, l (%\w+), l (%\w+)(?:, w \d+)?\)',lines[0])
   if not private_buffer(body,call[3]):continue
   result=lines[-1][4:];kind=0 if call[1]=='p111_rt_take' else int(call[1][-1])
   mask=sum(1<<i for i in found['sinkIndices'])
   replacement=f'{result} =l call $p169_rt_project(l %state, l {call[2]}, w {found["count"]}, w {found["selected"]}, w {mask}, w {kind})\nret {result}\n'
   start=fn.start(2)+block.start(2);end=fn.start(2)+block.end(2)
   edits.append(dict(start=start,end=end,before=text[start:end],after=replacement,shape=found))
 assert edits
 candidate=text
 for edit in reversed(edits):candidate=candidate[:edit['start']]+edit['after']+candidate[edit['end']:]
 cursor=0;inverse=[]
 for edit in edits:
  inverse.append(text[cursor:edit['start']]);inverse.append(edit['before']);cursor=edit['end']
 inverse.append(text[cursor:]);assert ''.join(inverse)==text
 # Replay every exact edit from the original; no unlisted generated change.
 parts=[];cursor=0
 for edit in edits:parts.extend((text[cursor:edit['start']],edit['after']));cursor=edit['end']
 parts.append(text[cursor:]);assert ''.join(parts)==candidate
 (out/'program.ssa').write_text(candidate)
 runtime=ROOT/'selfhost/src/runtime/qbe/runtime.c';helper=HERE/'projection-runtime.inc'
 assert pin(runtime)['sha256']=='aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333'
 (out/'runtime.c').write_bytes(runtime.read_bytes()+b'\n'+helper.read_bytes())
 for name in ('runtime.h','primitives.h'):(out/name).write_bytes((runtime.parent/name).read_bytes())
 (out/'edits.json').write_text(json.dumps(edits,indent=2)+'\n')
 assets=json.loads((ROOT/'selfhost/manifests/assets-native.json').read_text())['assets']
 def asset(key):
  value=dict(assets[key]);value['file']=str((ROOT/value['file']).resolve());verify(value);return value
 gcc=asset('linker');qbe=asset('qbe');assembler=asset('assembler')
 jobs=[]
 def job(label,command,seconds=30,expected=None):jobs.append(dict(label=label,command=command,seconds=seconds,expectedStdout=expected))
 for serial,fast in ((1,0),(1,1),(0,0),(0,1)):
  label=f'controls-{serial}-{fast}'
  flags=[gcc['file'],'-O2','-std=gnu11','-ffp-contract=off',f'-DP144_SINGLE_MUTATOR_RFC={serial}',f'-DP169_PROJECT_FAST={fast}']
  job(label+'-build',flags+['-I',str(out),str(HERE/'projection-controls.c'),'-pthread','-lm','-o','{out}/'+label])
  job(label,['{out}/'+label],5,'projection: 24 complete-state rows + static + packed PASS\n')
 for fast in (0,1):
  job(f'runtime-{fast}',[gcc['file'],'-O2','-std=gnu11','-ffp-contract=off','-DP144_SINGLE_MUTATOR_RFC=1',f'-DP169_PROJECT_FAST={fast}','-c',str(out/'runtime.c'),'-o',f'{{out}}/runtime-{fast}.o'])
 job('qbe',[qbe['file'],'-t','amd64_sysv','-o','{out}/program.s',str(out/'program.ssa')])
 job('assemble',[assembler['file'],'-mbranches-within-32B-boundaries','-o','{out}/program.o','{out}/program.s'])
 for fast in (0,1):job(f'link-{fast}',[gcc['file'],'-no-pie','{out}/program.o',f'{{out}}/runtime-{fast}.o','-pthread','-lm','-o',f'{{out}}/program-{fast}'])
 oracle=ROOT/'experiments/phase169/checker32.expected'
 variants=[('baseline',report['binary']['file']),('abi-only','{out}/program-0'),('fast','{out}/program-1')]
 for round in range(4):
  for label,binary in variants if round%2==0 else reversed(variants):job(f'run-{round}-{label}',[binary,'--threads','1','--gpu','off'],30,oracle.read_text())
 inputs=[pin(Path(__file__)),pin(HERE/'projection-census.py'),pin(HERE/'projection-controls.c'),pin(helper),pin(runtime),pin(report_path),pin(oracle),*([report[k] for k in ('sourceIR','binary','object','runtime')]),gcc,qbe,assembler]
 outputs=[pin(out/name) for name in ('program.ssa','runtime.c','runtime.h','primitives.h','edits.json')]
 plan=dict(kind='phase169-owned-projection-ceiling',targetsRun=False,productionChanged=False,inverseExact=True,semanticCompilerAdmission=False,inputs=inputs+outputs,branches=len(edits),jobs=jobs)
 (out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(json.dumps(dict(plan=str(out/'plan.json'),branches=len(edits),source=pin(out/'program.ssa'))))
if __name__=='__main__':main()
