#!/usr/bin/env python3
"""Read-only conservative private-function reachability audit of emitted QBE.

Every nonprivate function is a root. Exported private functions and every private
symbol use other than its definition or a direct call are roots too. This tool
produces counts and proof hashes only; it does not write transformed QBE.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def pin(path):
    raw = path.read_bytes()
    return dict(file=str(path.resolve()), bytes=len(raw), sha256=sha(raw))


def proof(value):
    return sha(json.dumps(value, sort_keys=True, separators=(',', ':')).encode())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--source', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    if args.out.exists():
        raise ValueError('Fresh report required')
    inputs = [pin(Path(__file__)), pin(args.source)]
    raw = args.source.read_bytes()
    header = re.compile(rb'(?m)^(export )?function [^\n]*?\$([A-Za-z0-9_.]+)\([^\n]*\) \{\n')
    close = re.compile(rb'(?m)^\}\n?')
    private_use = re.compile(rb'\$(p112w_[A-Za-z0-9_.]+)')
    direct_call = re.compile(rb'\bcall\s+(\$p112w_[A-Za-z0-9_.]+)\s*\(')
    functions, definitions, call_spans, calls = {}, set(), set(), []
    prior_end = 0
    for match in header.finditer(raw):
        if match.start() < prior_end:
            raise ValueError('Nested or overlapping function')
        end_match = close.search(raw, match.end())
        if end_match is None:
            raise ValueError('Unclosed function')
        end = end_match.end()
        name = match[2].decode()
        if name in functions:
            raise ValueError('Duplicate function symbol')
        functions[name] = dict(start=match.start(), end=end, bytes=end-match.start(),
                               sha256=sha(raw[match.start():end]), exported=bool(match[1]))
        if name.startswith('p112w_'):
            definitions.add((match.start(2)-1, match.end(2)))
        for call in direct_call.finditer(raw, match.end(), end):
            call_spans.add(call.span(1))
            calls.append((name, call[1][1:].decode()))
        prior_end = end
    if len(functions) != len(re.findall(rb'(?m)^(?:export )?function\b', raw)):
        raise ValueError('A function header was not recognized')
    if not functions:
        raise ValueError('No functions found')
    private = {name for name in functions if name.startswith('p112w_')}
    escaped, escape_occurrences, uses = set(), 0, 0
    for use in private_use.finditer(raw):
        uses += 1
        name = use[1].decode()
        if name not in private:
            raise ValueError('Unresolved private symbol: ' + name)
        if use.span() not in definitions and use.span() not in call_spans:
            escaped.add(name)
            escape_occurrences += 1
    edges = {name: set() for name in functions}
    for caller, callee in calls:
        edges[caller].add(callee)
    roots = {name for name in functions if name not in private}
    exported_private = {name for name in private if functions[name]['exported']}
    roots |= exported_private | escaped
    seen, todo = set(), list(roots)
    while todo:
        name = todo.pop()
        if name not in seen:
            seen.add(name)
            todo.extend(edges[name] - seen)
    reachable, unreachable = private & seen, private - seen
    function_bytes = sum(row['bytes'] for row in functions.values())
    private_bytes = sum(functions[name]['bytes'] for name in private)
    dead_bytes = sum(functions[name]['bytes'] for name in unreachable)
    proof_rows = [[name, functions[name]['start'], functions[name]['end'], functions[name]['sha256']]
                  for name in sorted(unreachable)]
    record = dict(kind='phase112-offline-private-reachability', complete=True, targetsExecuted=False,
                  inputs=inputs,
                  roots='ALL nonprivate functions plus exported private symbols and ALL non-call/non-definition private references',
                  counts=dict(sourceBytes=len(raw), functions=len(functions), functionBytes=function_bytes,
                              nonprivateFunctions=len(functions)-len(private), privateFunctions=len(private),
                              privateBytes=private_bytes, privateSymbolOccurrences=uses,
                              privateDefinitionOccurrences=len(definitions), directPrivateCallOccurrences=len(calls),
                              uniqueDirectPrivateEdges=sum(map(len, edges.values())),
                              addressEscapedPrivateFunctions=len(escaped), addressEscapeOccurrences=escape_occurrences,
                              exportedPrivateFunctions=len(exported_private), rootFunctions=len(roots),
                              reachablePrivateFunctions=len(reachable), unreachablePrivateFunctions=len(unreachable),
                              unreachablePrivateBytes=dead_bytes,
                              unreachableFractionOfPrivateBytes=dead_bytes/private_bytes if private_bytes else 0,
                              unreachableFractionOfSourceBytes=dead_bytes/len(raw)),
                  proof=dict(allFunctions=proof([[name, functions[name]] for name in sorted(functions)]),
                             callGraph=proof([[name, sorted(edges[name])] for name in sorted(edges)]),
                             roots=proof(sorted(roots)), reachablePrivate=proof(sorted(reachable)),
                             unreachablePrivateNamesRangesAndBodies=proof(proof_rows)),
                  scope='Conservative whole-file symbol reachability, not dynamic hotness. Unknown private-symbol use roots the target. No public function or metadata is proposed for deletion.')
    for item in inputs:
        if pin(Path(item['file'])) != item:
            raise ValueError('Input changed during audit')
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(record, indent=2)+'\n')
    print(json.dumps(record['counts']))


if __name__ == '__main__':
    main()
