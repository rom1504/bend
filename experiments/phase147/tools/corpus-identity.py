#!/usr/bin/env python3
"""Authenticate retained QBE references and compare completed qualification products."""
import argparse
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
import assets
from common import fresh_output, pin, require, same_bytes, verify, write_json


def identity(a, b):
    return all(a[k] == b[k] for k in ('bytes','sha256'))


def read(item):
    return json.loads(verify(item).read_text())


def freeze(out):
    require(not out.exists(), 'Fresh reference manifest required')
    catalog_file = ROOT/'selfhost/tools/conformance/qualification-catalog.json'
    qualification_file = ROOT/'implementation/phase146/qualification.json'
    catalog, qualification = json.loads(catalog_file.read_text()), json.loads(qualification_file.read_text())
    require(qualification['complete'] and qualification['nativeQualified'], 'Qualified historical corpus required')
    document = assets.load_assets(ROOT/'selfhost/manifests/assets-native.json',ROOT)
    image, metadata = assets.image(document,'qbe-n2','native','N2','qbe')
    require(identity(image,qualification['n2']) and identity(metadata['sourceIdentity'],qualification['source']),
            'Historical qualification does not belong to current baseline image/source')
    machine = {k:assets.asset(document,k) for k in ('qbe','assembler','linker','qbe-runtime')}
    require(identity(machine['qbe-runtime'],qualification['runtime']), 'Qualified runtime differs')
    inputs = [pin(__file__),pin(catalog_file),pin(qualification_file),document['_manifest'],image,*machine.values()]
    cases = {r['name']:r for r in catalog['cases']}; rows = []
    for suite, directory in [('focused','p146-n2-focused19'),('broad','p146-n2-full45')]:
        suite_pin = next(p for p in qualification['inputs'] if Path(p['file']).parent.name == directory)
        old = read(suite_pin); inputs.append(suite_pin)
        require(old['complete'] and old['passed'], 'Historical suite incomplete')
        for row in old['rows']:
            if not row.get('semanticPass'): continue
            case = cases[row['name']]
            require(case['suite'] == suite and 'refusal' not in case and case['expect'] == row['expected'], 'Source/oracle catalog join differs')
            require(row['status'] == 'passed' and row['compiled'] and row['built'] and row['executed'], 'Historical positive gate incomplete')
            emission = read(row['emission']); build = read(row['build'])
            require(emission['complete'] and identity(emission['image'],image)
                    and all(emission['gates'][k] == 'passed' for k in ('emission','comparison','build','semantics'))
                    and emission['comparison']['byteExact'], 'Qualified original emission required')
            command = next(j['command'] for j in emission['jobs'] if j['label'] == 'native-request')
            offset = command.index('phase111')
            original_source = next(p for p in emission['inputs'] if p['file'] == command[offset+1])
            source = dict(case['source'],file=str(ROOT/case['source']['file']))
            require(identity(source,original_source), 'Historical source bytes differ: '+case['id'])
            require(identity(row['product'],emission['product'])
                    and identity(row['product'],emission['comparison']['product']), 'Original product identity differs')
            require(build['complete'] and build['outputExact'], 'Independent historical execution required')
            for tool in machine.values():
                require(any(identity(tool,p) for p in build['inputs']), 'Historical machine tool/runtime differs')
            jobs = {j['label']:j for j in build['jobs']}
            require(jobs['qbe']['command'][1:3] == ['-t','amd64_sysv']
                    and '-mbranches-within-32B-boundaries' in jobs['assemble']['command']
                    and all(x in jobs['link']['command'] for x in ('-no-pie','-pthread','-lm')), 'Historical machine policy differs')
            current_inputs = [source,row['emission'],row['product'],row['build'],build['object']]
            for item in current_inputs: verify(item)
            inputs += current_inputs
            rows.append(dict(id=case['id'],name=case['name'],suite=suite,source=source,expected=case['expect'],
                historicalSource=original_source,suiteReceipt=suite_pin,emission=row['emission'],product=row['product'],
                build=row['build'],object=build['object'],historicalParentExact=True))
    require(len(rows) == 61 and len({r['id'] for r in rows}) == 61, 'Expected61 unique positive references')
    for item in inputs: verify(item)
    write_json(out,dict(kind='phase147-frozen-qbe-reference-corpus',version=1,complete=True,targetsRun=False,
        inputs=inputs,catalog=pin(catalog_file),baselineImage=image,baselineSource=qualification['source'],machine=machine,
        rows=rows,uniquePositiveCases=61,bytes=sum(r['product']['bytes'] for r in rows),
        scope='61 unique retained complete QBE/object references:16 focused+45 broad. Historical77 included the focused16 twice at N1/N2. No original compiler run or source/output normalization. Historical method/source paths are provenance data only.',
        negativePolicy='Three current refusals are qualified independently. Historical negative-foreign source-admission label is not reused.'))
    print(json.dumps(dict(references=str(out),cases=len(rows),targetsRun=False)))


def compare(args):
    frozen = json.loads(args.references.read_text())
    require(frozen['complete'] and frozen['kind'] == 'phase147-frozen-qbe-reference-corpus', 'Frozen corpus required')
    for item in frozen['inputs']: verify(item)
    image = json.loads(args.image_report.read_text()); binding = image['imageBinding']
    require(image['complete'] and not image['changedInputs'] and binding['complete'] and binding['stage'] == 'N2'
            and binding['host'] == 'native' and binding['protocol'] == 'qbe-source-v1', 'Completed actual N2 required')
    verify(binding['image']); require(identity(binding['linkedRuntime'],frozen['machine']['qbe-runtime']), 'Candidate runtime differs')
    inputs = [pin(__file__),pin(args.references),pin(args.image_report),binding['image'],*frozen['inputs']]
    references = {r['id']:r for r in frozen['rows']}; seen = set(); negatives = []
    out = fresh_output(args.out,ROOT)
    report = dict(kind='phase147-qualified-corpus-product-identity',version=1,complete=False,passed=False,targetsRun=False,
        inputs=inputs,image=binding,rows=[],negatives=negatives,
        scope='Offline literal comparison of complete QBE and machine objects from independently completed qualification runs. No compiler reexecution, normalization, ELF equality or new runtime timing claim.')
    def save(): write_json(out/'report.json',report)
    save()
    try:
        for file in args.qualification:
            run = json.loads(file.read_text()); inputs.append(pin(file))
            require(run['kind'] == 'bend-finite-qualification' and run['complete'] and run['passed']
                    and not run['changedInputs'] and run['host'] == 'native' and run['target'] == 'qbe'
                    and run['stage'] == 'N2' and identity(run['image'],binding['image']), 'Completed same-image native qualification required')
            require(any(identity(p,frozen['catalog']) for p in run['inputs']), 'Qualification catalog differs')
            for row in run['rows']:
                require(row['id'] not in seen and row['status'] == 'pass', 'Duplicate or failed case'); seen.add(row['id'])
                emission = read(row['emission']); inputs.append(row['emission'])
                require(identity(emission['image'],binding['image']), 'Product emitter differs')
                if row['id'] not in references:
                    require(row['id'] in ('focused/negative-type','focused/negative-affine','focused/negative-foreign'), 'Unknown negative case')
                    negatives.append(dict(id=row['id'],status=row['status'],expectedStage=row['expectedStage'],emission=row['emission']))
                    continue
                ref = references[row['id']]; product = emission['product']; build = read(row['build'])
                require(emission['complete'] and not emission['changedInputs'] and identity(emission['source'],ref['source'])
                        and row['expected'] == ref['expected'] and build['complete'] and build['outputExact'], 'Source/oracle/product qualification differs')
                require(identity(build['runtime'],frozen['machine']['qbe-runtime']), 'Built runtime differs')
                for tool in frozen['machine'].values(): require(any(identity(tool,p) for p in build['inputs']), 'Built machine tool differs')
                for item in (product,row['build'],build['object']): verify(item); inputs.append(item)
                actual = dict(id=row['id'],source=emission['source'],reference=ref['product'],product=product,
                    qbeExact=same_bytes(product['file'],ref['product']['file']),object=build['object'],referenceObject=ref['object'],
                    objectExact=same_bytes(build['object']['file'],ref['object']['file']))
                report['rows'].append(actual); save()
                require(actual['qbeExact'] and actual['objectExact'], 'Complete generated bytes changed: '+row['id'])
        require(set(references) <= seen and len(negatives) == 3, 'Full focused+broad qualification required')
        for item in inputs: verify(item)
        report['complete'] = report['passed'] = True
    except BaseException as error:
        report['error'] = repr(error); raise
    finally: save()
    print(json.dumps(dict(passed=True,qbeExact=len(report['rows']),objectsExact=len(report['rows']),refusals=len(negatives),targetsRun=False)))


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__); sub = p.add_subparsers(dest='mode',required=True)
    f = sub.add_parser('freeze'); f.add_argument('--out',type=Path,required=True)
    c = sub.add_parser('compare'); c.add_argument('--references',type=Path,required=True)
    c.add_argument('--image-report',type=Path,required=True); c.add_argument('--qualification',type=Path,action='append',required=True)
    c.add_argument('--out',type=Path,required=True)
    a = p.parse_args(); freeze(a.out) if a.mode == 'freeze' else compare(a)
