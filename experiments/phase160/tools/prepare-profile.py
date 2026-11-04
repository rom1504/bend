#!/usr/bin/env python3
"""Bind the already validated full request to the maintained physical profiler."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,write_json,fresh_output,require
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--run',choices=['full-c01','checker01'],default='full-c01')
a=p.parse_args();out=fresh_output(a.out,ROOT)
receipt=ROOT/'selfhost/build/phase160'/a.run/'report.json'
d=json.loads(receipt.read_text());require(d['complete'],'Full request must pass first')
r=d['rows'][0];require(r['passed'] and r['byteExact'] and r['role']=='c','Wrong reference')
for item in d['inputs']:verify(item)
command=list(r['process']['command']);require(command[-1]==r['product']['file'],'Unexpected output argument')
command[-1]='/dev/stdout'
expected=dict(stdout=dict(kind='exact',**r['product']),stderr=dict(kind='exact',**r['process']['stderr']),exitCode=0)
sampler=pin(ROOT/'selfhost/build/phase159/thread-sampler01/sampler.so')
manifest=dict(schema='bend-native-profile-workloads-v1',cwd=str(ROOT),sampler=sampler,
    scope='Same complete compiler request; private bendc C/GC, BEND_UNBOX=0 acquisition. Diagnostic output goes through /dev/stdout into a regular file rather than the clean named output; exact independent QBE bytes required. Physical leaves, not logical caller attribution.',
    inputs=[pin(__file__),pin(receipt),*d['inputs']],
    groups={'gc_reuse_search':r'^gc_refill', 'gc_mark_collect':r'^gc_(mark|collect|sweep|scan)',
        'gc_allocation':r'^gc_', 'memory':r'^(mem|__mem|malloc|free|realloc|calloc)',
        'scheduler':r'^(WL_|task_|pool_|work_)','generated_bend':r'^(F_|U_|W_|D_)'},
    workloads=[dict(name=d['case'],timeoutSeconds=300,variants=[dict(name='bendc-c-boxed',
        binary=pin(command[0]),argv0='transfer',command=command,expected=expected)])])
write_json(out/'manifest.json',manifest)
print(out/'manifest.json')
