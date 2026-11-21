"""Join process CPU timer samples to exact private return sequences in their original ELF."""
from pathlib import Path
from collections import Counter, defaultdict
import hashlib
import json
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BUILD = ROOT / 'selfhost/build'
SCREENS = ['phase195/profile-priority02', 'phase195/profile-remaining02', 'phase195/profile-tree-bst01',
           'phase192/profile02', 'phase191/profile-capture03', 'phase191/profile-capture01','phase190/profile-capture01']
READ = re.compile(r'mov (?:0x[0-9a-f]+)?\(%r11\),%rax$')
WRITE = re.compile(r'mov %r10,(?:0x[0-9a-f]+)?\(%r11\)$')

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def audit(binary):
    result = subprocess.check_output(['objdump', '-dw', '--no-show-raw-insn', binary], text=True)
    fns = {}
    for line in result.splitlines():
        head = re.fullmatch(r'[0-9a-f]+ <(.+)>:', line)
        if head:
            fn = []
            fns[head[1]] = fn
        elif row := re.match(r'^\s*([0-9a-f]+):\s+(.+)', line):
            fn.append((int(row[1],16), ' '.join(row[2].split())))
    groups = defaultdict(set)
    targets = set()
    sites = Counter()
    for sym, fn in fns.items():
        for i, (pc, op) in enumerate(fn[:-3]):
            if not re.match(r'callq? \w+ <p113d_',op):
                continue
            if not (fn[i+1][1].startswith('lea ') and READ.fullmatch(fn[i+2][1])):
                continue
            k = i+1
            while k+2 < len(fn) and fn[k][1].startswith('lea ') and READ.fullmatch(fn[k+1][1]) and fn[k+2][1].startswith('mov %rax,'):
                groups['payload'].update(addr for addr,_ in fn[k:k+3])
                k += 3
            arity = (k-i-1)//3
            assert arity >= 2,(sym, i, fn[i:i+8])
            # Exact unmodified transfer of every delivered word to the caller's own result buffer.
            destinations = [fn[pos+2][1].split(',')[1] for pos in range(i+1,k,3)]
            if k+3*arity < len(fn) and all(
                fn[k+3*lane][1] == 'mov '+destination+',%r10'
                and fn[k+3*lane+1][1].endswith(',%r11')
                and fn[k+3*lane+2][1] == ('mov %r10,' + (hex(8*lane) if lane else '')+'(%r11)')
                for lane,destination in enumerate(destinations)) and fn[k+3*arity][1]=='xor %eax,%eax':
                sites['forward'+str(arity)]+=1
                groups['forward_payload'].update(addr for addr,_ in fn[i+1:k+3*arity])
            target = op.split('<')[1].rstrip('>')
            targets.add(target)
            sites['call'+str(arity)] += 1
            groups['caller_envelope'].add(pc)
            j = i-1
            while j>=0 and i-j<=40 and fn[j][1].split()[0] in ('lea','mov','movabs','xor','movslq'):
                groups['caller_envelope'].add(fn[j][0])
                j -= 1
    for sym in targets:
        fn = fns[sym]
        # Include normal and versioned fallback bodies. The latter forward the same out-pointer.
        for linked in (sym, sym.replace('p113d_', 'p117v_',1)):
            for i, (pc,op) in enumerate(fns.get(linked, [])):
                f = fns[linked]
                if WRITE.fullmatch(op) and f[i-1][1].endswith(',%r11') and f[i-2][1].endswith(',%r10'):
                    groups['payload'].update(addr for addr,_ in f[i-2:i+1])
                    if f[i+1][1] == 'xor %eax,%eax':
                        groups['payload'].add(f[i+1][0])
                        for addr, ins in f[i+2:i+14]:
                            groups['return_envelope'].add(addr)
                            if ins in ('ret','retq'): break
        for addr, ins in fn:
            if ins.split()[0] not in ('push','pushq','mov','sub'): break
            groups['entry_envelope'].add(addr)
    groups['outer'] = set.union(set(),*groups.values())
    return groups, sites

def main():
    out = []
    for screen in SCREENS:
        role = {'phase191/profile-capture01':'both-both','phase190/profile-capture01':'operands'}.get(screen,'candidate-candidate')
        files = sorted((BUILD/screen).glob('*sample-*-'+role+'/analysis.json'))
        assert files,screen
        by_binary = defaultdict(list)
        for path in files:
            data = json.loads(path.read_text())
            by_binary[Path(data['header']['exe'])].append((path, data))
        for binary, entries in by_binary.items():
            marks, sites = audit(binary)
            digest = sha(binary)
            totals = Counter()
            inputs = []
            for path,data in entries:
                assert digest == data['identities']['binary']['sha256']
                scores = Counter()
                for row in data['pcs']:
                    n = row['samples']
                    scores['all'] += n
                    if row['mapping'] == str(binary):
                        for key, pcs in marks.items():
                            if int(row['elf_address'],16) in pcs:
                                scores[key] += n
                assert scores['all'] == data['header']['samples']
                for key,count in scores.items():
                    totals[key] += count * data['header']['period_us']
                inputs.append(dict(file=str(path.relative_to(ROOT)), sha256=sha(path), samples=scores,
                                   period_us=data['header']['period_us'],usable=data['usable'],zero_loss=data['zeroLoss']))
            out.append(dict(binary=str(binary.relative_to(ROOT)),sha256=digest,static_sites=sites,
                            share={k: totals[k]/totals['all'] for k in marks},samples=inputs))
    print(json.dumps(out, indent=2))
if __name__ == '__main__': main()
