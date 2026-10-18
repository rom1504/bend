#!/usr/bin/env python3
"""Prepare a native IR kernel and matching checked JS source; run no compiler."""
import argparse
import hashlib
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[4]
PHASE=HERE.parent
def pin(file):
    p=Path(file).resolve(strict=True);data=p.read_bytes()
    return dict(file=str(p),bytes=len(data),sha256=hashlib.sha256(data).hexdigest())

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args();out=a.out.resolve()
    assert out.is_relative_to(ROOT/'selfhost/build/phase107') and not out.exists()
    common=PHASE.parent/'phase106'
    sources=[common/'ir'/f'{name}.bend' for name in ['model','optimize','verify','json','c','workloads']]
    sources += [common/'laws/bridge.bend']
    sources += [PHASE/'backends'/f'{name}.bend' for name in ['qbe','qbe-entry']]
    sources += [PHASE/'inline'/f'{name}.bend' for name in ['model','admit','rename','expand','deep','tail','entry','leaf','reachable','demand','memory','pipeline','promotion','constant']]
    sources += [HERE/'main.bend']
    out.mkdir(parents=True);snapshot=out/'source';snapshot.mkdir()
    for i,file in enumerate(sources):(snapshot/f'{i:02d}-{file.name}').write_bytes(file.read_bytes())
    (out/'producer.bend').write_text('import Base\n\n'+'\n\n'.join(file.read_text() for file in sources)+'\n')
    pipelines=dict(raw=[],pure=['nx_tail_optimize','nx_inline_entry(4096)','nx_optimize','nx_reachable'],
                   memory=['nx_tail_optimize','nx_inline_entry(4096)','nx_reachable','nx_inline_leaf(4096)','nx_optimize','nx_reachable'],
                   checked=['nx_tail_optimize','nx_inline_demand(4096)','nx_reachable','nx_inline_leaf(4096)','nx_reachable','nx_memory_forward','nx_optimize'],
                   fast=['nx_pipeline_fast'],promote=['nx_pipeline_fast','nx_scalar_promote'],constant=['nx_pipeline_fast','nx_scalar_promote','nx_constant_propagate'])
    report=dict(kind='phase107-native-ir-kernel-source',version=1,prepared=True,targetsExecuted=False,
                method=pin(__file__),inputs=[pin(file) for file in sources],source=pin(out/'producer.bend'),
                pipelines=pipelines,qbeFusion={**{name:name!='raw' for name in pipelines},'maxBodyNodes':512},
                exports=['nx_workload','nx_verify','nx_kernel_policy','nx_kernel_text'],
                invocation=['WORKLOAD','raw|pure|memory|checked|fast|promote|constant','json|qbe'],
                scope='IR constructor/optimizer/emitter only. No Bend source frontend or installed compiler replacement.')
    (out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(source=report['source'],manifest=str(out/'manifest.json'),targetsExecuted=False)))

if __name__=='__main__':main()
