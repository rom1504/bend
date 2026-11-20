"""Freeze a checked-output tree transpose diagnostic while retaining the original fallback."""
from pathlib import Path
import hashlib
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = ROOT / 'selfhost/build/phase197/discoveryBTiming01/tree-bitonic/project-baseline/program.s'
SOURCE_SHA = 'cff945285617f74a49e16d558f1c79e363651cb244b0748b986e2459ca5f2dca'
OWNER = 'p113d_FID_' + ''.join(str(ord(c)) + '_' for c in '$direct.warp_zip')
FALL = '.Lp198_original_transpose'
COUNTS = 'p198_transpose_counts'


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def table(src, name, directive):
    body = src.split('\n'+name+':\n',1)[1].split('\n.size',1)[0]
    return [line.split()[1] for line in body.splitlines() if line.startswith(directive)]


def project(src, candidate, counts):
    assert hashlib.sha256(src.encode()).hexdigest() == SOURCE_SHA
    head = src.index('\n'+OWNER+':\n') + len(OWNER)+3
    stop = src.index('\n.size '+OWNER+',', head)
    arm = src[head:stop].split('\n.L'+OWNER+'_b2:',1)[0]
    cid = 165
    assert re.findall(r'call (\w+)',arm) == ['p125_rt_take2']*2+['p125_rt_ctor2']*3
    desc = table(src,'p111_program','.quad')
    assert list(map(int, desc[:12])) == [11102,192,194,167,0,0,5,1,38,1,0,15]
    assert desc[16:18] == ['p111_cid_arity+0','p111_cid_hot+0']
    assert table(src,'p111_cid_arity','.byte')[cid]=='2' and table(src,'p111_cid_hot','.byte')[cid]=='0'
    fields = list(range(2))  # Loc is a 40-bit word index
    heap = 51413504 + ((int(desc[8])+127)&-128)
    assert fields == [0,1] and heap == 51413632
    ev = lambda n: f'  incq {COUNTS}+{8*n}(%rip)\n' if counts else ''
    if not candidate:
        return src[:head]+ev(0)+src[head:]
    # Raw term layout, static bound and release's cold CID are verified above.
    prep = f'''  movq %rsi, %rax
  shrq $40, %rax
  cmpl ${(2<<16)|cid}, %eax
  jne {FALL}
  movq %rdx, %rax
  shrq $40, %rax
  cmpl ${(2<<16)|cid}, %eax
  jne {FALL}
  cmpq %rsi, %rdx
  je {FALL}
  movabsq ${(1<<40)-1}, %rax
  movq %rsi, %r8
  andq %rax, %r8
  cmpq ${heap}, %r8
  jb {FALL}
  movq %rdx, %r9
  andq %rax, %r9
  cmpq ${heap}, %r9
  jb {FALL}
'''
    move = f'''  movq 0(%rdi), %r10
  movq 8(%r10,%r8,8), %rax
  movq 0(%r10,%r9,8), %r11
  movq %r11, 8(%r10,%r8,8)
  movq %rax, 0(%r10,%r9,8)
  subq $24, %rsp
  movq %rsi, 0(%rsp)
  movq %rdx, 8(%rsp)
  movl ${cid}, %esi
  movq %rsp, %rdx
  call p125_rt_ctor2
  addq $24, %rsp
  ret
{FALL}:
'''
    return src[:head] + ev(0) + prep + ev(1) + move + src[head:]
