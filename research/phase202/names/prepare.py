"""Offline neutral-string observer overlay; no compiler invocation."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent

def apply(source):
    start=source.index('def p88_string_eq_go(')
    end=source.index('def p98_eq_finish(',start)
    old=source[start:end].strip()
    assert old.count('p88_string_eq_go(')==2 and 'case SCon{h1, t1} SCon{h2, t2} False{}: False{}' in old
    assert 'def p202n_' not in source
    reference=old.replace('p88_string_eq_go','p202n_original')
    candidate=(HERE/'neutral.bend').read_text().strip()
    return source[:start]+reference+'\n\n'+candidate+'\n\n'+source[end:]

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();old=a.source.read_bytes();new=apply(old.decode()).encode()
    with a.out.open('xb') as f:f.write(new)
    print(json.dumps(dict(parentSHA256=hashlib.sha256(old).hexdigest(),candidateSHA256=hashlib.sha256(new).hexdigest(),bytes=len(new))))
