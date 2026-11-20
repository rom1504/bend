"""Generate the checked Bend X188 sequence for the bounded all-or-fallback traversal."""
from pathlib import Path
HERE=Path(__file__).parent
R=['rax','rcx','rdx','rbx','rsp','rbp','rsi','rdi','r8','r9','r10','r11','r12','r13','r14','r15']
code=[]
def reg(r,w=64):
    return f'x188_reg({R.index(r)},{w})'
def mem(r,d=0):
    return f'X187Mem{{{R.index(r)},{d%2**32}}}'
def indexed(r,i,scale,d=0):
    return f'X187Indexed{{{R.index(r)},{R.index(i)},{scale},{d}}}'
def imm(v):
    if isinstance(v,str):return 'X187Imm{'+v+',0}'
    return f'X187Imm{{{v%2**32},{(v>>32)%2**32}}}'
def rip(d):return f'X187Rip{{"p111_program",{d},0}}'
def lab(label):return 'slow' if label=='slow' else 'prefix ++ "_'+label+'"'
def label(name):code.append('x188_label('+lab(name)+')')
def op(o,*args):code.append('x188_i'+str(len(args))+'("'+o+'"'+(',' if args else '')+','.join(args)+')')
def j(o,target):op(o,'X187Target{'+lab(target)+'}')
def mov(a,b):op('movq',a,b)
def loadhead(w,dst,shift):mov(reg(w),reg(dst));op('shrq',imm(shift),reg(dst))
def cmp(a,b):op('cmpq',a,b)
def ep():
    op('addq',imm(9304),reg('rsp'))
    for r in ['r15','r14','r13','r12','rbx','rbp']:op('popq',reg(r))
def putpair(d,a,b):mov(reg(a),indexed('rsp','r13',1,d));mov(reg(b),indexed('rsp','r13',1,d+8))
# Fresh H invocation. A non-fresh call retains its mode/depth/prior registers.
for x in [reg('r8'),reg('r9'),mem('rsp',8)]:cmp(imm(0),x);j('jne','slow')
for offset,want in [(0,11102),(8,192)]:
    mov(rip(offset),reg('rax'));cmp(imm(want),reg('rax'));j('jne','slow')
mov(rip(88),reg('rax'));op('andq',imm(9),reg('rax'));cmp(imm(9),reg('rax'));j('jne','slow')
op('pushq',reg('rbp'));mov(reg('rsp'),reg('rbp'))
for r in ['rbx','r12','r13','r14','r15']:op('pushq',reg(r))
op('subq',imm(9304),reg('rsp'))
# Byte 0 state, 8/16 root words, 24 direction, 32 dynamic bound.
for i,r in enumerate(['rdi','rsi','rdx','rcx']):mov(reg(r),mem('rsp',8*i))
op('xorl',reg('rbx',32),reg('rbx',32));cmp(imm(0),reg('rcx'));j('je','setup')
op('movabsq','X187Imm{0,falseHi}',reg('rax'));cmp(reg('rax'),reg('rcx'));j('je','setup')
op('movl',imm(1),reg('rbx',32));cmp(imm(1),reg('rcx'));j('je','setup')
op('movabsq','X187Imm{0,trueHi}',reg('rax'));cmp(reg('rax'),reg('rcx'));j('jne','miss')
label('setup');mov(mem('rdi'),reg('r12'));mov(rip(64),reg('rax'));op('addq',imm(127),reg('rax'));op('andq',imm(-128),reg('rax'));op('addq',imm(51413504),reg('rax'));mov(reg('rax'),mem('rsp',32))
op('leaq',mem('rsp',8),reg('rax'));mov(reg('rax'),mem('rsp',64));op('leaq',mem('rsp',16),reg('rax'));mov(reg('rax'),mem('rsp',72))
op('movl',imm(16),reg('r13',32));op('xorl',reg('r14',32),reg('r14',32));op('xorl',reg('r15',32),reg('r15',32))
label('scan');cmp(imm(0),reg('r13'));j('je','commit');op('subq',imm(16),reg('r13'));mov(indexed('rsp','r13',1,64),reg('rdi'));mov(indexed('rsp','r13',1,72),reg('rsi'))
mov(mem('rdi'),reg('rdx'));mov(mem('rsi'),reg('rcx'))
loadhead('rdx','r8',32);op('cmpl',imm('leafHi'),reg('r8',32));j('jne','node')
loadhead('rcx','r9',32);op('cmpl',imm('leafHi'),reg('r9',32));j('jne','miss')
op('addl',imm(1),reg('r15',32));op('cmpl',imm(1024),reg('r15',32));j('ja','miss')
op('cmpl',reg('rcx',32),reg('rdx',32));j('je','scan');op('seta',reg('rax',8));op('movzbl',reg('rax',8),reg('rax',32));op('xorl',reg('rbx',32),reg('rax',32));j('je','scan')
cmp(imm(8192),reg('r14'));j('je','miss');mov(reg('rdi'),indexed('rsp','r14',1,1088));mov(reg('rsi'),indexed('rsp','r14',1,1096));op('addq',imm(16),reg('r14'));j('jmp','scan')
label('node');op('shrq',imm(8),reg('r8'));op('cmpl',imm('nodeHead'),reg('r8',32));j('jne','miss')
loadhead('rcx','r9',40);op('cmpl',imm('nodeHead'),reg('r9',32));j('jne','miss')
op('movabsq',imm((1<<40)-1),reg('rax'));op('andq',reg('rax'),reg('rdx'));op('andq',reg('rax'),reg('rcx'))
cmp(mem('rsp',32),reg('rdx'));j('jb','miss');cmp(mem('rsp',32),reg('rcx'));j('jb','miss');cmp(reg('rcx'),reg('rdx'));j('je','miss')
cmp(imm(992),reg('r13'));j('ja','miss')
op('leaq',indexed('r12','rdx',8,8),reg('rdi'));op('leaq',indexed('r12','rcx',8,8),reg('rsi'));putpair(64,'rdi','rsi')
op('leaq',indexed('r12','rdx',8),reg('rdi'));op('leaq',indexed('r12','rcx',8),reg('rsi'));putpair(80,'rdi','rsi')
op('addq',imm(32),reg('r13'));j('jmp','scan')
label('commit');cmp(reg('r14'),reg('r13'));j('je','done')
mov(indexed('rsp','r13',1,1088),reg('rdi'));mov(indexed('rsp','r13',1,1096),reg('rsi'));mov(mem('rdi'),reg('rax'));mov(mem('rsi'),reg('rdx'));mov(reg('rdx'),mem('rdi'));mov(reg('rax'),mem('rsi'))
op('addq',imm(16),reg('r13'));j('jmp','commit')
label('done');mov(mem('rsp'),reg('rdi'));op('movl',imm('nodeCid'),reg('rsi',32));op('leaq',mem('rsp',8),reg('rdx'))
op('call','X187Target{"p125_rt_ctor2"}');ep();op('ret')
label('miss')
for i,r in enumerate(['rdi','rsi','rdx','rcx']):mov(mem('rsp',8*i),reg(r))
op('xorl',reg('r8',32),reg('r8',32));op('xorl',reg('r9',32),reg('r9',32));ep();j('jmp','slow')

def generate():
    chunks=[code[i:i+14] for i in range(0,len(code),14)]
    # All code paths produce the same typed sequence for the object encoder
    # and assembly printer. Split literal chunks to bound parser/checker depth.
    s=['# Generated by machine.py. Checked typed instruction sequence; no assembly parser or C helper.']
    args=['prefix','slow','nodeCid','nodeHead','leafHi','falseHi','trueHi']
    sig=lambda a:'+'+a+(': String' if a in ('prefix','slow') else ': U32')
    calls=[]
    for i,chunk in enumerate(chunks):
        present=[a for a in args if any(a in v for v in chunk)]
        s+=['','def x198pw_part'+str(i)+'('+', '.join(map(sig,present))+') -> X188Seq:',
            '  x188_many([\n    '+',\n    '.join(chunk)+'])']
        calls.append('x198pw_part'+str(i)+'('+','.join(present)+')')
    s+=['','def x198pw_machine('+', '.join(map(sig,args))+') -> X188Seq:',
        '  x188_many([\n    '+',\n    '.join(calls)+'])']
    (HERE/'machine.bend').write_text('\n'.join(s)+'\n')
if __name__=='__main__':generate()
