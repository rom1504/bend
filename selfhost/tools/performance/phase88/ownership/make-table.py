#!/usr/bin/env python3
"""Offline: bind bounded ownership unwind rows to one existing ELF image."""
import argparse, hashlib, json, re, subprocess
from pathlib import Path

NAMES = ('term_drop', 'span_fade', 'rfc_wrap')
def command(*args):
    return subprocess.check_output(args, text=True)
def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args(); binary=a.binary.resolve(); out=a.out.resolve()
    out.mkdir(parents=True,exist_ok=False)
    symbols={}
    for line in command('nm','-n','-S','--defined-only',str(binary)).splitlines():
        fields=line.split()
        if len(fields)==4 and fields[3] in (*NAMES,'io_now_run'):
            symbols[fields[3]]=(int(fields[0],16),int(fields[1],16))
    assert set(symbols)==set((*NAMES,'io_now_run')),symbols
    wanted={symbols[name][0]:name for name in NAMES}; allrows=[]; current=None; columns=None; rows=[]; end=0
    def finish():
        if current is None: return
        assert rows and rows[0][0]==symbols[current][0],(current,'missing entry CFI')
        for i,(pc,cfa,ra) in enumerate(rows):
            stop=rows[i+1][0] if i+1<len(rows) else end
            assert pc<stop<=symbols[current][0]+symbols[current][1]
            allrows.append(dict(start=pc,end=stop,cfa=cfa,ra=ra,function=current))
    for line in command('readelf','-W','--debug-dump=frames-interp',str(binary)).splitlines():
        fde=re.search(r'FDE .*pc=([0-9a-f]+)\.\.([0-9a-f]+)',line)
        if fde:
            finish(); start,end=(int(x,16) for x in fde.groups());current=wanted.get(start);columns=None;rows=[];continue
        if re.search(r'\bCIE\b',line):
            finish();current=None;continue
        if current is None: continue
        fields=line.split()
        if fields and fields[0]=='LOC': columns=fields;continue
        if not fields or not re.fullmatch(r'[0-9a-f]{8,16}',fields[0]): continue
        assert columns and len(fields)==len(columns),(current,line,columns)
        row=dict(zip(columns,fields));cfa=re.fullmatch(r'rsp([+-]\d+)',row['CFA']);ra=re.fullmatch(r'c([+-]\d+)',row['ra'])
        assert cfa and ra,(current,'unsupported CFI; fail closed',row)
        rows.append((int(row['LOC'],16),int(cfa[1]),int(ra[1])))
    finish();allrows.sort(key=lambda x:x['start'])
    assert {r['function'] for r in allrows}==set(NAMES)
    header=['/* Generated from this exact ELF; do not hand-edit. */',f'#define P88_BINARY_SHA "{sha(binary)}"',
        f'#define P88_NOW_START UINTPTR_C(0x{symbols["io_now_run"][0]:x})',
        f'#define P88_NOW_END UINTPTR_C(0x{sum(symbols["io_now_run"]):x})',
        'typedef struct { uintptr_t start, end; intptr_t cfa, ra; } P88Unwind;',
        'static const P88Unwind p88_unwind[] = {']
    header += [f'  {{0x{r["start"]:x}, 0x{r["end"]:x}, {r["cfa"]}, {r["ra"]}}},' for r in allrows]
    header += ['};','']
    # UINTPTR_C is not defined by every C library; use explicit uintptr_t casts.
    h='\n'.join(header).replace('UINTPTR_C(', '((uintptr_t)')
    (out/'unwind-table.h').write_text(h)
    report=dict(schema='phase88-ownership-unwind-v1',binary=str(binary),binary_sha256=sha(binary),symbols=symbols,rows=allrows,
        limitations=['Only rsp-relative CFI and CFA-relative return addresses accepted.','Physical runtime frames only; musttail-eliminated Bend frames cannot be recovered.'],
        header_sha256=sha(out/'unwind-table.h'),generator_sha256=sha(__file__))
    (out/'table.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(binary_sha256=report['binary_sha256'],rows=len(allrows),out=str(out))))
if __name__=='__main__': main()
