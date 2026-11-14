
/home/ai/bend2/build/publish/bend/selfhost/build/phase186/release-native45-acquire01/variation-ray-active-64-2440/phase186-qbe-n2/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000407000 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_>:
  407000:	endbr64 
  407004:	push   %rbp
  407005:	mov    %rsp,%rbp
  407008:	sub    $0x88,%rsp
  40700f:	push   %rbx
  407010:	push   %r12
  407012:	push   %r13
  407014:	push   %r14
  407016:	push   %r15
  407018:	mov    0x48(%rbp),%rax
  40701c:	mov    0x40(%rbp),%r15
  407020:	mov    0x38(%rbp),%r10
  407024:	mov    0x30(%rbp),%rbx
  407028:	mov    %r10,%r11
  40702b:	mov    0x28(%rbp),%r10
  40702f:	mov    0x20(%rbp),%r12
  407033:	mov    0x18(%rbp),%r13
  407037:	mov    0x10(%rbp),%r14
  40703b:	xchg   %rdx,%rbx
  40703e:	mov    %rsi,-0x80(%rbp)
  407042:	mov    %r15,%rsi
  407045:	mov    %r9,%r15
  407048:	mov    %rdi,-0x78(%rbp)
  40704c:	mov    %rax,%rdi
  40704f:	mov    %r8,%rax
  407052:	mov    %rdx,%r9
  407055:	xchg   %r10,%r11
  407058:	mov    %rsi,%rdx
  40705b:	nopl   0x0(%rax,%rax,1)
  407060:	cs cs cs mov %rcx,%cs:-0x68(%rbp)
  407068:	mov    %rax,%cs:-0x70(%rbp)
  40706d:	mov    %r11,-0x30(%rbp)
  407071:	mov    %r9,-0x28(%rbp)
  407075:	mov    %r10,-0x60(%rbp)
  407079:	mov    %rdx,-0x58(%rbp)
  40707d:	cmp    $0x0,%rbx
  407081:	sete   %sil
  407085:	movzbl %sil,%esi
  407089:	mov    %esi,-0xc(%rbp)
  40708c:	cmp    $0x1,%rdi
  407090:	mov    %rdi,%rsi
  407093:	sete   %dil
  407097:	movzbl %dil,%edi
  40709b:	shr    $0x28,%rsi
  40709f:	and    $0x7fffff,%rsi
  4070a6:	cmp    $0x10002,%rsi
  4070ad:	sete   %r8b
  4070b1:	movzbl %r8b,%r8d
  4070b5:	mov    %edi,%esi
  4070b7:	or     %r8d,%esi
  4070ba:	mov    %esi,-0x10(%rbp)
  4070bd:	mov    -0xc(%rbp),%esi
  4070c0:	cmp    $0x0,%esi
  4070c3:	jne    40747e <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x47e>
  4070c9:	cs cs cs cs sub $0x1,%rbx
  4070d1:	cs movq %rcx,%xmm2
  4070d7:	movq   %rax,%xmm4
  4070dc:	movq   %r15,%xmm3
  4070e1:	movq   %r14,%xmm0
  4070e6:	movq   %r13,%xmm5
  4070eb:	movq   %r12,%xmm1
  4070f0:	mov    %ebx,%esi
  4070f2:	mov    %rsi,-0x50(%rbp)
  4070f6:	mov    -0x10(%rbp),%esi
  4070f9:	xor    $0x1,%esi
  4070fc:	mov    -0x50(%rbp),%rsi
  407100:	jne    4072e5 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2e5>
  407106:	mov    %r11,%r10
  407109:	mov    %r9,%rdx
  40710c:	or     %r8d,%edi
  40710f:	je     4072ae <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x2ae>
  407115:	cmp    $0x8,%rbx
  407119:	mov    $0x8,%edi
  40711e:	cmovb  %rbx,%rdi
  407122:	mov    %rdi,%r8
  407125:	shl    $0x3,%r8
  407129:	lea    0x192b0(%rip),%rdi        # 4203e0 <p126s_table_FID_36_100_105_114_101_99_116_46_115_120_>
  407130:	mov    (%rdi,%r8,1),%r11
  407134:	cmp    $0x8,%rbx
  407138:	mov    $0x8,%edi
  40713d:	cmovb  %rbx,%rdi
  407141:	mov    %rdi,%r8
  407144:	shl    $0x3,%r8
  407148:	lea    0x19249(%rip),%rdi        # 420398 <p126s_table_FID_36_100_105_114_101_99_116_46_115_121_>
  40714f:	mov    (%rdi,%r8,1),%r9
  407153:	mov    %r9,-0x18(%rbp)
  407157:	cmp    $0x8,%rbx
  40715b:	mov    $0x8,%edi
  407160:	cmovb  %rbx,%rdi
  407164:	mov    %rdi,%r8
  407167:	shl    $0x3,%r8
  40716b:	lea    0x191de(%rip),%rdi        # 420350 <p126s_table_FID_36_100_105_114_101_99_116_46_115_122_>
  407172:	mov    (%rdi,%r8,1),%r8
  407176:	mov    %r8,-0x20(%rbp)
  40717a:	mov    -0x18(%rbp),%r9
  40717e:	cmp    $0x8,%rbx
  407182:	mov    $0x8,%edi
  407187:	cmovb  %rbx,%rdi
  40718b:	mov    %rdi,%r8
  40718e:	shl    $0x3,%r8
  407192:	lea    0x1916f(%rip),%rdi        # 420308 <p126s_table_FID_36_100_105_114_101_99_116_46_115_114_>
  407199:	mov    (%rdi,%r8,1),%rdi
  40719d:	mov    -0x20(%rbp),%r8
  4071a1:	movq   %r11,%xmm6
  4071a6:	subss  %xmm6,%xmm2
  4071aa:	movq   %r9,%xmm6
  4071af:	subss  %xmm6,%xmm4
  4071b3:	movq   %r8,%xmm6
  4071b8:	subss  %xmm6,%xmm3
  4071bc:	mulss  %xmm2,%xmm0
  4071c0:	mulss  %xmm4,%xmm5
  4071c4:	addss  %xmm5,%xmm0
  4071c8:	mulss  %xmm3,%xmm1
  4071cc:	addss  %xmm0,%xmm1
  4071d0:	movss  %xmm1,%xmm0
  4071d4:	mulss  %xmm1,%xmm0
  4071d8:	mulss  %xmm2,%xmm2
  4071dc:	mulss  %xmm4,%xmm4
  4071e0:	addss  %xmm4,%xmm2
  4071e4:	mulss  %xmm3,%xmm3
  4071e8:	addss  %xmm3,%xmm2
  4071ec:	movq   %rdi,%xmm3
  4071f1:	mulss  %xmm3,%xmm3
  4071f5:	subss  %xmm3,%xmm2
  4071f9:	subss  %xmm2,%xmm0
  4071fd:	movss  0x12e1f(%rip),%xmm2        # 41a024 <_IO_stdin_used+0x24>
  407205:	ucomiss %xmm0,%xmm2
  407208:	seta   %dil
  40720c:	movzbl %dil,%edi
  407210:	mov    %edi,%edi
  407212:	cmp    $0x1,%rdi
  407216:	je     407289 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x289>
  407218:	xorps  0x12df1(%rip),%xmm1        # 41a010 <_IO_stdin_used+0x10>
  40721f:	addss  0x12dfd(%rip),%xmm1        # 41a024 <_IO_stdin_used+0x24>
  407227:	movss  %xmm1,-0x44(%rbp)
  40722c:	cvtss2sd %xmm0,%xmm0
  407230:	callq  402500 <sqrt@plt>
  407235:	movsd  %xmm0,%xmm1
  407239:	mov    -0x68(%rbp),%rcx
  40723d:	mov    -0x70(%rbp),%rax
  407241:	mov    -0x30(%rbp),%r10
  407245:	mov    -0x28(%rbp),%rdx
  407249:	mov    -0x50(%rbp),%rsi
  40724d:	movss  -0x44(%rbp),%xmm0
  407252:	cvtsd2ss %xmm1,%xmm1
  407256:	subss  %xmm1,%xmm0
  40725a:	movss  0x12dc6(%rip),%xmm1        # 41a028 <_IO_stdin_used+0x28>
  407262:	ucomiss %xmm0,%xmm1
  407265:	seta   %dil
  407269:	movzbl %dil,%edi
  40726d:	mov    %edi,%edi
  40726f:	movq   %xmm0,%r8
  407274:	mov    %r8d,%r8d
  407277:	cmp    $0x1,%rdi
  40727b:	mov    $0x4e6e6b28,%edi
  407280:	mov    %rdi,%r11
  407283:	cmovne %r8,%r11
  407287:	jmp    40728f <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x28f>
  407289:	mov    $0x4e6e6b28,%r11d
  40728f:	movq   %r11,%xmm0
  407294:	movq   %r10,%xmm1
  407299:	ucomiss %xmm0,%xmm1
  40729c:	seta   %dil
  4072a0:	movzbl %dil,%edi
  4072a4:	mov    %edi,%edi
  4072a6:	mov    %rsi,%r9
  4072a9:	jmpq   407060 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x60>
  4072ae:	cs cs cs mov %cs:-0x80(%rbp),%rbx
  4072b6:	mov    -0x78(%rbp),%rdi
  4072ba:	mov    $0x4,%esi
  4072bf:	callq  413ed0 <p111_rt_fail>
  4072c4:	movq   $0x0,(%rbx)
  4072cb:	movq   $0x0,0x8(%rbx)
  4072d3:	movq   $0x0,0x10(%rbx)
  4072db:	mov    $0x0,%eax
  4072e0:	jmpq   407500 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x500>
  4072e5:	cmp    $0x8,%rbx
  4072e9:	mov    $0x8,%edi
  4072ee:	cmovb  %rbx,%rdi
  4072f2:	mov    %rdi,%r8
  4072f5:	shl    $0x3,%r8
  4072f9:	lea    0x190e0(%rip),%rdi        # 4203e0 <p126s_table_FID_36_100_105_114_101_99_116_46_115_120_>
  407300:	mov    (%rdi,%r8,1),%r11
  407304:	cmp    $0x8,%rbx
  407308:	mov    $0x8,%edi
  40730d:	cmovb  %rbx,%rdi
  407311:	mov    %rdi,%r8
  407314:	shl    $0x3,%r8
  407318:	lea    0x19079(%rip),%rdi        # 420398 <p126s_table_FID_36_100_105_114_101_99_116_46_115_121_>
  40731f:	mov    (%rdi,%r8,1),%r9
  407323:	mov    %r9,-0x38(%rbp)
  407327:	cmp    $0x8,%rbx
  40732b:	mov    $0x8,%edi
  407330:	cmovb  %rbx,%rdi
  407334:	mov    %rdi,%r8
  407337:	shl    $0x3,%r8
  40733b:	lea    0x1900e(%rip),%rdi        # 420350 <p126s_table_FID_36_100_105_114_101_99_116_46_115_122_>
  407342:	mov    (%rdi,%r8,1),%r8
  407346:	mov    %r8,-0x40(%rbp)
  40734a:	mov    -0x38(%rbp),%r9
  40734e:	cmp    $0x8,%rbx
  407352:	mov    $0x8,%edi
  407357:	cmovb  %rbx,%rdi
  40735b:	mov    %rdi,%r8
  40735e:	shl    $0x3,%r8
  407362:	lea    0x18f9f(%rip),%rdi        # 420308 <p126s_table_FID_36_100_105_114_101_99_116_46_115_114_>
  407369:	mov    (%rdi,%r8,1),%rdi
  40736d:	mov    -0x40(%rbp),%r8
  407371:	movq   %r11,%xmm6
  407376:	subss  %xmm6,%xmm2
  40737a:	movq   %r9,%xmm6
  40737f:	subss  %xmm6,%xmm4
  407383:	movq   %r8,%xmm6
  407388:	subss  %xmm6,%xmm3
  40738c:	mulss  %xmm2,%xmm0
  407390:	mulss  %xmm4,%xmm5
  407394:	addss  %xmm5,%xmm0
  407398:	mulss  %xmm3,%xmm1
  40739c:	addss  %xmm0,%xmm1
  4073a0:	movss  %xmm1,%xmm0
  4073a4:	mulss  %xmm1,%xmm0
  4073a8:	mulss  %xmm2,%xmm2
  4073ac:	mulss  %xmm4,%xmm4
  4073b0:	addss  %xmm4,%xmm2
  4073b4:	mulss  %xmm3,%xmm3
  4073b8:	addss  %xmm3,%xmm2
  4073bc:	movq   %rdi,%xmm3
  4073c1:	mulss  %xmm3,%xmm3
  4073c5:	subss  %xmm3,%xmm2
  4073c9:	subss  %xmm2,%xmm0
  4073cd:	movss  0x12c4f(%rip),%xmm2        # 41a024 <_IO_stdin_used+0x24>
  4073d5:	ucomiss %xmm0,%xmm2
  4073d8:	seta   %dil
  4073dc:	movzbl %dil,%edi
  4073e0:	mov    %edi,%edi
  4073e2:	cmp    $0x1,%rdi
  4073e6:	je     407459 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x459>
  4073e8:	xorps  0x12c21(%rip),%xmm1        # 41a010 <_IO_stdin_used+0x10>
  4073ef:	addss  0x12c2d(%rip),%xmm1        # 41a024 <_IO_stdin_used+0x24>
  4073f7:	movss  %xmm1,-0x48(%rbp)
  4073fc:	cvtss2sd %xmm0,%xmm0
  407400:	callq  402500 <sqrt@plt>
  407405:	movsd  %xmm0,%xmm1
  407409:	mov    -0x68(%rbp),%rcx
  40740d:	mov    -0x70(%rbp),%rax
  407411:	mov    -0x60(%rbp),%r10
  407415:	mov    -0x58(%rbp),%rdx
  407419:	mov    -0x50(%rbp),%rsi
  40741d:	movss  -0x48(%rbp),%xmm0
  407422:	cvtsd2ss %xmm1,%xmm1
  407426:	subss  %xmm1,%xmm0
  40742a:	movss  0x12bf6(%rip),%xmm1        # 41a028 <_IO_stdin_used+0x28>
  407432:	ucomiss %xmm0,%xmm1
  407435:	seta   %dil
  407439:	movzbl %dil,%edi
  40743d:	mov    %edi,%edi
  40743f:	movq   %xmm0,%r8
  407444:	mov    %r8d,%r8d
  407447:	cmp    $0x1,%rdi
  40744b:	mov    $0x4e6e6b28,%edi
  407450:	mov    %rdi,%r11
  407453:	cmovne %r8,%r11
  407457:	jmp    40745f <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x45f>
  407459:	mov    $0x4e6e6b28,%r11d
  40745f:	movq   %r11,%xmm0
  407464:	movq   %r10,%xmm1
  407469:	ucomiss %xmm0,%xmm1
  40746c:	seta   %dil
  407470:	movzbl %dil,%edi
  407474:	mov    %edi,%edi
  407476:	mov    %rsi,%r9
  407479:	jmpq   407060 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x60>
  40747e:	mov    %edi,%eax
  407480:	mov    -0x10(%rbp),%esi
  407483:	mov    -0x80(%rbp),%rbx
  407487:	mov    -0x78(%rbp),%rdi
  40748b:	mov    %esi,%ecx
  40748d:	xor    $0x1,%ecx
  407490:	jne    4074e2 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4e2>
  407492:	or     %r8d,%eax
  407495:	jne    4074bf <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x4bf>
  407497:	mov    $0x4,%esi
  40749c:	callq  413ed0 <p111_rt_fail>
  4074a1:	movq   $0x0,(%rbx)
  4074a8:	movq   $0x0,0x8(%rbx)
  4074b0:	movq   $0x0,0x10(%rbx)
  4074b8:	mov    $0x0,%eax
  4074bd:	jmp    407500 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x500>
  4074bf:	cs cs mov %r9d,%eax
  4074c4:	cmp    $0x9,%rax
  4074c8:	sete   %al
  4074cb:	movzbl %al,%eax
  4074ce:	mov    %eax,%eax
  4074d0:	mov    %rax,(%rbx)
  4074d3:	mov    %r11,0x8(%rbx)
  4074d7:	mov    %r9,0x10(%rbx)
  4074db:	mov    $0x0,%eax
  4074e0:	jmp    407500 <p113d_FID_36_112_114_111_100_117_99_116_46_110_101_97_114_101_115_116_+0x500>
  4074e2:	mov    %edx,%eax
  4074e4:	cmp    $0x9,%rax
  4074e8:	sete   %al
  4074eb:	movzbl %al,%eax
  4074ee:	mov    %eax,%eax
  4074f0:	mov    %rax,(%rbx)
  4074f3:	mov    %r10,0x8(%rbx)
  4074f7:	mov    %rdx,0x10(%rbx)
  4074fb:	mov    $0x0,%eax
  407500:	pop    %r15
  407502:	pop    %r14
  407504:	pop    %r13
  407506:	pop    %r12
  407508:	pop    %rbx
  407509:	leaveq 
  40750a:	retq   

Disassembly of section .fini:
