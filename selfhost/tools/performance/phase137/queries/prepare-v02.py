"""Freeze key-first interfaces and fixed-kind scalar observers; no targets."""
import importlib.util
import json
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('p137q',HERE/'prepare-v01.py')
P=importlib.util.module_from_spec(spec);spec.loader.exec_module(P)

def main():
    old=json.loads((HERE/'manifest-v01.json').read_text());cases=[]
    for row in old['cases']:
        if row['composition']!='fused': continue
        source=Path(row['source']['file']).read_text()
        assert P.C.pin(row['source']['file'])==row['source']
        changes=[('def p137q_name_eq(record: KDef, key: String)','def p137q_name_eq(key: String, record: KDef)'),
            ('p137q_name_eq(d, name)','p137q_name_eq(name, d)'),
            ('def p137q_record_query(record: P137QRecord, key: String)','def p137q_record_query(key: String, record: P137QRecord)'),
            ('p137q_record_query(record,key)','p137q_record_query(key,record)'),
            ('p137q_record_query(record,":absent:")','p137q_record_query(":absent:",record)'),
            ('p137q_record_query(record,"λ🌍")','p137q_record_query("λ🌍",record)'),
            ('p137q_record_query(record,"λ")','p137q_record_query("λ",record)'),
            ('p137q_kind_eq(d, "BookCache")','p137q_is_cache(d)'),
            ('p137q_kind_eq(d, "ADT")','p137q_is_adt(d)'),
            ('p137q_kind_eq(lookup(dc(d), name), "Ctr")','p137q_is_ctr(lookup(dc(d), name))')]
        used=[]
        for before,after in changes:
            count=source.count(before)
            if count:
                assert count==1,(before,count)
                source=source.replace(before,after);used.append(dict(before=before,after=after))
            else: assert row['family']=='queries' and before in ['p137q_record_query(record,key)','p137q_record_query(record,":absent:")']
        extra=''
        for name,kind in [('cache','BookCache'),('adt','ADT'),('ctr','Ctr')]:
            extra+='''\n@unsafe
def p137q_is_'''+name+'''(record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,"'''+kind+'''")
    case KIndexLeaf{hash,bucket}: False{}
    case KIndexNode{hash,mask,left,right}: False{}
'''
        source+='\n# Exact specialization of the three observed constant String arguments.\n'+extra
        frozen=P.put(HERE/(row['family']+'-fused-v02.bend'),source)
        cases.append(dict(row,name=row['family']+'-fused-v02',source=frozen,substitutions=used))
    report=dict(complete=True,targetsRun=False,cases=cases,inputs=[P.C.pin(__file__),P.C.pin(HERE/'prepare-v01.py'),P.C.pin(HERE/'manifest-v01.json')],
        scope='Additional source-only composition ceiling, not a producer policy. Kind observers preserve exact field-first comparison but constant non-KDef results remove irrelevant IndexLeaf/IndexNode String construction. Name/record observer argument order changes only; comparison operand order remains field-first. Actuals at changed callsites are pure local variables/literals, so no effect order is changed. Original v01 source/oracle remain frozen; no performance claim.')
    P.put(HERE/'cases-v02.json',json.dumps(dict(complete=True,cases=cases),indent=2)+'\n')
    P.put(HERE/'manifest-v02.json',json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(complete=True,cases=len(cases))))
if __name__=='__main__':main()
