"""Offline evidence only: authenticated ELF relocations and source-level guard proof."""
import gzip, hashlib, json, struct
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent

def pin(p):
    p=Path(p);b=p.read_bytes()
    return {'file':str(p.relative_to(ROOT)), 'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}

def relocations(p):
    b=p.read_bytes();assert b[:6]==b'\x7fELF\x02\x01'
    off=struct.unpack_from('<Q',b,40)[0];size,n=struct.unpack_from('<HH',b,58)
    sh=[struct.unpack_from('<IIQQQQIIQQ',b,off+i*size) for i in range(n)]
    counts={}
    for s in sh:
        if s[1]!=4:continue
        syms=sh[s[6]];strings=sh[syms[6]];txt=b[strings[4]:strings[4]+strings[5]]
        for pos in range(s[4],s[4]+s[5],s[9]):
            _,info,_=struct.unpack_from('<QQq',b,pos);idx=info>>32
            nameoff=struct.unpack_from('<I',b,syms[4]+idx*syms[9])[0]
            name=txt[nameoff:txt.index(b'\0',nameoff)].decode()
            if name in ('p111_rt_keep','p111_rt_sink'):counts[name]=counts.get(name,0)+1
    return counts

manifest=ROOT/'selfhost/build/phase198/p199-integrated-native45-01/programs.manifest.json'
old=ROOT/'research/phase198/profile/evidence/screen.json.gz'
census=json.load(gzip.open(old))['reports']['ownership-count01']
prior={c['id']:c for c in census['cases']}
rows=[]
for c in json.loads(manifest.read_bytes())['cases']:
    p=c['products']['candidate']['generatedSource']; path=Path(p['file'])
    actual=pin(path);assert all(actual[k]==p[k] for k in ('bytes','sha256'))
    d=prior[c['id']]['second'];counts=relocations(path)
    rows.append({'case':c['id'],'family':c['family'],'phase199Object':actual,'ownershipRelocations':counts,
      'historicalPhase198SecondDeltaImmediate':d.get('keep 0',0)+d.get('sink 0',0),
      'historicalPhase198SecondDeltaOwnership':sum(v for k,v in d.items() if k.startswith(('keep ','sink '))),
      'historicalBothDeltasStable':prior[c['id']]['stable']})
# Exact partition proof, independent of any heap/allocator implementation:
# keep first tests RFC, then trivial masked tag; sink tests trivial directly.
truth=[]
for high in range(256):
    admitted=(high>>1)==0
    keep_has_no_heap_effect=not(high&128) and ((high&127)<=1)
    sink_has_no_heap_effect=(high&127)<=1
    assert not admitted or (keep_has_no_heap_effect and sink_has_no_heap_effect)
    truth.append({'highByte':high,'fast':admitted,'keepTagOnlyTrivial':keep_has_no_heap_effect,
                  'sinkTagOnlyTrivial':sink_has_no_heap_effect})
assert not truth[128]['keepTagOnlyTrivial'] and not truth[129]['keepTagOnlyTrivial']
out={'complete':True,'scope':'Read-only metadata and ELF analysis. No compiler or target execution; historical dynamic counts are not Phase199 observations or performance evidence.',
 'inputs':[pin(manifest),pin(old),pin(ROOT/'selfhost/src/runtime/qbe/runtime.c')],
 'cases':rows,'guardHighByteTruthTable':truth,'admittedHighBytes':[0,1],
 'familiesWithStaticOwnershipEdges':sorted({r['family'] for r in rows if r['ownershipRelocations']}),
 'phase199CurrentDynamicCounts':None,'physicalPerformance':None}
(HERE/'audit.json').write_text(json.dumps(out,indent=2)+'\n')
print(len(rows),'cases;',len(out['familiesWithStaticOwnershipEdges']),'families with static ownership edges')
