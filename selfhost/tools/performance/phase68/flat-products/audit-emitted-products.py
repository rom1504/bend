#!/usr/bin/env python3
"""Read generated C as data. Never compile or execute a compiler or target.

Worker edges are exact emitted direct calls. Scheduler reachability conservatively
includes referenced continuations/closures; it does not prove runtime feasibility.
"""
import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
import re


def decoded(fid):
    fid = fid.removeprefix('NF_').removeprefix('FID_')
    if not re.fullmatch(r'(?:[0-9]+_)+', fid):
        return fid
    return ''.join(chr(int(x)) for x in fid.rstrip('_').split('_'))


def brace_end(src, start):
    depth, i, state = 1, start, ''
    while i < len(src):
        c, nxt = src[i], src[i:i+2]
        if state in ('"', "'"):
            if c == '\\':
                i += 2
                continue
            if c == state:
                state = ''
        elif state == '//':
            if c == '\n':
                state = ''
        elif state == '/*':
            if nxt == '*/':
                state = ''
                i += 2
                continue
        elif c in ('"', "'"):
            state = c
        elif nxt in ('//', '/*'):
            state = nxt
            i += 2
            continue
        elif c == '{':
            depth += 1
        elif c == '}':
            depth -= 1
            if not depth:
                return i
        i += 1
    raise ValueError('unclosed C body at offset ' + str(start))


def host_body(body):
    """Keep line numbers; select DEVICE branches without invoking a preprocessor."""
    stack, result, uncertain = [], [], []
    enabled = True
    for line in body.splitlines(True):
        directive = re.match(r'\s*#\s*(if|ifdef|ifndef|else|elif|endif)\b(.*)', line)
        if directive:
            kind, cond = directive.groups()
            cond = cond.strip()
            if kind in ('if', 'ifdef', 'ifndef'):
                truth = {'DEVICE': False, '!DEVICE': True}.get(cond) if kind == 'if' else None
                stack.append((enabled, truth))
                enabled = enabled and truth is not False
                if truth is None:
                    uncertain.append(line.strip())
            elif kind in ('else', 'elif'):
                if not stack:
                    raise ValueError('unmatched conditional in segment')
                parent, truth = stack[-1]
                if kind == 'elif':
                    uncertain.append(line.strip())
                    truth = None
                enabled = parent and truth is not True
            else:
                if not stack:
                    raise ValueError('unmatched endif in segment')
                enabled, _ = stack.pop()
            result.append('\n' if line.endswith('\n') else '')
        else:
            result.append(line if enabled else ('\n' if line.endswith('\n') else ''))
    if stack:
        raise ValueError('unclosed conditional in segment')
    return ''.join(result), uncertain


def line_at(src, offset):
    return src.count('\n', 0, offset) + 1


parser = argparse.ArgumentParser()
parser.add_argument('source', type=Path)
parser.add_argument('--out', type=Path)
parser.add_argument('--entry', default='main', help='decoded scheduler entry name')
parser.add_argument('--hot-suffix', action='append', default=[])
parser.add_argument('--require-q-hot-zero', action='store_true')
parser.add_argument('--forbid-product-suffix', action='append', default=[])
args = parser.parse_args()
raw = args.source.read_bytes()
src = raw.decode()
workers, segments, graph, edge_lines = {}, {}, {}, {}

for match in re.finditer(r'^(?:INLINE|NF_INLINE) Term (NF_FID_[A-Za-z0-9_]+)\(([^\n]*)\) \{', src, re.M):
    name, params = match.groups()
    end = brace_end(src, match.end())
    body = src[match.end():end]
    base_line = line_at(src, match.end())
    calls = sorted(set(re.findall(r'\b(NF_FID_[A-Za-z0-9_]+)\s*\(', body)))
    graph[name] = calls
    for callee in calls:
        edge_lines[name, callee] = [base_line + body.count('\n', 0, m.start()) for m in re.finditer(r'\b' + re.escape(callee) + r'\s*\(', body)]
    tuple_lines = [base_line + body.count('\n', 0, m.start()) for m in re.finditer(r'\bterm_(?:ctr|pak)\s*\(\s*CID_TUPLE\b', body)]
    workers[name] = dict(name=decoded(name), line=line_at(src, match.start()),
        bodyBytes=len(body.encode()), physicalParams=len(re.findall(r'\bTerm\s+v_[0-9]+\b', params)),
        product=decoded(name).startswith('$product.'), calls=calls,
        tupleConstructorLines=tuple_lines, tupleConstructorSites=len(tuple_lines),
        tupleTagSites=len(re.findall(r'\bCID_TUPLE\b', body)) - len(tuple_lines),
        constructorTakeSites=len(re.findall(r'\bctr_take\s*\(', body)),
        heapAllocationSites=len(re.findall(r'\bheap_alloc\s*\(', body)),
        arrayKeepSites=len(re.findall(r'\bblk_keep\s*\(', body)),
        resultIndices=sorted(set(int(x) for x in re.findall(r'\bnf_out\[(\d+)\]', body))),
        selfLoop=bool(re.search(r'\bgoto\s+nf_again\s*;', body)),
        schedulerTokens=sorted(set(re.findall(r'\bWL_[A-Za-z0-9_]+', body))),
        unboundSentinel='NATIVE_UNBOUND_VARIABLE' in body)

for match in re.finditer(r'^\s*WL_CASE\((FID_[A-Za-z0-9_]+)\)\s*\{', src, re.M):
    name = match[1]
    end = brace_end(src, match.end())
    body, uncertain = host_body(src[match.end():end])
    base_line = line_at(src, match.end())
    calls = sorted(set(re.findall(r'\b(?:NF_)?FID_[A-Za-z0-9_]+\b', body)))
    graph[name] = calls
    for callee in calls:
        edge_lines[name, callee] = [base_line + body.count('\n', 0, m.start()) for m in re.finditer(r'\b' + re.escape(callee) + r'\b', body)]
    segments[name] = dict(name=decoded(name), line=line_at(src, match.start()),
                          calls=calls, unknownConditionalDirectives=uncertain)

entries = [name for name in segments if decoded(name) == args.entry]
parents = {name: None for name in entries}
queue = deque(entries)
while queue:
    caller = queue.popleft()
    for callee in graph.get(caller, []):
        if callee not in parents:
            parents[callee] = caller
            queue.append(callee)


def path_to(name):
    path = []
    while name in parents and parents[name] is not None:
        caller = parents[name]
        path.append(dict(caller=decoded(caller), callee=decoded(name),
                         lines=edge_lines[caller, name], workerCall=caller in workers))
        name = caller
    return list(reversed(path))


hot = [name for name, row in workers.items() if name in parents and row['product']
       and any(row['name'].endswith(suffix) for suffix in args.hot_suffix)]
hot_closure = set(hot)
queue = deque(hot)
while queue:
    for callee in graph.get(queue.popleft(), []):
        if callee not in hot_closure:
            hot_closure.add(callee)
            queue.append(callee)
errors = []
if len(entries) != 1:
    errors.append('expected one scheduler entry, found ' + str(len(entries)))
for name, row in workers.items():
    if row['schedulerTokens'] or row['unboundSentinel']:
        errors.append('invalid private worker body: ' + row['name'])
    for callee in row['calls']:
        if callee not in workers:
            errors.append('undefined worker: ' + callee)
    if row['product'] and any(row['name'].endswith(s) for s in args.forbid_product_suffix):
        errors.append('forbidden product entry present: ' + row['name'])
if args.require_q_hot_zero:
    if not args.hot_suffix or not hot:
        errors.append('no entry-reachable product hot worker')
    for name in hot_closure:
        row = workers.get(name)
        if row is None:
            errors.append('hot graph leaves defined worker set: ' + name)
        elif row['tupleConstructorSites'] or row['tupleTagSites'] or row['constructorTakeSites']:
            errors.append('shell traffic in hot worker: ' + row['name'])

report = dict(kind='phase68-product-selected-flow-source-audit', source=str(args.source.resolve()),
    sourceSha256=hashlib.sha256(raw).hexdigest(), workerCount=len(workers),
    reachableWorkerCount=sum(name in parents for name in workers),
    reachableProductCount=sum(name in parents and row['product'] for name, row in workers.items()),
    unusedProductNames=[row['name'] for name, row in workers.items() if row['product'] and name not in parents],
    hotRoots=[workers[name]['name'] for name in hot],
    hotPaths={workers[name]['name']: path_to(name) for name in hot},
    hotClosure=[workers[name] for name in sorted(hot_closure) if name in workers],
    workers=workers, segments=segments, errors=errors, passed=not errors,
    scope='Static emitted C only. Worker calls are selected direct edges. Scheduler reachability includes possible closures/continuations and is not a runtime execution proof. No target executed.')
if args.out:
    if args.out.exists():
        raise SystemExit('refusing to overwrite receipt: ' + str(args.out))
    args.out.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps({k: v for k, v in report.items() if k not in ('workers', 'segments', 'hotPaths', 'hotClosure')}))
raise SystemExit(0 if report['passed'] else 1)
