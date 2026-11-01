#!/usr/bin/env python3
"""Prepare an exact-provider build-only C bridge from the canonical compiler."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import sys
sys.dont_write_bytecode = True
import source as assembly
from common import ROOT, fresh_output, pin, require, verify, write_json

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--profile',type=Path,required=True)
    ap.add_argument('--assets',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    args=ap.parse_args()
    profile=json.loads(args.profile.read_text())
    require(profile.get('kind')=='bend-public-cli-source-profile' and profile.get('complete') and profile['allOtherBodiesIdentical'],'Exact public profile required')
    manifest=ROOT/'selfhost/src/compiler.json'
    canonical=assembly.maintained_assemble(manifest,ROOT/'selfhost','qbe')
    require(len(canonical)==profile['canonicalSource']['bytes'] and hashlib.sha256(canonical).hexdigest()==profile['canonicalSource']['sha256'],'Canonical source differs from profile')
    source=assembly.maintained_assemble(manifest,ROOT/'selfhost','native-c')
    _,rows=assembly.blocks(source);before=assembly.grouped(rows)
    require(not any(name.startswith('cli_build_') for name in before),'Build-only name collision')
    require(not any(name in before for name in ['NativeHost.read','NativeHost.path','NativeHost.publish']),'Bridge must have no NativeHost foreign declarations')
    def change(name,old,new):
        nonlocal source
        require(len(before[name])==1 and before[name][0]['data'].count(old)==1,'Exact policy seam differs: '+name)
        original=before[name][0]['data'];require(source.count(original)==1,'Ambiguous policy body')
        source=source.replace(original,original.replace(old,new))
    change('p86_effect_file',b'def p86_effect_file(',b'def cli_build_effect_file_original(')
    change('no_effect_definitions',b'v => no_effect_foreign_allowed(db(d), String.eq(tg(nc_unann(dv(d))), "Foreign"), dn(d)),',
           b'v => cli_build_host_foreign(d) || no_effect_foreign_allowed(db(d), String.eq(tg(nc_unann(dv(d))), "Foreign"), dn(d)),')
    change('p118np_foreign',b'Bool.not(db(d)) &&',b'Bool.not(db(d) || cli_build_host_foreign(d)) &&')
    host=profile['foreignProvider'];verify(host)
    provider=Path(profile['source']['file']).parent/'native-os.c'
    require(pin(provider)['sha256']==host['sha256'],'Actual profile foreign provider differs')
    names=['NativeHost.read','NativeHost.path','NativeHost.publish']
    paths=[str(provider),str(provider.parent)+'/./native-os.c']
    predicate=' || '.join('kf_has_path(ks(nc_unann(dv(d))), '+json.dumps(p)+')' for p in paths)
    extra='\n@unsafe\ndef p86_effect_file(+base: String, +path: String) -> String:\n  kc(String, '+ ' || '.join('String.eq(path, '+json.dumps(p)+')' for p in paths)+', u => "native-os.c", u => cli_build_effect_file_original(base, path))\n'
    extra+='\n@unsafe\ndef cli_build_host_foreign(+d: KDef) -> Bool:\n  p98_tag_eq(nc_unann(dv(d)), "Foreign") && no_effect_provider_member('+json.dumps(names)+', dn(d)) && ('+predicate+')\n'
    source+=extra.encode()
    _,rows=assembly.blocks(source);after=assembly.grouped(rows)
    changed=[name for name in before if assembly.normalized(before[name])!=assembly.normalized(after[name])]
    require(set(changed)=={'p86_effect_file','no_effect_definitions','p118np_foreign'},'Unexpected build-only body change')
    require(set(after)-set(before)=={'cli_build_effect_file_original','cli_build_host_foreign'},'Unexpected build-only declarations')
    inputs=[pin(__file__),pin(assembly.__file__),pin(args.profile),pin(args.assets),pin(manifest),host,*profile['inputs']]
    inputs += [pin(ROOT/'selfhost'/name) for name in json.loads(manifest.read_text())['modules']]
    for row in inputs:verify(row)
    out=fresh_output(args.out,ROOT);(out/'compiler.bend').write_bytes(source)
    assets=json.loads(args.assets.read_text());require(assets['kind']=='bend-build-assets' and assets['complete'],'Explicit operational assets required')
    providers=[]
    for name,row in [*[(n[5:],r) for n,r in profile['assets'].items() if n.startswith('effs/')],('native-os.c',host)]:
        dest=out/'effs'/name;dest.parent.mkdir(exist_ok=True);dest.write_bytes(verify(row).read_bytes())
        key='cli-build-'+name[:-2];assets['assets'][key]=pin(dest);providers.append(key)
    assets['providers']['c']['effects']=providers
    require('runtimeTemplate' in assets['providers']['c'],'Prepared C runtime template is required')
    assets['scope']='Build-only exact-profile provider map. Not an ordinary compiler permission or installed release.'
    assets['parentManifest']=pin(args.assets)
    write_json(out/'assets.json',assets)
    report=dict(kind='bend-public-cli-build-bridge',version=1,complete=True,targetsRun=False,installed=False,
        source=pin(out/'compiler.bend'),canonicalSource=profile['canonicalSource'],profile=pin(args.profile),
        publicSource=profile['source'],foreignProvider=host,allowedNames=names,allowedPaths=paths,
        changedDeclarations=changed,addedDeclarations=sorted(set(after)-set(before)),allOtherBodiesIdentical=True,
        assets=pin(out/'assets.json'),inputs=inputs,
        scope='Build-only producer: exact three foreign names and exact provider paths receive observer/packing permission. '
              'Provider bytes are authenticated before/after acquisition. The emitted public CLI retains ordinary restricted admission unchanged.')
    write_json(out/'report.json',report);print(json.dumps({'complete':True,'source':report['source'],'report':str(out/'report.json')}))

if __name__=='__main__':main()
