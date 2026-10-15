#!/usr/bin/env python3
"""Test a deliberately bad C lifetime operation outside the Bend theorem scope."""
import argparse
import sys
sys.dont_write_bytecode=True
from common import BUILD,CLANG,ROOT,pin,save,read,verify,run,passed


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--out',type=__import__('pathlib').Path,required=True)
    out=parser.parse_args().out.resolve();assert out.is_relative_to(BUILD);out.mkdir(parents=True,exist_ok=False)
    old=ROOT/'selfhost/build/phase96/audit01/production-native'
    prior=read(old/'report.json');assert prior['complete'] and prior['cases']==32
    worker=read(old/'execution/report.json');assert worker['complete'] and worker['passed'] and worker['inputsUnchanged']
    pins=[pin(__file__),pin(ROOT/'selfhost/tools/laws/phase97/common.py'),pin(old/'report.json'),pin(old/'execution/report.json'),
          prior['binary'],prior['expected'],prior['clang'],worker['product']]
    for item in pins:verify(item)
    source=__import__('pathlib').Path(worker['product']['file']).read_text()
    start=source.index('OUTLINE void span_fade(');end=source.index('\n}\n',start)+3
    before=source[start:end]
    old_line='rfc_bump(e, term_loc(f), 1);';new_line='rfc_bump(e, term_loc(f), 0); /* Phase97 deliberate missing child retain */'
    assert before.count(old_line)==1
    after=before.replace(old_line,new_line)
    candidate=out/'missing-retain.c';candidate.write_text(source[:start]+after+source[end:])
    report=dict(complete=False,scope='Deliberately incorrect generated-C runtime, outside unchanged source-level Bend proofs. No production edit.',
                inputs=pins,candidate=pin(candidate),mutation=dict(function='span_fade',before=before,after=after),rows={})
    def write():save(out/'report.json',report)
    write()
    try:
        baseline=run(out/'baseline',[prior['binary']['file']],30);report['rows']['baseline']=baseline;write()
        assert passed(baseline) and not baseline['stderr']
        expected=__import__('pathlib').Path(prior['expected']['file']).read_text()
        assert baseline['stdout']==expected
        binary=out/'missing-retain'
        build=run(out/'build',[CLANG,'-isystem',CLANG.parent.parent/'include/clang','-std=c11','-O3',candidate,'-o',binary,'-lm','-pthread'],120)
        report['rows']['build']=build;write();assert passed(build)
        report['binary']=pin(binary)
        mutated=run(out/'mutated',[binary],15);report['rows']['mutated']=mutated;write()
        report['detected']=not passed(mutated) or mutated['stdout']!=expected
        report['classification']=('resource-stop-inconclusive' if mutated['process'].get('stoppedFor') else
                                  'runtime-rejection' if mutated['process']['returncode']!=0 else
                                  'full-output-mismatch' if mutated['stdout']!=expected else 'escaped')
        for item in pins:verify(item)
        report.update(complete=True,inputsUnchanged=True)
    except BaseException as error:report['error']=repr(error);raise
    finally:write()
    print(__import__('json').dumps({k:report[k] for k in ['complete','detected','classification']}))


if __name__=='__main__':main()
