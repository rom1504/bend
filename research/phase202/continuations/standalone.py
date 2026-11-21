"""Prepare exact old/new selector closures for identical 128-function ELF output."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
from prepare import apply,BASE,HERE,ROOT
sys.dont_write_bytecode=True
spec=importlib.util.spec_from_file_location('elf_slice',ROOT/'research/phase201/elf/standalone.py');previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)

def run(out):
    out.mkdir(parents=True,exist_ok=False);base=BASE.read_bytes();new=apply(base);h=(HERE/'screen.bend').read_bytes();report={}
    for role,src in [('old',base),('new',new)]:
        data,n=previous.slice_source(src,h);p=out/(role+'.bend');p.write_bytes(data);report[role]={'bytes':len(data),'declarations':n,'standalone':{'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)},'parent':hashlib.sha256(src).hexdigest()}
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);run(p.parse_args().out)
