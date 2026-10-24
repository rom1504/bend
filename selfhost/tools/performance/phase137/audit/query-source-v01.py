#!/usr/bin/env python3
"""Audit fixture extraction and the exact scalar-composition delta; no targets."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5]
METHOD=ROOT/'selfhost/tools/performance/phase131/prepare.py'
spec=importlib.util.spec_from_file_location('blocks',METHOD)
C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
SUBS={
 'lookup':[('p88_string_eq(dk(d), "BookCache")','p137q_kind_eq(d, "BookCache")'),
           ('p88_string_eq(dn(d), name)','p137q_name_eq(d, name)')],
 'f_find':[('f_eq(name, dn(d))','p137q_key_eq(name, d)')],
 'nc_ctor_owned':[('p88_string_eq(dk(d), "ADT")','p137q_kind_eq(d, "ADT")'),
                  ('p88_string_eq(dk(lookup(dc(d), name)), "Ctr")','p137q_kind_eq(lookup(dc(d), name), "Ctr")')],
 'p137q_record_query':[('  p88_string_eq(p137q_label(record),key)',
                      '  match record:\n    case P137QRecord{label,other,numbers,labels,payload,serial,marker,children,tail}: p88_string_eq(label,key)')],
}

def main():
 ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--manifest',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
 out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'implementation/phase137/audit')
 r=json.loads(a.manifest.read_text());assert r['complete'] and r['source']['sha256']=='a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57'
 inputs=[C.pin(__file__),C.pin(METHOD),C.pin(a.manifest),r['source'],r['prefix'],r['expected'],*r['inputs']]
 parent=C.blocks(Path(r['source']['file']).read_text(),combine=True)
 prefix=C.blocks(Path(r['prefix']['file']).read_text(),combine=True)
 assert set(prefix)==set(r['exactDeclarations']) and len(prefix)==43
 assert all(C.norm(prefix[n])==C.norm(parent[n]) for n in prefix)
 rows=[]
 for family in ['queries','record']:
  original=next(x for x in r['cases'] if x['family']==family and x['composition']=='original')
  fused=next(x for x in r['cases'] if x['family']==family and x['composition']=='fused')
  inputs.extend([original['source'],fused['source']])
  old=C.blocks(Path(original['source']['file']).read_text(),combine=True);new=C.blocks(Path(fused['source']['file']).read_text(),combine=True)
  assert all(C.norm(old[n])==C.norm(parent[n]) for n in prefix)
  assert set(new)-set(old)=={'p137q_name_eq','p137q_key_eq','p137q_kind_eq'}
  assert not set(old)-set(new)
  changed=sorted(n for n in old if C.norm(old[n])!=C.norm(new[n]));assert changed==sorted(SUBS)
  for name,replacements in SUBS.items():
   expected=old[name]
   for before,after in replacements:
    assert expected.count(before)==1;expected=expected.replace(before,after)
   assert C.norm(expected)==C.norm(new[name]),name
  rows.append(dict(family=family,original=original['source'],fused=fused['source'],changedDeclarations=changed,originalSemantics='43 declarations exact; five compiler expressions preserve equality operand order; unrelated record observer is a separate sixth expression.'))
 for item in inputs:assert C.pin(item['file'])==item,item['file']
 result=dict(kind='phase137-independent-query-source-audit',complete=True,targetsRun=False,inputs=inputs,rows=rows,
  scope='Exact source extraction/delta audit. Predicates and23 expected ordinary controls received independent source review; this is not a general equivalence proof or a checked/native execution result. Actual reader admission/callsite reachability remain separate gates.')
 out.parent.mkdir(parents=True,exist_ok=True);out.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,report=C.pin(out))))

if __name__=='__main__':main()
