#!/usr/bin/env python3
"""Bind explicitly relinked compiler variants to their unchanged source/machine provenance."""
import argparse,copy,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,fresh_output,write_json
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--pair',type=Path,required=True);p.add_argument('--origin',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
pair=json.loads(a.pair.read_text());origin=json.loads(a.origin.read_text())
require(pair['kind']=='phase172-static-seal-linked-pair' and pair['complete'],'Linked pair required')
require(origin['kind']=='bend-native-build' and origin['complete'] and origin.get('imageBinding'),'Compiler origin required')
require(pair['programObject']==origin['object'],'Different program object')
require(all(pair['programIR'][k]==origin['retainedIR'][k] for k in ['bytes','sha256']),'Different program IR')
inputs=[pin(__file__),pin(a.pair),pin(a.origin),*pair['inputs'],origin['imageBinding']['sourceIdentity']]
for x in inputs:verify(x)
out=fresh_output(a.out,ROOT);reports=[]
for row in pair['variants']:
 verify(row['binary']);binding=copy.deepcopy(origin['imageBinding']);binding.update(image=row['binary'],linkedRuntime=row['runtime'],qualification='Private runtime relink of unchanged checked N1 object; no additional bootstrap generation, native self-reproduction or installed promotion.')
 r=dict(kind='phase172-compiler-runtime-relink-binding',complete=True,inputs=inputs+[row['binary']],imageBinding=binding,programObject=pair['programObject'],programIR=pair['programIR'],originalCompilerBuild=pin(a.origin),runtimeOnly=True)
 file=out/(row['label']+'.json');write_json(file,r);reports.append(pin(file))
write_json(out/'report.json',dict(complete=True,targetsRun=False,inputs=inputs,bindings=reports))
print(json.dumps(dict(complete=True,bindings=reports)))
