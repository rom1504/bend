"""Confirm each authored worker's private clone reverses to its exact pinned Base body."""
import argparse
from hashlib import sha256
import json
from pathlib import Path
import re

from pivot import ARGS, BASE, CALL, SCOPES, TYPES
from prototype import copy_body, pin


def definitions(text):
    return {m[1]: m[0].rstrip() for m in re.finditer(r'^def ([\w.]+)\(.*?(?=\n\n|\Z)',text,re.M|re.S)}


def main(manifest):
    data=json.loads(manifest.read_text())
    base=BASE.read_text()
    assert pin(BASE)==data['base']
    report={'manifestSha256':sha256(manifest.read_bytes()).hexdigest(),'cases':{}}
    for name,row in data['cases'].items():
        report['cases'][name]={}
        for role,source in row['roles'].items():
            path=Path(source['file']);assert pin(path)==source
            text=path.read_text()
            declarations=definitions(text)
            known=set()
            for nm,block in declarations.items():
                known.add(nm)
                for ref in re.findall(r'\b((?:kw|kp)\.[\w.]+)\(',block):
                    assert ref in known,(nm,ref)
            checked=0
            if role in ('cached','clone'):
                for nm in SCOPES:
                    cloned=declarations['kw.'+nm]
                    if role=='cached':
                        cloned=cloned.replace('def kw.'+nm+'('+TYPES,'def Map.'+nm+'(',1)
                        cloned=cloned.replace('kw.bit('+ARGS,'Map.bit(')
                        for target in SCOPES:
                            cloned=cloned.replace('kw.'+target+'('+ARGS,'Map.'+target+'(')
                    else:
                        cloned=cloned.replace('def kw.'+nm+'(','def Map.'+nm+'(',1)
                        for target in SCOPES:
                            cloned=cloned.replace('kw.'+target+'(','Map.'+target+'(')
                    assert cloned==copy_body(base,nm),(name,role,nm)
                    checked+=1
            report['cases'][name][role]={'privateForwardReferences':0,'exactReversedBodies':checked}
    print(json.dumps(report,indent=2))


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('manifest',type=Path);main(p.parse_args().manifest)
