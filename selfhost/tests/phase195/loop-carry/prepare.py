#!/usr/bin/env python3
"""Metadata-only exact-machine recurrence diagnostic. Never executes a target."""
import argparse, difflib, hashlib, json, re, sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[4]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin, verify
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args()
out=a.out.resolve();assert not out.exists();out.mkdir(parents=True)
symbol='p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_'
label='.L'+symbol+'_'
manifest_path=ROOT/'selfhost/build/phase195/branch-dev-build01/programs.manifest.json'
emission_path=ROOT/'selfhost/build/phase195/branch-dev-emit01/report.json'
manifest=json.loads(manifest_path.read_text());emission=json.loads(emission_path.read_text())
assert emission['complete'] and all(r['complete'] and r['verified'] for r in emission['rows'])
assets_path=ROOT/'selfhost/build/phase194/assets.json';assets=json.loads(assets_path.read_text())
inputs=[pin(Path(__file__)),pin(Path(__file__).with_name('run.py')),pin(Path(__file__).with_name('observer.c')),pin(manifest_path),pin(emission_path),pin(assets_path),pin(ROOT/'selfhost/tools/build/common.py')]
for k in ['assembler','linker','qbe-runtime']:
 item=dict(assets['assets'][k]);item['file']=str((ROOT/item['file']).resolve());verify(item);inputs.append(item)
plan={'kind':'phase195-exact-machine-loop-carry','complete':False,'targetsRun':False,'symbol':symbol,'inputs':inputs,'assets':str(assets_path),'rows':[],'scope':'Exact retained-machine causal diagnostic only. Not compiler-produced derivative code, native qualification, promotion, general optimizer or measured ceiling.'}
original_block=None
for case in ['editdist','local-pair']:
 row=next(r for r in emission['rows'] if r['id']==case);base=next(r for r in manifest['cases'] if r['id']==case)
 for item in [row['assembly'],row['product'],base['source'],base['expectedFile'],base['products']['branch']['artifact']]:verify(item);inputs.append(item)
 source=Path(row['assembly']['file']).read_text();start=source.index(symbol+':');end=source.index('.size '+symbol,start);body=source[start:end]
 if original_block is None:original_block=body
 else:assert body==original_block,'The two actual row bodies must be byte-identical'
 header=label+'b1:\n'+label+'loop:\n'
 load='  movq %rdi, %rsi\n  andq %r13, %rsi\n  movl 0(%rdx,%rsi,4), %r14d\n'
 store='  movl %eax, 0(%rdx,%rdi,4)\n'
 assert body.count(header)==body.count(load)==body.count(store)==1
 hot=body.split(label+'b2:\n')[1]
 assert hot.count('%r14')==2 and 'call ' not in hot
 assert len(re.findall(r'^  j\w+ ',hot,re.M))==1 and hot.rstrip().endswith('jmp '+label+'loop')
 assert hot.count('movl %eax, 0(%rdx,%rdi,4)')==1
 assert not re.search(r'^  \w+ [^\n]*, %(?:rdx|edx|r13|r13d)\s*$',hot,re.M)
 assert '  movl %edi, %edi\n  movq %rdi, %rsi\n  addl $1, %esi\n  movq %rsi, %rdi\n  andq %r13, %rdi\n' in hot
 assert '  movq -2616(%rbp), %r10\n  movq %r10, %rdi\n  jmp '+label+'loop' in hot
 entry=label+'b1:\n  cmpq $0, %rsi\n  je '+label+'loop\n  movq %rdi, %r10\n  andq %r13, %r10\n  movl 0(%rdx,%r10,4), %r14d\n'+label+'loop:\n'
 patched=body.replace(header,entry).replace(load,'').replace(store,store+'  movl %eax, %r14d\n')
 derivative=source[:start]+patched+source[end:]
 directory=out/case;directory.mkdir()
 patch=directory/'carry.patch';patch.write_text(''.join(difflib.unified_diff(source.splitlines(True),derivative.splitlines(True),fromfile=row['assembly']['file'],tofile=str(directory/'carry.s'))))
 variants={}
 for role,text in [('baseline',source),('carry',derivative)]:
  file=directory/(role+'.s');file.write_text(text);inputs.append(pin(file));variants[role]=pin(file)
  if case=='editdist':
   observer=file.with_name(role+'-observer.s')
   marker='.globl main\n.type main, @function\nmain:';assert text.count(marker)==1
   text=text.replace(marker,'.globl p195lc_original_main\n.type p195lc_original_main, @function\np195lc_original_main:')
   assert text.count('.size main, .-main')==1
   text=text.replace('.size main, .-main','.size p195lc_original_main, .-p195lc_original_main')
   observer.write_text(text);inputs.append(pin(observer));variants[role+'Observer']=pin(observer)
 inputs.append(pin(patch))
 plan['rows'].append({'id':case,'source':base['source'],'expectedFile':base['expectedFile'],'point':base['point'],'originalAssembly':row['assembly'],'originalObject':row['product'],'originalELF':base['products']['branch']['artifact'],'variants':variants,'patch':pin(patch)})
plan['complete']=True
(out/'plan.json').write_text(json.dumps(plan,indent=2)+'\n')
print(json.dumps({'plan':pin(out/'plan.json'),'targetsRun':False,'assemblyBytes':sum(x['bytes'] for r in plan['rows'] for x in r['variants'].values())}))
