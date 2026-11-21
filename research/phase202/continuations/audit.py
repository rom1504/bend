"""Count real predecessor IR witnesses and authenticate the independent direct-object instruction oracle."""
import hashlib,json,re,struct,sys
from pathlib import Path
from prepare import HERE,ROOT,BASE,apply
sys.path.insert(0,str(ROOT/'research/phase201/elf'));import importlib.util
spec=importlib.util.spec_from_file_location('elf_tables',ROOT/'research/phase201/elf/audit.py');tables=importlib.util.module_from_spec(spec);spec.loader.exec_module(tables);sections=tables.sections

def digest(b):return hashlib.sha256(b).hexdigest()
def witness():
    q=ROOT/'selfhost/build/phase186/release-qbe-chain01/n2/program.ssa';s=q.read_bytes();assert digest(s)=='ffd59ee1ec27e2ab1dce48b1d756c2eb26fff990ead1aa876bba1b0fbd0f0bf7'
    lines=['@entry','%v_scratch =l alloc8 2048','%t_1 =l add %state, 16','%v_p114t_0_sp =l loadl %t_1','%v_p114t_0_next_sp =l add %v_p114t_0_sp, 18446744073709551608','%t_2 =l add %state, 16','storel %v_p114t_0_next_sp, %t_2','%v_ignored =l copy 0','%t_4 =l add %state, 16','%v_p114t_3_sp =l loadl %t_4',r'(?P<h>%v_v_\d+) =l loadl %v_p114t_3_sp','%t_5 =l add %state, 40',r'(?P<i>%v_v_\d+) =l loadl %t_5',r'(?P<a>%v_v_\d+) =l copy (?P=h)',r'%v_reply =l call \$p111_rt_apply\(l %state, l (?P=i), l (?P=a)\)','ret %v_reply']
    exact=re.compile(('\n'.join(lines)).encode());found=[]
    for m in re.finditer(rb'export function l \$(p111_FID_[^ (]+)\(l %state\) \{\n([^}]+)\n\}',s):
        n=exact.fullmatch(m[2]);
        if n and len(set(n.groups()))==3:found.append((m.start(),m[1].decode(),m[2].decode()))
    p=ROOT/'selfhost/build/phase198/progress-native-self01/program.o';b=p.read_bytes();assert digest(b)=='b3a382d4600dcbb5e5fa797dffed49b25972962445911bd82fc69eb36de4a65a';sec=dict(sections(b));t=sec['.text'];off=2382587;machine=b[t[4]+off:t[4]+off+118];rel=sec['.rela.text'];records=[(o-off,info&0xffffffff,add)for o,info,add in struct.iter_unpack('<QQq',b[rel[4]:rel[4]+rel[5]]) if off<=o<off+118];assert records==[(99,4,-4)]
    return dict(parent=digest(BASE.read_bytes()),candidate=digest(apply(BASE.read_bytes())),qbeSource=str(q.relative_to(ROOT)),qbeSha256=digest(s),completeAlphaDistinctQbeMatches=len(found),firstQbeOffset=found[0][0],firstQbeSymbol=found[0][1],firstQbeBody=found[0][2],nativeObject=digest(b),nativeFamilyCount=7174,nativeExample='$p111.k.3195',nativeTextOffset=off,nativeBytes=machine.hex(),localRelocations=records)

if __name__=='__main__':print(json.dumps(witness(),indent=2))
