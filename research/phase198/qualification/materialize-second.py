#!/usr/bin/env python3
"""Bind frozen source/audit to existing parameterized argv; execute no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[3];BUILD=ROOT/'selfhost/build/phase198'
def pin(path):
    p=Path(path).resolve();data=p.read_bytes()
    return dict(file=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--source',type=Path,required=True);p.add_argument('--manifest',type=Path,required=True);p.add_argument('--audit',type=Path,required=True);p.add_argument('--prefix',default='composed');p.add_argument('--label',required=True)
a=p.parse_args();assert re.fullmatch('[a-z][a-z0-9-]*',a.prefix)
source=pin(a.source);audit=json.loads(a.audit.read_text())
assert audit.get('complete') is True and audit['selectedSource']==source
assert audit.get('exactExecutableBodiesIdentical',True) is True
manifest=pin(a.manifest)
template=Path(__file__).with_name('second-chain-templates.json');doc=json.loads(template.read_text())
folder=BUILD/(a.prefix+'-argv01');assert not folder.exists();folder.mkdir()
values={'source':source['file'],'manifest':manifest['file'],'prefix':a.prefix}
outputs=[]
for name,argv in doc['commands'].items():
    result=[]
    for word in argv:
        for k,v in values.items():word=word.replace('{{'+k+'}}',v)
        assert '{{' not in word
        result.append(word)
    if '--out' in result:assert not Path(result[result.index('--out')+1]).exists()
    path=folder/(name+'-argv.json');path.write_text(json.dumps(result,indent=2)+'\n');outputs.append(pin(path))
record=dict(kind='phase198-second-native-chain-materialized',complete=True,targetsRun=False,label=a.label,prefix=a.prefix,method=pin(__file__),templates=pin(template),selectedSource=source,manifest=manifest,audit=pin(a.audit),argv=outputs,order=doc['order'],defaultReference=doc['defaultReference'],scope=doc['sourcePolicy'])
out=folder/'plan.json';out.write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(pin(out)))
