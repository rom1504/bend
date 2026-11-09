#!/usr/bin/env python3
"""Audit explicit promotion evidence; install with rollback and publish one selector."""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import shutil
import sys

sys.dont_write_bytecode = True
import source as assembly
import release_bridge
from common import fresh_output, pin, require, verify as check_pin, workspace, write_json


def same(a, b):
    return isinstance(a, dict) and isinstance(b, dict) and all(a.get(k) == b.get(k) and k in a for k in ('bytes', 'sha256'))


def at(document, dotted):
    for key in dotted.split('.'):
        document = document[key]
    return document


def path(root, name):
    result = root / name
    require(result.absolute() == result.resolve() and '..' not in Path(name).parts, 'Noncanonical/symlink path: ' + str(name))
    return result


def bound(row, root):
    return check_pin(dict(row, file=str(path(root, row['file']))))


def bindings(document, root, candidates=None):
    require(document.get('kind') == 'bend-current-bindings' and document.get('version') == 1 and document.get('complete') is True, 'Complete current bindings required')
    files = document['files']
    require(0 < len(files) <= 256, 'Bounded installed file inventory required')
    for name, row in files.items():
        require(name.startswith('selfhost/dist/') and Path(name) == Path(row['file']), 'Installed file must have exact dist-relative identity')
        path(root, name)
        if candidates is not None:
            require(name in candidates and same(row, candidates[name]), 'Promotion/install artifact mismatch')
            bound(candidates[name], root)
        else:
            bound(row, root)
    source = document['source']
    recipe = bound(source['recipe'], root)
    assembled = assembly.maintained_assemble(recipe, path(root, source['root']), source['profile'])
    require(same(dict(bytes=len(assembled), sha256=hashlib.sha256(assembled).hexdigest()), source['identity']), 'Maintained source differs from release source')
    components = document['components']
    require(set(components) in ({'qbe', 'js', 'nativeCli'}, {'qbe', 'js', 'nativeCli', 'x86'}), 'All base components and only recognized targets required')
    contracts = [('qbe','native','N2','qbe-source-v1'),('js','js','B2','hosted-api-v1'),('nativeCli','native','N1','native-public-cli-v1')]
    if 'x86' in components:
        contracts.append(('x86','native','N2','native-x86-source-v1'))
    for key, host, stage, protocol in contracts:
        item = components[key]
        require((item['host'],item['stage'],item['protocol']) == (host,stage,protocol), 'Wrong actual component host/stage/protocol: ' + key)
        require(item.get('capabilities') and item['image']['file'] in files and same(item['image'], files[item['image']['file']]), 'Component image not bound to installed files')
        require(set(item['capabilities']) <= ({'js','c','qbe'} if host == 'js' else {'c'} if key == 'nativeCli' else {'x86'} if key == 'x86' else {'qbe'}), 'Unsupported capability')
        if host == 'native':
            require(os.access(bound(candidates[item['image']['file']] if candidates is not None else item['image'],root),os.X_OK), 'Native component is not executable')
        if key == 'x86':
            profile = item['sourceProfile']
            require(profile['recipe'] == source['recipe'] and profile['root'] == source['root']
                    and profile['profile'] == 'x86', 'Assembly must use the maintained x86 source profile')
            emitted = assembly.maintained_assemble(recipe, path(root, profile['root']), 'x86')
            require(same(dict(bytes=len(emitted), sha256=hashlib.sha256(emitted).hexdigest()), item['sourceIdentity']), 'Assembly profile differs from selected compiler source')
            require(item.get('runtimeArgumentConvention') == 'bend-rts-v1' and item.get('linkedRuntimeABI') == 11102
                    and same(item.get('linkedRuntime'), document['providers']['qbeRuntime']), 'Assembly runtime binding differs')
        elif key == 'qbe' and not same(item['sourceIdentity'], source['identity']):
            require(release_bridge.shape(item,source['identity']), 'Explicit QBE canonical-source equivalence required')
        elif key != 'nativeCli':
            require(same(item['sourceIdentity'], source['identity']), 'Component does not derive from the canonical source')
    for row in document.get('providers', {}).values():
        if row['file'] in files:
            require(same(row, files[row['file']]), 'Installed provider identity differs')
        else:
            bound(row, root)
    return document


def audit(file, root):
    manifest = pin(file)
    promotion = json.loads(Path(manifest['file']).read_text())
    require(promotion.get('kind') == 'bend-release-promotion' and promotion.get('version') == 1 and promotion.get('complete') is True, 'Complete explicit promotion proposal required')
    current = bindings(promotion['bindings'], root, promotion['files'])
    require(set(promotion['files']) == set(current['files']), 'Unexpected install artifact')
    gates, checked = promotion['gates'], {}
    require(0 < len(gates) <= 64, 'Bounded explicit gates required')
    for name, gate in gates.items():
        report = json.loads(bound(gate['report'], root).read_text())
        require(report.get('complete') is True and not report.get('changedInputs') and not report.get('error'), 'Incomplete/changed/failed gate: ' + name)
        require(gate['role'] in ('qualification','lineage','derivation') and gate.get('claims'), 'Gate role and claims required')
        if gate['role'] == 'qualification':
            statuses = [report[k] for k in ('passed','qualified','nativeQualified') if k in report]
            require(statuses and all(value is True for value in statuses), 'Qualification did not pass: ' + name)
        for field, expected in gate['claims'].items():
            require(type(at(report,field)) is type(expected) and at(report,field) == expected, 'Gate claim differs: ' + name + ':' + field)
        for field, expected in gate.get('bindings', {}).items():
            require(same(at(report,field), expected), 'Gate artifact/source identity differs: ' + name + ':' + field)
        checked[name] = report
    for name, component in current['components'].items():
        selected = [gates[key] for key in component['gates']]
        image, source = component['image'], component['sourceIdentity']
        require(any(g['role'] == 'qualification' and any(same(v,image) for v in g.get('bindings',{}).values()) for g in selected), 'Independent image qualification missing: ' + name)
        require(any(any(same(v,image) for v in g.get('bindings',{}).values()) and any(same(v,source) for v in g.get('bindings',{}).values()) for g in selected), 'Image/source lineage missing: ' + name)
    release_bridge.audit(current,checked)
    js = checked[promotion['jsFixedPoint']]
    require(js.get('kind') == 'bend-js-self-emission' and js.get('stage') == 'B3' and all(js.get(k) is True for k in ('freshSelfCheck','typeAccepted','byteEquality')), 'Actual B2 self-check/B3 fixed point required')
    require(same(js['generator'], current['components']['js']['image']) and same(js['image'], js['generator']) and same(js['source'], current['source']['identity']), 'JS generation/source/equality mismatch')
    cli = checked[promotion['nativeCliDerivation']]
    require(cli.get('kind') == 'bend-public-cli-source-profile' and cli.get('allOtherBodiesIdentical') is True and set(cli['changedDeclarations']) == {'main','p86_effect_read'}, 'Public CLI profile differs from admitted seams')
    require(same(cli['canonicalSource'], current['source']['identity']) and same(cli['source'], current['components']['nativeCli']['sourceIdentity']), 'CLI profile does not derive from canonical source')
    if 'x86' in current['components']:
        audit_x86(current, promotion, checked, root)
    receipt = dict(kind='bend-release-audit', version=1, complete=True, qualified=True, method=pin(__file__), bridgeMethod=pin(release_bridge.__file__), promotion=manifest, gates={k:v['report'] for k,v in gates.items()}, sourceIdentity=current['source']['identity'], components=current['components'], installed=False, mathematicalProof=False)
    return promotion, receipt



def audit_x86(current, promotion, checked, root):
    """Actual assembly generations and independent source/behavior gates."""
    component = current['components']['x86']
    image, source, runtime = component['image'], component['sourceIdentity'], current['providers']['qbeRuntime']
    names = promotion['x86Qualification']
    require(set(names) == {'sourceCheck', 'seed', 'n1', 'n2', 'reproduction', 'behavior', 'runtime'}, 'Complete explicit assembly gates required')
    require(set(names.values()) <= set(component['gates']), 'Assembly mandatory gate not selected')
    source_check, seed, n1, n2, reproduced, behavior, runtime_controls = (checked[names[k]] for k in
        ['sourceCheck','seed','n1','n2','reproduction','behavior','runtime'])
    require(source_check.get('kind') == 'bend-independent-source-check'
            and source_check.get('checked') is True and source_check.get('typeAccepted') is True
            and source_check.get('unresolvedHoles') == 0 and same(source_check['source'], source)
            and source_check['upstream'] == current['upstream'], 'Independent current-upstream assembly source check required')
    producer = current['components']['qbe']
    for report, stage, target in [(seed,'N0','qbe'),(n1,'N1','x86'),(n2,'N2','x86')]:
        binding, request = report['imageBinding'], report['request']
        metadata = request['imageMetadata']
        require(report.get('kind') == 'bend-native-build' and report.get('target') == target
                and binding.get('complete') is True
                and (binding['host'],binding['stage'],binding['protocol']) == ('native',stage,'native-x86-source-v1')
                and binding['targets'] == ['x86'] and same(binding['image'],report['binary'])
                and same(binding['sourceIdentity'],source) and same(request['source'],source)
                and same(report['runtime'],runtime) and same(binding['linkedRuntime'],runtime)
                and report.get('runtimeABI') == 11102
                and report.get('runtimeArgumentConvention') == 'bend-rts-v1'
                and binding.get('linkedRuntimeABI') == 11102
                and binding.get('runtimeArgumentConvention') == 'bend-rts-v1', 'Actual same-source/current-runtime assembly '+stage+' required')
        require((request['host'],request['stage'],request['target']) == ('native',producer['stage'],target)
                and (report['host'],report['stage']) == ('native',producer['stage'])
                and request.get('outputContract') == 'stdout' and same(request['image'],producer['image'])
                and (metadata['host'],metadata['stage'],metadata['protocol']) ==
                    ('native',producer['stage'],producer['protocol'])
                and target in metadata.get('targets', [])
                and same(metadata['sourceIdentity'],producer['sourceIdentity'])
                and same(metadata.get('linkedRuntime'),runtime)
                and metadata.get('runtimeArgumentConvention') == 'bend-rts-v1'
                and same(binding['producer'],request['image'])
                and (binding['producerHost'],binding['producerStage']) == (request['host'],request['stage']),
                'Actual selected producer and request binding required for assembly '+stage)
        producer = binding
    require(same(n1['request']['image'],seed['binary']) and n1['request']['stage'] == 'N0'
            and same(n2['request']['image'],n1['binary']) and n2['request']['stage'] == 'N1'
            and same(n2['binary'],image) and n2.get('comparedToReference') is True
            and same(n1['assemblyDigest'],n2['assemblyDigest'])
            and same(n2['expectedAssembly'],n1['assemblyDigest']), 'Actual N0 to N1 to N2 assembly reproduction required')
    process, request = reproduced['process'], reproduced['request']
    metadata = request['imageMetadata']
    require(reproduced.get('kind') == 'bend-build-request' and reproduced.get('byteExact') is True
            and (reproduced['host'],reproduced['stage'],reproduced['target']) == ('native','N2','x86')
            and same(reproduced['image'],image) and same(reproduced['source'],source)
            and (request['host'],request['stage'],request['target']) == ('native','N2','x86')
            and request.get('outputContract') == 'stdout'
            and same(request['image'],image) and same(request['source'],source)
            and (metadata['host'],metadata['stage'],metadata['protocol']) == ('native','N2','native-x86-source-v1')
            and metadata.get('targets') == ['x86'] and same(metadata['sourceIdentity'],source)
            and same(metadata.get('linkedRuntime'),runtime) and metadata.get('linkedRuntimeABI') == 11102
            and metadata.get('runtimeArgumentConvention') == 'bend-rts-v1'
            and same(reproduced['product'],n2['assemblyDigest'])
            and same(request['expected'],reproduced['product'])
            and same(process['stdout'],reproduced['product']) and process.get('complete') is True
            and process.get('exitCode') == 0 and not process.get('timedOut') and not process.get('error')
            and process['stderr']['bytes'] == 0, 'Actual N2 same-source assembly re-emission required')
    catalog_pin = promotion['x86QualificationCatalog']
    catalog = json.loads(bound(catalog_pin, root).read_text())
    require(catalog.get('kind') == 'bend-qualification-catalog' and catalog.get('version') == 1
            and catalog.get('upstream') == current['upstream']
            and isinstance(catalog.get('cases'), list) and len(catalog['cases']) == 64
            and all(isinstance(case.get('id'), str) and case['id'] for case in catalog['cases']),
            'Explicit current-upstream native64 catalog required')
    case_ids = {case['id'] for case in catalog['cases']}
    require(len(case_ids) == 64, 'Distinct native64 catalog cases required')
    require(behavior.get('kind') == 'bend-finite-qualification' and behavior.get('passed') is True
            and (behavior['host'],behavior['stage'],behavior['target']) == ('native','N2','x86')
            and behavior['upstream'] == current['upstream'] and same(behavior['image'],image)
            and same(behavior['catalog'],catalog_pin)
            and any(same(row,runtime) for row in behavior.get('inputs', []))
            and behavior['counts'] == {'pass':64,'fail':0,'unsupported':0}
            and len(behavior['selected']) == len(set(behavior['selected'])) == len(behavior['rows']) == 64
            and {row['id'] for row in behavior['rows']} == set(behavior['selected']) == case_ids
            and all(row['status'] == 'pass' for row in behavior['rows']), 'Actual N2 current-upstream native64 required')
    runtime_cases = ['numeric', 'array-unchecked', 'array-unchecked-boxed', 'char-output',
                     'argv', 'files', 'open-errors', 'exit', 'exit-upper-valid', 'halt-valid']
    require(runtime_controls.get('kind') == 'phase183-x86-runtime-controls'
            and runtime_controls.get('passed') is True and same(runtime_controls['image'],image)
            and (runtime_controls['host'],runtime_controls['stage'],runtime_controls['target']) == ('native','N2','x86')
            and same(runtime_controls.get('runtime'),runtime) and runtime_controls.get('runtimeABI') == 11102
            and runtime_controls['selection'] == dict(all=True, count=10, total=10, names=runtime_cases)
            and len(runtime_controls['rows']) == 10
            and {row['name'] for row in runtime_controls['rows']} == set(runtime_cases)
            and all(row.get('complete') is True for row in runtime_controls['rows']),
            'Actual N2 current-runtime ten controls required')


def installed(file, root):
    document = bindings(json.loads(Path(file).read_text()), root)
    require(document.get('gateStatus', {}).get('qualified') is True, 'Published qualification state missing')
    bound(document['provenance'], root)  # Hash only; never traverse historical methods.
    return dict(complete=True, manifest=pin(file), sourceIdentity=document['source']['identity'], operationalOnly=True)


def install(file, root, out):
    proposal, evidence = audit(file, root)
    require(shutil.disk_usage(root).free >= 5*1024**3 + 2*sum(p['bytes'] for p in proposal['files'].values()), 'Install staging/backups require bytes plus 5 GiB reserve')
    out = fresh_output(out, root)
    write_json(out/'audit.json', evidence)
    current = copy.deepcopy(proposal['bindings'])
    copies = dict(proposal['files'])
    audit_name = 'selfhost/dist/current-audit.json'
    require(audit_name not in copies, 'Audit path is reserved')
    copies[audit_name] = pin(out/'audit.json')
    current['files'][audit_name] = dict(copies[audit_name], file=audit_name)
    current['provenance'] = current['files'][audit_name]
    current['gateStatus'] = dict(qualified=True, mathematicalProof=False, components={k:v['gates'] for k,v in current['components'].items()})
    selector = 'selfhost/manifests/current.json'
    staged, backups, applied = {}, {}, []
    report = dict(kind='bend-release-install', complete=False, audit=pin(out/'audit.json'), mutations=[], rollback=False)
    try:
        for index, (name, row) in enumerate(copies.items()):
            staged[name] = out/('stage-'+str(index))
            shutil.copy2(bound(row,root), staged[name])
            require(same(pin(staged[name]),row), 'Staged artifact differs')
        staged[selector] = out/'current.json'
        write_json(staged[selector],current)
        for index, name in enumerate(staged):
            destination = path(root,name)
            if destination.exists():
                backups[name] = out/('backup-'+str(index))
                shutil.copy2(destination,backups[name])
            else:
                backups[name] = None
        report['backups'] = {name:str(value) if value else None for name,value in backups.items()}
        write_json(out/'report.json',report)
        audit(file,root)  # Revalidate inputs and gates after staging, before publication.
        for name, temporary in staged.items():  # Selector is deliberately last.
            destination = path(root,name)
            destination.parent.mkdir(parents=True,exist_ok=True)
            applied.append(name)
            os.replace(temporary,destination)
            report['mutations'].append(name)
            write_json(out/'report.json',report)
        report['verification'] = installed(root/selector,root)
        report['complete'] = True
    except BaseException as error:
        report['error'] = repr(error)
        for name in reversed(applied):
            destination = path(root,name)
            if backups[name] is None:
                destination.unlink(missing_ok=True)
            else:
                restored = out/'restore.tmp'
                shutil.copy2(backups[name],restored)
                os.replace(restored,destination)
        report['rollback'] = True
    write_json(out/'report.json',report)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('operation',choices=['verify','audit','install'])
    parser.add_argument('--workspace',type=Path)
    parser.add_argument('--manifest',type=Path,required=True)
    parser.add_argument('--out',type=Path)
    args = parser.parse_args(); root = workspace(args.workspace)
    if args.operation == 'verify':
        result = installed(args.manifest,root)
    else:
        require(args.out is not None,'Fresh audit report/install transaction path required')
        if args.operation == 'audit':
            require(not args.out.exists(),'Fresh audit report required')
            _, result = audit(args.manifest,root); write_json(args.out,result)
        else:
            result = install(args.manifest,root,args.out)
    print(json.dumps(result,indent=2))
    return 0 if result['complete'] else 1


if __name__ == '__main__':
    sys.exit(main())
