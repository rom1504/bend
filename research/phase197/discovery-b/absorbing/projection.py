"""Freeze a flow-sensitive, absorbing-state exit after the initial four-candidate screen."""
import sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
from freeze import ROOT, BUILD, digest, read, save

SYMBOL='p113d_FID_36_112_114_111_100_117_99_116_46_98_115_116_46_100_111_119_110_'
LABEL='.L'+SYMBOL
NEW_LABEL='.Lphase197_absorbed_return'
K=72237913944883200


def project(lines, variant):
    start=lines.index(SYMBOL+':')
    stop=lines.index('.size '+SYMBOL+', .-'+SYMBOL)
    old=lines[start:stop]
    assert digest_block(old)==read(HERE/'frozen.json')['workerSha']
    block=old.copy()
    if variant:
        arm=block.index('  movabsq $72237913944883200, %r13')
        assert block[arm+1]=='  jmp '+LABEL+'_b3'
        block[arm:arm+2]=['  movabsq $72237913944883200, %rsi','  jmp '+NEW_LABEL]
        base=block.index('  jne '+LABEL+'_b0')+1
        block.insert(base,NEW_LABEL+':')
    return lines[:start]+block+lines[stop:]


def digest_block(lines):
    import hashlib
    return hashlib.sha256(('\n'.join(lines)+'\n').encode()).hexdigest()


def freeze():
    src=BUILD/'phase195/ctor-gate-emit01/off/coverage-bst-64/program.s'
    lines=src.read_text().splitlines()
    block=lines[lines.index(SYMBOL+':'):lines.index('.size '+SYMBOL+', .-'+SYMBOL)]
    tail=block[block.index(LABEL+'_b3:')+1:-1]
    assert tail==['  movq -2256(%rbp), %r10','  movq %r10, %rdi','  movq %r13, %rsi']
    assert (K>>40)&65535==164
    tagstart=block.index(LABEL+'_b0:')+1
    arm=block.index('  movabsq $72237913944883200, %r13')
    pre=[x.strip() for x in block[tagstart:arm-1]]
    common=[block[arm].strip(),*[v.strip() for v in tail],'cmpq $0, %rdi']
    assert len(pre)==8
    native={r['id']:r for r in read(BUILD/'phase195/native45-01/report.json')['rows']}
    result=dict(origin='Post hoc CFG follow-up to the failed four-way tag/instruction screen. Separate decision.',
                method=digest(__file__),workerSha=digest_block(block),sourceSha=digest(src),
                directObjects={k:native[k]['object'] for k in ['coverage-bst-64','coverage-bst-32']},
                beforeArm=[block[arm],block[arm+1]],afterArm=['  movabsq $72237913944883200, %rsi','  jmp '+NEW_LABEL],
                baseLabel='Insert '+NEW_LABEL+' at the original zero-fuel product-return fallthrough',
                precondition='Entry fuel > 0 and the current tag equals 164. Next carried value is K, which has that tag. Other observable state passes through unchanged; countdown uses a decreasing positive integer. The eliminated trace contains only register operations and a write/read of a nonescaping local fuel spill. No helper, allocation, release, fail, IO, stack growth or user callback. Zero-fuel path and all other tags retain original code. Restore exactly K plus incoming path, saved registers and calling convention through the existing return.',
                traces=[dict(fuel=n,before=common+(pre+common)*(n-1),after=[f'movabsq ${K}, %rsi']) for n in [1,8,32]],
                timing='All four layout/session medians <=0.98, >=3/4 faster in each. Confirm on separately compiled BST32 and BST64. Coverage counter and boundary executables are separate from timed binaries.')
    save(HERE/'frozen.json',result)

if __name__=='__main__':
    freeze()
