"""Reconcile the generated-program and cold-build lines from their exact common source."""
import hashlib,subprocess,sys
from pathlib import Path
base=Path('selfhost/build')
def pinned(rel,sha):
    p=base/rel
    assert hashlib.sha256(p.read_bytes()).hexdigest()==sha,rel
    return p
cold=pinned('phase204/cont02/compiler.bend','1983fed06b9a59067b9cbf8c76054a29188dbce2c417ff8f05b52fa2a54980df')
common=pinned('phase198/progress-portfolio01/compiler.bend','72061fa57c75993b59eaf42e18c6b923eebea640c352d0f7b9cd1d27ce7be91d')
speed=pinned('phase200/p200-candidate-source01/compiler.bend','c8b1b8a30d08e15e37d92cd6ed65ccc33b9bff484957e21ebeb903069ef106d7')
data=subprocess.run(['git','merge-file','-p',cold,common,speed],stdout=subprocess.PIPE,check=True).stdout
assert hashlib.sha256(data).hexdigest()=='4bf2e99f71d1dc771e083a9533f880f0df72c16662bbe340cfe5d0ecffacb496'
out=Path(sys.argv[1]);out.mkdir(parents=True,exist_ok=False);(out/'compiler.bend').write_bytes(data)
