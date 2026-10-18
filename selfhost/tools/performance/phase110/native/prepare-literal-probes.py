#!/usr/bin/env python3
"""Source-only literal-size falsifier for the timed-out native image acquisition."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--source',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args()
pin=lambda path:dict(file=str(path.resolve()),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())
def verify(row):
 path=Path(row['file']);found=pin(path)
 if found['bytes']!=row['bytes'] or found['sha256']!=row['sha256']:raise ValueError('changed '+str(path))
 return path
source_manifest=a.source.resolve()/'manifest.json';m=json.loads(source_manifest.read_text());out=a.out.resolve()
if not m['complete'] or not m.get('generalEntry'):raise ValueError('full Base-literal native source required')
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
base=verify(m['assets']['base']);runtime=verify(m['assets']['runtime']);text=base.read_text()
if len(text)!=75064 or len(text.encode())!=75064:raise ValueError('unexpected exact Base length')
out.mkdir();rows=[]
for label,size in [('small-1024',1024),('full-75064',75064)]:
 selected=text[:size];fixture=out/(label+'.bend');expected=out/(label+'.expected')
 fixture.write_text('import Base\n\ndef p110_literal_probe() -> String:\n  '+json.dumps(selected,ensure_ascii=False)+'\n\ndef main() -> IO(Unit):\n  IO.print(p110_literal_probe())\n')
 expected.write_text(selected+'\n')
 emit_out=ROOT/'selfhost/build/phase108'/('p110-'+out.name)/label
 command=['python3','-B',str(HERE.parent.parent/'phase108/run.py'),'emit',str(fixture),'--runtime',str(runtime),'--out',str(emit_out),'--seconds','45']
 rows.append(dict(label=label,characters=size,source=pin(fixture),expectedExecutionStdout=pin(expected),emitCommand=command,
     guardCommand=['python3','-B',str(HERE.parent.parent/'phase86/guard.py'),'--out',str(emit_out.parent/(label+'-guard')),'--seconds','60','--rss-mib','3072','--available-mib','8192','--cpu','3','--',*command]))
report=dict(kind='phase110-native-literal-size-probes',complete=True,targetsRun=False,inputs=[pin(Path(__file__)),pin(source_manifest),m['assets']['base'],m['assets']['runtime']],rows=rows,
 hypotheses=['The native static image is capped at65536 words;75064 SCon cells exceed it even in isolation.',
 'String compaction expands literals into nested constructors; remaining dynamic prefix forms a large single lowered body.'],
 limits=['Preparation only; root runs both B2 emits under the same prepared compiler/runtime.','Timeout is diagnostic evidence, never successful source acquisition.','Expected stdout is frozen for later execution if an image is built; no execution is claimed by emission.'])
(out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,manifest=str(out/'manifest.json'),rows=rows)))
