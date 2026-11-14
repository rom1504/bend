
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/native45-02/scalar-region-8192/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040912e <p113d_FID_36_100_105_114_101_99_116_46_112_57_51_46_108_111_111_112_>:
  40912e:	push   %rbp
  40912f:	mov    %rsp,%rbp
  409132:	sub    $0x9e0,%rsp
  409139:	mov    %r12,-0x10(%rbp)
  40913d:	mov    %rbx,-0x8(%rbp)
  409141:	mov    %r13,-0x18(%rbp)
  409145:	mov    %r14,-0x20(%rbp)
  409149:	mov    %r15,-0x28(%rbp)
  40914d:	mov    %rdi,%rax
  409150:	mov    %rax,%r12
  409153:	mov    %rsi,%rax
  409156:	mov    %rax,%rdi
  409159:	mov    %rdx,%rax
  40915c:	mov    %rax,%r14
  40915f:	mov    %rcx,%rax
  409162:	mov    %rax,%rbx
  409165:	mov    %r8,%rax
  409168:	mov    %rax,%r13
  40916b:	cmp    $0x0,%rdi
  409172:	jne    409194 <p113d_FID_36_100_105_114_101_99_116_46_112_57_51_46_108_111_111_112_+0x66>
  409178:	mov    %r13,%rax
  40917b:	mov    -0x10(%rbp),%r12
  40917f:	mov    -0x8(%rbp),%rbx
  409183:	mov    -0x18(%rbp),%r13
  409187:	mov    -0x20(%rbp),%r14
  40918b:	mov    -0x28(%rbp),%r15
  40918f:	mov    %rbp,%rsp
  409192:	pop    %rbp
  409193:	retq   
  409194:	mov    %rdi,%r15
  409197:	sub    $0x1,%r15
  40919e:	mov    %ebx,%edi
  4091a0:	and    $0x3ff,%rdi
  4091a7:	sub    $0x200,%edi
  4091ad:	mov    %rdi,%rsi
  4091b0:	mov    %ebx,%edi
  4091b2:	shr    $0xa,%rdi
  4091b6:	and    $0x3ff,%rdi
  4091bd:	sub    $0x200,%edi
  4091c3:	mov    %r12,%r10
  4091c6:	mov    %r10,0x40(%rsp)
  4091cb:	mov    %r14,%r10
  4091ce:	mov    %r10,0x48(%rsp)
  4091d3:	mov    %rsi,%r10
  4091d6:	mov    %r10,0x50(%rsp)
  4091db:	mov    %rdi,%r10
  4091de:	mov    %r10,0x58(%rsp)
  4091e3:	movabs $0x0,%r10
  4091ed:	mov    %r10,0x60(%rsp)
  4091f2:	movabs $0x0,%r10
  4091fc:	mov    %r10,0x68(%rsp)
  409201:	movabs $0x0,%r10
  40920b:	mov    %r10,0x70(%rsp)
  409210:	movabs $0x0,%r10
  40921a:	mov    %r10,0x78(%rsp)
  40921f:	mov    0x40(%rsp),%rdi
  409224:	mov    0x48(%rsp),%rsi
  409229:	mov    0x50(%rsp),%rdx
  40922e:	mov    0x58(%rsp),%rcx
  409233:	mov    0x60(%rsp),%r8
  409238:	mov    0x68(%rsp),%r9
  40923d:	mov    0x70(%rsp),%r10
  409242:	mov    %r10,(%rsp)
  409246:	mov    0x78(%rsp),%r10
  40924b:	mov    %r10,0x8(%rsp)
  409250:	xor    %eax,%eax
  409252:	callq  4085f2 <p113d_FID_36_100_105_114_101_99_116_46_109_105_116_>
  409257:	mov    %rax,%rdi
  40925a:	mov    %edi,%edi
  40925c:	mov    %rdi,%r10
  40925f:	movabs $0x2000,%r11
  409269:	cmp    %r11,%r10
  40926c:	movabs $0x1,%rax
  409276:	movabs $0x0,%r11
  409280:	cmove  %rax,%r11
  409284:	mov    %r11,%rsi
  409287:	mov    %r13d,%edi
  40928a:	mov    %rdi,%r13
  40928d:	add    %esi,%r13d
  409290:	mov    %r15,%rdi
  409293:	jmpq   40916b <p113d_FID_36_100_105_114_101_99_116_46_112_57_51_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
