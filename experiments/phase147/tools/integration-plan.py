#!/usr/bin/env python3
"""Prepare explicit root-owned integration jobs; copy no source and run no target."""
import argparse
import json
from pathlib import Path
import sys
from prepare import ROOT, guard, pin, require, write_json, fresh_output
from common import verify


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    source = pin(a.source)
    base = ROOT/'selfhost/build/phase147/baseline-source/compiler.bend'
    reference = ROOT/'selfhost/build/consolidation/qbe-source-match01/program.ssa'
    baseline = pin(base); expected = pin(reference)
    require((baseline['bytes'], baseline['sha256']) == (3010912, '00940ed508e7d1456dd19bee01b0d2e16ac227fdf13ac306e805a1e4c982fb5e'),
            'Frozen baseline source differs')
    require((expected['bytes'], expected['sha256']) == (117232528, 'dceae94a7659ad1ff58395ed34914971422ff9e5841668e910cd95e6b0914010'),
            'Independent complete baseline QBE differs')
    assets = ROOT/'selfhost/manifests/assets-native.json'
    cold = ROOT/'selfhost/build/phase147/cold-baseline01/report.json'
    prior = json.loads(cold.read_text())
    require(prior['complete'] and not prior['changedInputs'] and prior['request']['source'] == baseline
            and prior['irDigest'] == {k: expected[k] for k in ('bytes','sha256')}, 'Completed cold baseline required')
    require(prior['request']['image']['sha256'] == '367b639915c0bbc8906fc5827b002ca2c7fc07acc238034e54be994f8833d251',
            'Cold baseline used another producer')
    out = fresh_output(a.out, ROOT); image = out/'image'; jobs = {}
    check = out/'source-check'
    exports = out/'check-exports.json'
    write_json(exports,dict(kind='bend-hosted-api-exports',version=1,exports=['p111_empty']))
    common = ['python3','-B',ROOT/'selfhost/tools/build/native.py','--assets',assets,
              '--host','native','--target','qbe','--mode','cache','--seconds','600']
    jobs['source-check'] = guard('integrated-source-check',check,
        [ROOT/'selfhost/.assets/bin/bun',ROOT/'selfhost/tools/build/hosted.mjs','acquire',
         '--source',a.source.resolve(),'--exports',exports,'--out',check,
         '--upstream',ROOT/'selfhost/.bootstrap/upstream-phase66',
         '--engine',ROOT/'selfhost/.assets/bin/bun'],150,3072,64)
    jobs['acquire'] = guard('integrated-native-acquisition',image,
        [*common,'--stage','N2','--image-key','qbe-n2','--source',a.source.resolve(),
         '--output-stage','N1','--retain-ir','--out',image],660,3072,1024)
    bound = ['--stage','N1','--image',image/'program','--image-receipt',image/'report.json']
    jobs['fast-pairs'] = guard('integrated-fast-pairs',out/'fast-pairs',
        ['python3','-B',ROOT/'experiments/phase147/tools/request-pairs.py','--assets',assets,
         '--baseline-key','qbe-n2','--candidate',image/'report.json',
         '--cases',ROOT/'selfhost/build/phase147/verifier-baseline02/capture-cases.json',
         '--pairs','3','--seconds','60','--budget-seconds','180','--out',out/'fast-pairs'],210,2048,512)
    for suite in ('focused','broad'):
        target = out/('qualification-'+suite)
        jobs[suite] = guard('integrated-'+suite,target,
            ['python3','-B',ROOT/'selfhost/tools/build/qualification.py','--assets',assets,
             '--host','native','--target','qbe','--mode','cache',*bound,'--suite',suite,
             '--seconds','60','--build-seconds','90','--execute-seconds','20','--out',target],
            600,3072,1024)
    jobs['cold'] = guard('integrated-frozen-source-cold',out/'cold',
        [*common,*bound,'--source',base,'--expected',reference,'--out',out/'cold'],660,3072,1024)
    inputs = [pin(__file__),pin(ROOT/'experiments/phase147/tools/request-pairs.py'),source,baseline,expected,pin(cold),pin(assets),
              pin(ROOT/'selfhost/tools/stage0-library.mjs')]
    for name in ('bend.ts','comp.ts','base.bend'):
        inputs.append(pin(ROOT/'selfhost/.bootstrap/upstream-phase66/bend2'/name))
    for name in ('native.py','request.py','qualification.py','common.py','assets.py'):
        inputs.append(pin(ROOT/'selfhost/tools/build'/name))
    for item in inputs: verify(item)
    report = dict(kind='phase147-integrated-native-job-plan',version=1,complete=True,targetsRun=False,
        source=source,baselineSource=baseline,baselineQbe=expected,coldBaseline=pin(cold),inputs=inputs,
        baselineImage=prior['request']['image'],baselineImageSource=prior['request']['imageMetadata']['sourceIdentity'],
        sequence=['source-check','acquire','fast-pairs','cold','focused','broad'],jobs=jobs,
        scope='Prepared commands only. Root schedules each after prerequisite gates. Installed N2 is the timing baseline, with its original96c40 source identity preserved. The cold request compiles frozen00940 and requires complete dceae94 QBE identity. Candidate image is actual N1, no promotion or parity claim. No duplicate full source or QBE copies.',
        sourceCheck='Maintained stage0-library checks the entire book with upstream book_valid, rejects unresolved holes/laws, then emits only p111_empty and its dependencies. No full compiler JS emission. Expected exit0 and Checked1 API exports diagnostic (with spaces). Result remains an independent checked-book gate, not self-host or mathematical equivalence proof.',
        timing='Fast pairs measure native child requests with exact output; cold uses identical native.py emit→QBE→assembler→link pipeline as cold-baseline01.')
    write_json(out/'manifest.json',report)
    for name,job in jobs.items(): write_json(out/(name+'-job.json'),job)
    print(json.dumps(dict(plan=str(out/'manifest.json'),source=source,targetsRun=False)))


if __name__ == '__main__': main()
