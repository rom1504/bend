"""Join exact selected source, generated function inventory and existing profile.

No compiler or generated target execution. Source type shapes are leads, not
substitutes for the checked NQ signature/admission algorithm.
"""
import collections
import hashlib
import importlib.util
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[5]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('blocks',ROOT/'selfhost/tools/performance/phase131/prepare.py')
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
source_file = ROOT/'selfhost/build/phase143/integrated-source03/compiler.bend'
qualification = ROOT/'implementation/phase143/qualification.json'
profile_file = ROOT/'selfhost/build/phase144/profile01/attribution/report.json'
q = json.loads(qualification.read_text())
profile = json.loads(profile_file.read_text())
assert q['complete'] and q['source'] == C.pin(source_file)
assert q['qbe'] == C.pin(q['qbe']['file'])
assert profile['pairing']['verified'] and profile['pairing']['correct']
blocks = C.blocks(source_file.read_text(),combine=True)
single = {}
for name, body in blocks.items():
    if body.startswith('type '):
        ctors = re.findall(r'^\s+([A-Za-z0-9_.]+)\{([^{}]*)\}',body,re.M)
        if len(ctors) == 1:
            single[name] = dict(constructor=ctors[0][0],fields=len(re.findall(r'(?:^|,)\s*\+?\w+\s*:',ctors[0][1])))
counts = collections.Counter()
for row in profile['dispatchContexts']:
    if row.get('loweredOwner'):
        counts[row['loweredOwner']] += row['samples']
explicit = {'p131i_insert','p111v_put','p111v_get','f_find','nc_ctor_owned','String.append','p111v_step','p111v_decl','p111v_body','index_join','index_node','index_leaf','p111v_assign','p111q_memory','p113k_get','p134e_registered','p134e_private','p134e_public','p134e_legacy','p134e_next','p112c_try','p112c_frame','p112c_freeze'}
rows = {}
for name,samples in counts.items():
    body = blocks.get(name,'')
    m = re.search(r'->\s*([A-Za-z0-9_.]+)\s*:',body)
    typ = m[1] if m else None
    if name in explicit or (samples >= 10 and typ in single):
        rows[name] = dict(name=name,samples=samples,fraction=samples/profile['coverage']['allSamples'],
            declaredResultType=typ,singleConstructorSourceShape=single.get(typ),
            sourceFirstLine=(source_file.read_text().count('\n',0,source_file.read_text().index('def '+name+'('))+1) if body else None,
            sourceDeclarationSha256=hashlib.sha256(body.encode()).hexdigest(),functions=[])
for name in explicit - set(rows):
    body = blocks[name]
    m = re.search(r'->\s*([A-Za-z0-9_.]+)\s*:',body)
    rows[name] = dict(name=name,samples=0,fraction=0,declaredResultType=m[1] if m else None,
        singleConstructorSourceShape=single.get(m[1]) if m else None,functions=[])


def decode(symbol):
    if '_FID_' not in symbol:
        return symbol
    p,c = symbol.split('_FID_',1)
    try:
        return p+':'+''.join(chr(int(n)) for n in c.split('_') if n)
    except ValueError:
        return symbol


current = None
with Path(q['qbe']['file']).open() as stream:
    for line in stream:
        if line.startswith(('function ','export function ')):
            match = re.search(r'\$(\w+)\(',line)
            symbol = match[1] if match else ''
            decoded = decode(symbol)
            owner = decoded.split(':',1)[-1].removeprefix('$direct.').removeprefix('$product.')
            current = dict(symbol=symbol,name=decoded,qbeLines=0,calls=collections.Counter()) if owner in rows else None
            if current:
                rows[owner]['functions'].append(current)
        if current:
            current['qbeLines'] += 1
            for callee in re.findall(r'call \$(\w+)\(',line):
                current['calls'][decode(callee)] += 1
        if line.startswith('}'):
            current = None
out = ROOT/'selfhost/build/phase144/product-hot-census01'
assert not out.exists()
out.mkdir()
for r in rows.values():
    r['directReady'] = any(f['name']=='p113d:$direct.'+r['name'] or f['name']=='p113d:'+r['name'] for f in r['functions'])
    r['productReady'] = any(f['name']=='p113d:$product.'+r['name'] for f in r['functions'])
    r['physicalLeaves'] = sorted([dict(leaf=x['leafSymbol'],samples=x['samples']) for x in profile['contextLeafMatrix']
        if x.get('dispatchLoweredOwner')==r['name']],key=lambda x:x['samples'],reverse=True)[:8]
report = dict(kind='phase144-profile-paired-selected-admission-census',complete=True,targetsRun=False,
    inputs=[C.pin(__file__),C.pin(C.__file__),C.pin(qualification),C.pin(source_file),q['qbe'],C.pin(profile_file)],
    allSamples=profile['coverage']['allSamples'],rows=sorted(rows.values(),key=lambda x:x['samples'],reverse=True),
    scope='Exact selected source and QBE inventory joined to exact-object existing diagnostic dispatch contexts. Ready denotes an actual p113d emitted function. Single-constructor source result is only a product-signature lead; it does not prove an NQ signature, failed candidate or cause. Owner contexts overlap physical leaves and are not inclusive stacks or removable savings.')
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps([dict(name=r['name'],samples=r['samples'],type=r['declaredResultType'],direct=r['directReady'],product=r['productReady']) for r in report['rows']]))
