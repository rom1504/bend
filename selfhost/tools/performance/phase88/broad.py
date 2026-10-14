#!/usr/bin/env python3
"""Closed-source native coverage: retained catalog points, independent B2 C oracle."""
import argparse, hashlib, json, re, subprocess, sys
from pathlib import Path
from native_support import authenticate, native_args

ROOT = Path(__file__).resolve().parents[4]
P = ROOT / 'selfhost/tools/performance'
NODE = '/home/ai/.nvm/versions/node/v24.18.0/bin/node'
BASE = ROOT / 'selfhost/.bootstrap/upstream-phase66/bend2/base.bend'
RUNTIME = ROOT / 'selfhost/build/phase86/runtime01/runtime.c'
EFFS = ROOT / 'selfhost/src/runtime/native/effs'
CLANG = '/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/bin/clang'
INCLUDE = '/home/ai/.elan/toolchains/leanprover--lean4---v4.32.0/include/clang'

def pin(p):
    p = Path(p).resolve()
    b = p.read_bytes()
    return dict(file=str(p), sha256=hashlib.sha256(b).hexdigest(), bytes=len(b))

def save(p, value):
    p.write_text(json.dumps(value, indent=2) + '\n')

def guard(out, cmd, seconds=40):
    r = subprocess.run([sys.executable, str(P/'phase86/guard.py'), '--out', str(out),
                        '--seconds', str(seconds), '--cpu', '3', '--', *map(str,cmd)],
                       capture_output=True, text=True)
    if r.returncode:
        return dict(pass_=False, guard=str(out), error=r.stdout+r.stderr)
    return dict(pass_=True, guard=str(out))

def prepare(out):
    out.mkdir(parents=True, exist_ok=False)
    catalog = P/'phase37/catalog.json'
    rows = []
    for c in json.loads(catalog.read_text())['cases']:
        original = P/'phase37'/c['source']['path']
        assert pin(original)['sha256'] == c['source']['sha256']
        text = original.read_text()
        assert re.findall(r'^import .*$', text, re.M) == ['import Base']
        # Preserve the original body, including its former entry, but reach only
        # the catalog's bounded point. This is an explicit source derivation.
        text, renamed = re.subn(r'^def main\(', 'def p88_original_main(', text, flags=re.M)
        assert renamed in (0, 1)
        text, renamed_law = re.subn(r'^law main:', 'law p88_original_main:', text, flags=re.M)
        assert renamed_law in (0, 1)
        pt = c['point']; call = pt['exportName']+'('+', '.join(map(str,pt['args']))+')'
        expr = call if isinstance(pt['expected'],str) else 'U32.show('+call+')'
        adapter = ''
        if c.get('adapter') == 'generic-row':
            adapter = '''
# Observe every array element, matching the catalog's complete-state serializer.
def p88_row_numbers(xs: List<U32>) -> String:
  match xs:
    case Nil{}: ""
    case Con{h, Nil{}}: U32.show(h)
    case Con{h, Con{h2, rest}}: U32.show(h) ++ "," ++ p88_row_numbers(Con{h2, rest})

def p88_row_array(a: Array<U32>) -> String:
  "[" ++ p88_row_numbers(Array.to_list(U32, a)) ++ "]"

def p88_row_output(st: Dp) -> String:
  match st:
    case Dp{a,b,prev,cur}:
      "[" ++ p88_row_array(a) ++ "," ++ p88_row_array(b) ++ "," ++ p88_row_array(prev) ++ "," ++ p88_row_array(cur) ++ "]"
'''
            expr = 'p88_row_output(row.probe('+', '.join(map(str,pt['args']))+'))'
        suffix = adapter+'\n# Phase88: exact catalog point, ordinary IO entry.\ndef main() -> IO(Unit):\n  IO.print('+expr+')\n'
        target = out/(c['id']+'.bend'); target.write_text(text+suffix)
        rows.append(dict(id=c['id'], family=c['family'], source=pin(target), original=pin(original),
                         renamedMain=bool(renamed), renamedLaw=bool(renamed_law), adapter=c.get('adapter'), append=suffix, expected=str(pt['expected'])))
    save(out/'manifest.json', dict(catalog=pin(catalog), method=pin(__file__), cases=rows))

def run(manifest, binary, out, ids, execute, cache_receipt):
    out.mkdir(parents=True, exist_ok=False)
    m = json.loads(manifest.read_text())
    auth = authenticate(binary, cache_receipt)
    assert pin(BASE)['sha256'] == '99ac43f2b2bb3e3f39acdcedcecbbd3cb44749ce13969c827d6973fa66f7facf'
    transport = json.loads((RUNTIME.parent/'receipt.json').read_text())
    template = Path(transport['template'])
    assert pin(template)['sha256'] == transport['templateSha256'] == 'f9f5a1c98f17f892d891032ca35489234e43d3b4112a18e592e6da408b09736c'
    canonical = json.loads(template.read_text())
    assert pin(RUNTIME)['sha256'] == canonical['runtimeSha256']
    for i in range(5):
        assert Path(str(RUNTIME)+f'.part{i}').read_text() == canonical['parts'][i]
    for name, digest in {
        'args.c':'7209a5fa11396fa8b0667a6738c913c40f554797e442c847a25e13a5f69676e0',
        'print.c':'709500d2ace6e2eaeec0f5f1e4373d4ec5e402b3c1e289bd70dfef7e2a635b26',
        'now.c':'da5fde65701c4fadc7560625c9615b4d60b2eefbd7b6bbe1aedda61887b825b9',
    }.items():
        assert pin(EFFS/name)['sha256'] == digest
    rows = []; report = dict(complete=False, pass_=False, method=pin(__file__), manifest=pin(manifest),
                            binary=pin(binary), base=pin(BASE), runtime=pin(RUNTIME), authentication=auth, cases=rows)
    for c in m['cases']:
        if ids and c['id'] not in ids: continue
        src = Path(c['source']['file']); assert pin(src) == c['source']
        directory = out/c['id']; directory.mkdir()
        row = dict(id=c['id'], source=c['source'], expected=c['expected'], jobs={}); rows.append(row)
        for role in ['b2', 'native']:
            prefix = directory/role
            cmd = (native_args(auth,src,prefix,1) if role=='native'
                   else [NODE,'--max-old-space-size=1024','--stack-size=4096',P/'phase86/reference.mjs','b2',src,prefix,'1'])
            row['jobs'][role] = guard(directory/(role+'-guard'),cmd,60)
            emitted = Path(str(prefix)+'.1.c')
            if emitted.exists(): row[role] = pin(emitted)
        row['exact'] = bool(row.get('b2') and row.get('native') and row['b2']['sha256']==row['native']['sha256'])
        if execute and row['exact']:
            exe = directory/'program'
            row['jobs']['clang'] = guard(directory/'clang-guard',[CLANG,'-isystem',INCLUDE,'-O2',row['native']['file'],'-o',exe,'-lm','-pthread'],60)
            if row['jobs']['clang']['pass_']:
                row['jobs']['execute'] = guard(directory/'execute-guard',[exe,'--threads','1','--gpu','off'],20)
                output = (directory/'execute-guard/stdout.log').read_text().rstrip('\n')
                row['executionExact'] = output == c['expected']
        row['pass_'] = row['exact'] and all(j['pass_'] for j in row['jobs'].values()) and (not execute or row.get('executionExact',False))
        save(out/'report.json',report)
        print(json.dumps(dict(id=c['id'],exact=row['exact'],pass_=row['pass_'])),flush=True)
    report['complete'] = True; report['pass_'] = bool(rows) and all(r['pass_'] for r in rows)
    assert authenticate(binary, cache_receipt) == auth
    save(out/'report.json',report)
    return 0 if report['pass_'] else 1

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__); sub=p.add_subparsers(dest='action',required=True)
    prep=sub.add_parser('prepare'); prep.add_argument('out',type=Path)
    r=sub.add_parser('run'); r.add_argument('manifest',type=Path); r.add_argument('binary',type=Path); r.add_argument('out',type=Path)
    r.add_argument('--cases'); r.add_argument('--execute',action='store_true'); r.add_argument('--cache-receipt',type=Path)
    a=p.parse_args()
    if a.action=='prepare': prepare(a.out.resolve())
    else: sys.exit(run(a.manifest.resolve(),a.binary.resolve(),a.out.resolve(),set(a.cases.split(',')) if a.cases else None,a.execute,a.cache_receipt))
