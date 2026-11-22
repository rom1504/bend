"""Build the pinned upstream workloads. Each failure is recorded per cell."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.path.insert(0, str(HERE.parent))
import acquire
from common import pin

REV = '0e2f38f759cc830849e489307f3d256a7d148288'
ROLES = ('hand-c', 'upstream-c', 'agy', 'bend-c', 'qbe')
SIZES = ('small', 'medium', 'upstream')
SPEC = json.loads((HERE/'suite.json').read_text())
ASSETS = ROOT/'selfhost/manifests/assets-native.json'
CLANG_ROOT = ROOT/'selfhost/build/phase1/clang/root/usr'
CLANG = CLANG_ROOT/'bin/clang-16'
BUN = ROOT/'selfhost/.assets/bin/bun'
AGY = Path(os.environ.get('AGY_ROOT', '/home/ai/bend2_agy'))
API = AGY/'selfhost/build/agy/wave2_unified/api.mjs'
RUNTIME = AGY/'selfhost/build/agy/unified/runtime-agy.o'
RTS = ['+RTS', '--threads', '1', '--gpu', 'off', '-RTS']
FLAGS = ['-std=gnu11', '-O3', '-ffp-contract=off']

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def run(cmd, cwd, log, env=None):
    result = subprocess.run(cmd, cwd=cwd, env=env, capture_output=True, timeout=100)
    with log.open('ab') as f:
        f.write(('\n'+' '.join(map(str,cmd))+'\n').encode()+result.stdout+result.stderr)
    if result.returncode:
        raise RuntimeError((result.stderr+result.stdout).decode(errors='replace')[-2400:])

def cc(src, program, log, extra=()):
    env = dict(os.environ, LD_LIBRARY_PATH=f'{CLANG_ROOT}/lib/x86_64-linux-gnu:{CLANG_ROOT}/lib/llvm-16/lib')
    run([CLANG, *FLAGS, *extra, src, '-o', program, '-lm', '-pthread'], program.parent, log, env)

def replace_once(text, pattern, repl):
    replaced, n = re.subn(pattern, repl, text, flags=re.M)
    if n != 1:
        raise ValueError(f'expected one size parameter for {pattern}, found {n}')
    return replaced

def prepare(checkout, family, size, out):
    desc = SPEC[family]
    out.mkdir()
    fixture = checkout/'bench/runtime'/family
    sources = {}
    for ext in ('bend','c'):
        path = fixture/('main.'+ext)
        if sha(path)!=desc['sourceSha256'][ext]:
            raise ValueError('upstream workload digest changed')
        sources[ext] = path.read_text()
    extra = []
    if size!='upstream':
        for name, c_name, old, new in zip(desc['bendKnobs'],desc['cKnobs'],desc['upstream'],desc[size]):
            sources['bend']=replace_once(sources['bend'],rf'(^def {name}\(\) -> Nat:\n  ){old}n$',rf'\g<1>{new}n')
            if family=='gameoflife':
                sources['c']=replace_once(sources['c'],rf'(  uint32_t {c_name} = ){old}u;',rf'\g<1>{new}u;')
            else:
                extra.append(f'-D{c_name}={new}u')
    for ext, text in sources.items():
        (out/('main.'+ext)).write_text(text)
    return extra

def build_cell(role, src, directory, checkout, defines, assets):
    directory.mkdir()
    program = directory/'program'
    log = directory/'build.log'
    if role=='hand-c':
        cc(src.with_suffix('.c'),program,log,defines)
        return [str(program)]
    if role=='upstream-c':
        generated = directory/'program.c'
        run([BUN,checkout/'bend2/main.ts',src,'-o',generated],checkout,log)
        cc(generated,program,log)
    elif role=='agy':
        obj=directory/'main.o'
        node=os.environ.get('NODE','/home/ai/.nvm/versions/node/v24.22.1/bin/node')
        run([node,'--stack-size=4096',AGY/'research/agy/emit_obj.mjs',API,src,obj],ROOT,log)
        run(['gcc','-no-pie',obj,RUNTIME,'-pthread','-lm','-o',program],directory,log)
    else:
        target='c' if role=='bend-c' else 'qbe'
        recipe=dict(provider='build',assets=str(ASSETS),host='native',target=target,
                    stage='N2' if target=='qbe' else 'N1',mode='cache')
        if target=='qbe':
            recipe['imageKey']='qbe-n2'
        else:
            recipe.update(image=str(ROOT/'selfhost/dist/native/bend'),imageReceipt=str(ROOT/'selfhost/dist/native/BUILD.json'))
        product,_=acquire.acquire_case(recipe,assets,pin(src),directory/'acquisition',ROOT,100)
        if target=='c':
            cc(Path(product['generatedSource']['file']),program,log)
        else:
            program=Path(product['artifact']['file'])
        return [str(program),*acquire.bench.native_runtime_arguments(product)]
    return [str(program),*RTS]

def build(out,checkout,roles,sizes,families):
    head=subprocess.check_output(['git','-C',checkout,'rev-parse','HEAD'],text=True).strip()
    if head!=REV or subprocess.check_output(['git','-C',checkout,'status','--porcelain','--','bend2','bench/runtime']):
        raise ValueError('expected an unmodified pinned upstream checkout')
    out.mkdir(parents=True,exist_ok=True)
    assets=acquire.assets.load_assets(ASSETS,ROOT)
    inputs={str(p):sha(p) for p in [BUN,CLANG,API,RUNTIME,AGY/'research/agy/emit_obj.mjs',
            AGY/'selfhost/dist/base.bend',AGY/'selfhost/build/agy/bootstrap/base.p130',ASSETS,
            ROOT/'selfhost/dist/native/bend',ROOT/'selfhost/dist/qbe/bend']}
    report=dict(upstream=head,compilerInputs=inputs,cFlags=FLAGS,products={})
    for size in sizes:
        for family in families:
            point=out/(family+'-'+size)
            defines=prepare(checkout,family,size,point)
            src=point/'main.bend'
            for role in roles:
                key=f'{family}/{size}/{role}'
                row=dict(bendSha256=sha(src),cSha256=sha(src.with_suffix('.c')),defines=defines)
                try:
                    argv=build_cell(role,src,point/role,checkout,defines,assets)
                    row.update(status='built',argv=argv,sha256=sha(Path(argv[0])))
                except (RuntimeError,ValueError,subprocess.SubprocessError,OSError) as exc:
                    row.update(status='build-failed',error=str(exc)[-2400:])
                report['products'][key]=row
                (out/'build.json').write_text(json.dumps(report,indent=2)+'\n')
                print(key,row['status'],row.get('error','')[:250],flush=True)
    if any(sha(Path(p))!=digest for p,digest in inputs.items()):
        raise ValueError('compiler input changed during acquisition')

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('out',type=Path)
    p.add_argument('checkout',type=Path)
    p.add_argument('--roles',nargs='+',choices=ROLES,default=ROLES)
    p.add_argument('--sizes',nargs='+',choices=SIZES,default=SIZES)
    p.add_argument('--families',nargs='+',choices=SPEC,default=list(SPEC))
    a=p.parse_args()
    build(a.out.resolve(),a.checkout.resolve(),a.roles,a.sizes,a.families)
