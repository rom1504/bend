"""Verify source, whole-source check and optional acquired N1 bindings before handoff."""
import argparse,hashlib,json
from pathlib import Path

def pin(path):
    p=Path(path).resolve()
    return {'file':str(p),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}

def verify(s,c,image=None):
    output=Path(s)
    composition=json.loads((output/'report.json').read_bytes())
    source=pin(output/'compiler.bend')
    assert composition['source']==source and composition['composition']['selectedSource']=={k:source[k] for k in ('bytes','sha256')}
    checked=json.loads(Path(c).read_bytes())
    assert checked['complete'] and checked['checked'] and checked['typeAccepted'] and checked['unresolvedHoles']==0 and checked['source']==source
    assert composition['manifest'] in checked['inputs']
    if image:
        n1=json.loads(Path(image).read_bytes());b=n1['imageBinding']
        assert n1['complete'] and b['complete'] and not n1['changedInputs']
        assert n1['binary']==pin(n1['binary']['file'])==b['image']
        assert b['sourceIdentity']==source and b['host']=='native' and b['stage']=='N1' and b['targets']==['x86'] and b['protocol']=='native-x86-source-v1'
    print(source['sha256'], 'whole check and native N1 binding verified' if image else 'whole check verified')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--source-root',required=True);p.add_argument('--check',required=True);p.add_argument('--image')
    a=p.parse_args();verify(a.source_root,a.check,a.image)
