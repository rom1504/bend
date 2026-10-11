#!/usr/bin/env python3
"""Prepare finite scalar-signature saved-C variants; no target executions."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
ROOT = Path(__file__).resolve().parents[5]
PARENT = ROOT/'selfhost/build/phase69/node-reuse-prep01/plan.json'
PARENT_SHA = '170100ef6d15b558a6a5b1ecc69d8182f44b33fae075252d7e160febb5b4cb9a'
PREFIX = '../phase37/fixtures-historical/tree-bitonic:'


def pin(p):
    p=Path(p).resolve();return dict(path=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest(),bytes=p.stat().st_size)


def verify(p):
    assert pin(p['path'])==p,p['path']


def derive(original, count):
    text=original;edits=[]
    for name in ['warp_leaf', 'warp_leaf.go']:
        symbol='NF_FID_'+''.join(str(ord(c))+'_' for c in PREFIX+name)
        pattern=r'^(?:INLINE|NF_INLINE) Term '+re.escape(symbol)+r'\(Env e, bool seq, Term\* nf_out, Term v_4294967295, Term v_4294967294, Term v_4294967293\)(?:;| \{)'
        matches=list(re.finditer(pattern,text,re.M));assert len(matches)==2,(name,len(matches))
        for m in reversed(matches):
            before=m.group(0);after=before
            for param in ('v_4294967295','v_4294967294','v_4294967293')[:count]:
                old='Term '+param;assert after.count(old)==1;after=after.replace(old,'u32 '+param)
            at=m.start();edits.append(dict(offsetInParent=at,lineInParent=text.count('\n',0,at)+1,before=before,after=after,function=name,typedParameterCount=count))
            text=text[:at]+after+text[at+len(before):]
    reverse=text
    for e in reversed(edits):
        at=e['offsetInParent'];assert reverse[at:at+len(e['after'])]==e['after']
        reverse=reverse[:at]+e['before']+reverse[at+len(e['after']):]
    assert reverse==original
    return text,edits


def main():
    assert os.sched_getaffinity(0)=={0}
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--out',required=True,type=Path);args=ap.parse_args()
    out=args.out.resolve();assert out.is_relative_to(ROOT/'selfhost/build/phase69');out.mkdir(parents=True,exist_ok=False)
    parent_pin=pin(PARENT);assert parent_pin['sha256']==PARENT_SHA
    plan=json.loads(PARENT.read_text());parents={j['arm']:j for j in plan['jobs']}
    rows=[]
    for label,base,count in [('u32_cold','cold',2),('scalars_cold','cold',3),('scalars_cold_reuse','cold_reuse',3)]:
        p=parents[base]['source'];verify(p);original=Path(p['path']).read_text();text,edits=derive(original,count)
        c=out/(label+'.c');c.write_text(text)
        rows.append(dict(arm=label,parent=p,source=pin(c),edits=edits,reverseRecoversParent=True,bodyChanges=False))
    result=dict(kind='phase69-typed-worker-saved-c-plan-v1',targetsExecuted=False,
      producer=pin(__file__),hypothesis=pin(ROOT/'experiments/phase69/P69-008-typed-native-worker-parameters.md'),
      parentPlan=parent_pin,baseline=parents['cold']['source'],jobs=rows,
      typedSource=pin(ROOT/'selfhost/tools/performance/phase37/fixtures-historical/tree-bitonic.bend'),
      scope='Four role comparison: existing cold baseline, U32-only private signatures, U32+Bool, U32+Bool plus prior local reuse. Body/call/poll/runtime unchanged. Checked valid-source witness only; no raw truncation permission or compiler integration.')
    (out/'plan.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(plan=pin(out/'plan.json'),targetsExecuted=False)))

if __name__=='__main__':main()
