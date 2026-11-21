"""Authenticate two live-runtime relinks and compare the mapped ELF sections."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import sys

sys.dont_write_bytecode=True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
METHOD=HERE.parent/'qualification/compare-source-products.py'
spec=importlib.util.spec_from_file_location('ordinary_comparison',METHOD)
M=importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
P=M.P
B=P.bench
C=P.common
need=C.require
ROLES=('c','phase197','candidate','live')

def mapped_payload(path):
    raw=Path(path).read_bytes()
    need(raw[:6]==b'\x7fELF\x02\x01','ELF64 little-endian binary required')
    phoff,shoff=struct.unpack_from('<QQ',raw,32)
    phsize,nph,shsize,nsh,strings=struct.unpack_from('<HHHHH',raw,54)
    need(phsize==56 and shsize==64 and 0<strings<nsh,'Program/section table bounds')
    sections=[struct.unpack_from('<IIQQQQIIQQ',raw,shoff+i*shsize) for i in range(nsh)]
    s=sections[strings];names=raw[s[4]:s[4]+s[5]]
    skip=[dict(field='e_shoff',start=40,end=48)]
    for section in sections:
        if section[1]!=7 or names[section[0]:].split(b'\0',1)[0]!=b'.note.gnu.build-id':continue
        pos=section[4];stop=pos+section[5]
        while pos<stop:
            need(pos+12<=stop,'Truncated ELF note')
            n,sz,kind=struct.unpack_from('<III',raw,pos)
            owner=pos+12;descriptor=owner+((n+3)&~3);end=descriptor+sz
            need(end<=stop,'Truncated ELF note descriptor')
            if kind==3 and raw[owner:owner+n]==b'GNU\0':skip.append(dict(field='GNU build-ID descriptor',start=descriptor,end=end))
            pos=descriptor+((sz+3)&~3)
    normalized=bytearray(raw)
    for r in skip:normalized[r['start']:r['end']]=bytes(r['end']-r['start'])
    table=raw[phoff:phoff+nph*phsize]
    need(len(table)==nph*phsize,'Truncated ELF program header table')
    segments=[]
    for off in range(0,len(table),phsize):
        kind,flags,where,vaddr,paddr,size,memsize,align=struct.unpack_from('<IIQQQQQQ',table,off)
        if kind!=1:continue
        need(where+size<=len(raw),'Truncated PT_LOAD')
        segments.append(dict(where=where,bytes=size,raw=hashlib.sha256(raw[where:where+size]).hexdigest(),
                             normalized=hashlib.sha256(normalized[where:where+size]).hexdigest()))
    need(bool(segments),'ELF contains no loadable segments')
    masked=[raw[r['start']:r['end']].hex() for r in skip]
    return dict(headers=hashlib.sha256(table).hexdigest(),exceptions=skip,maskedValues=masked,segments=segments)

def compare_mapping(a,b):
    left=mapped_payload(a);right=mapped_payload(b)
    same_headers=left['headers']==right['headers']
    same_ranges=left['exceptions']==right['exceptions']
    def same(key):
        return [(r['where'],r['bytes'],r[key]) for r in left['segments']]==[(r['where'],r['bytes'],r[key]) for r in right['segments']]
    differing=[r['field'] for r,x,y in zip(left['exceptions'],left['maskedValues'],right['maskedValues']) if x!=y] if same_ranges else None
    return dict(programHeadersIdentical=same_headers,rawLoadFileBytesIdentical=same('raw'),
                normalizedLoadFileBytesIdentical=same_headers and same_ranges and same('normalized'),
                differingExcludedFields=differing,left=left,right=right)

def keyed(rows):
    result={c['id']:c for c in rows}
    need(len(rows)==len(result)==45,'Exactly 45 distinct catalog rows required')
    return result

def verify_preflight(folder,side,held,known,refs,evidence):
    prep_pin=C.pin(folder/'report.json')
    prep=evidence.read(prep_pin)
    P.completed(prep,'Live relink preparation')
    manifest_pin=C.pin(folder/'manifest.json')
    need(prep['manifest']==manifest_pin and prep['native']==side['manifest'] and prep['source']==side['producer']['source'],
         'Relink does not bind ordinary native acquisition and original compiler source')
    need(prep['method']==C.pin(HERE/'portfolio.py') and prep['inputs']==held,'Different live preparation method or inputs')
    evidence.verify(prep['source']);evidence.verify(prep['method'])
    manifest=evidence.read(manifest_pin)
    native=evidence.read(prep['native'])
    for doc in (manifest,native):
        for pin in doc['inputs']:evidence.verify(pin)
    roles=manifest['roles']
    need(set(roles)==set(ROLES) and roles['live']['runtime']==held['live'] and roles['candidate']['runtime']==held['original'],
         'Runtime artifact or role set differs')
    for alias in ('candidate','live'):
        r=roles[alias]
        need(r['compilerSource']==prep['source'] and r['compiler']==native['roles']['candidate']['compiler'] and
             r['host']=='native' and r['stage']=='N1' and r['target']=='x86' and r['emit']=='object','Native producer identity differs')
        for field in ('compiler','compilerSource','runtime'):evidence.verify(r[field])
    need(roles['candidate']==native['roles']['candidate'],'Original portfolio role differs from native producer')
    indexed=keyed(manifest['cases']);built=keyed(native['cases'])
    need(indexed.keys()==built.keys()==known.keys()==prep['cases'].keys(),'Live plan catalog differs')
    for name,case in indexed.items():
        products=case['products'];proof=prep['cases'][name]
        arch=built[name]['products']['candidate']
        need(products['c']==refs['c'][name]['products']['c'] and products['phase197']==refs['phase197'][name]['products']['candidate'],
             'Frozen C/Phase197 baseline differs on '+name)
        need(case['point']==built[name]['point']==refs['c'][name]['point'] and
             case['source']==built[name]['source']==refs['c'][name]['source'] and
             case['expectedFile']==built[name]['expectedFile']==refs['c'][name]['expectedFile'],'Catalog identity differs on '+name)
        need(set(products)==set(ROLES) and products['candidate']==arch and dict(arch,artifact=proof['live'])==products['live'] and
             proof['object']==arch['generatedSource']==known[name]['object'] and proof['base']==arch['artifact']==known[name]['binary'],
             'Runtime arms are not the same ordinary N1 object on '+name)
        need(P.product_compare.same(proof['originalRelink'],proof['base']),'Original relink differs on '+name)
        evidence.verify(proof['originalRelink']);evidence.verify(proof['object'])
        need(set(proof['oracles'])==set(ROLES),'Four preflight roles required on '+name)
        for alias,prod in products.items():
            evidence.verify(prod['artifact'])
            obs=proof['oracles'][alias];child=obs['process'];point=case['point']
            n=int(point['repetitions']>0)
            argv=[prod['artifact']['file'],*B.native_runtime_arguments(prod),str(n),'0',*map(str,point['runtimeArgs'])]
            need(obs['repetitions']==n and child['command']==argv and not child['timedOut'],'Preflight command differs on '+name+'/'+alias)
            streams=[evidence.verify(child[k]).read_bytes() for k in ('stdout','stderr')]
            elapsed=B.observation(*streams,child['exitCode'],dict(point,repetitions=n,warmups=0),child['seconds'])
            need(elapsed==obs['elapsedMs'],'Recorded preflight observation differs on '+name+'/'+alias)
    return prep_pin,manifest_pin,indexed

def execute(a):
    out=C.fresh_output(a.out,ROOT)
    evidence=P.Evidence()
    report=dict(kind='phase198-cross-source-live-product-equivalence',complete=False,targetsRun=False,measurementsRun=False,rows=[])
    try:
        for path in (Path(__file__),METHOD,HERE/'portfolio.py',HERE/'portfolio-pins.json',P.bench.__file__,P.common.__file__):
            evidence.verify(C.pin(path))
        ordinary_pin=C.pin(a.ordinary_proof)
        ordinary=evidence.read(ordinary_pin);P.completed(ordinary,'Ordinary cross-source product comparison')
        need(ordinary.get('kind')=='phase198-explicit-source-native-product-equivalence' and
             ordinary['objectsIdentical']==ordinary['allocatedLayoutsIdentical']==45,'Ordinary all45 proof required')
        for pin in ordinary['inputs']:evidence.verify(pin)
        refs_pin=C.pin(HERE/'portfolio-pins.json');held=evidence.read(refs_pin)
        for pin in held.values():evidence.verify(pin)
        refs={k:keyed(evidence.read(held[v])['cases']) for k,v in [('c','matureC'),('phase197','phase197')]}
        base=keyed(ordinary['rows'])
        need(all(r['complete'] and r['objectIdentical'] and r['allocatedLayoutIdentical'] for r in base.values()),'Incomplete ordinary proof rows')
        pins=[]
        for path,label in [(a.measured_plan,'left'),(a.new_plan,'right')]:
            pins.append(verify_preflight(path,ordinary[label],held,{k:v[label] for k,v in base.items()},refs,evidence))
        (old_p,old_m,old),(new_p,new_m,new)=pins
        summary_pin=C.pin(a.summary);s=evidence.read(summary_pin);P.completed(s,'Measured runtime summary')
        need(s['producer']==old_p and s['references']==old_m and s['rounds']==4 and s['positionBalanced'] and
             s['oracleRevalidated']['samples']==720,'Historical timing receipt does not bind measured plan')
        raw=evidence.read(s['report']);P.completed(raw,'Measured runtime receipt')
        need(old_m in raw['inputs'] and raw['fullCatalog'] and raw['positionBalanced'] and raw['rounds']==4,
             'Measured runtime receipt must cover the full position-balanced plan')
        timed=keyed(s['cases'])
        report.update(ordinaryComparison=ordinary_pin,measuredPlan=old_p,measuredManifest=old_m,newPlan=new_p,newManifest=new_m,
            compilerSources=ordinary['compilerSources'],liveRuntime=held['live'],measuredSummary=summary_pin,measuredReport=s['report'])
        for name in old:
            old_products=old[name]['products'];new_products=new[name]['products']
            need(all(timed[name]['artifacts'][role]==old_products[role]['artifact'] for role in ROLES),'Timed ELF identity differs on '+name)
            aa=old_products['live'];bb=new_products['live']
            need(P.product_compare.same(aa['generatedSource'],bb['generatedSource']),'Native object bytes differ on '+name)
            left=M.loaded_layout(aa['artifact']['file']);right=M.loaded_layout(bb['artifact']['file'])
            need(left==right,'Live allocated ELF layout or payload differs on '+name)
            report['rows'].append(dict(id=name,measured=aa['artifact'],corrected=bb['artifact'],
                measuredObject=aa['generatedSource'],correctedObject=bb['generatedSource'],
                wholeElfIdentical=P.product_compare.same(aa['artifact'],bb['artifact']),allocatedLayout=left,
                loadDiagnostics={role:compare_mapping(old_products[role]['artifact']['file'],new_products[role]['artifact']['file'])
                                 for role in ('candidate','live')}))
        report.update(complete=True,objectsIdentical=45,liveAllocatedLayoutsIdentical=45,
            wholeLiveElfsIdentical=sum(r['wholeElfIdentical'] for r in report['rows']),preflightValidated=360,
            scope='The two N1 sources produce byte-identical objects and equal live-runtime allocated section layouts and payloads across these 45 inputs. The GNU build ID is excluded. Runtime outcomes and durations belong to the measured source and binaries. No timing or general compiler equivalence is inferred for other inputs.')
        report['mappedImageDiagnostics']={role:{key:sum(r['loadDiagnostics'][role][key] for r in report['rows'])
            for key in ('programHeadersIdentical','rawLoadFileBytesIdentical','normalizedLoadFileBytesIdentical')} for role in ('candidate','live')}
    except Exception as e:
        report['error']=repr(e)
    report['inputs']=list(evidence.inputs.values())
    report['changedInputs']=C.changed_inputs(report['inputs'])
    if report['changedInputs']:report['complete']=False
    C.write_json(out/'report.json',report)
    print(json.dumps({k:report.get(k) for k in ('complete','error','liveAllocatedLayoutsIdentical','wholeLiveElfsIdentical','preflightValidated')}))
    return 0 if report['complete'] else 1

if __name__=='__main__':
    parser=argparse.ArgumentParser()
    for name in ('measured-plan','new-plan','ordinary-proof','summary','out'):
        parser.add_argument('--'+name,type=Path,required=True)
    sys.exit(execute(parser.parse_args()))
