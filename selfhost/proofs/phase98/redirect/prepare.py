#!/usr/bin/env python3
"""Extract exact redirect functions and finite safe dependency closure; no targets."""
import argparse
import hashlib
import json
from pathlib import Path
import re

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]


def pin(path):
    path=Path(path).resolve();data=path.read_bytes()
    return dict(file=str(path),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())


def declarations(text):
    rows=list(re.finditer(r'(?m)^(?:@unsafe\n)?(type|def|law) ([\w.]+)\b',text));result={}
    for i,m in enumerate(rows):
        end=rows[i+1].start()if i+1<len(rows)else len(text)
        key=(m.group(1),m.group(2));assert key not in result,key
        result[key]=text[m.start():end]
    return result


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--receipt',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();assert out.is_relative_to(ROOT)and not out.exists()
    receipt=json.loads(a.receipt.read_text());assert receipt['complete']
    for key in ['source','parentSource','candidate']:assert pin(receipt[key]['file'])==receipt[key]
    source=Path(receipt['source']['file']).read_text();candidate=Path(receipt['candidate']['file']).read_text();replay=source
    for c in receipt['changes']:
        start=c['offset'];end=start+len(c['old']);assert replay[start:end]==c['old']
        replay=replay[:start]+c['new']+replay[end:]
    assert replay==candidate
    local=[c for c in receipt['localChanges']if c['function']=='no_scalar_redirect'];assert len(local)==1
    old,new=local[0]['old'],local[0]['new']
    assert Path(receipt['parentSource']['file']).read_text().count(old)==1 and candidate.count(new)==1
    ds=declarations(candidate);selected=[]
    for name in ['KTerm','N_WordKind','N_Param','N_Frame','N_Segment','NC_Text','NC_Code','NF_Worker',
                 'nt_choose','p88_string_eq_go','p98_eq_finish','p88_string_eq',
                 'nct_leaf','nct_empty','nct_cat_right','nct_cat_left','nct_cat','nc_prepend',
                 'nc_ctor_codes','nt_fid','nf_name','nf_segment_args','nf_arg_c',
                 'no_root_index','no_shared_roots','no_adapter_name']:
        key=('type',name)if ('type',name)in ds else('def',name)
        original=ds[key];extracted=original.removeprefix('@unsafe\n');record=dict(name=name,original=original)
        if name=='nc_ctor_codes':
            signature=ds[('law',name)]
            assert 'for +name: String\n  String\n'in signature
            before='def nc_ctor_codes(name):';after='def nc_ctor_codes(+name: String) -> String:'
            assert extracted.count(before)==1
            extracted=extracted.replace(before,after,1)
            assert extracted.replace(after,before,1)==original.removeprefix('@unsafe\n')
            record['signature']=signature;record['headerBridge']=dict(before=before,after=after,bodyUnchanged=True)
        assert '@unsafe'not in extracted
        record['extracted']=extracted;selected.append(record)
    reference=old.removeprefix('@unsafe\n').replace('no_scalar_redirect(', 'no_scalar_redirect_reference(')
    assert reference.replace('no_scalar_redirect_reference(', 'no_scalar_redirect(')==old.removeprefix('@unsafe\n')
    assert old.count('no_scalar_redirect(')==2
    actual=new.removeprefix('@unsafe\n');assert '@unsafe'not in actual
    out.mkdir(parents=True)
    (out/'candidate.bend').write_text('import Base\n\n'+''.join(x['extracted']for x in selected)+reference+'\n'+actual)
    for name in ['proof.bend','prepare.py']:(out/name).write_bytes((HERE/name).read_bytes())
    manifest=dict(kind='phase98-exact-redirect-preservation-proof-source',targetsRun=False,
                  method=pin(__file__),receipt=pin(a.receipt),source=receipt['source'],parent=receipt['parentSource'],candidate=receipt['candidate'],
                  forwardReplayExact=True,definitions=selected,reference=dict(original=old,extracted=reference),
                  actual=dict(original=new,extracted=actual),entry=str(out/'proof.bend'),
                  outputs=[pin(path)for path in sorted(out.iterdir())],
                  publicLaws=['redirect_workers_preserves'],supportLemmas=['redirect_worker_choice','redirect_list_cons'],
                  transformation='Actual helper bodies and datatypes, with unsafe annotations removed; original redirect function and self-call renamed together. nc_ctor_codes original law-style String signature is combined with its def header reversibly; its body is unchanged and its ordinary function signature is not counted as a theorem.',
                  boundary='Universal complete worker-list equality for arbitrary typed workers, owner and root indices. No proof of generated C ownership, evaluation cost or unsafe surrounding planning routes.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(dict(entry=manifest['entry'],targetsRun=False,publicLaws=1,supportLemmas=2)))


if __name__=='__main__':main()
