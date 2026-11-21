"""Compile exact persistent-root observations for the original and selected alternatives."""
import argparse,json
import os
from pathlib import Path
import subprocess
from collections import Counter
from oracle import insert,shape
from prepare import HERE,ROOT,SOURCE,ENTRY,ROLES,pin
from screen import authenticate,command,read,write

SHAPES=[None,(None,5,None),((None,2,None),5,(None,7,None)),
        (((None,0,None),2,None),5,((None,5,None),7,(None,0xffffffff,None)))]
POINTS=[(0,0),(0,5),(1,5),(1,1),(1,8),(2,2),(2,6),(2,7),(3,5),(4,0xffffffff),(8,0)]

def literal(t):
    return 'BLeaf{}' if t is None else 'BNode{'+literal(t[0])+', '+str(t[1])+', '+literal(t[2])+'}'

def materialize(role):
    s=SOURCE.read_text().split('# Phase93:')[0]
    if role!='stock':
        replacement=(HERE/(role+'.bend')).read_text()+'\n'+ENTRY.split('\n')[0]+'\n  '+ROLES[role]+'(fuel, x, tree)'
        s=s.replace(ENTRY,replacement)
    s += '''
def zt.show(t: BST) -> String:
  match t:
    case BLeaf{}: "_"
    case BNode{l, v, r}:
      "(" ++ zt.show(l) ++ "," ++ U32.show(v) ++ "," ++ zt.show(r) ++ ")"

def zt.check(+t: BST, x: U32, fuel: Nat) -> String:
  zt.show(t) ++ "|" ++ zt.show(p37.bst.insert(fuel, x, t))

def main() -> IO(Unit):
  do IO<Unit>:
'''
    rows=[]
    for tree in SHAPES:
        for fuel,x in POINTS:
            s+='    Unit <- IO.print(zt.check('+literal(tree)+', '+str(x)+', '+str(fuel)+'n))\n'
            c=Counter();new=insert(tree,x,fuel,c)
            rows.append(dict(fuel=fuel,key=x,tree=shape(tree),result=shape(new),events=dict(c)))
    s+='    IO.print("done")\n'
    expected=''.join(r['tree']+'|'+r['result']+'\n' for r in rows)+'done\n'
    return s,rows,expected

def main(a):
    assert os.sched_getaffinity(0)=={3};out=a.out.resolve();out.mkdir()
    rec=read(ROOT/'selfhost/build/phase198/p199-integrated-native45-01/coverage-bst-64/machine/report.json')
    for item in rec['inputs']:authenticate(item)
    tc=rec['toolchain'];cc=authenticate(read(ROOT/'selfhost/build/phase194/assets.json')['assets']['linker'])
    runtime=authenticate(read(ROOT/'selfhost/build/phase199/runtime-bundle01/report.json')['variants']['live']['bundle'])
    report=dict(complete=False,roles={})
    for role in a.roles.split(','):
        d=out/role;d.mkdir();source,rows,expected=materialize(role)
        src=d/'control.bend';src.write_text(source)
        command(d,'check',['selfhost/.assets/bin/bun','selfhost/tools/build/check-source.mjs','--source',src,
                     '--out',d/'upstream','--manifest','selfhost/src/compiler.json','--upstream','selfhost/.bootstrap/upstream-phase182'])
        assert read(d/'upstream/report.json')['unresolvedHoles']==0
        cmd=rec['compilerCommand'][:];cmd[9]=str(src);obj=d/'p.o';exe=d/'program'
        command(d,'emit',cmd,obj);command(d,'link',[cc,*tc['linkerFlags'],obj,runtime,*tc['libraries'],'-o',exe])
        p=subprocess.run([str(exe),'+RTS','--threads','1','--gpu','off','-RTS','--RTS'],capture_output=True,timeout=8)
        (d/'actual').write_bytes(p.stdout);(d/'expected').write_text(expected)
        assert p.returncode==0 and not p.stderr and p.stdout.decode()==expected,(role,p.stderr,p.stdout[:120])
        report['roles'][role]=dict(source=pin(src),object=pin(obj),binary=pin(exe),rows=rows,output=pin(d/'actual'))
        write(out/'report.json',report)
    report['complete']=True;write(out/'report.json',report)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--roles',default='stock,compact,direct')
    p.add_argument('--out',required=True,type=Path);main(p.parse_args())
