"""Freeze actual-query scalar-composition ceilings; no target execution."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
spec=importlib.util.spec_from_file_location('C',ROOT/'selfhost/tools/performance/phase131/prepare.py')
C=importlib.util.module_from_spec(spec);spec.loader.exec_module(C)
SOURCE=ROOT/'selfhost/build/phase134/verify-selected-source01/compiler.bend'
SHA='a00019246b5181b288ab4d3e09e616bd41415fe6381e89a96185c05efa19fb57'

def put(path,text):
    if path.exists(): assert path.read_text()==text, 'Changed frozen output '+str(path)
    else: path.write_text(text)
    return C.pin(path)

def main():
    assert C.pin(SOURCE)['sha256']==SHA
    whole=SOURCE.read_text();blocks=C.blocks(whole,combine=True)
    needed=set('KTerm KDef dn dk da db dc lookup nc_ctor_owned f_find p88_string_eq book_cached'.split())
    pending=list(needed)
    while pending:
        name=pending.pop()
        text=re.sub(r'"(?:[^"\\]|\\.)*"|#[^\n]*','',blocks[name])
        deps=set(re.findall(r'\b[A-Za-z_][A-Za-z_0-9.]*',text))&blocks.keys()
        for dep in deps-needed: needed.add(dep);pending.append(dep)
    assert len(needed)==43
    prefix='import Base\n\n'+'\n'.join(body for name,body in blocks.items() if name in needed)
    prefixpin=put(HERE/'compiler-prefix-v01.bend',prefix)
    # Names are source declaration identities; record values below are constructed,
    # not presented as the compiler's complete checked book or measured distribution.
    names=[name for name,body in blocks.items() if body.lstrip().startswith(('@unsafe\ndef ','def ')) and name!='p111_emit_admitted'][:63]
    names.append('p111_emit_admitted');assert len(set(names))==64
    namebody='@unsafe\ndef p137q_names() -> List<&2,String>:\n  ['+', '.join(json.dumps(x)for x in names)+']\n\n'
    work=(HERE/'workload-v01.bend').read_text()+ '\n'+namebody
    original=prefix+'\n'+work
    changed=dict(blocks)
    substitutions={
      'lookup': [('p88_string_eq(dk(d), "BookCache")','p137q_kind_eq(d, "BookCache")'),('p88_string_eq(dn(d), name)','p137q_name_eq(d, name)')],
      'f_find': [('f_eq(name, dn(d))','p137q_key_eq(name, d)')],
      'nc_ctor_owned': [('p88_string_eq(dk(d), "ADT")','p137q_kind_eq(d, "ADT")'),('p88_string_eq(dk(lookup(dc(d), name)), "Ctr")','p137q_kind_eq(lookup(dc(d), name), "Ctr")')],
    }
    for name,replacements in substitutions.items():
        for old,new in replacements:
            assert changed[name].count(old)==1,(name,old)
            changed[name]=changed[name].replace(old,new)
    fused='import Base\n\n'+'\n'.join(changed[name] for name in blocks if name in needed)+'\n'+(HERE/'predicates-v01.bend').read_text()+'\n'+work
    old='  p88_string_eq(p137q_label(record),key)'
    new='''  match record:
    case P137QRecord{label,other,numbers,labels,payload,serial,marker,children,tail}: p88_string_eq(label,key)'''
    assert fused.count(old)==1;fused=fused.replace(old,new)
    expected='1\n'*23
    expectedpin=put(HERE/'expected-v01.stdout',expected)
    expectedjson=put(HERE/'expected-v01.json',json.dumps(dict(status=0,stdout=expected,stderr=''),indent=2)+'\n')
    rows=[]
    for family in ['queries','record']:
        for composition,source in [('original',original),('fused',fused)]:
            if family=='record':
                old='  p137q_queries(book,key)'
                new='  U32.add(Bool.to_u32(p137q_record_query(record,key)),Bool.to_u32(p137q_record_query(record,":absent:")))'
                assert source.count(old)==1;source=source.replace(old,new)
            pin=put(HERE/(family+'-'+composition+'-v01.bend'),source)
            rows.append(dict(name=family+'-'+composition,source=pin,expected=expectedjson,expectedStdoutEvidence=expectedjson,
                family=family,composition=composition,timed=dict(argv=['REPEATS'],once=127 if family=='queries' else 1,
                    stdout=['once','(once * repeats) modulo 2^32','elapsed milliseconds'],defaultRepeats=10000)))
    report=dict(complete=True,targetsRun=False,source= C.pin(SOURCE),prefix=prefixpin,exactDeclarations=sorted(needed),
        changedDeclarations=list(substitutions)+['p137q_record_query'],names=names,cases=rows,expected=expectedpin,
        inputs=[C.pin(__file__),C.pin(C.__file__),C.pin(HERE/'workload-v01.bend'),C.pin(HERE/'predicates-v01.bend')],
        sourceBridge='Original43 declarations equal selected Phase134 after comment/whitespace normalization. Fused source changes only5 named projection+equality expressions in3 actual compiler declarations, plus unrelated observer.',
        scope='Constructed65-row book using64 actual compiler declaration names, not an actual checked compiler book or dynamic distribution. Same raw scans and existing Patricia BookCache implementation. Two source compositions crossed with independently fixed baseline/width16 producer. No runtime/verifier changes and no performance claim until native evidence.',
        oracle='23 independently true predicates: exact missing conventions, first duplicate wins, BookCache before name dispatch, false-owned first ADT, nonCtr child shadow, cached child, ignored nonADT, Unicode, index variants, retained opaque/aliased fields and unrelated9-field record. Timed query result63+63+1=127; missing paths contribute0. Record hit+miss=1. Each iteration repeats identical held immutable inputs; setup/reclamation outside IO.now, whole process separately charged.')
    put(HERE/'cases-v01.json',json.dumps(dict(complete=True,cases=rows),indent=2)+'\n')
    put(HERE/'manifest-v01.json',json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,cases=len(rows),declarations=len(needed),bytes=rows[0]['source']['bytes'])))
if __name__=='__main__': main()
