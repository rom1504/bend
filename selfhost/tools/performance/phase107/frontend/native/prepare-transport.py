#!/usr/bin/env python3
"""Extract exact transport and trusted escaping definitions for a small checked gate."""
import argparse
import json
import re
from pathlib import Path
from run import pin, verify

HERE = Path(__file__).resolve().parent


def blocks(text):
    starts = list(re.finditer(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',text,re.M))
    result={}
    for i,m in enumerate(starts):
        block=text[m.start():starts[i+1].start() if i+1<len(starts) else len(text)].strip()
        result.setdefault(m.group(1),[]).append(block)
    return {name:'\n\n'.join(parts) for name,parts in result.items()}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    manifest=json.loads(a.manifest.read_text())
    source=verify(manifest['selectedSource'])
    groups=[(Path(source['file']),['kc','kp_hex','kp_digit','sk_quote','sk_escape','sk_char']),
            (HERE.parents[1]/'backends/units.bend',['NxqUnit']),
            (HERE/'entry.bend',['p107_unit_json','p107_unit_items'])]
    text='import Base\n\n'+'\n\n'.join('\n\n'.join(blocks(file.read_text())[name] for name in names) for file,names in groups)+'\n'
    (out/'source.bend').write_text(text)
    report=dict(kind='phase107-native-transport-source',source=pin(out/'source.bend'),
                inputs=[dict(pin=pin(file),definitions=names) for file,names in groups],method=pin(__file__))
    (out/'inputs.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(source=str(out/'source.bend'),targetsExecuted=False)))


if __name__=='__main__':main()
