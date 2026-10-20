#!/usr/bin/env python3
"""Authenticate completed hosted→N1→self/N2 lineage and exact QBE bytes offline."""
import argparse
import importlib.util
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('native_plan_tools',HERE/'prepare-native-plan.py')
tool=importlib.util.module_from_spec(spec);spec.loader.exec_module(tool)
pin,verify,read=tool.pin,tool.verify,tool.read


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--plan',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    if a.out.exists():raise ValueError('Fresh comparison receipt required')
    plan=read(a.plan)
    if plan.get('kind')!='phase113-native-qualification-plan':raise ValueError('Qualification plan required')
    for row in plan['inputs']:verify(row)
    paths={name:Path(plan['artifacts'][name])/'report.json' for name in ['hosted','n1','self']}
    paths['n2']=Path(plan['artifacts']['self'])/'build/report.json'
    reports={name:read(path) for name,path in paths.items()}
    if not all(row.get('complete') for row in reports.values()):raise ValueError('Complete hosted/native/build receipts required')
    hosted,n1,native,n2=[reports[key] for key in ['hosted','n1','self','n2']]
    if (hosted.get('pipeline')!='array' or hosted.get('transportVersion')!=2 or
        any(hosted.get(key)!=value for key,value in plan['transportContract'].items()) or
        not all(hosted.get(key) for key in ['sourceChecked','runtimeAdmitted','irVerified'])):
        raise ValueError('Hosted array contract mismatch')
    if (hosted['product'] not in n1['inputs'] or native['image']!=n1['binary'] or
        native.get('imageReceipt')!=pin(paths['n1']) or native['product'] not in n2['inputs'] or
        native.get('buildReport')!=pin(paths['n2']) or any(plan['runtime'] not in build['inputs'] for build in [n1,n2])):
        raise ValueError('Broken actual product/image/runtime lineage')
    if hosted.get('mode')!='cache' or native.get('mode')!='cache' or any(plan['source'] not in row['inputs'] for row in [hosted,native]):
        raise ValueError('Compiler input/mode differs')
    assets=read(tool.PHASE/'native-assets01.json')
    for expected in [assets['base'],assets['cache']['carrier']]:
        if any(expected not in row['inputs'] for row in [hosted,native]):raise ValueError('Base/carrier mismatch')
    inputs=[pin(__file__),pin(a.plan),*[pin(path) for path in paths.values()]]
    for row in reports.values():
        for item in row['inputs']:verify(item)
        inputs+=row['inputs']
    for item in [hosted['product'],native['product'],n1['binary'],n2['binary']]:
        verify(item)
        inputs.append(item)
    left,right=verify(hosted['product']),verify(native['product'])
    exact=tool.native.same_bytes(left,right)
    result=dict(kind='phase113-native-qbe-reproduction',complete=exact,targetsRun=False,byteExact=exact,
                inputs=list({row['file']:row for row in inputs}.values()),hostedQbe=hosted['product'],nativeQbe=native['product'],n1=n1['binary'],n2=n2['binary'],
                scope='Exact source/assets/runtime and actual hosted→N1→native-self→N2 build chain. Byte comparison is raw QBE, without normalization. Semantic suite results and N2 self-emission are separate.')
    a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text(json.dumps(result,indent=2)+'\n')
    if not exact:raise ValueError('Hosted/native full-source QBE differs; failed receipt preserved')
    print(json.dumps(dict(complete=True,targetsRun=False,report=str(a.out))))


if __name__=='__main__':main()
