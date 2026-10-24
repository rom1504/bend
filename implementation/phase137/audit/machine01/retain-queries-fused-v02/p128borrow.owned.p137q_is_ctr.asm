
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

00000000004090c0 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_99_116_114_>:
  4090c0:	endbr64 
  4090c4:	push   %rbp
  4090c5:	mov    %rsp,%rbp
  4090c8:	sub    $0x828,%rsp
  4090cf:	push   %rbx
  4090d0:	push   %r12
  4090d2:	push   %r13
  4090d4:	push   %r14
  4090d6:	push   %r15
  4090d8:	mov    %rsi,%rax
  4090db:	shr    $0x28,%rax
  4090df:	and    $0xffff,%rax
  4090e5:	cmp    $0x99,%rax
  4090eb:	sete   %cl
  4090ee:	movzbl %cl,%ecx
  4090f1:	cmp    $0x0,%ecx
  4090f4:	jne    40918d <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_99_116_114_+0xcd>
  4090fa:	nopw   0x0(%rax,%rax,1)
  409100:	cmp    $0x9a,%rax
  409106:	je     409165 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_99_116_114_+0xa5>
  409108:	cmp    $0x9b,%rax
  40910e:	je     409125 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_99_116_114_+0x65>
  409110:	cs mov $0x4,%esi
  409116:	callq  432730 <p111_rt_fail>
  40911b:	mov    $0x0,%eax
  409120:	jmpq   4092d1 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_99_116_114_+0x211>
  409125:	cs cs lea %cs:-0x820(%rbp),%rdx
  40912f:	mov    %rdi,%rbx
  409132:	callq  437c20 <p125_rt_take4>
  409137:	mov    %rbx,%rdi
  40913a:	mov    -0x810(%rbp),%rsi
  409141:	mov    -0x808(%rbp),%r12
  409148:	mov    %rdi,%rbx
  40914b:	callq  431fa0 <p111_rt_sink>
  409150:	mov    %r12,%rsi
  409153:	mov    %rbx,%rdi
  409156:	callq  431fa0 <p111_rt_sink>
  40915b:	mov    $0x0,%eax
  409160:	jmpq   4092d1 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_99_116_114_+0x211>
  409165:	lea    -0x820(%rbp),%rdx
  40916c:	mov    %rdi,%rbx
  40916f:	callq  437750 <p125_rt_take2>
  409174:	mov    %rbx,%rdi
  409177:	mov    -0x818(%rbp),%rsi
  40917e:	callq  431fa0 <p111_rt_sink>
  409183:	mov    $0x0,%eax
  409188:	jmpq   4092d1 <p113d_FID_36_112_49_50_56_98_111_114_114_111_119_46_111_119_110_101_100_46_112_49_51_55_113_95_105_115_95_99_116_114_+0x211>
  40918d:	mov    $0x9,%ecx
  409192:	lea    -0x820(%rbp),%rdx
  409199:	mov    %rdi,%rbx
  40919c:	callq  432190 <p111_rt_take>
  4091a1:	mov    %rbx,%rdi
  4091a4:	mov    -0x820(%rbp),%rsi
  4091ab:	mov    -0x818(%rbp),%r12
  4091b2:	mov    -0x810(%rbp),%r13
  4091b9:	mov    -0x808(%rbp),%r15
  4091c0:	mov    -0x800(%rbp),%r14
  4091c7:	mov    -0x7f8(%rbp),%rbx
  4091ce:	mov    %rbx,-0x8(%rbp)
  4091d2:	mov    -0x7f0(%rbp),%rbx
  4091d9:	mov    %rbx,-0x10(%rbp)
  4091dd:	mov    -0x7e8(%rbp),%rbx
  4091e4:	mov    %rbx,-0x18(%rbp)
  4091e8:	mov    -0x7e0(%rbp),%rbx
  4091ef:	mov    %rbx,-0x20(%rbp)
  4091f3:	mov    %rdi,%rbx
  4091f6:	callq  431fa0 <p111_rt_sink>
  4091fb:	mov    %r13,%rsi
  4091fe:	mov    %rbx,%rdi
  409201:	mov    -0x8(%rbp),%r13
  409205:	mov    %rdi,%rbx
  409208:	callq  431fa0 <p111_rt_sink>
  40920d:	mov    %r15,%rsi
  409210:	mov    %rbx,%rdi
  409213:	mov    -0x10(%rbp),%r15
  409217:	mov    %rdi,%rbx
  40921a:	callq  431fa0 <p111_rt_sink>
  40921f:	mov    %r14,%rsi
  409222:	mov    %rbx,%rdi
  409225:	mov    -0x18(%rbp),%r14
  409229:	mov    %rdi,%rbx
  40922c:	callq  431fa0 <p111_rt_sink>
  409231:	mov    %r13,%rsi
  409234:	mov    %rbx,%rdi
  409237:	mov    -0x20(%rbp),%r13
  40923b:	mov    %rdi,%rbx
  40923e:	callq  431fa0 <p111_rt_sink>
  409243:	mov    %r15,%rsi
  409246:	mov    %rbx,%rdi
  409249:	mov    %rdi,%rbx
  40924c:	callq  431fa0 <p111_rt_sink>
  409251:	mov    %r14,%rsi
  409254:	mov    %rbx,%rdi
  409257:	mov    %rdi,%rbx
  40925a:	callq  431fa0 <p111_rt_sink>
  40925f:	mov    %r13,%rsi
  409262:	mov    %rbx,%rdi
  409265:	mov    %rdi,%rbx
  409268:	callq  431fa0 <p111_rt_sink>
  40926d:	mov    %r12,%rsi
  409270:	mov    %rbx,%rdi
  409273:	mov    %rdi,%rbx
  409276:	callq  431f10 <p111_rt_keep>
  40927b:	mov    %rbx,%rdi
  40927e:	mov    %rax,%rsi
  409281:	mov    %rsi,%r12
  409284:	movabs $0x200190003108648,%rsi
  40928e:	mov    %rdi,%rbx
  409291:	callq  431f10 <p111_rt_keep>
  409296:	mov    %r12,%rsi
  409299:	mov    %rbx,%rdi
  40929c:	mov    %rax,%r13
  40929f:	mov    $0x1,%ecx
  4092a4:	mov    %r13,%rdx
  4092a7:	mov    %rsi,%r12
  4092aa:	mov    %rdi,%rbx
  4092ad:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  4092b2:	mov    %r12,%rsi
  4092b5:	mov    %rbx,%rdi
  4092b8:	mov    %rax,%rbx
  4092bb:	mov    %rdi,%r12
  4092be:	callq  431fa0 <p111_rt_sink>
  4092c3:	mov    %r13,%rsi
  4092c6:	mov    %r12,%rdi
  4092c9:	callq  431fa0 <p111_rt_sink>
  4092ce:	mov    %rbx,%rax
  4092d1:	pop    %r15
  4092d3:	pop    %r14
  4092d5:	pop    %r13
  4092d7:	pop    %r12
  4092d9:	pop    %rbx
  4092da:	leaveq 
  4092db:	retq   

Disassembly of section .fini:
