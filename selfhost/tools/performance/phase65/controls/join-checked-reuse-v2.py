#!/usr/bin/env python3
"""Prove checked-gate reuse across host-only changes; never run or rewrite targets."""
import argparse
import copy
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[5]
RAW = ROOT/'selfhost/build/phase65'
READERS = ROOT/'selfhost/tools/performance/phase63/latency/join-final.py'
assert hashlib.sha256(READERS.read_bytes()).hexdigest() == 'fea5078e72aa4c3626366590f3584f16c846b3776fbd1e7125aad784e9598602'
spec = importlib.util.spec_from_file_location('checked_reuse_readers', READERS)
parent = importlib.util.module_from_spec(spec)
spec.loader.exec_module(parent)
pin, read, passed, audit = parent.pin, parent.read, parent.passed, parent.audit


def install_checked_relocations(changed):
    """Retain exact historical host identities; never accept another mismatch."""
    global pin
    original_pin = parent.pin
    assert {x['relative'] for x in changed} == {'tools/typed-driver.mjs','tools/base-cache-graph.mjs'}
    mappings = {}
    for row in changed:
        retained = original_pin(row['old']); selected = original_pin(row['new'])
        logical = str((ROOT/'selfhost'/row['relative']).resolve(strict=True))
        current = original_pin(logical)
        assert current['sha256'] == selected['sha256'] and retained['sha256'] != current['sha256']
        mappings[(logical,retained['sha256'])] = dict(logicalPath=logical,retained=retained,current=current,selected=selected,uses=0)
    def relocated(value):
        if isinstance(value,dict) and value.get('sha256'):
            logical = str(Path(value.get('file') or value.get('path')).resolve(strict=True))
            match = mappings.get((logical,value['sha256']))
            if match is not None:
                if 'canonicalPath' in value: assert value['canonicalPath'] == logical
                if 'bytes' in value: assert value['bytes'] == match['retained']['bytes']
                assert original_pin(logical) == match['current']
                retained = original_pin(match['retained']); match['uses'] += 1
                return retained
        return original_pin(value)
    parent.pin = pin = relocated
    return list(mappings.values())


def attempt(value):
    path = value/'attempt.json' if value.is_dir() else value
    row = read(path)
    assert row['checked'] and row['config']['strictExact'] and row['artifactKind'] == 'derived-b1'
    for key in ['api', 'checkedApi', 'runtime', 'base', 'node', 'bootstrapReport', 'derivationReport']:
        pin(row[key])
    for item in row['artifacts']: pin(item)
    strict = passed(path.parent/'validation-001/report.json')
    assert strict['strictExact'] and pin(strict['attempt'])['sha256'] == pin(path)['sha256']
    assert strict['api']['sha256'] == row['api']['sha256']
    assert strict['selected']['selectedComplete'] and strict['selected']['exactDifferences'] == strict['selected']['discrepancies'] == 0
    assert all(strict['selected'][role]['statuses']['pass'] == 36 for role in ['candidate', 'reference'])
    boot = read(row['bootstrapReport'])
    assert boot['provenance']['verifiedAfterBuild'] and boot['apiSha256'] == row['checkedApi']['sha256']
    for item in boot['provenance']['inputs']: pin(item)
    source = pin(boot['source']); assert source['sha256'] == boot['sourceSha256']
    assert len(boot['exports']) == len(set(boot['exports'])) == 99
    snapshot = Path(row['snapshot']['root'])
    files = {}
    for item in row['snapshot']['sources']:
        frozen = pin(item['frozen']); relative = str(Path(frozen['file']).relative_to(snapshot))
        assert relative not in files; files[relative] = frozen
    return path, row, boot, source, files


def checked_suites(directory, old_api):
    suites = {}
    for group, count, field in [('composition', 18, 'candidatePass'), ('overapplication', 2, 'candidatePass'),
                                 ('source', 96, 'candidateSourcePass'), ('numeric', 34, 'candidatePass')]:
        path = directory/(group+'-controls')/'report.json'; row = passed(path)
        assert row['counts'][field] == row['counts']['total'] == len(row['observations']) == count
        assert all(x[field] and x['pass'] for x in row['observations'])
        suites[group] = pin(path)
        acquired = directory/(group+'-acquisition')/'manifest.json'
        passed(acquired, 'passed'); suites[group+'Acquisition'] = pin(acquired)
    joined = read(directory/'source-join.json'); assert joined['complete']
    for item in joined['parents']: pin(item)
    suites['sourceRoleJoin'] = pin(directory/'source-join.json')
    path = directory/'maintained8/report.json'; row = passed(path)
    assert len(row['tests']) == 8 and all(x['pass'] for x in row['tests'])
    assert row['api']['sha256'] == old_api['sha256']; suites['maintained8'] = pin(path)
    path = directory/'direct-census/report.json'; row = passed(path)
    assert row['semanticAgreement'] == 26 and row['oraclePass'] and row['referenceOraclePass']
    assert row['api']['sha256'] == old_api['sha256']; suites['direct26'] = pin(path)
    path = directory/'native3/report.json'; row = passed(path)
    assert len(row['rows']) == 3 and all(x['pass'] and x['byteEqual'] for x in row['rows'])
    suites['native3'] = pin(path)
    path = directory/'program45-smoke/report.json'; row = passed(path, 'passed')
    assert len(row['cases']) == 45 and all(x['passed'] and x['result']['pass'] for x in row['cases'])
    for item in row['cases']: pin(item['result']['module'])
    suites['program45Smoke'] = pin(path)
    manifest_file = directory/'program45/manifest.json'; manifest = read(manifest_file)
    assert manifest['complete'] and len(manifest['cases']) == 45
    assert len({x['id'] for x in manifest['cases']}) == 45
    assert manifest['roles']['candidate']['compiler']['api']['sha256'] == old_api['sha256']
    preparation = manifest['preparation']; prep = read(dict(preparation, file=str(manifest_file.parent/preparation['path'])))
    assert prep['complete'] and prep['backend'] == 'direct' and len(prep['sources']) == 23
    for item in manifest['cases']:
        module = item['modules']['candidate']; pin(dict(module, file=str(manifest_file.parent/module['path'])))
    suites['program45Preparation'] = pin(manifest_file.parent/preparation['path'])
    suites['program45Manifest'] = pin(manifest_file)
    return suites, pin(manifest_file)


def join(args):
    old_path, old, old_boot, old_source, old_files = attempt(args.old_attempt)
    new_path, new, new_boot, new_source, new_files = attempt(args.new_attempt)
    assert old_path != new_path and set(old_files) == set(new_files)
    equality = {}
    for key in ['api', 'checkedApi', 'runtime', 'base', 'node']:
        left, right = pin(old[key]), pin(new[key]); assert left['sha256'] == right['sha256']
        equality[key] = dict(old=left, new=right)
    assert old_source['sha256'] == new_source['sha256']
    equality['assembledSource'] = dict(old=old_source, new=new_source)
    left, right = old_files['src/runtime/js/direct.mjs'], new_files['src/runtime/js/direct.mjs']
    assert left['sha256'] == right['sha256']; equality['directRuntime'] = dict(old=left, new=right)
    assert old_boot['exports'] == new_boot['exports']; equality['roots'] = old_boot['exports']
    changed = [dict(relative=name, old=old_files[name], new=new_files[name])
               for name in sorted(old_files) if old_files[name]['sha256'] != new_files[name]['sha256']]
    assert {x['relative'] for x in changed} == {'tools/typed-driver.mjs', 'tools/base-cache-graph.mjs'}
    relocations = install_checked_relocations(changed)
    plan = read(args.original_plan); audit(plan)
    assert plan['kind'] == 'phase58-checked-qualification-plan' and plan['scope'] == 'final' and plan['executed'] is False
    assert pin(plan['attempt'])['sha256'] == pin(old_path)['sha256']
    commands = plan['commands']; assert len(commands) == len({x['name'] for x in commands}) == 14
    failed = read(args.failed_execution)
    assert failed['complete'] is False and failed['pass'] is False
    assert pin(failed['plan'])['sha256'] == failed['planSha256'] == pin(args.original_plan)['sha256']
    assert len(failed['steps']) == 12
    for actual, expected in zip(failed['steps'], commands):
        assert actual['name'] == expected['name'] and actual['command'] == expected['command']
    assert all(x['returncode'] == 0 for x in failed['steps'][:11])
    assert failed['steps'][11]['name'] == 'program45-acquisition' and failed['steps'][11]['returncode'] == 2
    resumed = passed(args.resume_execution)
    assert resumed['returncode'] == 0 and len(resumed['steps']) == 3
    resume_plan = read(resumed['plan']); audit(resume_plan)
    assert pin(resumed['plan'])['sha256'] == resumed['planSha256']
    assert resume_plan['commands'] == commands[11:]
    assert pin(resume_plan['resumption']['originalPlan'])['sha256'] == pin(args.original_plan)['sha256']
    assert pin(resume_plan['resumption']['failedExecution'])['sha256'] == pin(args.failed_execution)['sha256']
    assert {k:v for k,v in resume_plan.items() if k not in ['commands','resumption']} == {k:v for k,v in plan.items() if k != 'commands'}
    for actual, expected in zip(resumed['steps'], commands[11:]):
        assert actual['name'] == expected['name'] and actual['command'] == expected['command'] and actual['returncode'] == 0
    successful = failed['steps'][:11] + resumed['steps']
    assert [x['name'] for x in successful] == [x['name'] for x in commands]
    checked_output = Path(plan['outBase']); suites, manifest = checked_suites(checked_output, old['api'])
    for item in list(parent.INPUTS.values()): pin(item)
    return dict(kind='phase65-checked-gates-reuse', complete=True, **{'pass':True}, dataOnly=True, targetExecuted=False,
        producer=pin(__file__), receiptReaders=pin(READERS), oldAttempt=pin(old_path), newAttempt=pin(new_path),
        checkedOutput=str(checked_output), qualifiedManifest=manifest, compilerEquality=equality,
        frozenSources=dict(count=len(old_files), unchangedCount=len(old_files)-len(changed), changed=changed),
        historicalInputRelocations=relocations,
        executionCoverage=dict(originalPlan=pin(args.original_plan), failedExecution=pin(args.failed_execution),
            resumePlan=pin(resumed['plan']), resumeExecution=pin(args.resume_execution), successfulPrefixCount=11,
            successfulSuffixCount=3, commandCount=14, commandNames=[x['name'] for x in commands],
            failedCommand=dict(index=11,name=failed['steps'][11]['name'],returncode=2), failedReportRetained=True),
        suiteReports=suites, verifiedInputCount=len(parent.INPUTS),
        verifiedInputIndexSha256=hashlib.sha256(json.dumps(sorted(parent.INPUTS.values(),key=lambda x:x['file']),sort_keys=True).encode()).hexdigest(),
        scope='Reuse of checked compiler semantic/native/emitted-program gates only, with exact compiler/source/runtime/Base/99-root equality and host-only frozen differences. Failed original execution remains failed; eleven successful prefix commands plus three exact resumed suffix commands cover fourteen once. New host controls, fresh selected B2 lineage/semantics/fixed-point, broad latency and release remain separate gates.')


def b2_plan(args):
    reuse = passed(args.reuse_receipt)
    assert reuse['kind'] == 'phase65-checked-gates-reuse' and reuse['targetExecuted'] is False
    pin(reuse['producer']); pin(reuse['oldAttempt']); pin(reuse['newAttempt'])
    for item in reuse['suiteReports'].values(): pin(item)
    for item in reuse['executionCoverage'].values():
        if isinstance(item, dict) and 'sha256' in item: pin(item)
    plan = read(args.original_plan); audit(plan)
    assert plan['kind'] == 'phase58-final-stage-plan' and plan['stage'] == 'b2' and plan['executed'] is False
    assert pin(plan['attempt'])['sha256'] == reuse['newAttempt']['sha256']
    assert len(plan['commands']) == 5 and plan['commands'][4]['name'] == 'b2-program-equality'
    original = copy.deepcopy(plan); command = plan['commands'][4]['command']
    old = str(Path(command[-1]).parent/'checked/program45/manifest.json')
    assert command[-2] == old and sum(x['command'].count(old) for x in plan['commands']) == 1
    replacement = pin(reuse['qualifiedManifest'])
    command[-2] = replacement['file']
    assert plan['commands'][:4] == original['commands'][:4]
    differences = [(i,a,b) for i,(a,b) in enumerate(zip(original['commands'][4]['command'],command)) if a != b]
    assert len(differences) == 1
    plan['originalPlan'] = pin(args.original_plan)
    plan['reuseReceipt'] = pin(args.reuse_receipt)
    plan['reuseManifestEdit'] = dict(commandIndex=4,argumentIndex=differences[0][0],old=old,new=replacement['file'])
    plan['inputs'] += [pin(__file__),pin(args.original_plan),pin(args.reuse_receipt),replacement]
    return plan


def main():
    parser = argparse.ArgumentParser(description=__doc__); modes = parser.add_subparsers(dest='mode',required=True)
    sub = modes.add_parser('join')
    for name in ['old-attempt','new-attempt','original-plan','failed-execution','resume-execution','out']:
        sub.add_argument('--'+name,type=Path,required=True)
    sub = modes.add_parser('b2-plan')
    for name in ['original-plan','reuse-receipt','out']: sub.add_argument('--'+name,type=Path,required=True)
    args = parser.parse_args(); out = args.out.resolve()
    assert out.is_relative_to(RAW) and not out.exists()
    result = join(args) if args.mode == 'join' else b2_plan(args)
    out.parent.mkdir(parents=True,exist_ok=True)
    with out.open('x') as stream: stream.write(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(output=pin(out),targetExecuted=False)))


if __name__ == '__main__': main()
