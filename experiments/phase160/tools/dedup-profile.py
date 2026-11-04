#!/usr/bin/env python3
"""Share only freshly completed, exact profiler output with its frozen oracle."""
import argparse,json,os,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,write_json,require,same_bytes
p=argparse.ArgumentParser();p.add_argument('--run',type=Path,required=True);a=p.parse_args()
out=a.run.resolve();require(out.is_relative_to(ROOT/'selfhost/build/phase160'),'Wrong root')
d=json.loads((out/'report.json').read_text());m=json.loads((out/'manifest.json').read_text())
require(d['complete'] and d['passed'],'Incomplete capture')
for row in d['rows']:
 require(row['correct'],'Bad output')
 v=next(v for w in m['workloads'] if w['name']==row['workload'] for v in w['variants'] if v['name']==row['variant'])
 product=verify(row['stdout']);reference=v['expected']['stdout'];canonical=verify(reference)
 require(product.is_relative_to(out) and same_bytes(product,canonical),'Not exact fresh output')
 intent=product.parent/'dedup-intent.json';require(not intent.exists(),'Already deduplicated')
 write_json(intent,dict(product=row['stdout'],canonical=reference,byteExact=True,complete=False))
 temporary=product.parent/'stdout.shared';os.link(canonical,temporary);os.replace(temporary,product)
 require(pin(product)==row['stdout'],'Changed output')
 write_json(product.parent/'dedup-result.json',dict(product=row['stdout'],canonical=reference,complete=True,links=product.stat().st_nlink))
print('Exact outputs shared; frozen oracle unchanged')
