#!/usr/bin/env python3
"""Add actual same-source stage timing and independent final qualification offline."""
import argparse
import importlib.util
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[5]
sys.dont_write_bytecode=True
spec=importlib.util.spec_from_file_location('p131_results_base',Path(__file__).with_name('report-results.py'))
B=importlib.util.module_from_spec(spec);spec.loader.exec_module(B)
pin=B.A.pin


def read(path):return json.loads(Path(path).read_text())


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--provisional',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();out=a.out.resolve();old=read(a.provisional)
    assert old['complete'] and old['kind']=='phase131-provisional-native-results'
    assert not out.exists() or out.read_bytes()==a.provisional.read_bytes()
    stage=B.block(ROOT/'selfhost/build/phase112/p131-final-stages-timing01/report.json',
        ROOT/'selfhost/build/phase131/final-stages-timing-analysis01/report.json','Final Phase131 N1 versus N2; fixed compiler source')
    assert stage['roles']['phase111']['source']==stage['roles']['phase112']['source']==old['finalCompilerComplexity']['final']['source']
    stage['sameCompilerSource']=True
    qualification_path=ROOT/'selfhost/build/phase131/final-native-qualification01.json';qualification=read(qualification_path)
    assert qualification['complete'] and qualification['nativeQualified'] and qualification['byteExact']
    assert qualification['source']==stage['roles']['phase112']['source']
    assert qualification['n1']==stage['roles']['phase111']['binary'] and qualification['n2']==stage['roles']['phase112']['binary']
    assert qualification['n2']==old['finalBlock']['roles']['phase112']['binary']
    for row in [qualification['source'],qualification['n1'],qualification['n2'],qualification['n3']]:assert pin(row['file'])==row
    reproduction_path=ROOT/'selfhost/build/phase130/p131-final-reproduce01/report.json';reproduction=read(reproduction_path)
    assert reproduction['complete'] and reproduction['byteExact'] and reproduction['image']==qualification['n2']
    assert reproduction['source']==qualification['source'] and reproduction['product']==qualification['reproducedQbe']['right']
    before=old['fullSourceRequestObservations']['observations'][1]
    assert before['product']==qualification['reproducedQbe']['left']
    r=reproduction
    third=dict(stage='Final Phase131 N2 emits same final source to Q3',receipt=pin(reproduction_path),image=r['image'],source=r['source'],
        product=r['product'],requestWallSeconds=r['nativeSeconds'],requestCpuSeconds=r['cpuSeconds'],harnessTotalSeconds=r['totalSeconds'],peakRssKiB=r['peakRssKiB'])
    old['fullSourceRequestObservations']['observations'].append(third)
    old['fullSourceRequestObservations'].update(secondThirdQbeByteEqual=True,
        n2OverN1RequestWallRatio=third['requestWallSeconds']/before['requestWallSeconds'],
        n2OverN1RequestCpuRatio=third['requestCpuSeconds']/before['requestCpuSeconds'],
        scope='One observation per native producer, same final compiler source. Acquisition overlapped separate CPU6 work; not randomized or a controlled multi-repeat gain estimate. Cold source-to-QBE child clocks exclude machine builds. N1 outputQ2 and N2 outputQ3 match byte-for-byte; Q1 differs.')
    source_manifest_path=ROOT/'selfhost/build/phase131/combined-literals-source01/manifest.json'
    source_manifest=read(source_manifest_path);expose=source_manifest['literalExposure']
    old['finalCompilerComplexity']['literalExposure']={k:expose[k] for k in ['reviewedOriginalCalls','actualReplacements','changedDeclarations','sourceByteGrowth','declarationCountChange']}
    parent_build_path=ROOT/'selfhost/build/phase111/p130-native01-n1/report.json';parent_build=read(parent_build_path)
    old['productGrowth']=dict(parentImage=parent_build['binary'],finalN2Image=qualification['n2'],finalN3Image=qualification['n3'],
        n2OverParentImageBytes=qualification['n2']['bytes']/parent_build['binary']['bytes'],
        qbeByGeneration=qualification['qbe'],
        reproducedQbe=qualification['reproducedQbe'])
    old.update(kind='phase131-native-results',provisionalSnapshot=pin(a.provisional),stageBlock=stage,
        qualification=pin(qualification_path),nativeQualification='Independent final N0->N1->N2->N3 binder closed; Q2=Q3, focused19 N2/N3, ordinary45 N3. Timings remain observations of actual N1/N2 binaries.',
        measuredStages=['Phase130 N1','Phase131 FAST N1','Phase131 final N1','Phase131 final N2'],
        qualifiedFinalStage='Phase131 final N3',n3PerformanceMeasured=False)
    old['inputs'] += [pin(__file__),pin(B.__file__),pin(a.provisional),stage['raw'],stage['analysis'],pin(qualification_path),pin(reproduction_path),pin(source_manifest_path),pin(parent_build_path)]
    old['limitations'].append('QBE fixed point and N3 qualification do not establish identical N2/N3 ELF or transfer a speed measurement to unmeasured N3.')
    out.write_text(json.dumps(old,indent=2)+'\n')
    text=a.provisional.with_name('README.md').read_text()
    text=text.replace('# Phase131 native results — provisional','# Phase131 native results')
    text=text.replace('Final N3 qualification was pending at this report cutoff; installed selection is unchanged.',
        'Independent final N3 qualification has now closed (Q2=Q3, focused19 N2/N3 and ordinary45 N3). The figures here measure the actual N2 binary; N3 speed is not asserted from QBE equality. Installed selection is unchanged.')
    text=text.replace('Q2=Q3 must still be established independently.',
        f"Final N2 then emitted Q3 in {third['requestWallSeconds']:.3f}s ({100*(1-third['requestWallSeconds']/before['requestWallSeconds']):.2f}% lower than N1 in this single pair), and Q2=Q3 now passes the independent binder.")
    marker='Selected final compiler:'
    index=text.index(marker)
    stage_lines=['Same-source compiler generations were also measured in a separate rotated 27-observation block. Both execute source `1bc5930…728f9`: N1 ELF `57b6f168…e7c3a`, N2 ELF `2fae3602…fd5dc`. N1 was built from parent-emitted Q1; N2 from final N1-emitted Q2. Runtime, machine tools, carrier and requested programs are unchanged.', '',
        '| Same-source request | N1 seconds [range] | N2 seconds [range] | N2/N1 |','|---|---:|---:|---:|']
    for c in stage['cases']:
        left=c['roles']['phase111']['requestSeconds'];right=c['roles']['phase112']['requestSeconds']
        stage_lines.append(f"| {c['name']} | {left['median']:.4f} [{left['minimum']:.4f}, {left['maximum']:.4f}] | {right['median']:.4f} [{right['minimum']:.4f}, {right['maximum']:.4f}] | {c['requestRatios']['candidateOverParent']:.4f} |")
    ratio=stage['geometricRatios']['requestSeconds']
    stage_lines += ['',f"N2 uses **{ratio['candidateOverParent']:.4f}× N1 request time ({100*(1-ratio['candidateOverParent']):.2f}% lower)** geometrically, with all three observed ranges below N1. Both native generations emit exact identical QBE for these requests. N1/upstream is {ratio['parentOverUpstream']:.4f}× and N2/upstream {ratio['candidateOverUpstream']:.4f}× in this block. This demonstrates benefit from the compiler's generated code with compiler source fixed. It does not yet measure increased subsequent optimization-research throughput.", '']
    text=text[:index]+'\n'.join(stage_lines)+'\n'+text[index:]
    text += f"\nLiteral exposure accounts for {expose['actualReplacements']} replacements in {expose['changedDeclarations']} declarations and {expose['sourceByteGrowth']:,} bytes, without changing declaration or line counts. The final N2 image is {qualification['n2']['bytes']:,} bytes ({100*(old['productGrowth']['n2OverParentImageBytes']-1):.2f}% larger than Phase130 N1).\n\nAdditional evidence: [same-source stage timing](../../selfhost/build/phase131/final-stages-timing-analysis01/report.json), [final qualification](../../selfhost/build/phase131/final-native-qualification01.json), [preserved provisional cutoff](../../selfhost/build/phase131/native-results-provisional01/report.json).\n"
    out.with_suffix('.md').write_text(text)
    print(json.dumps(dict(complete=True,result=pin(out),sameSourceN2OverN1=ratio['candidateOverParent'],qualifiedN3=qualification['n3'])))


if __name__=='__main__':main()
