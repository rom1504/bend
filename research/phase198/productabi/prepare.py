"""Build an isolated checked-API source with four narrowly changed backend declarations."""
import argparse
from pathlib import Path
import re
import subprocess
import sys

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
P=ROOT/'selfhost/src/back/x86'
def declaration(file,name):
    text=(P/file).read_text()
    pattern=r'(?ms)^@unsafe\ndef '+name+r'\(.*?(?=\n\n|\Z)'
    found=re.findall(pattern,text)
    assert len(found)==1,(name,len(found))
    return found[0]

def replace(text,before,after):
    assert text.count(before)==1,before
    return text.replace(before,after)

def prepare(out):
    out=out.resolve()
    out.mkdir(parents=True)
    assert not list(out.iterdir())
    hooks=[]
    f=declaration('program.bend','x181_forward_index')
    f=replace(f,'case Con{P113DFunction{+name,params,result,public,body},rest}:',
              '''case Con{P113DFunction{+name,+params,+result,public,+body},rest}:
      +calls = x198pr_calls(body,index)
      +index = nt_choose(KDef,U32.is_eq(result,2) && U32.is_eq(p113a_count_body(body,0),0) && x198pr_safe(body),
        u => x198pr_record(x198pr_symbol(name),False{},True{},calls),u => calls)''')
    hooks.append(f)
    f=declaration('program.bend','x181_program_private')
    f=replace(f,'+enabled =','+ids = x198pr_ids(ids,available)\n      +enabled =')
    f=replace(f,'x181_forward(function,ready))))','x181_program_join(x181_forward(function,ready),x198pr_worker(function,available,ids)))))')
    hooks.append(f)
    f=declaration('function.bend','x181_call')
    old=f.replace('def x181_call(', 'def x198pr_buffer_call(',1)
    mark=f.index('  match destinations:')
    f=f[:mark]+'''  match destinations:
    case Con{+first,Con{+second,Nil{}}}:
      nt_choose(X181Code,x198pr_target(ids,target),
        u => x181_add(x188_many([x181_call_text(x198pr_symbol(target),Con{p111_state(),x181_args(args)},ids,frame),
          x181_store(first,frame,x188_reg(10,64)),x181_store(second,frame,x188_reg(11,64))]),code),
        u => x198pr_buffer_call(destinations,target,args,ids,frame,code))
    case _: x198pr_buffer_call(destinations,target,args,ids,frame,code)'''
    hooks.extend([old,f])
    f=declaration('function.bend','x181_results')
    f=replace(f,'    case _: x181_store_results', '''    case Con{+first,Con{+second,Nil{}}}:
      nt_choose(X181Code,x198pr_frame(frame),u => x181_return(x188_cat(
        x181_load(first,ids,frame,x188_reg(10,64)),x181_load(second,ids,frame,x188_reg(11,64))),frame,code),
        u => x181_store_results(values,0,ids,frame,code))
    case _: x181_store_results''')
    hooks.append(f)
    f=declaration('function.bend','x181_prologue')
    f=replace(f,'X188One{PGlobal{symbol}}','nt_choose(X188Seq,x198pr_frame(frame),u => X188Empty{},u => X188One{PGlobal{symbol}})')
    hooks.append(f)
    module=out/'pair-hooks.bend'
    module.write_text('\n\n'.join(hooks)+'\n')
    command=[sys.executable,'-B','selfhost/tests/phase190/prepare-api.py','--parent-source','selfhost/build/phase198/selected-source01/compiler.bend','--assets','selfhost/build/phase194/assets.json',
             '--out',str(out/'api'),'--module',str(HERE/'pair.bend'),'--module',str(module)]
    for name in ('x181_forward_index','x181_program_private','x181_call','x181_results','x181_prologue'):
        command+=['--replace',name]
    for name in ('x198pr_selected','x181_forward_index','x198pr_worker','x181_direct','x198pr_ids','x181_prepared','x188_assemble'):
        if name not in ('x181_prepared','x188_assemble'):command+=['--export',name]
    subprocess.run(command,check=True,cwd=ROOT)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
    prepare(p.parse_args().out)
