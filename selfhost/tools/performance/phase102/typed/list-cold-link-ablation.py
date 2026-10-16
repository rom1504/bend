#!/usr/bin/env python3
"""Offline diagnostic: restore cold link stores in certified homogeneous TRMC lists."""
import argparse, hashlib, json, re
from pathlib import Path

def pin(path):
    path = Path(path).resolve(); data = path.read_bytes()
    return dict(file=str(path), sha256=hashlib.sha256(data).hexdigest(), bytes=len(data))
def verify(item):
    assert pin(item['file']) == item

def transform(source, selected):
    changes=[]
    for name in selected:
        symbol='NF_FID_'+''.join(str(ord(c))+'_' for c in name)+'_trmc'
        m=re.search(r'(?m)^NF_INLINE Term '+symbol+r'[^\n]*\) \{', source)
        assert m, name
        end=m.end(); depth=1
        while depth:
            depth+=(source[end]=='{')-(source[end]=='}');end+=1
        body=source[m.start():end]
        # Diagnostic scope is exact homogeneous Con chains; no arbitrary parent types.
        nodes=re.findall(r'Term (ntr_node_[0-9]+) = term_ctr\((CID_[A-Z0-9_]+),',body)
        assert nodes and all(cid=='CID_CON' for node,cid in nodes), nodes
        for node,cid in nodes:
            old='e.mem[nf_out[1]] = rfc_seal(e, '+node+');'
            new='e.mem[nf_out[1]] = '+node+';'
            assert body.count(old)==1
            at=source.index(old,m.start(),end)
            changes.append(dict(offset=at,old=old,new=new,worker=name))
            source=source[:at]+new+source[at+len(old):]
            end-=len(old)-len(new);body=source[m.start():end]
    return source,changes
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--products',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
a=p.parse_args(); products=json.loads(a.products.read_text());out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
rows=[]
for case in products['cases']:
    if case['id'] not in ['coverage-list-pipeline-128','coverage-list-pipeline-512']:continue
    src=case['products']['own']['c'];verify(src);text=Path(src['file']).read_text()
    assert '#define NATIVE_COLD_CTORS 1\n' in text
    assert not re.search(r'(?m)^#define NATIVE_HOT_CID_CON\b',text)
    for label,names in [('both',['p37.list','dbl']),('list',['p37.list']),('dbl',['dbl'])]:
        changed,edits=transform(text,names);inverse=changed
        for edit in reversed(edits):
            at=edit['offset'];assert inverse[at:at+len(edit['new'])]==edit['new']
            inverse=inverse[:at]+edit['old']+inverse[at+len(edit['new']):]
        assert inverse==text
        path=out/(case['id']+'-'+label+'.c');path.write_text(changed)
        rows.append(dict(id=case['id'],variant=label,source=src,candidate=pin(path),changes=edits,inverseExact=True,
            baseline=case['products']['upstream'],candidateProduct=case['products']['own']))
report=dict(complete=True,targetsRun=False,releaseQualified=False,method=pin(__file__),products=pin(a.products),rows=rows,
    scope='Diagnostic C-only ablation of newly added TRMC link RFC wrappers in two homogeneous cold Con-chain workers. '
          'Every edited worker constructs only Con and the request marks Con cold; published links are private until return. '
          'No other instruction, inline hint, ABI or control flow changes. This is not a general multi-constructor lowering rule. '
          'Each source still requires guarded build and complete output checks; no measured gain is implied.')
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps([dict(id=r['id'],variant=r['variant'],candidate=r['candidate']) for r in rows]))
