#!/usr/bin/env python3
"""Exercise object-cache identities and corruption handling without executing tools."""
import argparse
import copy
import json
from pathlib import Path
from cache import ObjectCache, digest
from run import pin


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    cache_dir, events, checks = out/'cache', [], []
    build_count = 0
    identity = dict(abi=dict(entry='u32(u64*)',signatures=['u32(u32)']),
                    source='compiler-v1',producer='image-v1',tool='qbe-v1')
    text, name = 'exact IL fixture', 'function_'+'x'*10000

    def request(label, body=text, key=identity):
        nonlocal build_count
        request_out = out/label
        request_out.mkdir()

        def build(obj, asm):
            nonlocal build_count
            build_count += 1
            obj.write_text('non-executable object fixture '+body)
            asm.write_text('assembly fixture '+body)

        obj = ObjectCache(cache_dir,request_out,events).object(name,body,key,build,assembly=True)
        assert len(obj.name) == 66 and obj.name == digest(name)+'.o'
        assert (request_out/(digest(name)+'.s')).exists()
        return events[-1]

    first = request('first')
    assert not first['hit'] and build_count == 1
    second = request('same')
    assert second['hit'] and second['key'] == first['key'] and build_count == 1
    checks += ['cold build','exact identity hit','hashed long filename','assembly retained on hit']
    for field in ['source','producer','tool','abi']:
        changed = copy.deepcopy(identity)
        changed[field] = {'changed':True} if field == 'abi' else 'changed'
        event = request('change-'+field,key=changed)
        assert not event['hit'] and event['key'] != first['key']
        checks.append('changed '+field+' misses')
    changed_text = request('change-text',body=text+' edited')
    assert not changed_text['hit'] and changed_text['key'] != first['key']
    checks.append('changed text misses')
    for filename in ['object.o','assembly.s','record.json']:
        file = cache_dir/first['key']/filename
        file.write_text('corrupt cache fixture')
        before = build_count
        repaired = request('corrupt-'+filename.replace('.','-'))
        assert repaired['corrupt'] and not repaired['hit'] and build_count == before+1
        checks.append('corrupt '+filename+' rebuilt')
    final = request('repaired-hit')
    assert final['hit']
    checks.append('repaired cache reused')
    report = dict(complete=True,targetsExecuted=False,fixtureObjectsExecutable=False,
                  method=pin(__file__),cacheMethod=pin(Path(__file__).with_name('cache.py')),
                  checks=checks,events=events,buildCallbacks=build_count)
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(passed=len(checks),targetsExecuted=False,report=str(out/'report.json'))))


if __name__ == '__main__':
    main()
