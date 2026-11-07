#!/usr/bin/env python3
"""Read-only function census of the three small native workload products."""
import json
from pathlib import Path
import re
import sys

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,write_json
result=dict(kind='phase176-pattern-worker-inspection',complete=True,inputs=[pin(__file__)],images=[])
for label,folder in [('baseline','pattern-native-baseline01'),('mutual','pattern-native-candidate02'),('single','pattern-single-native01')]:
    directory=ROOT/'selfhost/build/phase176'/folder
    receipt=json.loads((directory/'report.json').read_text());verify(receipt['retainedIR'])
    result['inputs'].extend([pin(directory/'report.json'),receipt['retainedIR']])
    text=(directory/'program.ssa').read_text();functions=[]
    for match in re.finditer(r'^(?:export )?function[^\n]*\$(\w+)\([^\n]*\) \{\n(.*?)^\}',text,re.M|re.S):
        symbol,body=match.groups();encoded=re.search(r'_FID_((?:\d+_)+)',symbol)
        decoded=''.join(chr(int(n))for n in encoded[1].rstrip('_').split('_'))if encoded else None
        functions.append(dict(symbol=symbol,source=decoded,textBytes=len(match[0].encode()),
                              calls=re.findall(r'\bcall \$(\w+)',body),
                              jumpCount=len(re.findall(r'\bjmp\b',body))))
    relevant=[f for f in functions if f['source'] and any(x in f['source']for x in ['p176pm_','p176ps_','f_pattern_sub','f_pattern_value'])]
    private=[f for f in relevant if f['symbol'].startswith('p113d_')]
    for f in private:f['callsSelf']=f['symbol']in f['calls']
    result['images'].append(dict(label=label,qbeBytes=len(text.encode()),binary=receipt['binary'],
                                functionCount=len(functions),privateWorkers=private,
                                relevantFunctionCount=len(relevant)))
write_json(ROOT/'experiments/phase176/machine-inspection.json',result)
print(json.dumps([dict(label=x['label'],qbeBytes=x['qbeBytes'],privateWorkers=[f['source']for f in x['privateWorkers']])for x in result['images']]))
