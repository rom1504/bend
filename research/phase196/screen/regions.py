"""Find straight-line regions in rendered Bend assembly with sampled native PCs."""
from collections import defaultdict
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT / 'selfhost/build'
CASES = {
    'tree-bitonic': ('phase195/ctor-gate-emit01/off', 'profile-tree-bst01'),
    'coverage-bst-64': ('phase195/ctor-gate-emit01/off', 'profile-tree-bst01'),
    'editdist': ('phase194/final-dev-emit01', 'profile-priority02'),
    'variation-ray-active-64-2440': ('phase194/final-dev-emit01', 'profile-priority02'),
    'lexer': ('phase194/final-dev-emit01', 'profile-remaining02'),
}


def read(path):
    return json.loads(Path(path).read_text())


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def disassembly(binary):
    text = subprocess.check_output(['objdump', '-dw', '--no-show-raw-insn', binary], text=True)
    functions = {}
    insns = []
    for line in text.splitlines():
        header = re.fullmatch(r'[0-9a-f]+ <(.+)>:', line)
        if header:
            insns = []
            functions[header[1]] = insns
        row = re.match(r'^\s*([0-9a-f]+):\s+(.+)', line)
        if row:
            insns.append((int(row[1], 16), row[2].strip()))
    return functions


def canonical_op(instruction):
    name = instruction.split()[0]
    aliases = {'sal': 'shl', 'je': 'jz', 'jne': 'jnz', 'jb': 'jc', 'jae': 'jnb',
               'cmove': 'cmovz', 'cmovne': 'cmovnz'}
    suffixable = ('mov', 'movabs', 'cmp', 'test', 'xor', 'and', 'or', 'add',
                  'sub', 'mul', 'imul', 'div', 'neg', 'lea', 'shr', 'shl', 'sar',
                  'sal', 'push', 'pop', 'ret', 'call', 'jmp', 'cvtsi2ss', 'cvttss2si',
                  'cmove', 'cmovne', 'cmovb', 'cmova', 'cmovbe', 'cmovae',
                  'cmovl', 'cmovg', 'cmovle', 'cmovge')
    if name[-1] in 'qlwb' and name[:-1] in suffixable:
        name = name[:-1]
    return aliases.get(name, name)


def pretty(sym):
    return re.sub(r'(?:\d+_){2,}',lambda m: ''.join(chr(int(c)) for c in m[0].strip('_').split('_')),sym)


@lru_cache(None)
def regions(case):
    emitted, prof = CASES[case]
    source = BUILD/emitted/case/'program.s'
    report = read(BUILD/emitted/'report.json')
    row = next(r for r in report['rows'] if r['id']==case)
    assert digest(source)==row['assembly']['sha256']
    files = sorted((BUILD/'phase195'/prof).glob('*sample-*-'+case+'-candidate-candidate/analysis.json'))
    assert len(files)==2
    ticks = defaultdict(int)
    total = 0
    for path in files:
        data = read(path)
        binary = Path(data['header']['exe'])
        assert digest(binary)==data['identities']['binary']['sha256']
        assert digest(binary.with_suffix('.o'))==row['product']['sha256']
        period = data['header']['period_us']
        for v in data['pcs']:
            weight = v['samples']*period
            total += weight
            if v['mapping']==str(binary):
                ticks[int(v['pc'],16)]+=weight
    listing = disassembly(binary)
    lines = source.read_text().splitlines()
    sym = None
    blocks = []
    for i,line in enumerate(lines):
        if line.startswith('.type ') and line.endswith(', @function'):
            sym = line.split()[1].rstrip(',')
            start = i+2
        if sym and line.startswith('.size '+sym+','):
            records = [(k,lines[k].strip()) for k in range(start,i) if lines[k].startswith('  ')]
            mach = listing.get(sym,[])
            if len(mach) >= len(records) and all(canonical_op(a)==canonical_op(b) for (_,a),(_,b) in zip(records,mach)):
                block = []
                for pos,((k,ins),(addr,_)) in enumerate(zip(records,mach)):
                    op = ins.split()[0]
                    boundary = (block and k!=block[-1][0]+1)
                    control = op.startswith(('j','call','ret','leave','push','pop'))
                    if boundary or control:
                        if block:
                            blocks.append((sym,block))
                        block = []
                    if not control:
                        block.append((k,ins,addr,ticks[addr]/total))
                if block:
                    blocks.append((sym,block))
            sym = None
    return source, binary, files, blocks


if __name__=='__main__':
    for case in CASES:
        source, binary, files, blocks=regions(case)
        print(case,len(blocks))
        for sym,block in sorted(blocks,key=lambda r:sum(v[3] for v in r[1]),reverse=True)[:7]:
            print(pretty(sym),block[0][0]+1,round(sum(v[3] for v in block)*100,1),len(block),'; '.join(v[1] for v in block[:6]))
