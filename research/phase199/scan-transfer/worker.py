"""Locate the renamed transfer worker and its literal SIMD-helper call in ELF objects."""
import argparse
from hashlib import sha256
import json
from pathlib import Path
import re
import subprocess

HELPER = 'p199_rt_u32_scan4'


def name(symbol):
    return re.sub(r'(?:\d+_){2,}', lambda m: ''.join(chr(int(k)) for k in m[0][:-1].split('_')), symbol)


def inspect(path, owner="frame.segment"):
    sections = subprocess.check_output(["objdump","-h",str(path)],text=True)
    text = next(line.split() for line in sections.splitlines() if line.split()[1:2]==[".text"])
    section_vma = int(text[3],16)
    file_offset = int(text[5],16)
    artifact = path.read_bytes()
    table = subprocess.check_output(['nm','-S','--defined-only',str(path)],text=True)
    workers = []
    for line in table.splitlines():
        fields = line.split()
        if len(fields)!=4 or fields[2].lower()!='t' or not name(fields[3]).endswith('$product.'+owner):
            continue
        address,size,_,symbol = fields
        dump = subprocess.check_output(['objdump','-dr','--disassemble='+symbol,str(path)],text=True)
        # --disassemble on relocatable objects may include relocations from
        # unrelated preceding symbols. Only the actual selected range counts.
        start = int(address,16)
        end = start+int(size,16)
        sites = []
        for entry in dump.splitlines():
            m = re.match(r'^\s*([0-9a-f]+):\s+(.+)$',entry)
            if m and start<=int(m[1],16)<end and HELPER in m[2]:
                sites.append(entry.strip())
        workers.append(dict(symbol=symbol,decoded=name(symbol),address=start,bytes=end-start,
                            bodySha256=sha256(artifact[file_offset+start-section_vma:file_offset+end-section_vma]).hexdigest(),
                            helperReferences=sites))
    return dict(artifact=str(path.resolve()),sha256=sha256(artifact).hexdigest(),workers=workers)


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('path',type=Path);parser.add_argument('--owner',default='frame.segment')
    args=parser.parse_args();print(json.dumps(inspect(args.path,args.owner),indent=2))
