#!/usr/bin/env python3
"""Exact-definition source derivative of the retained native02 compiler."""
import hashlib,json,re,sys
from pathlib import Path
assert len(sys.argv)==2,'Usage: freeze-native.py NEW_NATIVE_COMPILER.bend'
here=Path(__file__).resolve().parent;root=here.parents[4];out=Path(sys.argv[1])
parent=root/'selfhost/build/phase88/native02/compiler.bend'
parent_report=root/'selfhost/build/phase88/native02/report.json'
baseline=here/'bridge.baseline.bend';candidate=here/'bridge.candidate.bend'
source=parent.read_text();old=baseline.read_text();new=candidate.read_text()
pin=lambda p:dict(file=str(p.resolve()),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)
metadata=json.loads(parent_report.read_text());assert metadata['complete']
assert pin(parent)['sha256']==metadata['source']['sha256'],'Parent source differs from checked receipt'
assert source.startswith('import Base\n\n# Phase88 native-host-only consuming string helpers.')
def extract(text,name):
    matches=list(re.finditer(r'(?m)^@unsafe\ndef '+re.escape(name)+r'\(',text))
    assert len(matches)==1,(name,len(matches))
    start=matches[0].start();body_start=matches[0].end()
    tail=re.search(r'(?m)^(?:# Module:|@unsafe\s*$|(?:def|law|type)\s)',text[body_start:])
    end=body_start+tail.start() if tail else len(text)
    while end>start and text[end-1]=='\n':end-=1
    return start,end,text[start:end]
token=re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|#[^\n]*|[A-Za-z_][A-Za-z_0-9]*(?:\.[A-Za-z_][A-Za-z_0-9]*)*')
def adapted(text):
    return token.sub(lambda m:'p88_string_eq' if m[0]=='String.eq' else m[0],text)
start,end,current=extract(source,'nc_match_apply_slow_to')
expected=adapted(extract(old,'nc_match_apply_slow_to')[2])
assert current==expected,'Frozen native definition does not match baseline plus its equality adaptation'
names=['nc_match_apply_slow_to','nc_match_apply_hit_to','nc_match_apply_join']
for name in names[1:]:assert not re.search(r'(?m)^def '+name+r'\(',source),name
replacement='\n\n'.join(adapted(extract(new,name)[2]) for name in names)
result=source[:start]+replacement+source[end:]
# Only one definition range changes; reverse transport must reproduce every
# imported/prepared/equality/cache/entry byte exactly.
assert result[:start]+current+result[start+len(replacement):]==source
with out.open('x') as f:f.write(result)
report=dict(kind='phase89-native02-owned-match-derivative',complete=True,
            inputs=[pin(parent),pin(parent_report),pin(baseline),pin(candidate),pin(Path(__file__))],output=pin(out),
            replaced=dict(name=names[0],oldStartByte=len(source[:start].encode()),oldEndByte=len(source[:end].encode()),
                          oldSha256=hashlib.sha256(current.encode()).hexdigest(),newSha256=hashlib.sha256(replacement.encode()).hexdigest()),
            addedDefinitions=names[1:],inverseRecoversParent=True,
            equality='Only exact String.eq tokens in the three inserted definitions receive the existing p88_string_eq adaptation.',
            scope='Parent native02 bytes retained except the exact slow-match definition and two inserted helpers. '
                  'Existing imports, prepared Base/cache entry, equality helpers, runtime chunks and IO permissions unchanged. '
                  'This source is not checked or emitted by this offline tool.')
with Path(str(out)+'.derivation.json').open('x') as f:json.dump(report,f,indent=2);f.write('\n')
print(json.dumps(dict(output=str(out),sha256=report['output']['sha256'],bytes=report['output']['bytes'])))
