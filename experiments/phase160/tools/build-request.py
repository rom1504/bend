#!/usr/bin/env python3
"""Build the admitted identical Bend request implementation through C/Clang."""
import argparse,json,re,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
from common import pin,verify,run,write_json,fresh_output,require
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
a=p.parse_args();out=fresh_output(a.out,ROOT)
emission=ROOT/'selfhost/build/phase160/capped-request01/report.json'
equivalence=ROOT/'selfhost/build/phase160/parser-equivalence02/report.json'
original=ROOT/'selfhost/build/phase156/request-prepare01/checked-api/report.json'
e=json.loads(emission.read_text());q=json.loads(equivalence.read_text());o=json.loads(original.read_text())
require(e['complete'] and q['complete'] and q['byteEqualPerRow'] and o['complete'] and o['checked'],'Independent source/emission gates missing')
source=verify(e['process']['stdout']);text=source.read_text()
pairs=[('FILE_CLOSE','file_close_run'),('FILE_WRITE','file_write_run'),('FILE_WRITE_BYTES','file_write_bytes_run'),('FILE_OPEN','file_open_run'),('FILE_READ','file_read_run'),('FILE_READ_BYTES','file_read_bytes_run'),('FILE_READ_AT','file_read_at_run'),('FILE_SIZE','file_size_run'),('IO_ARGS','io_args_run')]
require(len(re.findall(r'\bio_eff\(',text))==len(pairs),'Unexpected IO registration set')
for cid,fn in pairs:
    before=f'io_eff(CID_{cid}, {fn});'
    require(text.count(before)==1,'Missing exact legacy effect registration')
    text=text.replace(before,f'io_eff(CID_{cid}, {fn}, 0);')
c=out/'program.c';c.write_text(text)
assets=json.loads((ROOT/'selfhost/manifests/assets-native.json').read_text())
cc=assets['assets']['clang'];header=ROOT/'selfhost/build/phase159/refill-prepare01/bendrt.h'
cmd=[cc['file'],'-std=c11','-O2',*assets['toolchains']['c'].get('includeFlags',[]),'-I',str(header.parent),'-I',str(ROOT/'selfhost/build/phase157/vendor/rt'),str(c),'-o',str(out/'program'),'-lpthread','-lm']
r=dict(kind='phase160-cross-built-request',complete=False,inputs=[pin(__file__),pin(emission),pin(equivalence),pin(original),pin(source),pin(c),pin(header),cc],
    sourceEquivalence=q['canonicalSha256'],effectAdapter=pairs,compilerFlags='-std=c11 -O2, pinned includes; same optimization level as published seed acquisition',
    runtime='Private Phase159 bounded-search GC, not production qualification',
    scope='Same independently checked complete Bend request algorithms; only execution backend changes. Ordinary output oracle remains pending.')
write_json(out/'report.json',r)
r['process']=run(cmd,cwd=ROOT,stdout=out/'stdout',stderr=out/'stderr',seconds=240)
r['complete']=r['process']['complete']
if r['complete']:r['binary']=pin(out/'program')
for x in r['inputs']:verify(x)
write_json(out/'report.json',r);print(json.dumps(dict(complete=r['complete'],seconds=r['process']['seconds'])))
sys.exit(0 if r['complete'] else 1)
