"""Offline C prototype: a private same-class unique-cell cache in TRMC loops."""
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
TOKEN = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|/\*.*?\*/|//[^\n]*|[{}]', re.S)
HEADER = re.compile(r'^(?:NF_INLINE|INLINE|OUTLINE) Term (NF_FID_[0-9_]+(?:_trmc)?)\([^\n]*\) \{', re.M)
PUT = re.compile(r'\bspare_free\(e, cls_fit\((\d+)\), ctr_take\(e, ([A-Za-z0-9_]+), (\d+), ([A-Za-z0-9_]+)\)\);')
GET = re.compile(r'\bheap_alloc\(e, cls_fit\((\d+)\)\)')


def functions(source):
    result = {}
    for head in HEADER.finditer(source):
        depth = 0
        for token in TOKEN.finditer(source, head.end()-1):
            if token.group() == '{': depth += 1
            elif token.group() == '}': depth -= 1
            if depth == 0:
                assert head[1] not in result
                result[head[1]] = (head.start(), token.end(), source[head.start():token.end()])
                break
        else: raise AssertionError('Unclosed function ' + head[1])
    return result


def transform(source):
    assert 'p102_trmc_keep_cell' not in source
    spans = functions(source); edits = []; rows = []
    for name, (begin, end, body) in spans.items():
        if not name.endswith('_trmc'): continue
        puts = list(PUT.finditer(body))
        if not puts: continue
        def put(match):
            assert match[1] == match[3], 'Cell class must match the taken arity'
            return ('p102_trmc_keep_cell(e, nf_out, cls_fit(' + match[1]
                    + '), ctr_take(e, ' + match[2] + ', ' + match[3] + ', ' + match[4] + '));')
        replaced, put_count = PUT.subn(put, body)
        replaced, get_count = GET.subn(lambda m: 'p102_trmc_take_cell(e, nf_out, cls_fit(' + m[1] + '))', replaced)
        assert get_count > 0
        edits.append((begin, end, replaced))
        wrapper_name = name[:-5]
        start, stop, wrapper = spans[wrapper_name]
        declaration = 'Term ntr_state[2] = { TERM_HOLE, 0 };'
        assert wrapper.count(declaration) == 1
        wrapper = wrapper.replace(declaration, 'Term ntr_state[4] = { TERM_HOLE, 0, 0, 0 };')
        failure = re.compile(r'if \(!(' + re.escape(name)
            + r'\(e, seq, ntr_state[^\n]*\))\) \{ term_sink\(e, ntr_state\[0\]\); return 0; \}')
        assert len(list(failure.finditer(wrapper))) == 1
        wrapper = failure.sub(lambda m: 'Term p102_trmc_ok = ' + m[1] + ';\n'
            + 'if (ntr_state[2]) spare_free(e, (Cls)ntr_state[3], (Loc)ntr_state[2]);\n'
            + 'if (!p102_trmc_ok) { term_sink(e, ntr_state[0]); return 0; }', wrapper)
        edits.append((start, stop, wrapper))
        rows.append(dict(worker=name, uniqueTransfers=put_count, allocationSites=get_count,
                         retainedCellLimit=1, extraPrivateStackBytes=16))
    assert rows, 'No TRMC reconstruction loop with unique input transfer'
    helpers = HERE.joinpath('reuse-cells.c').read_text()
    first = min(begin for begin, _, _ in edits)
    for begin, end, replacement in sorted(edits, reverse=True):
        source = source[:begin] + replacement + source[end:]
    source = source[:first] + helpers + '\n' + source[first:]
    return source, dict(kind='private TRMC same-class unique-cell reuse prototype', workers=rows,
                        publicResultABIChanged=False, inputOwnershipAuthority='existing ctr_take returned cell',
                        scope='C intervention only. No source-name selection; no input node is modified while shared. '
                        'Private cache freed before wrapper publishes or returns failure. No targets run by transform.')
