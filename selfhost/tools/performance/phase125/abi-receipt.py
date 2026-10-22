"""Bind reviewed source factories, verifier gates and additive runtime ABIs."""
import argparse,hashlib,json,re,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4];HERE=Path(__file__).resolve().parent
def pin(p):
 p=Path(p).resolve();b=p.read_bytes();return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
p=argparse.ArgumentParser();p.add_argument('--source-manifest',type=Path,required=True);p.add_argument('--api-report',type=Path,required=True);p.add_argument('--runtime-report',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--verified-sized',action='store_true');a=p.parse_args();assert not a.out.exists()
s,c,r=read(a.source_manifest),read(a.api_report),read(a.runtime_report)
assert s['complete'] and c['complete'] and c['checked'] and s['source'] in c['inputs'] and r['complete']
inputs=[pin(__file__),pin(a.source_manifest),pin(a.api_report),pin(a.runtime_report),s['source'],c['api'],r['source'],r['object'],*s['inputs'],*c['inputs'],*r['inputs']]
for x in inputs:assert pin(x['file'])==x
parent=ROOT/'selfhost/build/phase118/runtime-extend01/runtime.c'
assert Path(r['source']['file']).read_text().startswith(parent.read_text()+'\n')
modules=[HERE/'producer/model-v3.bend'];runtime_modules=[HERE/'producer/runtime-concat-typed.c']
audits=[HERE/'producer/audit.md',HERE/'producer/rfc1-review.md',HERE/'producer/value-abi-audit.md',HERE/'producer/typed-helper-audit.md']
imports=[dict(symbol='p125_rt_concat_typed',arguments=['Ptr state','U64 owningLeft','U64 owningRight','U32 emptyCID','U32 linkCID'],result='U64 owningListOrZero',authority=['p125p_admitted','p125p_equations','p125p_types','p125p_owner','p125p_wrap','p125p_import'],contract='Source-certified exact append equations and closed zero/two-field ADT; failure leaves both inputs untouched; success transfers both; every spine node dynamically unique and nonstatic before the single tail store. Retain wrappers and original publication policy.')]
if a.verified_sized:
 modules.append(HERE/'verified-runtime/model.bend');runtime_modules.append(HERE/'verified-runtime/runtime.c');audits.append(HERE/'verified-runtime/audit.md')
 for n in range(1,5):
  imports.extend([dict(symbol=f'p125_rt_ctor{n}',arguments=['Ptr state','U32 constructorCID','Ptr fields'],result='U64 owningTerm',authority=['p111v_counted_call','p111v_buffer','p111v_decl','p118e_verified','p118xs_original'],contract=f'After unchanged original complete-program verification: literal count{n}, real CID with matching arity, allocated buffer. Preserve every allocation/field/publication operation.'),dict(symbol=f'p125_rt_take{n}',arguments=['Ptr state','U64 owningTerm','Ptr outputs'],result=f'U64 constant{n}',authority=['p111v_counted_call','p111v_buffer','p111v_decl','p118e_verified','p118xs_original'],contract=f'After unchanged original verification: literal count{n} and allocated output buffer. Retain dynamic CID bounds/arity/tag and all original ownership/extraction/reclamation behavior.')])
for module in modules:assert pin(module) in s['inputs']
for module in runtime_modules:assert pin(module) in r['inputs']
inputs += [pin(parent),*[pin(x) for x in audits]]
text=Path(s['source']['file']).read_text();pattern=re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',re.M);hits=list(pattern.finditer(text));blocks={h[1]:text[h.start():hits[i+1].start() if i+1<len(hits) else len(text)] for i,h in enumerate(hits)}
declarations=[]
for name in sorted({name for row in imports for name in row['authority']}):
 raw=blocks[name].encode();declarations.append(dict(name=name,bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest()))
# Presence supplements the source/build contract; it does not infer ABI legality.
nm=Path('/usr/bin/nm').resolve();symbols=subprocess.check_output([nm,'--defined-only',r['object']['file']],text=True)
for row in imports:assert any(line.split()[-1]==row['symbol'] for line in symbols.splitlines() if line.split())
inputs.append(pin(nm))
out=dict(kind='phase125-native-runtime-abi-admission',complete=True,source=s['source'],runtime=r['object'],runtimeSource=r['source'],imports=imports,sourceDeclarations=declarations,inputs=inputs,scope='Explicit reviewed factory/projection contracts and original gates; no promotion, no general permission for arbitrary caller IR, no inference from successful linking.')
a.out.write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(dict(complete=True,imports=len(imports),receipt=pin(a.out))))
