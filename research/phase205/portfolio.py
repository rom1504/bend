"""Assemble the chosen experimental passes on an authenticated Phase204 source."""
import argparse, importlib.util, hashlib, json, subprocess, sys
from pathlib import Path
R=Path(__file__).resolve().parent
def module(path):
    spec=importlib.util.spec_from_file_location(path.parent.name,path)
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
def main():
    p=argparse.ArgumentParser()
    p.add_argument('out',type=Path);p.add_argument('--tree',action='store_true');p.add_argument('--zero',action='store_true')
    p.add_argument('--unfold',action='store_true');p.add_argument('--scalar',action='store_true');p.add_argument('--parent',type=Path);p.add_argument('--onepass',action='store_true')
    a=p.parse_args()
    subprocess.run([sys.executable,'-B',str(R/'hoist/prepare.py'),str(a.out),*([str(a.parent)] if a.parent else [])],check=True)
    path=a.out/'compiler.bend';s=path.read_text();e=json.loads((R/'hoist/exports.json').read_text())
    if a.onepass:s=module(R/'onepass/wire.py').apply(s)
    if a.unfold:
        s=module(R/'native-unfold/prepare.py').apply(s,scalar=a.scalar)
        e['exports'].extend(['p205u_attempt','p205u_pick','p205u_decls'])
    if a.tree:
        s=module(R/'tree/wire.py').apply(s)
        s+='\n'+(R/'tree/probe.bend').read_text()
        e['exports'].append('p205t_probe')
    if a.zero:s=module(R/"zero/wire.py").apply(s)
    path.write_text(s);(a.out/'exports.json').write_text(json.dumps(e,indent=2)+'\n')
    print(hashlib.sha256(s.encode()).hexdigest())
if __name__=='__main__':main()
