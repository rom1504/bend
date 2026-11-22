"""Build exactly one source per family/form for every selected backend."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
BENCH = HERE.parent
ROOT = BENCH.parents[2]
sys.path.insert(0, str(BENCH))
import acquire
from common import pin
from contract import load

CATALOG = BENCH / 'catalogs/native45/catalog.json'
FAMILIES = {
    'list': ('coverage-list-pipeline-128', 'structures/list-pipeline.c'),
    'expression': ('coverage-expression-32', 'structures/expression.c'),
    'bst': ('coverage-bst-32', 'structures/bst.c'),
    'editdist': ('editdist', 'algorithms/editdist.c'),
}
ROLES = ['agy', 'qbe', 'bend-c', 'hand-c']
AGY = Path(os.environ.get('AGY_ROOT','/home/ai/bend2_agy'))
API = AGY/'selfhost/build/agy/wave2_unified/api.mjs'
RUNTIME = AGY/'selfhost/build/agy/unified/runtime-agy.o'
CLANG_ROOT = ROOT/'selfhost/build/phase1/clang/root/usr'
CLANG = CLANG_ROOT/'bin/clang-16'
NODE = os.environ.get('NODE', '/home/ai/.nvm/versions/node/v24.22.1/bin/node')

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def bend_source(family,form):
    if form=='original':
        catalog=json.loads(CATALOG.read_text())
        entry=next(row['source'] for row in catalog['cases'] if row['id']==FAMILIES[family][0])
        fixture=BENCH/entry['file']
        if digest(fixture)!=entry['sha256']:
            raise ValueError(f'fixture changed: {fixture}')
        kernel, marker, _=fixture.read_text().partition('# Phase93: fixed catalog inputs, repeated complete-result validation.')
        if not marker: raise ValueError('missing fixture boundary')
    else:
        kernel=(HERE/'kernels'/((family if form=='tuned' else 'list-fused')+'.bend')).read_text()
    return kernel.rstrip()+'\n\n'+(HERE/'driver.bend').read_text()

def build(out,roles,families):
    load()
    out.mkdir(parents=True,exist_ok=True)
    assets_path=ROOT/'selfhost/manifests/assets-native.json'
    assets=acquire.assets.load_assets(assets_path,ROOT)
    receipts={}
    for family in families:
        for form in ['original','tuned']+(['fused'] if family=='list' else []):
            for role in roles:
                key=f'{family}-{form}-{role}'
                directory=out/key
                directory.mkdir()
                binary=directory/'program'
                if role=='hand-c':
                    inputs=BENCH/'handwritten-c'
                    kernel=inputs/FAMILIES[family][1] if form=='original' else HERE/'kernels'/((family if form=='tuned' else 'list-fused')+'.c')
                    driver=HERE/'driver.c'
                    env=dict(os.environ,LD_LIBRARY_PATH=f'{CLANG_ROOT}/lib/x86_64-linux-gnu:{CLANG_ROOT}/lib/llvm-16/lib')
                    subprocess.run([CLANG,'-std=c11','-O3','-ffp-contract=off','-fno-lto',driver,kernel,'-o',binary],env=env,check=True)
                    info={'driver':digest(driver),'source':digest(kernel),'clang':digest(CLANG)}
                    if form=='original' and family=='editdist':
                        info['header']=digest(kernel.with_name('editdist_kernel.h'))
                    argv=[str(binary)]
                else:
                    source=directory/'input.bend'
                    source.write_text(bend_source(family,form))
                    if role=='agy':
                        emitter=AGY/'research/agy/emit_obj.mjs'
                        subprocess.run([NODE,'--stack-size=4096',emitter,API,source,directory/'program.o'],check=True)
                        subprocess.run(['gcc','-no-pie',directory/'program.o',RUNTIME,'-pthread','-lm','-o',binary],check=True)
                        info={k:digest(v) for k,v in {'emitter':emitter,'api':API,'runtime':RUNTIME,'base':AGY/'selfhost/dist/base.bend','carrier':AGY/'selfhost/build/agy/bootstrap/base.p130'}.items()}
                        argv=[str(binary),'+RTS','--threads','1','--gpu','off','-RTS']
                    else:
                        target='c' if role=='bend-c' else 'qbe'
                        recipe=dict(provider='build',assets=str(assets_path),host='native',target=target,
                                    stage='N2' if target=='qbe' else 'N1',mode='cache')
                        if target=='qbe': recipe['imageKey']='qbe-n2'
                        else: recipe.update(image=str(ROOT/'selfhost/dist/native/bend'),imageReceipt=str(ROOT/'selfhost/dist/native/BUILD.json'))
                        result,_=acquire.acquire_case(recipe,assets,pin(source),directory/'build',ROOT,90)
                        binary=Path(result['artifact']['file'])
                        argv=[str(binary),*acquire.bench.native_runtime_arguments(result)]
                        info={'inputs':{item['file']:item['sha256'] for item in result['inputs']}}
                    info['source']=digest(source)
                receipts[key]=dict(argv=argv,sha256=digest(binary),inputs=info)
                (out/'products.json').write_text(json.dumps(receipts,indent=2)+'\n')
                print(key,receipts[key]['sha256'][:12],flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('out',type=Path)
    p.add_argument('--roles',choices=ROLES,nargs='+',default=ROLES)
    p.add_argument('--families',choices=FAMILIES,nargs='+',default=list(FAMILIES))
    a=p.parse_args()
    build(a.out.resolve(),a.roles,a.families)
