#!/usr/bin/env python3
"""Finite native public CLI continuity gate. Run only under the outer process/disk guard."""
import argparse
import json
from pathlib import Path
import shutil
import sys
sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'selfhost/tools/build'))
from common import fresh_output, pin, require, run, same_bytes, verify, write_json

def same(a,b):
    return all(a[k]==b[k] for k in ('bytes','sha256'))

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--package',type=Path,required=True)
    ap.add_argument('--baseline',type=Path,default=ROOT/'selfhost/dist/native')
    ap.add_argument('--cc',type=Path,required=True)
    ap.add_argument('--cc-include',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    args=ap.parse_args()
    package=args.package.resolve(strict=True);baseline=args.baseline.resolve(strict=True)
    authority=json.loads((package/'BUILD.json').read_text())
    old=json.loads((baseline/'BUILD.json').read_text())
    require(authority.get('kind')=='bend-public-cli-package' and authority.get('complete'), 'Constructed public package required')
    require(same(pin(package/'bend'),authority['image']), 'Package image differs')
    require(old.get('kind')=='phase103-native-cli-package-build'
            and same(pin(baseline/'bend'),old['native']['binary']), 'Explicit incumbent public image required')
    profile=json.loads(Path(authority['profile']['file']).read_text())
    oracle_file=Path(__file__).with_name('oracles.json')
    oracles=json.loads(oracle_file.read_text())
    require(oracles.get('kind')=='bend-native-public-cli-oracles' and oracles.get('version')==1,'Independent literal CLI oracles required')
    help_text=oracles['help']
    fixtures={'numeric':ROOT/'selfhost/tests/consolidation/cli/base-u32.bend',
              'io':ROOT/'selfhost/tests/consolidation/hosted/fixtures/io-tree.bend',
              'type-error':ROOT/'selfhost/tests/consolidation/hosted/fixtures/type-error.bend'}
    inputs=[pin(__file__),pin(ROOT/'selfhost/tools/build/common.py'),pin(package/'BUILD.json'),pin(baseline/'BUILD.json'),
            pin(package/'bend'),pin(baseline/'bend'),pin(args.cc),pin(args.cc_include/'stdbool.h'),pin(oracle_file),
            authority['profile'],authority['source'],*authority['inputs'],*map(pin,fixtures.values())]
    for name,row in authority['assets'].items():
        require(same(pin(package/'assets'/name),row),'Package asset differs');inputs.append(row)
        require(same(pin(baseline/'assets'/name),old['inputs']['assets'][name]),'Incumbent asset differs')
        inputs.append(pin(baseline/'assets'/name))
    for row in inputs:verify(row)
    out=fresh_output(args.out,ROOT);copy=out/'relocated package';copy.mkdir()
    shutil.copy2(package/'bend',copy/'bend');shutil.copytree(package/'assets',copy/'assets')
    actual_image=pin(copy/'bend');require(same(actual_image,authority['image']),'Relocated executing image differs')
    report=dict(kind='bend-native-public-cli-qualification',version=1,complete=False,passed=False,qualified=False,
        image=authority['image'],actualExecutingImage=actual_image,source=authority['source'],package=pin(package/'BUILD.json'),profile=authority['profile'],
        inputs=inputs,rows=[],products=[],ordinaryOutputs=[],installed=False,
        scope='Finite native CLI compatibility, exact incumbent C products, two independent complete stdout oracles, '
              'live/cache equality and asset/publication refusal controls. No universal conformance or performance claim.')
    def invoke(name,command,status=0,stdout=None,stderr=None):
        row=run(command,cwd=out,stdout=out/(name+'.stdout'),stderr=out/(name+'.stderr'),seconds=30)
        report['rows'].append(dict(name=name,expectedExitCode=status,**row));write_json(out/'report.json',report)
        require(row.get('exitCode')==status and not row.get('error') and not row.get('timedOut'),name+' process status differs')
        if stdout is not None:require(Path(row['stdout']['file']).read_bytes()==stdout.encode(),name+' stdout differs')
        if stderr is not None:require(Path(row['stderr']['file']).read_bytes()==stderr.encode(),name+' stderr differs')
        report['rows'][-1]['passed']=True
        return row
    cli=str(copy/'bend')
    try:
        invoke('help',[cli,'--help'],stdout=help_text,stderr='')
        invoke('version',[cli,'--version'],stdout=oracles['versionPrefix']+profile['canonicalSource']['sha256'][:12]+'\n',stderr='')
        invoke('no-args',[cli],2,stdout='',stderr='one input and -o OUTPUT.c are required\n'+help_text)
        invoke('unknown-option',[cli,'--not-a-cli-option'],2,stdout='',stderr='unknown option: --not-a-cli-option\n'+help_text)
        for name in ['numeric','io']:
            outputs=[]
            for role,binary in [('baseline',baseline/'bend'),('candidate',copy/'bend')]:
                product=out/(name+'-'+role+'.c')
                invoke(name+'-'+role,[binary,fixtures[name],'-o',product],stdout='',stderr='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n')
                require(product.is_file() and product.stat().st_size>0,'Missing complete C product')
                outputs.append(product)
            require(same_bytes(*outputs),name+' complete incumbent/candidate C differs')
            report['products'].append(dict(name=name,baseline=pin(outputs[0]),candidate=pin(outputs[1]),byteExact=True))
            executable=out/(name+'-program')
            invoke(name+'-build',[args.cc,'-isystem',args.cc_include,'-std=c11','-O3',outputs[1],'-pthread','-lm','-o',executable],stdout='')
            observation=invoke(name+'-run',[executable,'--threads','1','--gpu','off'],stdout=oracles['ordinaryStdout'],stderr='')
            report['ordinaryOutputs'].append(dict(name=name,binary=pin(executable),observation=observation,expectedStdout=oracles['ordinaryStdout'],exact=True))
        live=out/'numeric-live.c'
        invoke('live',[cli,fixtures['numeric'],'-o',live,'--live'],stdout='',stderr='ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n\n')
        require(same_bytes(live,out/'numeric-candidate.c'),'Complete live/cache C differs');report['liveCacheByteExact']=True
        refused=out/'type-error.c'
        invoke('type-refusal',[cli,fixtures['type-error'],'-o',refused],1,stdout='',stderr=oracles['typeRefusal'])
        require(not refused.exists(),'Rejected source published output')
        kept=out/'preserved.c';kept.write_bytes(b'keep original\n');before=pin(kept)
        invoke('no-overwrite',[cli,fixtures['numeric'],'-o',kept],1,stdout='',stderr='File exists\n');verify(before)
        for label,relative in [('base','base.bend'),('effect','effs/print.c')]:
            file=copy/'assets'/relative;original=file.read_bytes();file.write_bytes(original+b'\n# corruption control\n')
            target=out/('bad-'+label+'.c')
            try:
                invoke('corrupt-'+label,[cli,fixtures['io'],'-o',target],1,stdout='',stderr='read '+str(file)+': SHA-256 mismatch\n')
                require(not target.exists(),'Corrupt asset published output')
            finally:file.write_bytes(original)
        require(not list(out.glob('.bend-*')),'Publication temporary remains')
        for name,row in authority['assets'].items():require(same(pin(copy/'assets'/name),row),'Copied assets not restored')
        verify(actual_image)
        for row in inputs:verify(row)
        report.update(complete=True,passed=True,qualified=True)
    except BaseException as error:report['error']=repr(error)
    write_json(out/'report.json',report)
    print(json.dumps({key:report.get(key) for key in ('complete','passed','qualified','error')}))
    return 0 if report['passed'] else 1

if __name__=='__main__':raise SystemExit(main())
