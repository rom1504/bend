#!/usr/bin/env python3
"""Create a separate, unqualified binding for an already-built exact compiler.
The acquisition omitted --output-stage. Preserve its receipt; do not rerun a
three-minute compiler build solely to attach independently checkable metadata.
"""
import json, sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,require,write_json
folder=ROOT/'selfhost/build/phase177/full-native-n1'
build=folder/'report.json';composition=ROOT/'selfhost/build/phase177/full-source01/report.json';check=ROOT/'selfhost/build/phase177/full-source-check01/report.json'
b=json.loads(build.read_text());c=json.loads(composition.read_text());v=json.loads(check.read_text())
require(b['complete'] and not b['changedInputs'] and 'imageBinding' not in b,'Successful unchanged acquisition without binding required')
require(c['complete'] and c['mainUnchanged'] and c['protectedUnchanged'] and c['inverseExact'],'Exact complete compiler composition required')
require(v['complete'] and v['checked'] and v['typeAccepted'] and v['unresolvedHoles']==0,'Independent full-source check required')
require(b['request']['source']==c['source']==v['source'],'Actual emitted source differs')
inputs=[pin(__file__),pin(build),pin(composition),pin(check),b['binary'],b['runtime'],b['request']['source'],b['request']['image']]
for x in inputs:verify(x)
out=folder/'image-binding.json';require(not out.exists(),'Fresh binding required')
r=dict(kind='bend-build-image-binding',version=1,complete=True,image=b['binary'],sourceIdentity=b['request']['source'],host='native',stage='N1',protocol='qbe-source-v1',targets=['qbe'],linkedRuntime=b['runtime'],producer=b['request']['image'],producerHost=b['request']['host'],producerStage=b['request']['stage'],qualification='Built and independently source checked; semantic and self-host qualification is separate.',inputs=inputs,scope='Post-acquisition metadata only. The original successful acquisition receipt remains unchanged; no target execution, qualification or publication is claimed.')
write_json(out,r);print(json.dumps(dict(complete=True,targetsRun=False,binding=pin(out))))
