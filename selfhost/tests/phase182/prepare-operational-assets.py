#!/usr/bin/env python3
"""Prepare three current operational maps from audited release evidence; never install."""
import argparse
import copy
import json
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
BUILD = ROOT/'selfhost/tools/build'
sys.path.insert(0,str(BUILD))
import assets
import release
from common import changed_inputs, fresh_output, pin, require, verify, write_json


def prepare(a):
    proposal, audit = release.audit(a.promotion,ROOT)
    current = proposal['bindings']; qbe = current['components']['qbe']
    require(current.get('upstream') == '9a4223d577ba56a0cb53d1fd952d2b481c38930f', 'Current Phase182 release required')
    require('hostedApi' in qbe and qbe.get('sessionProtocols') == ['P140/2'],
            'Fresh hosted QBE and native session gates required before preserving operational capabilities')
    hosted = qbe['hostedApi']; receipts = qbe['qualificationReceipts']
    required = {'qbe-qualified','qbe-hosted-acquisition','qbe-hosted-qualified','qbe-session-bootstrap','qbe-session-normal'}
    require(required <= set(receipts), 'Operational gate receipts missing')
    document = assets.load_assets(a.assets,ROOT)
    require(document['upstream'] == current['upstream'] and 'bootstrapBridge' not in document,
            'Ordinary current asset map required; bootstrap bridge maps cannot be published')
    inputs = [pin(__file__),pin(assets.__file__),pin(release.__file__),pin(BUILD/'common.py'),
              pin(a.promotion),document['_manifest'],*proposal['files'].values()]
    for row in proposal['gates'].values(): inputs.append(row['report'])
    for role,key in [('base','base'),('jsLegacyRuntime','js-legacy-runtime'),('jsDirectRuntime','js-runtime'),
                     ('cRuntime','c-runtime'),('cRuntimeTemplate','c-runtime-template'),('qbeRuntime','qbe-runtime')]:
        selected = assets.asset(document,key); inputs.append(selected)
        require(release.same(selected,current['providers'][role]), 'Release/default provider differs: '+role)
    assets.prepared_base(document,'cache')
    for key in ('qbe-runtime','c-runtime'):
        require(assets.runtime_argument_convention(assets.runtime_provider(document,key)) == 'bend-rts-v1',
                'Current runtime convention missing: '+key)
    manifest = pin(ROOT/'selfhost/src/compiler.json'); inputs.append(manifest)
    config = json.loads(verify(manifest).read_text())
    upstream = (ROOT/'selfhost'/config['upstreamPath']).resolve(strict=True)
    require(config['upstream'] == current['upstream'], 'Source/provider upstream differs')
    revision = subprocess.check_output(['git','-C',str(upstream),'rev-parse','HEAD'],text=True,timeout=10).strip()
    dirty = subprocess.check_output(['git','-C',str(upstream),'diff','--name-only','HEAD','--','bend2'],text=True,timeout=10).strip()
    require(revision == current['upstream'] and not dirty,'Actual reference checkout differs')
    common = {key:copy.deepcopy(value) for key,value in document.items() if not key.startswith('_')}
    # Candidate API rows are acquisition artifacts, not installed selectors.
    for key in common.get('images',{}): common['assets'].pop(key,None)
    common['assets']['qbe-n2'] = dict(qbe['image'],executable=True)
    common['assets']['qbe-api'] = hosted['image']
    for name in ('bend','comp','main','safe'):
        row = pin(upstream/'bend2'/(name+'.ts')); inputs.append(row)
        common['assets']['upstream-'+name] = row
    common.setdefault('runtimePolicies',{})['upstream-comp'] = {'runtimeArgumentConvention':'bend-rts-v1'}
    for field,file in [('qualificationCatalog','qualification-catalog.json'),('publicCliCatalog','public-cli-catalog.json')]:
        row = pin(Path(__file__).with_name(file)); inputs.append(row)
        require(json.loads(verify(row).read_text())['upstream'] == current['upstream'],'Default catalog upstream differs')
        common[field] = row
    common['images'] = {
        'qbe-n2':dict(host='native',stage='N2',targets=['qbe'],protocol='qbe-source-v1',
            sourceIdentity=qbe['sourceIdentity'],linkedRuntime=current['providers']['qbeRuntime'],
            runtimeArgumentConvention='bend-rts-v1',preparationModes=['cache','live'],sessionProtocols=['P140/2'],
            qualificationReceipt=receipts['qbe-qualified'],sessionQualification=receipts['qbe-session-bootstrap'],
            sessionScope=qbe['sessionScope'],qualification='Current same-source N2; native64 and positive native session gates.'),
        'qbe-api':dict(host='js',stage='B1',targets=['qbe'],protocol='qbe-api-v1',checked=True,
            sourceIdentity=hosted['sourceIdentity'],exports=hosted['exports'],preparationModes=hosted['preparationModes'],
            acquisitionReceipt=receipts['qbe-hosted-acquisition'],qualificationReceipt=receipts['qbe-hosted-qualified'],
            qualification='Current-source checked cache-only hosted QBE with its own focused19 gate.')}
    common['operationalParent'] = pin(a.promotion)
    common['scope'] = 'Phase182 ordinary operational defaults. Installed images/evidence come from the audited proposal; historical manifests remain separate replay inputs.'
    originals = {}; proposed = {}
    for name in ('assets-native.json','assets-session.json','assets-c-request.json'):
        original_pin = pin(ROOT/'selfhost/manifests'/name); inputs.append(original_pin); originals[name] = original_pin
        original = json.loads(verify(original_pin).read_text())
        require(set(original['images']['qbe-api'].get('exports',[])) <= set(hosted['exports']),
                'Operational hosted export would be lost')
        value = copy.deepcopy(common)
        if name == 'assets-session.json':
            objcopy = original['assets']['objcopy']; verify(dict(objcopy,file=str(ROOT/objcopy['file'])))
            value['assets']['objcopy'] = objcopy; inputs.append(dict(objcopy,file=str(ROOT/objcopy['file'])))
        proposed[name] = value
    require(not changed_inputs(inputs),'Inputs changed during operational preparation')
    out = fresh_output(a.out,ROOT)
    for name,value in proposed.items(): write_json(out/name,value)
    report = dict(kind='phase182-operational-assets-proposal',version=1,complete=True,targetsRun=False,installed=False,
        release=pin(a.promotion),sourceIdentity=current['source']['identity'],originalManifests=originals,
        proposedManifests={name:pin(out/name) for name in proposed},inputs=inputs,
        requiredOrder='Install audited release files first; publish these exact maps only after their installed image/evidence pins verify.',
        preservedCapabilities=dict(hostedQbeExports=len(hosted['exports']),hostedQbeModes=hosted['preparationModes'],
            nativeQbeModes=['cache','live'],nativeSession=['P140/2']),
        scope='Metadata preparation only. Hosted session remains an explicitly selected experimental API; no additional installed session image is invented.')
    require(not changed_inputs(inputs),'Inputs changed before publication proposal completed')
    write_json(out/'report.json',report)
    return out/'report.json'


if __name__ == '__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ('promotion','assets','out'): parser.add_argument('--'+name,type=Path,required=True)
    print(prepare(parser.parse_args()))
