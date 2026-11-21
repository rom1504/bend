"""Optional native static-spine hook; no compiler or hardware execution."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent

def once(s,a,b):
    assert s.count(a)==1,(a[:100],s.count(a));return s.replace(a,b)
def apply(s,enabled=True,scalar=False):
    if not enabled:return s
    assert 'def p205u_attempt(' not in s
    additions=(HERE/'unfold.bend').read_text()
    if scalar:additions+='\n'+(HERE/'scalar.bend').read_text()
    # Keep the original text-law helpers in their original relative order.
    anchor='@unsafe\ndef p205_checked_body('
    variant='p205v_on(book,p205u_attempt(book,input))' if scalar else 'p205u_attempt(book,input)'
    additions+='\n@unsafe\ndef p205u_variant(+book: List<&2,KDef>, +input: KTerm) -> KTerm:\n  '+variant+'\n\n'
    if scalar:
        additions+='''@unsafe
def p205u_select(+context: List<&2,KDef>, +raw: KDef) -> KDef:
  +first = p205u_attempt(context,dv(raw))
  p205u_scalar_checked(context,raw,first,p205u_check(context,raw,p205v_on(context,first)))
@unsafe
def p205u_scalar_checked(+context: List<&2,KDef>, +raw: KDef, +first: KTerm, +checked: KDef) -> KDef:
  kc(KDef,String.eq(dk(checked),"Absent"),u => p205u_check(context,raw,first),u => checked)
'''
    else:
        additions+='''@unsafe
def p205u_select(+context: List<&2,KDef>, +raw: KDef) -> KDef:
  p205u_check(context,raw,p205u_attempt(context,dv(raw)))
'''
    additions+=(HERE/'request.bend').read_text()+'\n'
    s=once(s,anchor,additions+anchor)
    if 'def p205_update(' in s:
        s=once(s,'p205_decls(context,annotated,missing())','p205u_decls(context,annotated,missing(),False{})')
    else:
        # Older list-returning integration uses the same one-pick state.
        s=once(s,'p205_decls(context,annotated)','p205u_list(context,annotated,False{})')
    return s
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--source',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--off',action='store_true');p.add_argument('--scalar',action='store_true');a=p.parse_args()
    original=a.source.read_bytes();changed=apply(original.decode(),not a.off,a.scalar).encode();a.out.mkdir(parents=True,exist_ok=False)
    (a.out/'compiler.bend').write_bytes(changed)
    (a.out/'preparation.json').write_text(json.dumps(dict(parentSHA256=hashlib.sha256(original).hexdigest(),sourceSHA256=hashlib.sha256(changed).hexdigest(),enabled=not a.off,scalar=a.scalar,bytes=len(changed),status='unchecked offline overlay'),indent=2)+'\n')
