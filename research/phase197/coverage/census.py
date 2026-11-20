"""Count two Phase196 diagnostic instruction shapes in qualified N1 outputs."""
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / 'selfhost/build/phase195/native45-01/report.json'
OUTPUT = Path(__file__).with_name('qualified-shapes.json')
MINIMUM = re.compile(r'mov (%\w+),%r10\nmov (%\w+),%r11\ncmp %r11,%r10\nmov \1,%rax\nmov \2,%r11\ncmovb %rax,%r11\n')
DECREMENT = re.compile(r'mov (%\w+),%r10\nsub \$0x1,%r10\n')


def pin(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def scan(binary):
    dis = subprocess.check_output(['objdump','-dw','--no-show-raw-insn',binary],text=True)
    # Match only Bend-emitted bodies. C runtime helpers have different lowering.
    result = {}
    for raw_name,body in re.findall(r'^[0-9a-f]+ <([^>]+)>:\n(.*?)(?=\n\n|\Z)',dis,re.M|re.S):
        if '_FID_' not in raw_name:
            continue
        instructions='\n'.join(' '.join(ins.split()) for ins in
                    re.findall(r'^\s*[0-9a-f]+:\s+(.+)$',body,re.M))+'\n'
        counts={k:len(list(rewrite.finditer(instructions))) for k,rewrite in [('min',MINIMUM),('dec',DECREMENT)]}
        if any(counts.values()):
            name=re.sub(r'(?:\d+_){2,}', lambda m: ''.join(chr(int(x)) for x in m[0].strip('_').split('_')),raw_name)
            result[name]=counts
    return result


def main():
    built=json.loads(SOURCE.read_text())
    assert built['complete'] and not built['changedInputs'] and len(built['rows'])==45
    rows=[]
    for row in built['rows']:
        binary=Path(row['artifact']['file'])
        assert row['complete'] and pin(binary)==row['artifact']['sha256']
        functions=scan(binary)
        total=Counter()
        for counts in functions.values(): total.update(counts)
        rows.append(dict(case=row['id'],elfSha=pin(binary),min=total['min'],dec=total['dec'],functions=functions))
    report=dict(source=str(SOURCE.relative_to(ROOT)),sourceSha=pin(SOURCE),methodSha=pin(Path(__file__)),rows=rows,
        scope='Static shapes in generated symbol bodies. Counts do not establish liveness, legality, dynamic execution, speed or coverage of wider compiler rules.')
    OUTPUT.write_text(json.dumps(report,indent=2)+'\n')
    for key in ('min','dec'):
        print(key,sum(r[key]>0 for r in rows),'programs',sum(r[key] for r in rows),'sites')
        print([(r['case'],r[key]) for r in rows if r[key]>0][:15])


if __name__=='__main__':
    main()
