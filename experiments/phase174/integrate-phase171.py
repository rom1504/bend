#!/usr/bin/env python3
"""One-shot exact Phase171 source integration; metadata transport, no compiler runs."""
import base64
import copy
import hashlib
import json
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import source as assembly

PARENT = dict(bytes=3150535,sha256='434edd1d56128f9480800573abf8a0ae21d910a547837af089f25cd1d0e89b71')
MEASURED = dict(bytes=3161409,sha256='74cd7de3e5076490e20ba0218d4c9254853be72562946b9ef66fed6c10c7a53a')


def need(value,message):
    if not value: raise ValueError(message)


def identity(data):
    return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def pin(path):
    path=Path(path).resolve(strict=True)
    return dict(file=str(path),**identity(path.read_bytes()))


def signature(data):
    _,rows=assembly.blocks(data)
    need(len(rows)==1,'One declaration required')
    row=rows[0]
    lines=data[row['headerOffset']:].splitlines()
    result=[]
    for line in lines:
        result.append(line)
        if line.rstrip().endswith(b':'):
            return re.sub(rb'\s+',b' ',b'\n'.join(result)).strip()
    raise ValueError('Signature missing')


def new_owner(name):
    if name=='p171ff_direct_match':return 'src/back/qbe/direct-lower.bend'
    if name=='p171ff_product_match':return 'src/back/qbe/flat-products.bend'
    if name.startswith('p171s_'):return 'src/check/publication-reuse.bend'
    if name=='P171SCPlan' or name.startswith('p171sc_'):return 'src/back/qbe/borrowed-regions.bend'
    raise ValueError('Unexpected new declaration: '+name)


def main():
    recipe=ROOT/'selfhost/src/compiler.json'
    reference_path=ROOT/'selfhost/build/phase174/reference-source01/receipt.json'
    frozen_path=ROOT/'selfhost/build/phase171/native-source01/compiler.bend'
    frozen_report_path=frozen_path.with_name('report.json')
    inverse_path=frozen_path.with_name('inverse-originals.json')
    output=ROOT/'implementation/phase174/source-integration.json'
    need(not output.exists(),'Refuse overwriting integration receipt')
    reference=json.loads(reference_path.read_text())
    frozen_report=json.loads(frozen_report_path.read_text())
    config=json.loads(recipe.read_text())
    need(reference['complete'] and reference['kind']=='phase174-frozen-reference','Frozen baseline required')
    need({k:reference['source'][k] for k in PARENT}==PARENT,'Baseline pin differs')
    recipe_old=pin(recipe)
    baseline_recipe=next(row for row in reference['pins'] if row['file']=='selfhost/src/compiler.json')
    need(all(recipe_old[k]==baseline_recipe[k] for k in PARENT),'Recipe changed after root freeze')
    original=assembly.maintained_assemble(recipe,ROOT/'selfhost','qbe')
    frozen=frozen_path.read_bytes()
    need(identity(original)==PARENT and identity(frozen)==MEASURED,'Exact source identities required')
    need(frozen_report['complete'] and frozen_report['inverseExact'] and frozen_report['signaturesPreserved'] and frozen_report['protectedUnchanged'],'Measured source assertions missing')
    need(all(pin(frozen_path)[k]==frozen_report['source'][k] for k in PARENT),'Frozen report/source differs')
    need(pin(inverse_path)==frozen_report['inverse'],'Frozen inverse pin differs')
    need(len(config['protectedDeclarations'])==112,'Protected inventory differs')
    preamble,original_rows=assembly.blocks(original)
    original_by={(r['kind'],r['name']):r['data'] for r in original_rows}
    owners={}; module_bytes={}; original_modules={}
    for index,rel in enumerate(config['modules']):
        data=(ROOT/'selfhost'/rel).read_bytes();original_modules[rel]=data
        if rel==config['preamble']:continue
        prefix,rows=assembly.blocks(data)
        need(not prefix,'Unexpected module prefix')
        for row in rows:
            key=(row['kind'],row['name'])
            need(key not in owners and original_by[key]==row['data'],'Original module/source block mismatch')
            owners[key]=rel
    operations=frozen_report['operations']
    need(len(operations)==8442,'Unexpected operation count')
    chunks={}; final_order=[]; seen=set(); changed=[]; unchanged=[]
    counts={name:0 for name in ['keep','replace','append','insert-law']}
    positions={name:i for i,name in enumerate(config['modules'])}
    for op in operations:
        action=op['operation'];need(action in counts,'Unexpected separator or mutation')
        key=(op['kind'],op['name']);need(key not in seen,'Duplicate final key');seen.add(key)
        data=frozen[op['begin']:op['end']]
        need(identity(data)=={k:op[k] for k in PARENT},'Frozen operation span differs')
        if action in ['keep','replace']:
            need(key in original_by,'Missing canonical declaration')
            need(identity(original_by[key])==op['originalIdentity'],'Original span mismatch')
            owner=owners[key]
            if action=='keep':need(data==original_by[key],'Unexpected retained-body change')
            else:
                need(op['name'] not in config['protectedDeclarations'] and op['name']!='main','Protected/main replacement')
                need(signature(data)==signature(original_by[key]),'Original signature differs')
        else:
            need(key not in original_by,'Addition shadows original key')
            owner=new_owner(op['name'])
        chunks.setdefault(owner,[]).append(data)
        final_order.append([positions[owner],*key]);counts[action]+=1
        row=dict(kind=key[0],name=key[1],owner=owner,operation=action,
                 original=identity(original_by[key]) if key in original_by else None,
                 final=identity(data),measuredSpan=dict(begin=op['begin'],end=op['end'],**identity(data)))
        (unchanged if action=='keep' else changed).append(row)
    need(counts==dict(keep=8398,replace=16,append=22,**{'insert-law':6}),'Measured mutation scope differs')
    touched=sorted(set(row['owner'] for row in changed))
    need(len(touched)==6,'Unexpected maintained module footprint')
    # Preserve all untouched files, including lexer whose physical order differs
    # from the explicit source recipe. Touched owners retain exact frozen chunks.
    proposed=dict(original_modules)
    for owner in touched:proposed[owner]=b''.join(chunks[owner])
    entries={}
    for index,rel in enumerate(config['modules']):
        if rel==config['preamble']:continue
        prefix,rows=assembly.blocks(proposed[rel]);need(not prefix,'New unassigned module prefix')
        for row in rows:entries[(index,row['kind'],row['name'])]=row['data']
    assembled=original_modules[config['preamble']]+b''.join(entries[tuple(key)] for key in final_order)
    need(assembled==frozen,'Planned maintained assembly is not byte-identical to measured source')
    for op,key in zip(operations,final_order):
        need(entries[tuple(key)]==frozen[op['begin']:op['end']],'Declaration repartition changed a block')
    updated=copy.deepcopy(config)
    updated['order']=final_order
    old_keys={tuple(row) for row in config['order']}
    updated['inventoryChange']=dict(added=[row for row in final_order if tuple(row) not in old_keys],removed=[],
        scope='Exact Phase171 measured integration:16 replacements,28 added declarations; native source byte-identical to74cd7de3. Independent source/interface/native qualification remains required.')
    need(len(updated['inventoryChange']['added'])==28,'Addition inventory differs')
    need(updated['protectedDeclarations']==config['protectedDeclarations'],'Protection map changed')
    inverse=json.loads(inverse_path.read_text())['originalBlocks']
    recovered=[preamble]
    for op in operations:
        if op['operation']=='keep':recovered.append(assembled[op['begin']:op['end']])
        elif op['operation']=='replace':recovered.append(base64.b64decode(inverse[op['name']],validate=True))
    need(b''.join(recovered)==original,'Actual planned assembly inverse differs')
    unchanged_hash=hashlib.sha256()
    for row in unchanged:
        unchanged_hash.update((json.dumps([row['kind'],row['name'],row['owner'],row['final']],separators=(',',':'))+'\n').encode())
    inputs=[pin(reference_path),pin(frozen_path),pin(frozen_report_path),pin(inverse_path),pin(assembly.__file__),recipe_old]
    prior_pins={rel:pin(ROOT/'selfhost'/rel) for rel in touched}
    # All checks above precede the authorized six module edits and recipe update.
    for rel in touched:(ROOT/'selfhost'/rel).write_bytes(proposed[rel])
    recipe.write_text(json.dumps(updated,indent=2)+'\n')
    actual=assembly.maintained_assemble(recipe,ROOT/'selfhost','qbe')
    need(actual==frozen,'Post-write measured identity differs')
    profiles={name:identity(assembly.maintained_assemble(recipe,ROOT/'selfhost',name)) for name in updated['profiles']}
    report=dict(kind='phase174-exact-phase171-integration',version=1,complete=True,targetsRun=False,
        method=pin(__file__),inputs=inputs,referenceHead=reference['head'],
        parent=PARENT,maintainedSource=identity(actual),measuredSource=pin(frozen_path),
        declarationCounts=dict(original=8414,final=8442,unchanged=8398,replacements=16,additions=28,removed=0),
        byteIdenticalToMeasured=True,inverseRecoversParent=True,originalSignaturesPreserved=True,
        protected=dict(count=112,mapUnchanged=True,normalizedChecksPassed=True),
        mainUnchanged=next(row for row in unchanged if row['name']=='main' and row['kind']=='def'),
        unchangedDeclarations=dict(count=8398,allBlockBytesCompared=True,orderedRecordSha256=unchanged_hash.hexdigest(),
            recordFormat='Compact JSON [kind,name,owner,{bytes,sha256}] plus LF in measured operation order.'),
        changes=changed,helperLawPositions=frozen_report['helperLawPositions'],profiles=profiles,
        files=[dict(path=rel,before=prior_pins[rel],after=pin(ROOT/'selfhost'/rel)) for rel in touched],
        recipe=dict(before=recipe_old,after=pin(recipe)),
        productionDependencies=dict(moduleListUnchanged=True,preambleUnchanged=True,newHistoricalImports=False),
        scope='Only four measured Phase171 overlays. No Phase172/173 candidates, target execution, release assets, installed selection or qualification changes.')
    output.parent.mkdir(parents=True,exist_ok=True)
    output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(report=str(output),source=identity(actual),modules=len(touched),replaced=16,added=28,protected=112,targetsRun=False)))


if __name__=='__main__':main()
