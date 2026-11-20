#!/usr/bin/env python3
"""Read-only ELF audit; writes research evidence only, never executes a target."""
import difflib, hashlib, json, pathlib, re, subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3]
OUT=ROOT/'research/phase197/minimum/machine-evidence'
OUT.mkdir(exist_ok=True)
SYMBOL='p113d_FID_36_112_114_111_100_117_99_116_46_114_111_119_'
CASES=['editdist','local-pair','variation-editdist-3-123','coverage-bst-64','coverage-bst-32','mandelbrot']
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def dis(path,symbol=None,raw=False):
    args=['objdump','-d','-M','intel']
    if not raw: args+=['--no-show-raw-insn']
    if symbol: args+=['--disassemble='+symbol]
    return subprocess.check_output(args+[str(path)],text=True)
def parse(text):
    return [(int(m[1],16),' '.join(m[2].split())) for line in text.splitlines() if (m:=re.match(r'^\s*([0-9a-f]+):\s+(.+)',line))]
report={'method':'objdump actual ELF object instructions; positive row body from final backward jump target header, then its jne target, excluding final backward jump; no target execution', 'symbol':SYMBOL,'objdump_version':subprocess.check_output(['objdump','--version'],text=True).splitlines()[0],'objects':[],'loops':[]}
bodies={}
for case in CASES:
    base=None
    for role in ['baseline','minimum','combined']:
        rel=f'selfhost/build/phase195/native45-01/{case}/machine/program.o' if role=='baseline' else f'selfhost/build/phase197/shared-emission01/{role}/{case}/program.o'
        path=ROOT/rel
        digest=sha(path)
        if role=='baseline': base=digest
        full=parse(dis(path))
        report['objects'].append({'case':case,'role':role,'path':rel,'sha256':digest,'same_as_baseline':digest==base,'instruction_count':len(full),'cmov_count':sum(t.startswith('cmov') for a,t in full)})
        if case not in CASES[:3]: continue
        text=dis(path,SYMBOL)
        raw=dis(path,SYMBOL,True)
        (OUT/f'{case}-{role}.objdump').write_text(raw)
        ins=parse(text)
        back=ins[-1]
        assert back[1].startswith('jmp '),back
        target=int(back[1].split()[1],16)
        header=next(i for i,x in enumerate(ins) if x[0]==target)
        assert ins[header][1]=='cmp rsi,0x0' and ins[header+1][1].startswith('jne ')
        start=int(ins[header+1][1].split()[1],16)
        body=[x for x in ins if start<=x[0]<back[0]]
        assert not any(t.startswith(('j','call','ret')) for a,t in body)
        bodies[case,role]=[t for a,t in body]
        (OUT/f'{case}-{role}.body.txt').write_text('\n'.join(f'{i:02d} {a:x}: {t}' for i,(a,t) in enumerate(body))+'\n')
        report['loops'].append({'case':case,'role':role,'body_start':hex(start),'backedge':hex(back[0]),'header':hex(target),'instruction_count_excluding_backedge':len(body),'byte_count_excluding_backedge':back[0]-start,'cmovs':[{'address':hex(a),'instruction':t} for a,t in body if t.startswith('cmov')]})
for case in CASES[:3]:
    for role in ['minimum','combined']:
        diff=''.join(difflib.unified_diff([x+'\n' for x in bodies[case,'baseline']],[x+'\n' for x in bodies[case,role]],fromfile='baseline',tofile=role))
        (OUT/f'{case}-{role}.diff').write_text(diff)
    assert len(bodies[case,'baseline'])-len(bodies[case,'minimum'])==8
    assert len(bodies[case,'baseline'])-len(bodies[case,'combined'])==9
    for role in ['minimum','combined']:
        body=bodies[case,role]
        assert any(body[i:i+2]==['cmp r8,rsi','cmovae r8,rsi'] for i in range(len(body)))
        assert any(body[i:i+4]==['cmp r8,rsi','mov r11,rsi','cmovb r11,r8','mov QWORD PTR [rbp-0xb18],r11'] for i in range(len(body)))
report['audit_script_sha256']=sha(pathlib.Path(__file__))
(OUT/'report.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({'report':str(OUT/'report.json'),'loop_counts':[(r['case'],r['role'],r['instruction_count_excluding_backedge'],r['byte_count_excluding_backedge']) for r in report['loops']]},indent=2))
