#!/usr/bin/env python3
"""Freeze N2/self-host jobs only after the actual integrated N1 fast/cold gates."""
import argparse
import json
from pathlib import Path
from prepare import ROOT, guard, pin, require, write_json, fresh_output
from common import verify


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--plan', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args(); parent = a.plan.resolve().parent
    plan = json.loads(a.plan.read_text())
    require(plan.get('kind') == 'phase147-integrated-native-job-plan' and plan.get('complete'), 'Completed preparation required')
    for item in plan['inputs']: verify(item)
    source = verify(plan['source']); image_file = parent/'image/report.json'
    image = json.loads(image_file.read_text()); binding = image.get('imageBinding', {})
    require(image.get('complete') and not image.get('changedInputs') and binding.get('complete')
            and binding.get('stage') == 'N1' and binding.get('protocol') == 'qbe-source-v1'
            and image['request']['source'] == plan['source'] and binding['sourceIdentity'] == plan['source'],
            'Actual integrated N1 with exact source required')
    binary = verify(binding['image']); expected = verify(image['retainedIR'])
    require(image['irDigest'] == {k:image['retainedIR'][k] for k in ('bytes','sha256')}, 'Retained N1 QBE identity differs')
    fast_file, cold_file = parent/'fast-pairs/report.json', parent/'cold/report.json'
    fast, cold = json.loads(fast_file.read_text()), json.loads(cold_file.read_text())
    require(fast.get('complete') and fast.get('passed')
            and fast['images']['new']['binding']['image'] == binding['image']
            and all(c.get('passed') for c in fast['cases']), 'Actual exact-output fast pairs required')
    require(cold.get('complete') and not cold.get('changedInputs') and cold.get('comparedToReference')
            and cold['request']['image'] == binding['image'] and cold['request']['source'] == plan['baselineSource']
            and cold['irDigest'] == {k:plan['baselineQbe'][k] for k in ('bytes','sha256')},
            'Actual frozen-source complete QBE cold gate required')
    assets = ROOT/'selfhost/manifests/assets-native.json'; out = fresh_output(a.out,ROOT); second = out/'n2'
    common = ['--assets',assets,'--host','native','--target','qbe','--mode','cache']
    jobs = {}
    jobs['n2'] = guard('integrated-n2',second,
        ['python3','-B',ROOT/'selfhost/tools/build/native.py',*common,'--stage','N1','--image',binary,
         '--image-receipt',image_file,'--source',source,'--expected',expected,
         '--output-stage','N2','--seconds','600','--out',second],660,3072,1024)
    bound = ['--stage','N2','--image',second/'program','--image-receipt',second/'report.json']
    jobs['q3'] = guard('integrated-q3-byte-identity',out/'q3',
        ['python3','-B',ROOT/'selfhost/tools/build/request.py',*common,*bound,'--source',source,
         '--expected',expected,'--seconds','600','--out',out/'q3'],660,3072,512)
    jobs['fast-pairs'] = guard('integrated-n2-fast-pairs',out/'fast-pairs',
        ['python3','-B',ROOT/'experiments/phase147/tools/request-pairs.py','--assets',assets,
         '--baseline-key','qbe-n2','--candidate',second/'report.json',
         '--cases',ROOT/'selfhost/build/phase147/verifier-baseline02/capture-cases.json',
         '--pairs','3','--seconds','60','--budget-seconds','180','--out',out/'fast-pairs'],210,2048,512)
    for suite in ('focused','broad'):
        target = out/('qualification-'+suite)
        jobs[suite] = guard('integrated-n2-'+suite,target,
            ['python3','-B',ROOT/'selfhost/tools/build/qualification.py',*common,*bound,'--suite',suite,
             '--seconds','60','--build-seconds','90','--execute-seconds','20','--out',target],600,3072,1024)
    inputs = [pin(__file__),pin(a.plan),pin(image_file),pin(fast_file),pin(cold_file),*plan['inputs'],
              plan['source'],binding['image'],image['retainedIR'],pin(assets),
              pin(ROOT/'experiments/phase147/tools/request-pairs.py'),
              pin(ROOT/'selfhost/build/phase147/verifier-baseline02/capture-cases.json')]
    for name in ('native.py','request.py','qualification.py','common.py','assets.py'):
        inputs.append(pin(ROOT/'selfhost/tools/build'/name))
    for item in inputs: verify(item)
    write_json(out/'manifest.json',dict(kind='phase147-integrated-n2-job-plan',version=1,complete=True,targetsRun=False,
        inputs=inputs,source=plan['source'],n1=binding,expectedQbe=image['retainedIR'],
        sequence=['n2','q3','focused','broad','fast-pairs'],jobs=jobs,
        scope='N1 is reused. N2 construction and N2-emitted Q3 must each match entire upstream-of-N1 QBE; qualified runtime/toolchain unchanged. Fixed point is a byte-identity gate, not unrestricted semantic proof. Root owns execution and installation.'))
    for name,job in jobs.items(): write_json(out/(name+'-job.json'),job)
    print(json.dumps(dict(plan=str(out/'manifest.json'),targetsRun=False)))


if __name__ == '__main__': main()
