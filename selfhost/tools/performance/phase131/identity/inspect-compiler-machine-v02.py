"""Disassemble selected compiler functions without executing the compiler."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[5]

def pin(p):
    p=p.resolve();b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--qbe-inspection',type=Path,required=True)
    p.add_argument('--baseline-build',type=Path,required=True);p.add_argument('--candidate-build',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    q=json.loads(a.qbe_inspection.read_text());assert q['complete'] and len(q['rows'])==2
    out=a.out.resolve();assert not out.exists() and out.is_relative_to(ROOT/'selfhost/build/phase131');out.mkdir()
    objdump=Path(shutil.which('objdump')).resolve()
    report=dict(complete=False,targetsRun=False,inputs=[pin(Path(__file__)),pin(a.qbe_inspection),pin(objdump)],rows=[],
        scope='Read-only objdump of completed image builds pinned to inspected QBE. Machine instruction/static callsite counts are not runtime timings or allocation totals.')
    for row,build in zip(q['rows'],[a.baseline_build,a.candidate_build]):
        br=json.loads(build.read_text());assert br['complete']
        assert row['source'] in br['inputs'];assert pin(Path(row['source']['file']))==row['source']
        binary=Path(br['binary']['file']);assert pin(binary)==br['binary']
        report['inputs'].append(pin(build));entries=[]
        for fn in row['selected']:
            cmd=[str(objdump),'-d','--no-show-raw-insn','--disassemble='+fn['symbol'],str(binary)]
            text=subprocess.run(cmd,check=True,capture_output=True,text=True).stdout
            instructions=[line for line in text.splitlines() if re.match(r'^\s+[0-9a-f]+:\s+\S',line)]
            assert instructions,fn['symbol']
            dest=out/(row['label']+'-'+fn['symbol']+'.asm');dest.write_text(text)
            entries.append(dict(name=fn['name'],symbol=fn['symbol'],machineInstructions=len(instructions),
                calls=dict(Counter(re.findall(r'\bcallq?\s+[^\n]*<([^>]+)>',text))),assembly=pin(dest),command=cmd))
        report['rows'].append(dict(label=row['label'],build=pin(build),binary=br['binary'],qbe=row['source'],selected=entries))
    report['complete']=True
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')

if __name__=='__main__':main()
