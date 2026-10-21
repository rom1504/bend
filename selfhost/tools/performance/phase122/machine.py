"""Retain three authenticated editdist loop bodies and the primitive runtime body."""
import importlib.util, re, subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location('survey122', Path(__file__).with_name('survey.py'))
R = importlib.util.module_from_spec(spec); spec.loader.exec_module(R); S = R.S
manifest = ROOT/'selfhost/build/phase122/manifest01.json'
m = S.read(manifest); c = next(x for x in m['cases'] if x['name']=='editdist')
out = ROOT/'selfhost/build/phase122/machine01'; assert not out.exists(); out.mkdir()
result = dict(complete=False, inputs=[S.pin(__file__), S.pin(manifest), S.pin('/usr/bin/objdump')], rows=[],
              scope='Static selected loop bodies, not instruction execution counts or attribution of the runtime gap.')
for role, start, end in [('qbe',0x408490,0x408582),('upstream_c',0x7660,0x76bb),('selfhost_c',0xa280,0xa2db)]:
    binary = c['products'][role]; S.verify(binary); result['inputs'].append(binary)
    cmd = ['objdump','-d','--no-show-raw-insn','--start-address='+hex(start),'--stop-address='+hex(end),binary['file']]
    raw = subprocess.check_output(cmd, text=True); dest=out/(role+'.asm'); dest.write_text(raw)
    ins = re.findall(r'^\s*[0-9a-f]+:\s+([a-z][a-z0-9]*)\s*(.*?)$',raw,re.M)
    counts=dict(instructions=len(ins),stackMemoryOperands=sum(bool(re.search(r'\(%r(?:sp|bp)\)',args)) for _,args in ins),
                calls=sum(op.startswith('call') for op,_ in ins))
    result['rows'].append(dict(role=role,command=cmd,assembly=S.pin(dest),**counts))
runtime=ROOT/'selfhost/build/phase118/runtime-extend01/runtime.o'
S.verify(next(x for x in m['inputs'] if x['file']==str(runtime)))
cmd=['objdump','-dr','--disassemble=p111_rt_op',str(runtime)]
dest=out/'runtime-op.asm'; dest.write_bytes(subprocess.check_output(cmd))
result.update(complete=True,runtime=dict(input=S.pin(runtime),command=cmd,assembly=S.pin(dest)))
S.save(out/'report.json',result)
print([(x['role'],x['instructions'],x['stackMemoryOperands']) for x in result['rows']])
