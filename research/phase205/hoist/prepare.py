import sys,hashlib
from pathlib import Path
here=Path(__file__).resolve().parent
p=Path(sys.argv[2]) if len(sys.argv)>2 else Path('selfhost/build/phase204/cont02/compiler.bend')
s=p.read_text()
assert hashlib.sha256(s.encode()).hexdigest()in {'1983fed06b9a59067b9cbf8c76054a29188dbce2c417ff8f05b52fa2a54980df','4bf2e99f71d1dc771e083a9533f880f0df72c16662bbe340cfe5d0ecffacb496'}
a='@unsafe\ndef p86_plan_annotated('
b='u => P86PlanReady{nr_prepare_annotated(context, annotated), verdict},'
assert s.count(a)==s.count(b)==1
s=s.replace(a,(here/'distribute.bend').read_text()+'\n'+(here/'equations.bend').read_text()+'\n'+a).replace(b,'u => p205_ready(context,stops,verdict,annotated,p205_decls(context,annotated,missing())),')
out=Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=False)
(out/'compiler.bend').write_text(s)
