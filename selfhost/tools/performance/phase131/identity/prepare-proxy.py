"""Freeze a source-only extracted compiler index proxy and independent outputs."""
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SOURCE = ROOT / 'selfhost/build/phase130/mode-source01/compiler.bend'
PAT = re.compile(r'^(?:@unsafe\n)?(?:def|type|law) ([A-Za-z0-9_.]+)\b',re.M)
NAMES = ['KTerm','KDef','p88_string_eq_go','p98_eq_finish','p88_string_eq',
         'kc','kt','atom','dn','dk','da','dx','dt','dv','dc','db','du','missing',
         'index_hash','index_child','index_child_list','index_first',
         'index_find','index_find_absent','index_find_leaf','index_find_hash',
         'index_bucket','index_remove','index_remove_step','index_tip',
         'index_split_bit','index_leaf','index_node','index_join','index_insert',
         'index_insert_legacy','index_set']


def pin(p):
    p=p.resolve();b=p.read_bytes()
    return dict(file=str(p),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())


def blocks(text):
    hits=list(PAT.finditer(text));out={}
    for i,h in enumerate(hits):
        body=text[h.start():hits[i+1].start() if i+1<len(hits) else len(text)]
        if not body.lstrip().startswith('law '):out[h[1]]=body
    return out


def write(name,text):
    p=HERE/name
    if p.exists():
        if p.read_text()!=text:raise ValueError('Refusing changed frozen input '+str(p))
    else:p.write_text(text)
    return pin(p)


def checksum(count):
    acc=2166136261
    for version in range(1001,1001+count):acc=(acc*16777619+version)&0xffffffff
    return acc


def main():
    source=SOURCE.read_text();defs=blocks(source)
    selected=json.loads((ROOT/'implementation/phase130/candidate.json').read_text())
    assert pin(SOURCE)==selected['source']
    names=[n for n,b in defs.items() if b.lstrip().startswith('def ') or b.lstrip().startswith('@unsafe')][:256]
    assert len(names)==len(set(names))==256
    names_def='def p131ip_names() -> List<&2,String>:\n  ['+',\n   '.join(json.dumps(n) for n in names)+']\n'
    candidate=blocks((HERE/'patricia.bend').read_text())
    common='import Base\n\n'+'\n'.join(defs[n] for n in NAMES if n!='index_set')
    tail='\n'+names_def+'\n'+(HERE/'proxy-workload.bend').read_text()
    expected=write('proxy-expected.json',json.dumps(dict(status=0,stdout=''.join(str(checksum(n))+'\n' for n in [0,1,16,64,256]),stderr=''),indent=2)+'\n')
    rows=[]
    for label,insert in [('baseline',defs['index_set']),('candidate','\n'.join(candidate.values()))]:
        p=write('proxy-'+label+'.bend',common+'\n'+insert+tail)
        rows.append(dict(name='identity-patricia-'+label,source=p,expected=expected,expectedStdoutEvidence=expected))
    write('proxy-cases.json',json.dumps(dict(complete=True,cases=rows),indent=2)+'\n')
    write('proxy-manifest.json',json.dumps(dict(complete=True,targetsRun=False,
        inputs=[pin(Path(__file__)),pin(SOURCE),pin(HERE/'patricia.bend'),pin(HERE/'proxy-workload.bend')],
        declarations=NAMES,actualCompilerNames=names,cases=rows,
        checksums={str(n):checksum(n) for n in [0,1,16,64,256]},
        timing='IO.now is milliseconds. Repetitions*checksum(size) modulo2^32; two construction/update passes plus lookup and reclamation per repetition.',
        scope='Source extraction/composition only. Same KDef/index algorithms and 256 actual compiler declaration names; generated user-program proxy, not whole native compiler throughput.'),indent=2)+'\n')


if __name__=='__main__':main()
