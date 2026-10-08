#!/usr/bin/env python3
"""Freeze a small native comparison; pure hashing, never invokes a compiler."""
import argparse, hashlib, json, subprocess, os, shutil
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
def identity(p):
 p=Path(p).resolve(); b=p.read_bytes(); return dict(path=str(p),sha256=hashlib.sha256(b).hexdigest(),bytes=len(b))
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--api',type=Path,default=ROOT/'selfhost/dist/typed-api.mjs');a=p.parse_args()
up=ROOT/'selfhost/.bootstrap/upstream-phase66'; commit='059266225b77c8ca256ac6b25ee5c21449bab151'
assert subprocess.check_output(['git','-C',str(up),'rev-parse','HEAD'],text=True).strip()==commit
files=[*HERE.glob('*.py'),*HERE.glob('*.mjs'),ROOT/'selfhost/tools/performance/programs/support.py']
files += [ROOT/'selfhost/tools/performance/phase46'/n for n in ['cases.json','oracle.py','execute.py','make-batch.py']]
files += [ROOT/'selfhost/tools/performance/phase37'/n for n in ['fixtures-new/oracles.py','algorithm-oracles.py','coverage-catalog.py']]
for c in json.loads((ROOT/'selfhost/tools/performance/phase46/cases.json').read_text()):
 assert identity(ROOT/c['source'])['sha256']==c['sha256']; files += [ROOT/c['source'], ROOT/'selfhost/tools/performance/phase46'/(c['name']+'-batch.bend')]
files += [a.api,ROOT/'selfhost/src/runtime.mjs',ROOT/'selfhost/dist/base.bend',ROOT/'selfhost/src/compiler.json',ROOT/'selfhost/src/runtime/js/direct.mjs']
files += list((ROOT/'selfhost/src/runtime/native').rglob('*.c'))
files += [ROOT/'selfhost/tools'/n for n in ['typed-driver.mjs','assemble.mjs','native-build.mjs','node-resource-args.mjs','compiler-abi.mjs','base-cache-graph.mjs']]
files += list((ROOT/'selfhost/tools/development').glob('*.mjs'))+list((ROOT/'selfhost/tools/conformance').glob('*.mjs'))
files += [up/'bend2'/n for n in ['bend.ts','comp.ts','base.bend']]+list((up/'bend2/effs').glob('*.c'))
node=Path('/home/ai/.nvm/versions/node/v24.18.0/bin/node'); clang=Path('/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang');headers=clang.parent.parent/'include/clang'
files += [node,clang,*[f for f in headers.rglob('*') if f.is_file()]]
files += [clang.parent.parent/'lib'/n for n in ['libclang-cpp.so.22.1','libLLVM.so.22.1','libc++.so.1','libc++abi.so.1','libunwind.so.1']]
files += [clang.parent/'ld.lld',Path(shutil.which('ld'))]
compiler_environment={k:os.environ.get(k) for k in ['CC','CXX','CPATH','C_INCLUDE_PATH','CPLUS_INCLUDE_PATH','LIBRARY_PATH','LD_LIBRARY_PATH','SDKROOT']}
installed=a.api.resolve()==(ROOT/'selfhost/dist/typed-api.mjs').resolve()
if installed:files += [ROOT/'selfhost/dist/release.json']
recipe=dict(kind='phase67-native-method-v2',compilerEnvironment=compiler_environment,upstream=str(up),upstreamCommit=commit,api=str(a.api.resolve()),verifyInstalled=installed,node=str(node),clang=str(clang),clangArgs=['-isystem',str(headers),'-std=c11','-O3'],linkArgs=['-lpthread','-lm'],cpu=3,nodeArgs=['--max-old-space-size=1024','--stack-size=4096'],treeRssMiB=2048,availableMiB=4096,inputs=[identity(f) for f in sorted(set(files))],protocol={'emission':'Fresh process, native checked request. Selfhost prepared Base before request; TS loads/checks Base in request. Report preparation/imports separately. These are native acquisition clocks, not Phase66 JS compilation parity.','runtime':'Same wrapper, 16-input cycle, fixed warmups and measured repetitions per role. Four stdout lines: base, warm digest, measured digest, integer milliseconds. Execution excludes imports and C build; checksum formatting/printing included.','sampling':'Calibration separate; final rotated roles; no timings from failed correctness or zero milliseconds.'})
a.out.parent.mkdir(parents=True,exist_ok=True)
with a.out.open('x') as f:json.dump(recipe,f,indent=2);f.write('\n')
print(json.dumps(identity(a.out)))
