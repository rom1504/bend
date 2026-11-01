#!/usr/bin/env python3
"""Aggregate completed Phase147 evidence; execute no compiler or generated program."""
import argparse
import collections
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT/'selfhost/build/phase147'
sys.dont_write_bytecode = True
sys.path.insert(0,str(ROOT/'selfhost/tools/build'))
import source as assembly
from common import pin, require, same_bytes, verify, write_json


def identity(a,b): return all(a[k] == b[k] for k in ('bytes','sha256'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write',action='store_true',help='Publish fresh metrics/qualification only after every actual gate passes')
    args = parser.parse_args()
    inputs = [pin(__file__),pin(assembly.__file__)]
    def read(file,passed=False):
        file = file if file.is_absolute() else ROOT/file
        inputs.append(pin(file)); value = json.loads(file.read_text())
        require(value.get('complete') is True and not value.get('changedInputs'), 'Incomplete or changed evidence: '+str(file))
        if passed: require(value.get('passed') is True, 'Failed evidence: '+str(file))
        return value
    def evidence(rel,passed=False): return read(BUILD/rel,passed)
    final = pin(BUILD/'integrated-source03/compiler.bend')
    require(final['sha256'] == '0f3bd8a0f29944a317d6de14db05e6e34ba36daa22b350c25236d07519227eaf', 'Wrong final source boundary')
    baseline = pin(BUILD/'baseline-source/compiler.bend')
    require(baseline['sha256'] == '00940ed508e7d1456dd19bee01b0d2e16ac227fdf13ac306e805a1e4c982fb5e', 'Wrong frozen workload source')
    inputs += [final,baseline]
    recipe_file = ROOT/'selfhost/src/compiler.json'; recipe = json.loads(recipe_file.read_text()); inputs.append(pin(recipe_file))
    assembled = assembly.maintained_assemble(recipe_file,ROOT/'selfhost','qbe')
    require(assembled == verify(final).read_bytes(), 'Current maintained source differs from final snapshot')
    def census(file):
        data = verify(file).read_bytes(); _,rows = assembly.blocks(data)
        return dict(bytes=len(data),lines=len(data.splitlines()),declarations=len(rows),byKind=dict(collections.Counter(r['kind'] for r in rows))),assembly.grouped(rows)
    before,before_defs = census(baseline); after,after_defs = census(final)
    law_rows = lambda defs: {name:assembly.normalized([r for r in rows if r['kind'] == 'law'])
                            for name,rows in defs.items() if any(r['kind'] == 'law' for r in rows)}
    require(law_rows(before_defs) == law_rows(after_defs), 'Existing law bodies changed')
    require(before['byKind']['law'] == after['byKind']['law'] == 683, 'Law inventory differs')
    protected = recipe['protectedDeclarations']; require(len(protected) == 112, 'Protected inventory differs')
    for name,expected in protected.items():
        for defs in (before_defs,after_defs):
            require(name in defs and hashlib.sha256(assembly.normalized(defs[name])).hexdigest() == expected['normalizedSha256'], 'Protected declaration changed: '+name)
    installed_file = ROOT/'selfhost/manifests/current.json'
    original_preparation = evidence('verifier-baseline02/manifest.json')
    old_selector = next(p for p in original_preparation['inputs'] if p['file'] == str(installed_file))
    verify(old_selector); inputs.append(old_selector)
    installed = json.loads(installed_file.read_text())
    source_check = evidence('integrated-plan05/source-check/report.json')
    require(source_check['checked'] and identity(source_check['source'],final), 'Final full-book check missing')
    n1 = evidence('integrated-plan05/image/report.json'); n2 = evidence('integrated-sequel02/n2/report.json')
    for stage,report in [('N1',n1),('N2',n2)]:
        binding = report['imageBinding']
        require(binding['complete'] and binding['stage'] == stage and binding['host'] == 'native'
                and binding['protocol'] == 'qbe-source-v1' and identity(binding['sourceIdentity'],final)
                and binding['image'] == report['binary'] and identity(report['request']['source'],final), 'Actual compiler stage/source mismatch')
        verify(binding['image']); verify(report['object']); inputs += [binding['image'],report['object']]
    require(identity(n1['request']['image'],installed['components']['qbe']['image']), 'N1 producer is not frozen selected baseline')
    require(n2['request']['image'] == n1['binary'] and n2['request']['stage'] == 'N1', 'N2 producer lineage mismatch')
    expected = n1['retainedIR']; verify(expected); inputs.append(expected)
    require(n1['irDigest'] == n2['irDigest'] == {k:expected[k] for k in ('bytes','sha256')}
            and n2['comparedToReference'] and identity(n2['expectedQbe'],expected), 'Q1/Q2 complete QBE mismatch')
    q3 = evidence('integrated-sequel02/q3/report.json')
    require(q3['byteExact'] and q3['image'] == n2['binary'] and q3['stage'] == 'N2'
            and identity(q3['source'],final) and identity(q3['product'],expected)
            and same_bytes(verify(q3['product']),verify(expected)), 'Actual Q3 literal identity missing')
    inputs.append(q3['product'])
    suites = []
    for rel,image,stage,count in [('integrated-plan05/qualification-focused',n1['binary'],'N1',19),
                                ('integrated-sequel02/qualification-focused',n2['binary'],'N2',19),
                                ('integrated-sequel02/qualification-broad',n2['binary'],'N2',45)]:
        run = evidence(rel+'/report.json',True)
        require(run['host'] == 'native' and run['target'] == 'qbe' and run['stage'] == stage
                and identity(run['image'],image) and run['counts'] == {'pass':count,'fail':0,'unsupported':0}, 'Actual qualification stage/count mismatch')
        suites.append(dict(stage=stage,cases=count,counts=run['counts'],seconds=run['seconds'],receipt=pin(BUILD/rel/'report.json')))
    corpus = evidence('corpus-identity02/report.json',True)
    require(corpus['image']['image'] == n2['binary'] and len(corpus['rows']) == 61 and len(corpus['negatives']) == 3
            and all(r['qbeExact'] and r['objectExact'] for r in corpus['rows']), 'Complete qualified corpus identity missing')
    controls = []
    for rel,key,label in [('verifier-controls02','rows','verifier fixed expectations'),('verifier-extra02','rows','verifier supplemental semantics'),
                          ('verifier-real03','rows','captured complete verifier functions'),('numeric-controls01','rows','numeric helper flows'),
                          ('render-selected01/controls','rows','selected complete renderer bodies'),('runtime-classifier-controls03','rows','closed runtime-name classifier')]:
        run = evidence(rel+'/report.json',True)
        controls.append(dict(name=label,cases=len(run[key]),receipt=pin(BUILD/rel/'report.json')))
    numeric = evidence('numeric-controls01/report.json',True)
    controls.append(dict(name='isolated schema-count helper boundaries',cases=len(numeric['countBoundaries']),completeEntryExhaustion=False))
    cold = {}
    for role,rel in [('baseline','cold-baseline01'),('intermediate','integrated-plan04/cold'),('final','integrated-plan05/cold')]:
        report = evidence(rel+'/report.json')
        require(identity(report['request']['source'],baseline) and report['irDigest'] == {'bytes':117232528,'sha256':'dceae94a7659ad1ff58395ed34914971422ff9e5841668e910cd95e6b0914010'}, 'Cold request workload/product changed')
        for key in ('binary','assembly','object'): verify(report[key]); inputs.append(report[key])
        cold[role] = dict(receipt=pin(BUILD/rel/'report.json'),image=report['request']['image'],stage=report['request']['stage'],
            imageSourceIdentity=report['request']['imageMetadata']['sourceIdentity'],wallSeconds=report['wallSeconds'],
            emitAndQbeSeconds=report['emitAndQbeSeconds'],qbe=report['irDigest'],assembly=report['assembly'],object=report['object'],binary=report['binary'])
    require(cold['final']['image'] == n1['binary'], 'Final cold clock measured another candidate')
    for role in ('intermediate','final'):
        require(same_bytes(cold['baseline']['assembly']['file'],cold[role]['assembly']['file'])
                and same_bytes(cold['baseline']['object']['file'],cold[role]['object']['file']), 'Cold machine output changed')
    spec = importlib.util.spec_from_file_location('phase147_elf',ROOT/'selfhost/tools/profiler/elf.py')
    elf = importlib.util.module_from_spec(spec); spec.loader.exec_module(elf)
    inputs += [pin(spec.origin),pin(shutil.which('readelf'))]
    old_file,new_file = cold['baseline']['binary']['file'],cold['final']['binary']['file']
    old_loads,new_loads = elf.load_segments(old_file),elf.load_segments(new_file)
    require(old_loads == new_loads, 'Cold ELF load layout changed')
    old_bytes,new_bytes = Path(old_file).read_bytes(),Path(new_file).read_bytes(); loads = []
    for index,(offset,address,size) in enumerate(old_loads):
        left,right = old_bytes[offset:offset+size],new_bytes[offset:offset+size]
        loads.append(dict(index=index,fileOffset=offset,address=address,bytes=size,equal=left == right,
                          differentBytes=0 if left == right else sum(a != b for a,b in zip(left,right))))
    small = {}
    for role,rel in [('intermediate','integrated-plan04/fast-pairs'),('final','integrated-plan05/fast-pairs')]:
        run = evidence(rel+'/report.json',True)
        require(run['images']['new']['binding']['image'] == cold[role]['image']
                and identity(run['images']['old']['binding']['image'],cold['baseline']['image']), 'Fast timing image differs from named revision')
        small[role] = dict(receipt=pin(BUILD/rel/'report.json'),cases=[dict(name=r['name'],source=r['source'],medianSeconds=r['medianSeconds'],ratio=r['ratio'],
            pairRatios=[p['ratio'] for p in r['pairs']],performanceQualified=r['performanceQualified']) for r in run['cases']],pairsPerCase=3)
    micro_file = ROOT/'research/phase147/verifier-fast-loop.json'; inputs.append(pin(micro_file))
    micro = json.loads(micro_file.read_text())
    require(all(r['complete'] and r['passed'] for r in [*micro['timings'],*micro['successor04']['timings']]), 'Incomplete verifier-region measurements')
    render = evidence('render-fragment-native-plan01-original-pairs/report.json',True)
    classifier = evidence('runtime-classifier-pairs02/report.json',True)
    profile = read(ROOT/'research/phase147/final-profile.json')
    registry = next(r for r in profile['exclusiveStageComparison'] if r['label'] == 'registry preparation')
    qualification = dict(kind='phase147-native-qualification',version=1,complete=True,ordinaryNativeQualified=True,
        installedDefaultChanged=False,selectedManifest=old_selector,source=final,sourceChecked=True,sourceCheck=pin(BUILD/'integrated-plan05/source-check/report.json'),
        n1=n1['imageBinding'],n2=n2['imageBinding'],runtime=n2['runtime'],protectedDeclarationsExact=112,
        unchangedLawBodies=after['byKind']['law'],controls=controls,q1q2DigestExact=True,q3ObservedLiteralExact=True,ownSourceQbe=expected,
        selfHostMachineObjectsEqual=identity(n1['object'],n2['object']),selfHostCompleteElfsEqual=identity(n1['binary'],n2['binary']),
        suites=suites,uniqueN2PositivePrograms=61,exactQbeProducts=61,exactMachineObjects=61,independentN2Refusals=3,
        corpus=pin(BUILD/'corpus-identity02/report.json'),inputs=inputs,
        scope='Explicit ordinary serial native QBE candidate, qualified by current focused/broad controls and complete self-host QBE identity. Installed default unchanged. No universal correctness theorem, new JS/C image, broad session/GPU/multi-mutator qualification or upstream speed comparison.')
    metrics = dict(kind='phase147-measured-results',version=1,complete=True,targetsRun=False,source=final,
        installedDefaultChanged=False,selectedManifest=old_selector,
        sourceComplexity=dict(baseline=before,final=after,delta={k:after[k]-before[k] for k in ('bytes','lines','declarations')},
            addedDefinitions=after['byKind']['def']-before['byKind']['def'],addedTypes=after['byKind']['type']-before['byKind']['type'],
            protectedDeclarationsExact=112,scope='Assembled maintained Bend source, including retained independent original verifiers; no conceptual-complexity score.'),
        coldSameFrozenSource=dict(source=baseline,rows=cold,candidateOverBaseline=cold['final']['wallSeconds']/cold['baseline']['wallSeconds'],
            timeReductionPercent=100*(1-cold['final']['wallSeconds']/cold['baseline']['wallSeconds']),
            firstIntegrationReductionPercent=100*(1-cold['intermediate']['wallSeconds']/cold['baseline']['wallSeconds']),
            classifierExtraReductionPercent=100*(1-cold['final']['wallSeconds']/cold['intermediate']['wallSeconds']),
            scope='One observation per version, fresh native processes and prepared Base; complete native.py emission/QBE/assembly/link pipeline. OS caches not flushed; overlapped emission/QBE clock is not pure compiler time. The additional classifier cold change is inconclusive.'),
        coldMachineIdentity=dict(assemblyExact=True,objectsExact=True,completeElfEqual=old_bytes == new_bytes,loadLayoutEqual=True,loadSegments=loads,
            scope='First differing load bytes remain unclassified. Do not claim all ELF/load bytes equal or infer their cause.'),
        wholeRequestFastPairs=small,
        verifierRegionMicro=dict(candidate03=[{k:r[k] for k in ('family','ratio','medianSeconds','pairRatios')} for r in micro['timings']],
            candidate04=[{k:r[k] for k in ('family','ratio','medianSeconds','pairRatios')} for r in micro['successor04']['timings']],scope=micro['sourceScope']),
        rendererRegionMicro=dict(receipt=pin(BUILD/'render-fragment-native-plan01-original-pairs/report.json'),
            cases=[{k:r[k] for k in ('name','medianPairedRatio','medianBaselineSeconds','medianCandidateSeconds')} for r in render['cases']],scope='Captured whole raw function slices under the original scalar-renderer baseline, with byte oracles; not whole-compiler speed.'),
        classifierMicro=dict(receipt=pin(BUILD/'runtime-classifier-pairs02/report.json'),ratio=classifier['ratio'],medianSeconds=classifier['medianSeconds'],
            scope='Frequency-compressed captured symbol workload; not the full registry interval or full compiler.'),
        registryDiagnostic=dict(profile=pin(ROOT/'research/phase147/final-profile.json'),stage=registry,
            scope='Single diagnostic exclusive interval; final496samples below500-sample per-stage quantitative-attribution threshold. Stage clocks are observed, not a causal allocation of clean speed.'),
        acquisition=[dict(stage=stage,seconds=r['wallSeconds'],emitAndQbeSeconds=r['emitAndQbeSeconds'],retainedIR=r['retainIR']) for stage,r in [('N1',n1),('N2',n2)]],
        acquisitionTimingCaveat='Actual costs, not matched speed comparison: N1 retains QBE while N2 does not; both compile the new source, unlike frozen-source cold timing.',
        generatedProgramQuality=dict(uniquePositivePrograms=61,exactQbeProducts=61,exactMachineObjects=61,sameRuntime=True,
            freshRuntimeBenchmark=False,scope='Generated code identity and independent output oracles; no new broad runtime timing or upstream parity claim.'),
        qualification=pin(BUILD/'corpus-identity02/report.json'),inputs=inputs)
    for item in inputs: verify(item)
    if args.write:
        paths = [ROOT/'implementation/phase147'/name for name in ('metrics.json','qualification.json','candidate.json')]
        require(not any(p.exists() for p in paths), 'Fresh final summaries required')
        write_json(paths[0],metrics); write_json(paths[1],qualification)
        candidate = dict(kind='phase147-qualified-native-candidate',version=1,complete=True,installed=False,
            ordinaryNativeQualified=True,source=final,imageBinding=n2['imageBinding'],
            nativeBuild=pin(BUILD/'integrated-sequel02/n2/report.json'),qualification=pin(paths[1]),metrics=pin(paths[0]),
            selectedManifestUnchanged=old_selector,
            scope='Explicit native N2 candidate for ordinary serial QBE requests. Qualification is current cache-mode focused/broad and self-host byte identity; not installed, no new JS/C default, no GPU/multi-mutator/incremental qualification.',
            command=['python3','-B','selfhost/tools/build/request.py','--assets','selfhost/manifests/assets-native.json',
                '--host','native','--target','qbe','--stage','N2','--image',n2['binary']['file'],
                '--image-receipt',str(paths[2]),'--mode','cache','--source','INPUT.bend','--out','FRESH_BUILD_DIRECTORY'])
        write_json(paths[2],candidate)
    print(json.dumps(dict(complete=True,written=args.write,source=final,coldReductionPercent=metrics['coldSameFrozenSource']['timeReductionPercent'],
                         exactPrograms=61,protected=112,installedDefaultChanged=False)))


if __name__ == '__main__': main()
