"""Strict source-only dependency census of the pinned named B1 JavaScript.

The tokenizer is a direct Python translation of development/equality.mjs's
reviewed tokens() helper. It does not evaluate compiler code. Strings remain
opaque; comments/templates in the generated program section are refused.
"""
import json
import re
from pathlib import Path

MARKER = '// Program\n// =======\n'
NAME = re.compile(r'^\$[A-Za-z0-9_$]+\$$')


def tokens(source, start):
    out = []
    i = start
    while i < len(source):
        if source[i].isspace():
            i += 1
            continue
        at, c = i, source[i]
        if c in '\"\'':
            i += 1
            while i < len(source):
                if source[i] == '\\':
                    i += 2
                    continue
                assert source[i] not in '\n\r', 'Unsupported multiline string'
                if source[i] == c:
                    i += 1
                    break
                i += 1
            else:
                raise AssertionError('Unclosed string')
        elif c.isascii() and (c.isalpha() or c in '_$'):
            while i < len(source) and source[i].isascii() and (source[i].isalnum() or source[i] in '_$'):
                i += 1
        else:
            assert c != '`' and source[i:i+2] not in ['//', '/*'], 'Unsupported generated syntax'
            i += 1
        out.append(dict(text=source[at:i], start=at, end=i))
    stack = []
    for i, token in enumerate(out):
        text = token['text']
        if text in ['(', '[', '{']:
            stack.append(i)
        elif text in [')', ']', '}']:
            assert stack
            k = stack.pop()
            assert '([{'.index(out[k]['text']) == ')]}'.index(text)
            out[k]['close'] = i
    assert not stack
    return out


def program(file):
    source = Path(file).read_text()
    assert MARKER in source
    start = source.index(MARKER) + len(MARKER)
    assert not re.search(r'\$[A-Za-z0-9_$]+\$', source[:start]), 'Runtime calls generated binding'
    assert not re.search(r'\b(?:eval|Function|globalThis)\b', source[:start]), 'Dynamic runtime binding'
    ts = tokens(source, start)
    functions, declarations = {}, set()
    i = 0
    while ts[i]['text'] == 'function':
        first, name = i, ts[i+1]['text']
        assert NAME.fullmatch(name) and name not in functions
        assert ts[i+2]['text'] == '('
        body = ts[i+2]['close'] + 1
        assert ts[body]['text'] == '{'
        end = ts[body]['close']
        declarations.add(i+1)
        functions[name] = dict(source=source[ts[first]['start']:ts[end]['end']],
            refs={t['text'] for t in ts[body+1:end] if NAME.fullmatch(t['text'])})
        i = end + 1
    assert [t['text'] for t in ts[i:i+3]] == ['export', 'default', '{']
    end = ts[i+2]['close']
    assert end == len(ts)-2 and ts[end+1]['text'] == ';'
    export_source = source[ts[i]['start']:]
    exports = {}
    # This exact identity-marshalling shape is independently admitted by the
    # mandatory profile7 derivation. Here extract its one generated callee.
    for line in export_source.splitlines()[1:-1]:
        m = re.fullmatch(r'  ("[^"]+"): run_lib\(.*run_loop\((\$[\w$]+\$)\(.*', line)
        assert m, 'Unexpected public binding'
        key = json.loads(m[1])
        assert key not in exports and m[2] in functions
        assert re.findall(r'\$[A-Za-z0-9_$]+\$', line) == [m[2]], 'Additional export dependency'
        exports[key] = m[2]
    assert len(exports) == 99
    all_names = set(functions)
    for j, token in enumerate(ts):
        text = token['text']
        assert text not in ['eval', 'Function', 'globalThis'], 'Dynamic generated binding'
        if text not in all_names:
            continue
        prior = ts[j-1]['text'] if j else ''
        following = ts[j+1]['text'] if j+1 < len(ts) else ''
        assert prior not in ['const', 'let', 'var'] and following != '=', 'Rebound generated function'
        if prior == 'function':
            assert j in declarations, 'Shadowed generated binding'
    for name, row in functions.items():
        assert row['refs'] <= all_names, (name, row['refs']-all_names)
    return dict(runtime=source[:start], functions=functions, exports=exports, exportSource=export_source)


def closure(p, roots):
    todo = [p['exports'][root] for root in roots]
    seen = set()
    while todo:
        name = todo.pop()
        if name not in seen:
            seen.add(name)
            todo.extend(p['functions'][name]['refs'])
    return seen


def compare(old_file, new_file, driver):
    old, new = program(old_file), program(new_file)
    assert old['runtime'] == new['runtime'] and old['exportSource'] == new['exportSource']
    assert old['exports'] == new['exports']
    # All explicit API references in the complete host prefix before the
    # check return overapproximate the persistent parse/check entry points.
    # The three api[name] occurrences in this prefix only test typeof; none
    # invokes a dynamically selected function. Optional product APIs are
    # conservatively included although backendProducts:false disables them.
    stop = driver.index("    if(mode==='check') return")
    prefix = driver[:stop]
    dynamic = [line for line in prefix.splitlines() if 'api[' in line]
    assert len(dynamic) == 3 and all("typeof api[name]==='function'" in line or "typeof api[name]!=='function'" in line for line in dynamic)
    refs = set(re.findall(r'\bapi\.([A-Za-z_]\w*)', prefix))
    assert refs - old['exports'].keys() == {'bend', 'mjs'}  # filename strings
    roots = sorted(refs & old['exports'].keys())
    a, b = closure(old, roots), closure(new, roots)
    assert a == b
    assert all(old['functions'][name]['source'] == new['functions'][name]['source'] for name in a), 'Changed frontend-reachable generated code'
    changed = sorted(name for name in old['functions'].keys() | new['functions'].keys()
        if old['functions'].get(name, {}).get('source') != new['functions'].get(name, {}).get('source'))
    assert not set(changed) & a
    return dict(roots=roots, reachableFunctions=sorted(a), unchangedFunctionCount=len(a),
        changedUnreachableFunctions=changed, runtimeIdentical=True, exportWrappersIdentical=True,
        dynamicHostReferences=dynamic,
        method='Conservative lexical references to every named generated function, including function values passed to unchanged higher-order runtime helpers; exact bytes required for the complete reachable closure. No program execution or sampled call coverage.')
