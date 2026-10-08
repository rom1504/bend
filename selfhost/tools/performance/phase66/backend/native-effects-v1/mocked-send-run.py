#!/usr/bin/env python3
"""Root-only bounded execution of deterministic native syscall ABI controls."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,time
ROOT=Path(__file__).resolve().parents[6]
def pin(p):
 p=p.resolve(strict=True);h=hashlib.sha256()
 with p.open('rb') as f:
  for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
 return {'file':str(p),'sha256':h.hexdigest(),'bytes':p.stat().st_size}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--input',type=Path,required=True);ap.add_argument('--toolchain',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();a.out=a.out.resolve();assert a.out.is_relative_to(ROOT/'selfhost/build/phase66') and not a.out.exists();a.out.mkdir(parents=True)
 m=json.loads(a.input.read_text());tc=json.loads(a.toolchain.read_text());inputs=[pin(a.input),pin(a.toolchain),pin(Path(__file__)),tc['compiler'],*tc['compilerSharedLibraries'],*[v for v in m.values() if isinstance(v,dict) and set(v)=={'file','sha256','bytes'}]]
 for row in inputs:assert pin(Path(row['file']))==row
 for k,v in tc['environmentOverlay'].items():assert os.environ.get(k)==v
 def read(k):return Path(m[k]['file']).read_text()
 old=read('originalRuntime');original=read('originalGeneratedC');candidate=read('candidateRuntime');rebuilt=old
 for mark in ['// Tables\n// ======','// Spins\n// =====','// Segments\n// ========','// Requests\n// ========']:
  index=old.index(mark)+len(mark);anchor=old[index:index+180];assert original.count(mark)==1 and original.count(anchor)==1;start=original.index(mark)+len(mark);fragment=original[start:original.index(anchor,start)];rebuilt=rebuilt.replace(mark,mark+fragment);candidate=candidate.replace(mark,mark+fragment)
 assert rebuilt==original
 needle='int main(int argc, char** argv) {';assert candidate.count(needle)==1
 candidate=candidate.replace(needle,read('mockSyscall')+read('candidateProvider')+read('controlMain')+'\nint retained_bend_main(int argc, char** argv) {');assert candidate==read('derivedC')
 binary=a.out/'program';commands=[[os.environ['CC'],'-std=c11','-O3',m['derivedC']['file'],'-lpthread','-lm','-o',str(binary)],[str(binary)]];steps=[]
 for cmd in commands:
  start=time.monotonic()
  try:
   result=subprocess.run(cmd,capture_output=True,text=True,timeout=30);r={'command':cmd,'exitCode':result.returncode,'stdout':result.stdout,'stderr':result.stderr,'seconds':time.monotonic()-start}
  except subprocess.TimeoutExpired:r={'command':cmd,'exitCode':None,'timeout':True,'seconds':time.monotonic()-start}
  steps.append(r)
  if r['exitCode']!=0:break
 for row in inputs:assert pin(Path(row['file']))==row
 passed=len(steps)==2 and all(x['exitCode']==0 for x in steps) and steps[-1]['stdout']==m['expected'] and steps[-1]['stderr']==''
 report={'kind':'phase66-native-blocking-mocked-syscall-controls','pass':passed,'inputs':inputs,'environment':tc['environmentOverlay'],'steps':steps,'cases':m['cases'],'scope':'Exact staged provider+runtime with mockedsend under generated C scaffold. Complementary to actual-source and real socket gates; not a full native coverage claim.'};(a.out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({'pass':passed,'cases':len(m['cases']),'report':str(a.out/'report.json')}));return 0 if passed else 1
if __name__=='__main__':raise SystemExit(main())
