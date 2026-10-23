"""Read frozen QBE/ELF artifacts; no program execution or compilation."""
from pathlib import Path
import hashlib
import json
import re
import subprocess

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
OUT = HERE / 'v05-inspection'


def pin(path):
    data = path.read_bytes()
    return {'file':str(path),'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest()}


def decode(symbol):
    if '_FID_' not in symbol:
        return symbol
    prefix,codes = symbol.split('_FID_',1)
    return prefix+':'+''.join(chr(int(n)) for n in codes.split('_') if n)


def main():
    rows, inputs = [], [pin(Path(__file__).resolve())]
    for variant in ['baseline','scalar']:
        qbe = ROOT/f'selfhost/build/phase118/p130-scalar-ceiling-emit05/scalar-order-{variant}.ssa'
        elf = ROOT/f'selfhost/build/phase111/p130-scalar01-scalar-order-{variant}/program'
        inputs.extend([pin(qbe),pin(elf)])
        for match in re.finditer(r'^(?:export )?function [^\n]*\$(\w+)\([^\n]*\) \{\n(.*?)^\}',qbe.read_text(),re.M|re.S):
            symbol,body = match[1],match[2]
            name = decode(symbol)
            if not name.startswith('p113d:') or not any(x in name for x in
              ['p130s_order_go','p130s_query','p130s_digest','String.cmp','Pair.snd']):
                continue
            asm = subprocess.check_output(['objdump','-d','--disassemble='+symbol,str(elf)],text=True)
            instructions = [line.strip() for line in asm.splitlines() if re.match(
              r'^\s*[0-9a-f]+:\s+(?:[0-9a-f]{2}\s+)+([a-zA-Z][\w.]*)\b',line)]
            calls = re.findall(r'call \$(\w+)\(',body)
            rows.append({'variant':variant,'name':name,'symbol':symbol,'ssaLines':len(body.splitlines()),
              'ssaCalls':{decode(c):calls.count(c) for c in sorted(set(calls))},
              'machineInstructions':len(instructions),'machineCalls':[line for line in instructions if re.search(r'\bcallq?\b',line)]})
    report = {'kind':'phase130-readonly-v05-artifact-inspection','complete':True,'inputs':inputs,
      'scope':'Static qualified artifact inspection only. Counts exclude objdump continuation rows; dynamic execution counts and causal timing attribution remain unmeasured.',
      'rows':rows}
    out = OUT/'summary-v02.json'
    text = json.dumps(report,indent=2)+'\n'
    if out.exists() and out.read_text()!=text:
        raise ValueError('Refusing to overwrite inspection receipt')
    out.write_text(text)
    print(json.dumps([{'variant':r['variant'],'name':r['name'],'instructions':r['machineInstructions']} for r in rows],indent=2))


if __name__ == '__main__':
    main()
