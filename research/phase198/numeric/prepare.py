from pathlib import Path
import hashlib,json,sys
ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent
SYMBOL='p113d_FID_36_100_105_114_101_99_116_46_109_105_116_'
def pin(p):
 p=Path(p);b=p.read_bytes();return dict(file=str(p.resolve()),bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
def read(p):return json.loads(Path(p).read_text())
def verify(p):
 assert pin(p['file'])==p,p['file'];return Path(p['file'])
def main():
 source=ROOT/'selfhost/build/phase197/shared-emission01/combined/mandelbrot/program.s'
 obj=source.with_suffix('.o');native=ROOT/'selfhost/build/phase195/native45-01/mandelbrot/machine'
 assert obj.read_bytes()==(native/'program.o').read_bytes()
 lines=source.read_text().splitlines();start=lines.index(SYMBOL+':');end=lines.index('.size '+SYMBOL+', .-'+SYMBOL)
 old=lines[start:end]
 body=old[old.index('.L'+SYMBOL+'_b0:')+1:-1]
 pro=['pushq %rbx','pushq %r12','pushq %r13','movl 32(%rsp), %ebx','movl 40(%rsp), %edi','testq %rsi, %rsi','jz .Lp198_done']
 loop=['movl %r8d, %r10d','imull %r8d, %r10d','sarl $8, %r10d','movl %r9d, %r11d','imull %r9d, %r11d','sarl $8, %r11d','movl %r10d, %eax','addl %r11d, %eax','cmpl $1024, %eax','seta %r13b','movzbl %r13b, %r13d','orl %r13d, %ebx','movl %r10d, %r12d','subl %r11d, %r12d','addl %edx, %r12d','movl %r8d, %eax','imull %r9d, %eax','addl %eax, %eax','sarl $8, %eax','addl %ecx, %eax','testl %ebx, %ebx','cmovzl %r12d, %r8d','cmovzl %eax, %r9d','setz %r13b','movzbl %r13b, %r13d','addl %r13d, %edi','subq $1, %rsi']
 tail=['movl %edi, %eax','popq %r13','popq %r12','popq %rbx','ret']
 def function(loop):return [SYMBOL+':',*['  '+x for x in pro],'.Lp198_loop:',*['  '+x for x in loop],'  jne .Lp198_loop','.Lp198_done:',*['  '+x for x in tail]]
 early=loop[:12]+['testl %ebx, %ebx','jnz .Lp198_done']+loop[12:20]+['movl %r12d, %r8d','movl %eax, %r9d','addl $1, %edi','subq $1, %rsi']
 variants=[dict(name='typed-scalar',after=function(loop),model=loop),dict(name='typed-escape',after=function(early),model=None)]
 refs=read(ROOT/'selfhost/build/phase195/references01/manifest.json');ref=next(c for c in refs['cases'] if c['id']=='mandelbrot')
 result=dict(kind='phase198-numeric-frozen-v1',case='mandelbrot',source=pin(source),object=pin(obj),direct=pin(native/'program'),reference=ref,method=pin(__file__),symbol=SYMBOL,start=start,end=end,before=old,beforeModel=[x.strip() for x in body],variants=variants,
 legality='All scalar fields are zero-extended U32; n is an unboxed Nat count. SAR is exact sign-filled low32 shift. All products/add/sub wrap32 before shifting/comparison. No allocation, calls or externally visible effects occur in mit. Callee-saved registers and SysV stack args preserved. Esc is absorbing under bitwise OR; if nonzero all subsequent z/it states are unchanged, hence early return preserves result for every remaining n. Numeric loop only, not arbitrary effectful loop law.',
 prediction='Closed U32 loop eliminates expanded sign reconstruction and stack-carried state. Expect substantial local gain and potentially >25% whole-work gain; current dynamic mit weight unknown. Early escape may dominate low-iteration viewport cases. Neither is a SIMD compiler implementation.',
 points=[[2,0],[0,0],[1,17],[4,7],[5,31]],screen=dict(rounds=6,targetMs=160,roles=['direct','baseline','typed-scalar','typed-escape','c','qbe'],timedPoints=[[2,0]],finiteMitCases=1024),
 exclusions='Phase120 already tested signed-shift recognition in QBE; no claim of new shift-only idea. This explicitly tests full typed state and an absorbing escape state, distinct from Phase197 local MOV edits. No current profile block weight is invented.')
 assert not (HERE/'frozen.json').exists();(HERE/'frozen.json').write_text(json.dumps(result,indent=2)+'\n')
 for v in variants:(HERE/(v['name']+'.s')).write_text('.text\n.globl '+SYMBOL+'\n.type '+SYMBOL+', @function\n'+'\n'.join(v['after'])+'\n.size '+SYMBOL+', .-'+SYMBOL+'\n.section .note.GNU-stack,"",@progbits\n')
 print(json.dumps({'instructionsBefore':len(result['beforeModel']),'typedLoop':len(loop),'source':result['source']}))
if __name__=='__main__':main()
