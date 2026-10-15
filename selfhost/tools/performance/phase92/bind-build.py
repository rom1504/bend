#!/usr/bin/env python3
"""Bind an actual same-source upstream-C native B1 build, without executing it."""
import hashlib,json,pathlib,sys
ROOT=pathlib.Path(__file__).resolve().parents[4]
def pin(file):
 p=pathlib.Path(file).resolve();b=p.read_bytes();return dict(file=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
def verify(r):
 p=pin(r['file']);assert p==r,(p,r);return p
def read(p):return json.loads(pathlib.Path(p).read_text())
checked=ROOT/'selfhost/build/phase92/upstream-checked01/report.json'
guard=ROOT/'selfhost/build/phase92/build-guard/process.json'
image=ROOT/'selfhost/build/phase92/upstream-b1/compiler'
out=ROOT/'selfhost/build/phase92/upstream-b1/build.json'
a,g=read(checked),read(guard)
assert a['complete'] and a['inputsUnchanged'] and a['holes']==0
assert [p['name'] for p in a['phases']]==['load','check','emit-c']
assert a['upstream']=='059266225b77c8ca256ac6b25ee5c21449bab151'
assert a['source']['sha256']=='d04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'
assert g['complete'] and g['returncode']==0 and not g.get('stoppedFor')
for p in a['inputs']:verify(p)
source,c=verify(a['source']),verify(a['c']);binary=pin(image)
clang=pin('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang')
command=g['command'];assert command[-9:]==[clang['file'],'-isystem','/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang','-O2','-ftime-report',c['file'],'-o',binary['file'],'-lm','-pthread'][-9:]
assert clang['file'] in command and '-O2' in command and command[command.index('taskset')+1:command.index('taskset')+3]==['-c','2,3']
old=read(ROOT/'selfhost/build/phase90/compiler-own-native07.native-build.json')
assert old['source']['sha256']==source['sha256'] and old['source']['bytes']==source['bytes']
expected=list(old['command']);expected[expected.index(old['c']['file'])]=c['file'];expected[expected.index(old['binary']['file'])]=binary['file']
assert command==expected,'Only C input and executable destination may differ from native07 build flags'
result=dict(kind='phase92-upstream-native-b1-build',complete=True,source=source,c=c,image=binary,clang=clang,checked=pin(checked),guard=pin(guard),buildInputs=pin(guard.parent/'inputs.json'),command=command,method=pin(__file__),upstream=a['upstream'],sameSourceAsNative07=True,sameBuildFlagsAsNative07=True,cPatched=False,emitter='pinned upstream TypeScript C backend',argvSentinel=False,scope='Native B1 from exact D04 source. Executable runtime/providers use upstream ABI; compilation requests share own-emission runtime/providers with native07. No native execution qualification is implied by this build receipt.')
with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(dict(complete=True,source=source,image=binary,c=c)))
