"""Derive scoped lifetime/size bounds from the already verified Phase132 census."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[4]
def pin(p):
 p=Path(p).resolve();return {'file':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
p=ROOT/'implementation/phase132/census01.json';r=json.loads(p.read_text());assert r['complete']
functions=sorted(r['topFunctions'],key=lambda x:x['bytes'],reverse=True)
owners=[x for x in r['topSourceOwners'] if x['sourceOrigin'] is not None]
owner=max(owners,key=lambda x:x['bytes'])
qbe=ROOT/'selfhost/build/phase108/toolchain/qbe-1.3/main.c';text=qbe.read_text()
assert 'parse(inf, f, dbgfile, data, func);' in text and 'T.emitfn(fn, outf);' in text
result={'complete':True,'targetsRun':False,'inputs':[pin(__file__),pin(p),pin(qbe)],
 'wholeQbeBytes':r['rawBytes'],'functions':r['functions'],'instructions':r['instructions'],
 'largestFunction':functions[0], 'largestAttributedOwner':owner,
 'unknownOwnerBucketIsNotOneOwner':True,
 'wholeTextToLargestFunctionRatio':r['rawBytes']/functions[0]['bytes'],
 'dataTextBytes':r['sectionBytes']['data'],
 'fixedInventoryIllustrations':[{'logicalBytesPerInstruction':n,'instructionBaseBytes':n*r['instructions']} for n in [9,12,16,24,32]],
 'scope':'No new compiler execution or IR codec. Largest function from verified byte-sorted census. Hypothetical dense records are not Zig/Bend equivalent instructions and exclude payloads, tables, capacity, diagnostics and retained semantic state. Streaming still requires data/dispatch output and global legality/identity contracts. QBE source consumes functions independently and calls freeall; no QBE heap/RSS measurement.'}
out=ROOT/'research/phase133/unit-bounds.json';assert not out.exists();out.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'whole':result['wholeQbeBytes'],'maxFunction':functions[0]['bytes'],'maxAttributedOwner':owner['bytes'],'ratio':result['wholeTextToLargestFunctionRatio']}))
