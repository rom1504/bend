#!/usr/bin/env python3
"""Prepare a small checked Phase148 API; output target jobs, never run them."""
import argparse
from pathlib import Path
import json
from shared import ROOT,assembly,extract,guard,pin,require,sources,fresh_output,write_json

EXPORTS=['missing','p113e_originals','ns_ctor_index','p113e_signatures','p113e_signature','p113e_insert',
         'p111q_function_ids','p111q_constructor_ids','p113k_function','p147d_function','p113e_function',
         'p113e_private','p148_pack','p148_unpack','p148o_function','p148v_function','p148v_check']

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ['core','scalar','verify']:p.add_argument('--'+name,type=Path,required=True)
    p.add_argument('--extra-export',action='append',default=[]);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();parts,inputs,identity=sources([a.core,a.scalar,a.verify]);roots=EXPORTS+a.extra_export
    body,declarations=extract(parts,roots,1_500_000)
    out=fresh_output(a.out,ROOT);(out/'compiler.bend').write_bytes(body)
    exports=dict(kind='bend-hosted-api-exports',version=1,exports=roots,protocol='hosted-api-v1',targets=['qbe'],
                 preparationModes=['live'],scope='Private checked unit experiment; no public request capability or installation.')
    write_json(out/'exports.json',exports);api=out/'api'
    jobs=[guard('phase148-small-checked-api',api,[ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tools/build/hosted.mjs','acquire',
        '--source',out/'compiler.bend','--exports',out/'exports.json','--upstream',ROOT/'selfhost/.bootstrap/upstream-phase66',
        '--engine',ROOT/'selfhost/.assets/bin/bun','--out',api],150,3072,256)]
    result=dict(kind='phase148-unit-api-preparation',version=1,complete=True,targetsRun=False,checked=False,
                inputs=[pin(__file__),*inputs],canonicalSourceIdentity=identity,source=pin(out/'compiler.bend'),
                exports=pin(out/'exports.json'),declarations=declarations,acquisition=str(api/'report.json'),jobs=jobs,
                originalBodiesUnchanged=True,scope='Exact current declarations plus additive modules; no shadowing, checking pending.')
    write_json(out/'manifest.json',result);write_json(out/'jobs.json',jobs)
    print(json.dumps(dict(source=result['source'],declarations=len(declarations),jobs=str(out/'jobs.json'))))

if __name__=='__main__':main()
