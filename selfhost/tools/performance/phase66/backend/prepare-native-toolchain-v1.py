#!/usr/bin/env python3
"""Bind prior qualified Clang to fresh Phase66 native controls; no targets."""
from pathlib import Path
import argparse,json,hashlib,copy
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=p.resolve(strict=True);h=hashlib.sha256()
 with p.open('rb') as f:
  for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
 return {'file':str(p),'sha256':h.hexdigest(),'bytes':p.stat().st_size}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--parent',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();a.out=a.out.resolve();assert a.out.is_relative_to(ROOT/'selfhost/build/phase66') and not a.out.exists()
 parent=json.loads(a.parent.read_text());assert parent['kind']=='phase66-backend-source-control-recipe' and parent['lanes']==['native']
 prior=ROOT/'selfhost/build/phase65/final-state10/release/legacy42/checks/report.json';r=json.loads(prior.read_text());assert r['pass']
 variables={k:r['environment'][k] for k in ['CC','CPATH','LIBRARY_PATH','LD_LIBRARY_PATH']}
 compiler=pin(Path(variables['CC']));assert compiler==r['toolchain']
 for key in ['CPATH','LIBRARY_PATH','LD_LIBRARY_PATH']:assert Path(variables[key]).is_dir()
 libs=[]
 for name in ['libLLVM-16.so.1','libclang-cpp.so.16']:
  libs.append(pin(Path(variables['LD_LIBRARY_PATH'])/name))
 a.out.mkdir(parents=True);commands=[]
 for old in parent['commands']:
  c=copy.deepcopy(old);dest=a.out/c['name']/'observations';dest.mkdir(parents=True);cmd=c['command'];at=cmd.index('env');end=next(i for i in range(at+1,len(cmd)) if '=' not in cmd[i]);existing=cmd[at+1:end]
  assert not any(x.split('=',1)[0] in variables for x in existing)
  cmd[at+1:at+1]=[k+'='+v for k,v in variables.items()]
  cmd[cmd.index('--output')+1]=str(dest/'report.json');idx=next(i for i,x in enumerate(cmd) if x.endswith('/supervisor'));cmd[idx]=str(dest/'supervisor')
  selection=Path(c['selection']['file']);assert pin(selection)==c['selection'];local=dest/'selection.json';local.write_bytes(selection.read_bytes());cmd[cmd.index('--selection')+1]=str(local)
  c.update({'selection':pin(local),'report':str(dest/'report.json'),'environmentOverlay':variables,'parentReport':old['report']});commands.append(c)
 recipe={'kind':'phase66-native-toolchain-successor','version':1,'targetExecuted':False,'producer':pin(Path(__file__)),'parent':pin(a.parent),'attempt':parent['attempt'],'priorQualifiedReceipt':pin(prior),'compiler':compiler,'compilerSharedLibraries':libs,'environmentOverlay':variables,'commands':commands,'scope':'Same explicit04B1/source selectors/new upstream reference and frozenprojects. Only C toolchain environment and fresh output destinations differ. Earlier unsupported observations are retained. CC is the actual native-build resolver variable, not BEND_CC. Current compiler execution/versionprobe remains a root target.'}
 p=a.out/'recipe.json';p.write_text(json.dumps(recipe,indent=2)+'\n');print(json.dumps({'recipe':pin(p),'commands':len(commands),'targetExecuted':False}))
if __name__=='__main__':main()
