"""Retry receipt that persists typed nodes before completing full assembly rendering."""
import argparse
from pathlib import Path
import subprocess
from projection import HERE,BUILD,read
p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
out=p.parse_args().out
out.mkdir(parents=True)
binding=read(BUILD/'phase195/ctor-gate-emission-plan01.json')['producer']['bindingValue']
source=(HERE/'inspect.mjs').read_text()
mark='if(/p113d_.*(?:bst.down|occurs.go|occurs.step)/.test(pretty)) row.workers.push({pretty,params,setup,body});'
assert source.count(mark)==1
source=source.replace(mark,"""if(/(?:bst.down|occurs.go|occurs.step)/.test(pretty)) {
      row.workers.push({pretty,params,setup,body});
      fs.writeFileSync(path.join(out,id+'-partial.json'),JSON.stringify(row));
    }""")
for marker in ['const prep=','const planned=','const lower=','const selected=','const asm=']:
    source=source.replace(marker,"fs.appendFileSync(path.join(out,'stages.log'),Date.now()+' '+"
                          +repr(marker)+"+'\\n');"+marker)
script=out/'inspect-progress.mjs'
script.write_text(source)
subprocess.run([binding['engine']['file'],script,out],check=True,timeout=60)
