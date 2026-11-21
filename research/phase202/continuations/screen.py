"""Phase201 paired native harness with a frozen independent continuation text/relocation oracle."""
import argparse,hashlib,importlib.util,json,struct,sys
from pathlib import Path
from prepare import HERE,ROOT
p=ROOT/'research/phase201/elf';sys.path.insert(0,str(p));sp=importlib.util.spec_from_file_location('elf_screen',p/'screen.py');m=importlib.util.module_from_spec(sp);sp.loader.exec_module(m)

def oracle(data):
    table=dict(m.sections(data));section=lambda n:data[table[n][4]:table[n][4]+table[n][5]]
    body=bytes.fromhex(json.loads((HERE/'evidence.json').read_text())['nativeBytes']);text=section('.text');assert len(text)>=127*len(body) and text[:127*len(body)]==body*127,'admitted machine body differs from actual frozen compiler object'
    syms=section('.symtab');names=section('.strtab'); entries=list(struct.iter_unpack('<IBBHQQ',syms));symnames=[names[n:names.index(0,n)].decode() for n,*_ in entries];index=symnames.index('p111_rt_apply');rel=list(struct.iter_unpack('<QQq',section('.rela.text')));assert len(rel)==128 and all(rel[i]==(i*len(body)+99,(index<<32)|4,-4) for i in range(127));assert all(f'p111_FID_'+''.join(f'{ord(c)}_' for c in '$p111.k.'+str(i)) in symnames for i in range(1000,1128));return hashlib.sha256(data).hexdigest()

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--fixture',required=True,type=Path);p.add_argument('--out',required=True,type=Path);a=p.parse_args();m.oracle=oracle;m.FIXTURE=a.fixture.resolve();m.run(a.out)
