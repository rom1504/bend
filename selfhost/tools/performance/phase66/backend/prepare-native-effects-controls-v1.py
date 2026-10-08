#!/usr/bin/env python3
"""Freeze a native-only runtime overlay on checked04 for actual-source gates."""
from pathlib import Path
import argparse,json,hashlib,copy,shutil
ROOT=Path(__file__).resolve().parents[5]
HERE=Path(__file__).parent
def pin(p):
 p=p.resolve(strict=True);return {'file':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size}
def checked(row):
 assert pin(Path(row['file']))==row,row['file']
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();a.out=a.out.resolve();assert a.out.is_relative_to(ROOT/'selfhost/build/phase66') and not a.out.exists()
 parent=ROOT/'selfhost/build/phase66/backend-native-controls04-recipe/recipe.json';m=json.loads(parent.read_text());toolchain=ROOT/'selfhost/build/phase66/backend-native-controls04-clang01-recipe/recipe.json';tc=json.loads(toolchain.read_text());candidate=HERE/'native-effects-v1/candidate.json';c=json.loads(candidate.read_text());fixtures=HERE/'native-effects-v1/fixtures.json';f=json.loads(fixtures.read_text());up=ROOT/'selfhost/.bootstrap/upstream-phase66'
 names=['chan_close_send','chan_pipe','chan_proof_send','chan_rendezvous','channel_fork_join','nat_host_chan','tcp_bytes','tcp_loopback','tcp_short_recv','tcp_spawn','udp_bad_address','udp_loopback','udp_recv_park','udp_send_recv','udp_truncate']
 sources=[{'id':'io/'+name+'.bend','file':pin(up/'tests/io'/(name+'.bend'))} for name in names]
 for row in f['cases']:
  checked(row['derived']);sources.append({'id':'phase66/'+Path(row['derived']['file']).name,'file':row['derived'],'derived':True})
 a.out.mkdir(parents=True);commands=[];images=[]
 for command in m['commands']:
  role=command['name'];original=next(x for x in m['images'] if x['role']==role);project=Path(original['compilerImage']['file']).parents[1];changed=[];projectInputs=[]
  for row in original['copies']:checked(row['copy'])
  checked(original['compilerImage']);checked(original['adapterAfter'])
  if role=='bend-direct':
   derived=a.out/role/'project';shutil.copytree(project,derived)
   for row in c['files']:
    checked(row['after']);dst=derived/Path(row['relative']).relative_to('selfhost');before=pin(dst)
    assert before['sha256']==row['liveSource']['sha256'];dst.write_bytes(Path(row['after']['file']).read_bytes());changed.append({'relative':str(dst.relative_to(derived)),'before':before,'after':pin(dst)})
   projectInputs=[pin(x) for x in sorted(derived.rglob('*')) if x.is_file()];project=derived
  dest=a.out/role/'observations';dest.mkdir(parents=True);selection=dest/'selection.json';selected=[{'id':x['id'],'lanes':['native'],**({'file':x['file']['file']} if x.get('derived') else {})} for x in sources];selection.write_text(json.dumps({'cases':selected},indent=2)+'\n')
  cmd=copy.deepcopy(command['command']);oldProject=str(Path(original['compilerImage']['file']).parents[1]);cmd=[x.replace(oldProject,str(project)) for x in cmd];at=cmd.index('env');cmd[at+1:at+1]=[k+'='+v for k,v in tc['environmentOverlay'].items()];cmd[cmd.index('--output')+1]=str(dest/'report.json');cmd[cmd.index('--selection')+1]=str(selection);i=next(i for i,x in enumerate(cmd) if x.endswith('/supervisor'));cmd[i]=str(dest/'supervisor')
  commands.append({'name':role,'command':cmd,'expectedExitCodes':[0,1],'expectedObservations':len(sources),'selection':pin(selection),'report':str(dest/'report.json')});images.append({'role':role,'originalProject':oldProject,'project':str(project),'compilerImage':pin(project/'dist/conformance-api.mjs'),'overlays':changed,'frozenProjectInputs':projectInputs})
 recipe={'kind':'phase66-native-effects-source-recipe','targetExecuted':False,'producer':pin(Path(__file__)),'parent':pin(parent),'toolchainRecipe':pin(toolchain),'candidate':pin(candidate),'fixtures':pin(fixtures),'images':images,'sourceInputs':sources,'commands':commands,'scope':'Actual source emission using exact checked04 API and frozen project. Bend native runtime/effects overlay only, explicitly not a newly checked image. TS reference unchanged. Final selected snapshot and broader gates remain separate.'};p=a.out/'recipe.json';p.write_text(json.dumps(recipe,indent=2)+'\n');print(json.dumps({'recipe':pin(p),'sources':len(sources),'targetsExecuted':False}))
if __name__=='__main__':main()
