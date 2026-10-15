#!/usr/bin/env python3
"""Freeze exact production dispatch edits; data preparation only, no targets."""
import argparse
import difflib
import hashlib
import json
from pathlib import Path
import re
import sys
sys.dont_write_bytecode = True
from transform import CONFIG, dispatch
from direct import DIRECT, direct

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
D04 = ROOT / 'selfhost/build/phase92/upstream-checked01/compiler.bend'
D04_SHA = 'd04ad79cf08c019b509cfbbd4be2b16ae9e4af189767715d12e0645b9eee8097'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def pin(path):
    path = Path(path).resolve(strict=True)
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=sha(data))


def declaration(source, name):
    matches = list(re.finditer(r'(?m)^(?:@unsafe\n)?def ' + re.escape(name) + r'\(', source))
    assert len(matches) == 1, (name, len(matches))
    start = matches[0].start()
    end = source.index('\n\n', matches[0].end()) + 1
    following = re.search(r'(?m)^(?:(?:def|law|type) |@unsafe)', source[matches[0].end():])
    if following:
        end = min(end, matches[0].end() + following.start())
    body = source[start:end]
    return body, dict(name=name, startByte=len(source[:start].encode()), endByte=len(source[:end].encode()),
                      startLine=source.count('\n', 0, start) + 1, sha256=sha(body.encode()))


def translated(body, name):
    result = body.replace('String.eq(', 'p88_string_eq(')
    if name == 'nc_lower_live_to':
        # The D04 compiler retains Phase84's native C-text rope representation.
        for before, after in [
            ('NC_Code{ne_jump(nc_values(ks(t), env), nm(t)),', 'NC_Code{nct_leaf(ne_jump(nc_values(ks(t), env), nm(t))),'),
            ('NC_Code{"err_post(e.mem, ERR_FIDS); return 0;\\n",', 'NC_Code{nct_leaf("err_post(e.mem, ERR_FIDS); return 0;\\n"),'),
        ]:
            assert result.count(before) == 1, (name, before)
            result = result.replace(before, after, 1)
    return result


def hoist(body, expression='tg(t)', name='p98_tag', ty='String'):
    assert body.count(expression) >= 2
    # These concrete production declarations have a one-line inferred header.
    prefix, tail = body.split(':\n', 1)
    assert '\n' not in prefix.removeprefix('@unsafe\n')
    assert name not in body
    return prefix + ':\n  +' + name + ' : ' + ty + ' = ' + expression + '\n' + tail.replace(expression, name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--variant', default='hoist-core', choices=['hoist-core', 'dispatch-core', 'dispatch-check4', 'direct-hot', 'dispatch-wide'])
    args = parser.parse_args()
    out = args.out.resolve()
    assert out.is_relative_to(ROOT / 'selfhost/build/phase98') and not out.exists(), out
    source = D04.read_text()
    assert sha(source.encode()) == D04_SHA
    changes = []
    changed = source
    modules = {}
    selectors = []
    names = (list(DIRECT) if args.variant == 'direct-hot' else
             list(CONFIG) + list(DIRECT) if args.variant == 'dispatch-wide' else
             list(CONFIG) if args.variant == 'dispatch-check4' else ['infer_node', 'check_node'])
    for name in names:
        module = (DIRECT if name in DIRECT else CONFIG)[name][0]
        path = ROOT / 'selfhost/src' / module
        canonical = modules.setdefault(module, dict(original=path.read_text(), changed=path.read_text(), pin=pin(path)))
        old, loc = declaration(source, name)
        original, origin = declaration(canonical['original'], name)
        assert translated(original, name) == old, name
        bridge = None
        if name in DIRECT:
            new_original, bridge = direct(original, name)
        elif args.variant.startswith('dispatch-'):
            new_original, selector, bridge = dispatch(original, name)
            selectors.append(selector)
        else:
            new_original = hoist(original)
        new = translated(new_original, name)
        assert changed.count(old) == 1 and canonical['changed'].count(original) == 1
        changed = changed.replace(old, new, 1)
        canonical['changed'] = canonical['changed'].replace(original, new_original, 1)
        changes.append(dict(name=name, module=module, canonicalLocation=origin, d04Location=loc,
                            before=old, after=new, canonicalBefore=original, canonicalAfter=new_original,
                            observation='tg(t)', beforeObservations=old.count('tg(t)'), afterObservations=new.count('tg(t)'),
                            beforeLines=len(old.splitlines()), afterLines=len(new.splitlines()),
                            canonicalBridge=('String.eq( -> p88_string_eq(' + ('; Phase84 nct_leaf wrappers on the two existing NC_Code text fields' if name == 'nc_lower_live_to' else '')), dispatchBridge=bridge))
    reverse = changed
    for row in reversed(changes):
        assert reverse.count(row['after']) == 1
        reverse = reverse.replace(row['after'], row['before'], 1)
    assert reverse == source
    out.mkdir(parents=True)
    outputs = []
    def write(relative, data):
        path = out / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data.encode() if isinstance(data, str) else data)
        value = pin(path)
        outputs.append(value)
        return value
    def patch(before, after, path):
        return ''.join(difflib.unified_diff(before.splitlines(True), after.splitlines(True), fromfile='a/'+path, tofile='b/'+path))
    for file in sorted(HERE.iterdir()):
        if file.is_file():
            write('methods/' + file.name, file.read_bytes())
    candidate = write('compiler.bend', changed)
    if selectors:
        write('selectors.canonical.bend', '\n'.join(selectors))
        write('selectors.d04.bend', '\n'.join(selectors).replace('String.eq(', 'p88_string_eq('))
    write('compiler.patch', patch(source, changed, str(D04.relative_to(ROOT))))
    for module, row in modules.items():
        write('original-source/' + module, row['original'])
        write('candidate-source/' + module, row['changed'])
        write('patches/' + module + '.patch', patch(row['original'], row['changed'], 'selfhost/src/' + module))
        assert pin(row['pin']['file']) == row['pin']
    receipt = dict(kind='phase98-exact-source-dispatch-candidate', version=1, variant=args.variant,
                   complete=True, targetsRun=False, original=pin(D04), candidate=candidate,
                   canonicalSources=[row['pin'] for row in modules.values()], changes=changes,
                   frozenInputs=outputs.copy(), reverseReplayExact=True,
                   staticCounts=dict(functions=len(changes), baselineObservations=sum(r['beforeObservations'] for r in changes),
                                     candidateObservations=sum(r['afterObservations'] for r in changes),
                                     sourceLineDelta=sum(r['afterLines']-r['beforeLines'] for r in changes)),
                   semanticBoundary=('Cache the total immutable tg observation; all original branch expressions and comparisons stay in order. check_node additionally observes tg on the core_literal path.' if args.variant == 'hoist-core' else 'Safe ordered tag selectors return branch constructors; unsafe dispatch matches a parameter and retains complete original branch expressions. Literal gates stay before tag selection.'),
                   limitations=['No compilation or execution performed.', 'Universal tg laws do not prove unsafe recursive caller equivalence or C ownership.', 'No f_find or backend changes.'])
    assert pin(D04)['sha256'] == D04_SHA
    write('receipt.json', json.dumps(receipt, indent=2) + '\n')
    print(json.dumps(dict(complete=True, targetsRun=False, out=str(out), candidate=candidate, staticCounts=receipt['staticCounts'])))


if __name__ == '__main__':
    main()
