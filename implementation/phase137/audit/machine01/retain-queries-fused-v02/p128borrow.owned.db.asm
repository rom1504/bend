
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000407110 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_98_>:
  407110:	endbr64 
  407114:	push   %rbp
  407115:	mov    %rsp,%rbp
  407118:	sub    $0x828,%rsp
  40711f:	push   %rbx
  407120:	push   %r12
  407122:	push   %r13
  407124:	push   %r14
  407126:	push   %r15
  407128:	mov    %rsi,%rax
  40712b:	shr    $0x28,%rax
  40712f:	and    $0xffff,%rax
  407135:	cmp    $0x99,%rax
  40713b:	sete   %cl
  40713e:	movzbl %cl,%ecx
  407141:	cmp    $0x0,%ecx
  407144:	jne    4071d3 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_98_+0xc3>
  40714a:	cmp    $0x9a,%rax
  407150:	je     4071ab <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_98_+0x9b>
  407152:	cmp    $0x9b,%rax
  407158:	je     40716e <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_98_+0x5e>
  40715a:	mov    $0x4,%esi
  40715f:	callq  432730 <p111_rt_fail>
  407164:	mov    $0x0,%eax
  407169:	jmpq   4072b3 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_98_+0x1a3>
  40716e:	lea    -0x820(%rbp),%rdx
  407175:	mov    %rdi,%rbx
  407178:	callq  437c20 <p125_rt_take4>
  40717d:	mov    %rbx,%rdi
  407180:	mov    -0x810(%rbp),%rsi
  407187:	mov    -0x808(%rbp),%r12
  40718e:	mov    %rdi,%rbx
  407191:	callq  431fa0 <p111_rt_sink>
  407196:	mov    %r12,%rsi
  407199:	mov    %rbx,%rdi
  40719c:	callq  431fa0 <p111_rt_sink>
  4071a1:	mov    $0x1,%eax
  4071a6:	jmpq   4072b3 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_98_+0x1a3>
  4071ab:	lea    -0x820(%rbp),%rdx
  4071b2:	mov    %rdi,%rbx
  4071b5:	callq  437750 <p125_rt_take2>
  4071ba:	mov    %rbx,%rdi
  4071bd:	mov    -0x818(%rbp),%rsi
  4071c4:	callq  431fa0 <p111_rt_sink>
  4071c9:	mov    $0x1,%eax
  4071ce:	jmpq   4072b3 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_100_98_+0x1a3>
  4071d3:	mov    $0x9,%ecx
  4071d8:	lea    -0x820(%rbp),%rdx
  4071df:	mov    %rdi,%rbx
  4071e2:	callq  432190 <p111_rt_take>
  4071e7:	mov    %rbx,%rdi
  4071ea:	mov    -0x820(%rbp),%rsi
  4071f1:	mov    -0x818(%rbp),%r15
  4071f8:	mov    -0x810(%rbp),%r14
  4071ff:	mov    -0x808(%rbp),%r12
  407206:	mov    -0x800(%rbp),%r13
  40720d:	mov    -0x7f8(%rbp),%rbx
  407214:	mov    %rbx,-0x8(%rbp)
  407218:	mov    -0x7f0(%rbp),%rbx
  40721f:	mov    %rbx,-0x10(%rbp)
  407223:	mov    -0x7e8(%rbp),%rbx
  40722a:	mov    %rbx,-0x18(%rbp)
  40722e:	mov    -0x7e0(%rbp),%rbx
  407235:	mov    %rbx,-0x20(%rbp)
  407239:	mov    %rdi,%rbx
  40723c:	callq  431fa0 <p111_rt_sink>
  407241:	mov    %r15,%rsi
  407244:	mov    %rbx,%rdi
  407247:	mov    -0x8(%rbp),%r15
  40724b:	mov    %rdi,%rbx
  40724e:	callq  431fa0 <p111_rt_sink>
  407253:	mov    %r14,%rsi
  407256:	mov    %rbx,%rdi
  407259:	mov    -0x10(%rbp),%r14
  40725d:	mov    %rdi,%rbx
  407260:	callq  431fa0 <p111_rt_sink>
  407265:	mov    %r12,%rsi
  407268:	mov    %rbx,%rdi
  40726b:	mov    -0x18(%rbp),%rbx
  40726f:	mov    %rdi,%r12
  407272:	callq  431fa0 <p111_rt_sink>
  407277:	mov    %r13,%rsi
  40727a:	mov    %r12,%rdi
  40727d:	mov    -0x20(%rbp),%r13
  407281:	mov    %rdi,%r12
  407284:	callq  431fa0 <p111_rt_sink>
  407289:	mov    %r15,%rsi
  40728c:	mov    %r12,%rdi
  40728f:	mov    %rdi,%r12
  407292:	callq  431fa0 <p111_rt_sink>
  407297:	mov    %r14,%rsi
  40729a:	mov    %r12,%rdi
  40729d:	mov    %rdi,%r12
  4072a0:	callq  431fa0 <p111_rt_sink>
  4072a5:	mov    %r13,%rsi
  4072a8:	mov    %r12,%rdi
  4072ab:	callq  431fa0 <p111_rt_sink>
  4072b0:	mov    %rbx,%rax
  4072b3:	pop    %r15
  4072b5:	pop    %r14
  4072b7:	pop    %r13
  4072b9:	pop    %r12
  4072bb:	pop    %rbx
  4072bc:	leaveq 
  4072bd:	retq   

Disassembly of section .fini:
