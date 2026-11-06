#!/usr/bin/env python3
"""Offline streaming census of two built native products; executes neither."""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path

HEADER = re.compile(rb'^(?:export )?function [wl] \$([A-Za-z0-9_]+)\(')
CALL = re.compile(rb'\bcall \$([A-Za-z0-9_]+)')
HOT = {'lookup','index_find','index_set','p131i_insert','index_remove','p111v_put',
       'p111v_get','p111v_body','p147v_body','p143cp_canon','p143cp_walk',
       'check_definition_world','p134e_registered','p144e_body_tail',
       'p111_compile_defs','p113pl_candidates','main','String.append',
       'p88_string_eq_go','index_hash','p150l_scan','f_lex_cursor'}


def pin(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(1048576), b''):
            h.update(chunk)
    return {'file':str(path),'bytes':path.stat().st_size,'sha256':h.hexdigest()}


def decoded(symbol):
    if '_FID_' not in symbol:
        return symbol, symbol
    family, name = symbol.split('_FID_', 1)
    return family, ''.join(chr(int(x)) for x in name.rstrip('_').split('_'))


def inspect(root):
    report = json.loads((root/'report.json').read_text())
    assert report['complete'] and report['compilerExitCode'] == report['qbeExitCode'] == 0
    ir = root/'program.ssa'
    entries = {}
    families = collections.defaultdict(collections.Counter)
    calls = collections.Counter()
    data = []
    body = []
    symbol = None
    filehash = hashlib.sha256()
    with ir.open('rb') as stream:
        for line in stream:
            filehash.update(line)
            match = HEADER.match(line)
            if match:
                assert symbol is None
                symbol = match[1].decode()
                body = [line]
            elif symbol is not None:
                body.append(line)
                if line.rstrip() != b'}':
                    continue
                raw = b''.join(body)
                family, owner = decoded(symbol)
                row = {'owner':owner,'bytes':len(raw),'lines':len(body),
                       'sha256':hashlib.sha256(raw).hexdigest()}
                targets = collections.Counter(x.decode() for x in CALL.findall(raw))
                calls.update(targets)
                row['runtimeCalls'] = {k:v for k,v in targets.items() if '_rt_' in k}
                row['callsByFamily'] = dict(collections.Counter({
                    k:sum(v for t,v in targets.items() if t.startswith(k+'_FID_'))
                    for k in ['p111','p112w','p113d','p114r']}))
                row['forwarder'] = b'%p164_forward =l call $p113d_' in raw
                entries[(family,owner)] = row
                families[family].update(functions=1,bytes=len(raw),lines=len(body),
                    continuations=int(owner.startswith('$p111.k.')),
                    forwarders=int(row['forwarder']),
                    runtimeCalls=sum(row['runtimeCalls'].values()))
                symbol = None
            elif line.startswith((b'data $p111_', b'export data $p111_')):
                if len(line) < 512:
                    data.append(line.decode().strip())
    assert symbol is None
    actual = {'file':str(ir),'bytes':ir.stat().st_size,'sha256':filehash.hexdigest()}
    assert actual['bytes'] == report['irDigest']['bytes']
    assert actual['sha256'] == report['irDigest']['sha256']
    summary = {'report':pin(root/'report.json'),'ir':actual,'binary':report['binary'],
        'source':report['imageBinding']['sourceIdentity'],
        'runtime':report['runtime'],'functions':len(entries),'families':dict(families),
        'runtimeCalls':{k:v for k,v in calls.items() if '_rt_' in k},
        'smallRuntimeDataHeaders':data,
        'largestDirect':sorted((r for (f,n),r in entries.items() if f=='p113d'),
                               key=lambda x:x['bytes'],reverse=True)[:12]}
    return summary, entries


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline',type=Path,required=True)
    p.add_argument('--candidate',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args()
    assert not a.out.exists()
    old, aa=inspect(a.baseline);new,bb=inspect(a.candidate)
    assert old['source']['sha256']==new['source']['sha256']
    assert old['runtime']['sha256']==new['runtime']['sha256']
    changes={}
    for family in sorted(old['families'].keys()|new['families'].keys()):
        x={n:r for (f,n),r in aa.items() if f==family}
        y={n:r for (f,n),r in bb.items() if f==family}
        common=x.keys()&y.keys()
        removed=sorted(n for n in x.keys()-y.keys() if not n.startswith('$p111.k.'))
        added=sorted(n for n in y.keys()-x.keys() if not n.startswith('$p111.k.'))
        changes[family]={'commonNames':len(common),
            'exactBodies':sum(x[n]['sha256']==y[n]['sha256'] for n in common),
            'removedNamedCount':len(removed),'addedNamedCount':len(added),
            'removedNamed':removed if family in ('p113d','p114r') else removed[:50],
            'addedNamed':added if family in ('p113d','p114r') else added[:50]}
    hot={}
    for key in sorted(aa.keys()|bb.keys()):
        family,owner=key
        if owner in HOT or any(owner==prefix+n for n in HOT for prefix in
                ['$direct.','$p118borrow.read.','$p128borrow.owned.']):
            hot[family+':'+owner]={'baseline':aa.get(key),'candidate':bb.get(key)}
    result={'kind':'phase169-offline-native-product-census','complete':True,
        'method':pin(Path(__file__)),'baseline':old,'candidate':new,
        'familyChanges':changes,'selectedOwners':hot,
        'limits':['Static sites and byte counts are not dynamic work or timings.',
          'Continuation numeric identities shift; name differences are not semantic differences.',
          'Both products compile the unchanged canonical main, not the Phase169 experimental entry.',
          'No compiler or generated target executed by this census.']}
    a.out.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({'baselineFunctions':old['functions'],'candidateFunctions':new['functions'],
                      'oldFamilies':old['families'],'newFamilies':new['families'],
                      'directChanges':changes.get('p113d')},indent=2))


if __name__=='__main__':
    main()
