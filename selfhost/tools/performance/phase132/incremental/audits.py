"""Data-only invalidation, ELF identity, and ordinary-output plans for objects.py."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import time

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('object_proto', HERE/'objects.py')
M = importlib.util.module_from_spec(spec); spec.loader.exec_module(M)
ROOT = M.ROOT


def declarations(plan):
    """Fast body census after the independently pinned partition parser passed."""
    M.require(plan['complete'] and plan['types'] == 0, 'Expected already parsed no-type emitted grammar')
    path=M.verify(plan['source']); found={}; current=None; count=0
    with path.open('rb') as stream:
        for line in stream:
            h=M.L.HEADER.match(line)
            if h:
                M.require(current is None, 'Unexpected nested declaration')
                start=line.index(b'$')+1; name=M.L.NAME.match(line,start).group().decode()
                current=dict(name=name,kind=h[2].decode(),sha=hashlib.sha256(),bytes=0)
            if current:
                current['sha'].update(line);current['bytes']+=len(line)
                if (current['kind']=='function' and line.strip()==b'}') or current['kind']=='data':
                    if current['kind']=='data':M.require(line.rstrip().endswith(b'}'),'Multiline data census unsupported')
                    M.require(current['name'] not in found,'Duplicate declaration')
                    found[current['name']]=dict(kind=current['kind'],bytes=current['bytes'],sha256=current['sha'].hexdigest())
                    current=None;count+=1
    M.require(current is None and count==plan['functions']+plan['data'],'Declaration census incomplete')
    return found


def census(args):
    start=time.monotonic();a=M.read(args.baseline);b=M.read(args.changed)
    left,right=declarations(a),declarations(b)
    changes=[dict(name=n,before=left[n],after=right[n])for n in sorted(left.keys()&right.keys())if left[n]!=right[n]]
    old={u['id']:u for u in a['units']};new={u['id']:u for u in b['units']}
    unit_changes=[dict(id=n,before=old[n]['key'],after=new[n]['key'],irChanged=old[n]['ir']['sha256']!=new[n]['ir']['sha256'],bindingsChanged=old[n]['bindingSha256']!=new[n]['bindingSha256'])for n in sorted(old.keys()&new.keys())if old[n]['key']!=new[n]['key']]
    out=M.fresh(args.out)
    result=dict(complete=True,targetsRun=False,inputs=[M.pin(__file__),M.pin(HERE/'objects.py'),M.pin(args.baseline),M.pin(args.changed),a['source'],b['source']],
        sourceBytes=dict(before=a['source']['bytes'],after=b['source']['bytes']),
        declarations=dict(before=len(left),after=len(right),changedFunctions=sum(x['before']['kind']=='function'for x in changes),changedData=sum(x['before']['kind']=='data'for x in changes),changes=changes,added=sorted(right.keys()-left.keys()),removed=sorted(left.keys()-right.keys())),
        units=dict(before=len(old),after=len(new),stable=sum(old[n]['key']==new[n]['key']for n in old.keys()&new.keys()),changed=unit_changes,added=sorted(new.keys()-old.keys()),removed=sorted(old.keys()-new.keys())),
        seconds=time.monotonic()-start,scope='Exact full emitted declaration bytes and complete unit cache keys; no source-only invalidation assumption.')
    M.save(out/'report.json',result);print(json.dumps(dict(complete=True,report=M.pin(out/'report.json'),functions=result['declarations']['changedFunctions'],data=result['declarations']['changedData'],stableUnits=result['units']['stable'])))


def elf_headers(path):
    data=path.read_bytes();M.require(data[:6]==b'\x7fELF\x02\x01','ELF64 little endian required')
    kind,machine,version,entry,phoff=struct.unpack_from('<HHIQQ',data,16)
    phsize,phcount=struct.unpack_from('<HH',data,54);M.require(phsize==56,'Unexpected ELF program header size')
    return dict(ident=list(data[:16]),type=kind,machine=machine,version=version,entry=entry,
                programHeaders=[list(struct.unpack_from('<IIQQQQQQ',data,phoff+i*phsize))for i in range(phcount)])


def compare(args):
    start=time.monotonic();a=M.read(args.cached);b=M.read(args.reference)
    M.require(a['complete']and b['complete']and a['plan']==b['plan']and a['context']==b['context'],'Current build inputs differ')
    M.verify(a['plan']);M.verify(b['plan'])
    M.require(not a['cold']and b['cold']and b['reusedUnits']==0 and a['cache']!=b['cache'],'Independent cold reference required')
    left,right=M.verify(a['binary']),M.verify(b['binary']);la,ra=M.allocated(left),M.allocated(right);lh,rh=elf_headers(left),elf_headers(right)
    M.require(la==ra and lh==rh,'ELF execution image differs')
    out=M.fresh(args.out);result=dict(complete=True,targetsRun=False,method=M.pin(__file__),cached=M.pin(args.cached),reference=M.pin(args.reference),plan=a['plan'],allocatedSectionsExact=True,headersExact=True,headers=lh,sections=la,positiveCacheHits=a['reusedUnits']>0,reusedUnits=a['reusedUnits'],rebuiltUnits=a['builtUnits'],seconds=time.monotonic()-start,scope='Exact cached versus independent cold partitioned current ELF image. Zero hits remains a valid negative result, never a reuse-success claim. Monolithic and ordinary-output gates remain separate.')
    M.save(out/'report.json',result);print(json.dumps(dict(complete=True,report=M.pin(out/'report.json'),positiveCacheHits=result['positiveCacheHits'])))


def gates(args):
    out=M.fresh(args.out);roles={k:M.read(getattr(args,k))for k in ['baseline','cached','reference']}
    for r in roles.values():M.require(r['complete'],'Build not closed');M.verify(r['binary']);M.verify(r['plan'])
    comp=M.read(args.comparison)
    M.require(comp['complete']and comp['allocatedSectionsExact']and comp['headersExact']and comp['cached']==M.pin(args.cached)and comp['reference']==M.pin(args.reference),'Machine comparison differs')
    edited=M.read(ROOT/'selfhost/build/phase132/source-edit01/report.json');before=M.verify(edited['before']).read_bytes();after=M.verify(edited['after']).read_bytes()
    M.require(edited['complete']and edited['changedDeclarations']==['p111q_main']and edited['changedLiteralOccurrences']==2,'Wrong source edit')
    M.require(before.count(b'%result')==2 and after==before.replace(b'%result',b'%answer'),'Wrong local spelling edit')
    old_fragment=json.loads(before.decode().splitlines()[1].strip()).encode();new_fragment=json.loads(after.decode().splitlines()[1].strip()).encode()
    parent_source=M.verify(edited['inputs'][1]).read_bytes();changed_source=M.verify(edited['source']).read_bytes()
    M.require(parent_source.count(before)==1 and changed_source==parent_source.replace(before,after,1),'Source edit not exactly localized')
    emission=M.read(ROOT/'selfhost/build/phase130/p132-edited-full01/report.json')
    M.require(emission['complete']and emission['source']==edited['source']and emission['image']==edited['producer'],'Edited emission lineage differs')
    M.require(M.read(roles['baseline']['plan']['file'])['source']==edited['baselineQbe'],'Baseline QBE differs')
    for name in ['cached','reference']:M.require(M.read(roles[name]['plan']['file'])['source']==emission['product'],'Changed QBE differs')
    corpus=M.read(ROOT/'selfhost/build/phase131/final-parent-timing01.json')
    manifest=M.read(ROOT/'selfhost/build/phase131/final-profile01/manifest.json')
    # This frozen multi-case manifest stores the exact same three requested sources and QBE oracles.
    qbes={w['name']:{k:w['variants'][0]['expected']['stdout'][k] for k in ['file','bytes','sha256']}for w in manifest['workloads']}
    commands=[];oracles=[];products={}
    request=ROOT/'selfhost/tools/performance/phase130/native-request.py';builder=ROOT/'selfhost/tools/performance/phase123/build-aligned.py'
    for case in corpus['cases']:
        name=case['name'];M.verify(case['source']);M.verify(case['stdout']);old=M.verify(qbes[name]).read_bytes()
        M.require(old.count(old_fragment)==1,'Frozen ordinary QBE lacks exact original main fragment')
        new=old.replace(old_fragment,new_fragment,1);gold=out/(name+'-edited.ssa');gold.write_bytes(new)
        oracles.append(dict(name=name,source=case['source'],ordinaryStdout=case['stdout'],before=qbes[name],after=M.pin(gold),onlyMainFragmentChanged=True))
        for role,build in roles.items():
            dest=ROOT/f'selfhost/build/phase130/p132-objects-{role}-{name}01';M.require(not dest.exists(),'Request output already exists')
            expected=qbes[name]['file']if role=='baseline'else str(gold)
            commands.append(dict(name=f'{role}-{name}-request',argv=['python3','-B',str(request),'--image',build['binary']['file'],'--source',case['source']['file'],'--carrier-receipt',str(ROOT/'selfhost/build/phase130/base-carrier01/receipt.json'),'--out',str(dest),'--expected-qbe',expected,'--seconds','30']))
            products[(role,name)]=dest/'program.ssa'
        # Exact complete-QBE equality transfers the cached role's generated program.
        # Baseline and cold edited reference each execute the independent old ordinary-output oracle.
        for role in ['baseline','reference']:
            dest=ROOT/f'selfhost/build/phase111/p132-objects-{role}-{name}01';M.require(not dest.exists(),'Ordinary output already exists')
            commands.append(dict(name=f'{role}-{name}-ordinary',argv=['python3','-B',str(builder),'--source',str(products[(role,name)]),'--runtime',roles[role]['context']['runtime']['file'],'--out',str(dest),'--expected',case['stdout']['file'],'--seconds','30']))
    result=dict(complete=True,preparedOnly=True,targetsRun=False,inputs=[M.pin(__file__),M.pin(args.baseline),M.pin(args.cached),M.pin(args.reference),M.pin(args.comparison),M.pin(request),M.pin(builder),M.pin(ROOT/'selfhost/build/phase132/source-edit01/report.json'),M.pin(ROOT/'selfhost/build/phase130/p132-edited-full01/report.json'),M.pin(ROOT/'selfhost/build/phase131/final-parent-timing01.json'),M.pin(ROOT/'selfhost/build/phase131/final-profile01/manifest.json')],oracles=oracles,commands=commands,scope='9 complete-QBE request gates and6 independent ordinary-output gates. Edited golden is derived solely by replacing the exact source-defined main fragment; no broad variable rewrite or target-derived oracle. No native qualification/promotion claim.')
    M.save(out/'plan.json',result);print(json.dumps(dict(complete=True,plan=M.pin(out/'plan.json'),commands=len(commands))))


def main():
    p=argparse.ArgumentParser(description=__doc__);s=p.add_subparsers(dest='mode',required=True)
    a=s.add_parser('census');a.add_argument('--baseline',type=Path,required=True);a.add_argument('--changed',type=Path,required=True)
    b=s.add_parser('compare');b.add_argument('--cached',type=Path,required=True);b.add_argument('--reference',type=Path,required=True)
    c=s.add_parser('gates')
    for n in ['baseline','cached','reference','comparison']:c.add_argument('--'+n,type=Path,required=True)
    for v in [a,b,c]:v.add_argument('--out',type=Path,required=True)
    args=p.parse_args();{'census':census,'compare':compare,'gates':gates}[args.mode](args)


if __name__=='__main__':main()
