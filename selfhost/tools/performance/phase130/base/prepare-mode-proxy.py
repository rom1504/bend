"""Exact integrated decoder extraction; no target execution or semantic lowering."""
import argparse
import importlib.util
import json
from pathlib import Path
S=importlib.util.spec_from_file_location('proxy130',Path(__file__).with_name('prepare-proxy-v2.py'))
P=importlib.util.module_from_spec(S);S.loader.exec_module(P)

def main():
 ap=argparse.ArgumentParser(description=__doc__)
 ap.add_argument('--api-report',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
 out=a.out.resolve();assert not out.exists() and out.is_relative_to(P.ROOT/'selfhost/build/phase130')
 api=json.loads(a.api_report.read_text());assert api['complete'] and api['checked'] and api['status']==0
 source=Path(next(x for x in api['command'] if x.endswith('.bend')));sourcepin=P.pin(source);assert sourcepin in api['inputs']
 previous=P.ROOT/'selfhost/build/phase130/base-proxy02/manifest.json';pm=json.loads(previous.read_text());assert pm['complete']
 definitions=P.blocks(source.read_text());names=pm['variants']['decimal']['copiedDeclarations']
 mode=Path(__file__).with_name('mode-cursor-v02.bend');helpers=P.blocks(mode.read_text())
 assert all(P.norm(definitions[n])==P.norm(d) for n,d in helpers.items())
 additions=sorted(set(helpers)-set(names));assert all(n.startswith('p130m_') for n in additions)
 wrapper=Path(__file__).with_name('native-main.bend');text='import Base\n\n'+'\n'.join(definitions[n] for n in names+additions)+'\n'+wrapper.read_text()
 out.mkdir(parents=True);(out/'main.bend').write_text(text)
 r=dict(complete=True,checked=False,targetsRun=False,source=P.pin(out/'main.bend'),inputs=[P.pin(__file__),P.pin(S.origin),P.pin(a.api_report),sourcepin,api['api'],P.pin(previous),P.pin(mode),P.pin(wrapper)],copiedDeclarations=names+additions,scope='Exact integrated decoder extraction only; new source must be independently checked and emitted.')
 for row in r['inputs']:assert P.pin(row['file'])==row
 (out/'manifest.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r['source']))
if __name__=='__main__':main()
