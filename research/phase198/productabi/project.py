"""Exact two-lane machine experiment. Keep the original public ABI at every exported symbol."""
from collections import Counter
from pathlib import Path
import hashlib
import json
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BUILD = ROOT / 'selfhost/build'
CASES = {
    'lexer': BUILD/'phase195/prepared-combined01/combined/lexer/program.s',
    'coverage-bst-64': BUILD/'phase197/shared-emission01/combined/coverage-bst-64/program.s',
}
FN = re.compile(r'^\.globl (p113d_\w+)\n\.type \1, @function\n\1:\n.*?^\.size \1, [^\n]+',re.M|re.S)
PAIR = re.compile(r'^  (movq|movabsq) ([^,\n]+), %r10\n  movq ([^,\n]+), %r11\n  movq %r10, 0\(%r11\)\n'
                  r'  (movq|movabsq) ([^,\n]+), %r10\n  movq \3, %r11\n  movq %r10, 8\(%r11\)\n  xorl %eax, %eax$', re.M)
CALL = re.compile(r'^  call (p113d_\w+)\n  leaq (-\d+\(%rbp\)), %r11\n  movq 0\(%r11\), %rax\n  movq %rax, (\S+)\n'
                  r'  leaq \2, %r11\n  movq 8\(%r11\), %rax\n  movq %rax, (\S+)(?!\n  leaq [^\n]+, %r11\n  movq 16\(%r11\))$',re.M)
def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()
def private(sym):
    return 'p198r_' + sym
def rewrite(text):
    admitted = {}
    fallback = []
    stats = Counter()
    requested = {call[1] for call in CALL.finditer(text)}
    for fn in FN.finditer(text):
        sym,body = fn[1],fn[0]
        if sym not in requested:
            continue
        writes = list(PAIR.finditer(body))
        if not writes or len(writes)!=body.count('\n  ret\n'):
            continue
        if '  call p117v_' in body or re.search(r'^  jmp (?!\.L)',body,re.M):
            continue
        home = writes[0][3]
        incoming = '  movq %rsi, %rax\n  movq %rax, ' + home + '\n'
        if not re.fullmatch(r'-\d+\(%rbp\)',home) or body.count(incoming)!=1:
            continue
        if any(m[3]!=home or any(reg in op for reg in ('%r10','%r11') for op in (m[2],m[5])) for m in writes):
            continue
        candidate = PAIR.sub(lambda m:f'  {m[1]} {m[2]}, %r10\n  {m[4]} {m[5]}, %r11',body).replace(incoming,'')
        if home in candidate:
            continue
        assert candidate.count('\n  ret\n') == len(writes)
        # Rename only definitions and local labels. Raw symbol references still denote the old ABI.
        candidate = candidate.replace('.globl '+sym+'\n','.local '+private(sym)+'\n').replace('.type '+sym+',','.type '+private(sym)+',')
        candidate = candidate.replace('\n'+sym+':','\n'+private(sym)+':').replace('.L'+sym+'_', '.L'+private(sym)+'_')
        candidate = candidate.replace('.size '+sym+', .-'+sym,'.size '+private(sym)+', .-'+private(sym))
        admitted[sym] = candidate
        fallback.append(body)
        stats['workers'] += 1
        stats['return_paths'] += len(writes)
    normal = FN.sub(lambda fn:admitted.get(fn[1],fn[0]),text)
    chunks = []
    prev = 0
    for call in CALL.finditer(normal):
        if call[1] not in admitted:
            continue
        prefix = normal[prev:call.start()]
        lines = prefix.splitlines(keepends=True)
        j = len(lines)-1
        while j>=0 and re.match(r'^  (movq|movabsq|movl|xorl|leaq) ',lines[j]):
            j -= 1
        setup = ''.join(lines[j+1:])
        pointer = re.escape(call[2])
        direct = f'  leaq {call[2]}, %rsi\n'
        capture = re.search(r'^  leaq '+pointer+r', %r10\n  movq %r10, (\d+\(%rsp\))\n',setup,re.M)
        if setup.count(direct)==1:
            setup=setup.replace(direct,'')
        elif capture:
            load = '  movq '+capture[1]+', %rsi\n'
            assert setup.count(load)==1 and setup.count(capture[1]+'\n')==1
            setup=setup.replace(capture[0],'').replace(load,'')
        else:
            raise ValueError('unrecognized hidden pointer argument '+call[1])
        assert call[3]!='%r11' and call[4]!='%r10'
        chunks.extend([''.join(lines[:j+1]),setup,
                       f'  call {private(call[1])}\n  movq %r10, {call[3]}\n  movq %r11, {call[4]}'])
        prev=call.end()
        stats['calls'] += 1
    chunks.extend([normal[prev:],'\n.text\n','\n'.join(fallback),'\n'])
    return ''.join(chunks),stats
def freeze():
    cases={}
    for name,path in CASES.items():
        src=path.read_text()
        candidate,stats=rewrite(src)
        assert stats['calls']>=2
        cases[name]=dict(source=str(path.relative_to(ROOT)),asm=sha(path),object=sha(path.with_suffix('.o')),
                         register=hashlib.sha256(candidate.encode()).hexdigest(),stats=stats)
    return dict(cases=cases,implementation=sha(Path(__file__)),test='Median runtime ratio at most .98 and at least 3/4 favorable pairs under each assembler layout on at least one case before source implementation.')
if __name__=='__main__':print(json.dumps(freeze(),indent=2))
