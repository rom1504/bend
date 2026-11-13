
/home/ai/bend2/build/publish/bend/selfhost/build/phase191/extra-dev-build01/coverage-map-churn-32/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406fc7 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_>:
  406fc7:	push   %rbp
  406fc8:	mov    %rsp,%rbp
  406fcb:	sub    $0xa30,%rsp
  406fd2:	mov    %r12,-0x10(%rbp)
  406fd6:	mov    %rbx,-0x8(%rbp)
  406fda:	mov    %r13,-0x18(%rbp)
  406fde:	mov    %r14,-0x20(%rbp)
  406fe2:	mov    %rdi,%rax
  406fe5:	mov    %rax,%r12
  406fe8:	mov    %rsi,%rax
  406feb:	mov    %rax,%rdi
  406fee:	mov    %rdx,%rax
  406ff1:	mov    %rax,%rbx
  406ff4:	mov    %rcx,%rax
  406ff7:	mov    %rax,%r13
  406ffa:	mov    %rdi,%rsi
  406ffd:	shr    $0x28,%rsi
  407001:	and    $0xffff,%rsi
  407008:	movabs $0x18,%r11
  407012:	cmp    %r11,%rsi
  407015:	jne    40705f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x98>
  40701b:	mov    %r12,%rdi
  40701e:	movabs $0x1,%rsi
  407028:	mov    %esi,%esi
  40702a:	lea    -0x840(%rbp),%rdx
  407031:	movabs $0x0,%rcx
  40703b:	mov    %ecx,%ecx
  40703d:	xor    %eax,%eax
  40703f:	callq  44aee0 <p111_rt_special_ctor>
  407044:	mov    %rax,%rdi
  407047:	mov    %rdi,%rax
  40704a:	mov    -0x10(%rbp),%r12
  40704e:	mov    -0x8(%rbp),%rbx
  407052:	mov    -0x18(%rbp),%r13
  407056:	mov    -0x20(%rbp),%r14
  40705a:	mov    %rbp,%rsp
  40705d:	pop    %rbp
  40705e:	retq   
  40705f:	mov    %rdi,%rsi
  407062:	shr    $0x28,%rsi
  407066:	and    $0xffff,%rsi
  40706d:	movabs $0x19,%r11
  407077:	cmp    %r11,%rsi
  40707a:	jne    407371 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x3aa>
  407080:	mov    %rdi,%rsi
  407083:	shr    $0x38,%rsi
  407087:	and    $0x7f,%rsi
  40708e:	mov    %rsi,%rdx
  407091:	cmp    $0x2,%rdx
  407098:	sete   %dl
  40709b:	movzbl %dl,%edx
  40709e:	mov    %rdi,%rsi
  4070a1:	shr    $0x28,%rsi
  4070a5:	and    $0xffff,%rsi
  4070ac:	movabs $0x19,%r11
  4070b6:	cmp    %r11,%rsi
  4070b9:	sete   %sil
  4070bd:	movzbl %sil,%esi
  4070c1:	mov    %rsi,%r11
  4070c4:	mov    %rdx,%rsi
  4070c7:	and    %r11d,%esi
  4070ca:	mov    %rsi,%r10
  4070cd:	test   %r10d,%r10d
  4070d0:	je     407160 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x199>
  4070d6:	mov    (%r12),%rdx
  4070da:	movabs $0xffffffffff,%r11
  4070e4:	mov    %rdi,%rsi
  4070e7:	and    %r11,%rsi
  4070ea:	shr    $0x3f,%rdi
  4070ee:	cmp    $0x0,%rdi
  4070f5:	je     407129 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x162>
  4070fb:	mov    %rsi,%rdi
  4070fe:	shl    $0x3,%rdi
  407102:	mov    %rdi,%r11
  407105:	mov    %rdx,%rdi
  407108:	add    %r11,%rdi
  40710b:	mov    (%rdi),%esi
  40710d:	mov    0x4(%rdi),%edi
  407110:	shl    $0x20,%rdi
  407114:	mov    %rdi,%r11
  407117:	mov    %rsi,%rdi
  40711a:	or     %r11,%rdi
  40711d:	mov    %rdi,%rsi
  407120:	shr    $0x18,%rsi
  407124:	jmpq   407129 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x162>
  407129:	mov    %rsi,%rdi
  40712c:	shl    $0x3,%rdi
  407130:	mov    %rdi,%r11
  407133:	mov    %rdx,%rdi
  407136:	add    %r11,%rdi
  407139:	mov    (%rdi),%rsi
  40713c:	lea    -0x840(%rbp),%r10
  407143:	mov    %rsi,%r11
  407146:	mov    %r11,(%r10)
  407149:	mov    0x8(%rdi),%rdi
  40714d:	lea    -0x840(%rbp),%r10
  407154:	mov    %rdi,%r11
  407157:	mov    %r11,0x8(%r10)
  40715b:	jmpq   4071c7 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x200>
  407160:	mov    %r12,%r10
  407163:	mov    %r10,0x28(%rsp)
  407168:	mov    %rdi,%r10
  40716b:	mov    %r10,0x30(%rsp)
  407170:	lea    -0x840(%rbp),%r10
  407177:	mov    %r10,0x38(%rsp)
  40717c:	movabs $0x19,%r10
  407186:	mov    %r10d,%r10d
  407189:	mov    %r10,0x40(%rsp)
  40718e:	movabs $0x2,%r10
  407198:	mov    %r10d,%r10d
  40719b:	mov    %r10,0x48(%rsp)
  4071a0:	mov    0x28(%rsp),%rdi
  4071a5:	mov    0x30(%rsp),%rsi
  4071aa:	mov    0x38(%rsp),%rdx
  4071af:	mov    0x40(%rsp),%rcx
  4071b4:	mov    0x48(%rsp),%r8
  4071b9:	xor    %eax,%eax
  4071bb:	callq  44e570 <p118_rt_borrow_fields>
  4071c0:	mov    %rax,-0x968(%rbp)
  4071c7:	lea    -0x840(%rbp),%r10
  4071ce:	mov    (%r10),%r14
  4071d1:	lea    -0x840(%rbp),%r10
  4071d8:	mov    0x8(%r10),%rdi
  4071dc:	cmp    $0x0,%rbx
  4071e3:	jne    407365 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x39e>
  4071e9:	cmp    %r14,%r14
  4071ec:	jne    407329 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x362>
  4071f2:	cmp    $0x0,%r13
  4071f9:	jne    407243 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x27c>
  4071ff:	mov    %r12,%rdi
  407202:	movabs $0x2,%rsi
  40720c:	mov    %esi,%esi
  40720e:	lea    -0x840(%rbp),%rdx
  407215:	movabs $0x0,%rcx
  40721f:	mov    %ecx,%ecx
  407221:	xor    %eax,%eax
  407223:	callq  44aee0 <p111_rt_special_ctor>
  407228:	mov    %rax,%rdi
  40722b:	mov    %rdi,%rax
  40722e:	mov    -0x10(%rbp),%r12
  407232:	mov    -0x8(%rbp),%rbx
  407236:	mov    -0x18(%rbp),%r13
  40723a:	mov    -0x20(%rbp),%r14
  40723e:	mov    %rbp,%rsp
  407241:	pop    %rbp
  407242:	retq   
  407243:	mov    %r13,%rdi
  407246:	sub    $0x1,%rdi
  40724d:	lea    -0x840(%rbp),%r10
  407254:	movabs $0x1f,%r11
  40725e:	mov    %r11,(%r10)
  407261:	lea    -0x840(%rbp),%r10
  407268:	mov    %rdi,%r11
  40726b:	mov    %r11,0x8(%r10)
  40726f:	mov    %r12,%rdi
  407272:	movabs $0x3f,%rsi
  40727c:	mov    %esi,%esi
  40727e:	lea    -0x840(%rbp),%rdx
  407285:	movabs $0x2,%rcx
  40728f:	mov    %ecx,%ecx
  407291:	xor    %eax,%eax
  407293:	callq  449d00 <p111_rt_op>
  407298:	mov    %rax,%rdi
  40729b:	mov    %r14,%r10
  40729e:	mov    %r10d,%r10d
  4072a1:	mov    %r10,-0x988(%rbp)
  4072a8:	mov    %rdi,%r10
  4072ab:	mov    %r10,-0x990(%rbp)
  4072b2:	cmp    $0x20,%rdi
  4072b9:	jae    4072da <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x313>
  4072bf:	mov    -0x990(%rbp),%r11
  4072c6:	mov    -0x988(%rbp),%rdi
  4072cd:	mov    %r11d,%ecx
  4072d0:	shr    %cl,%rdi
  4072d3:	mov    %edi,%edi
  4072d5:	jmpq   4072e4 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x31d>
  4072da:	movabs $0x0,%rdi
  4072e4:	and    $0x1,%rdi
  4072eb:	cmp    $0x0,%rdi
  4072f2:	je     407307 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x340>
  4072f8:	movabs $0x1,%rdi
  407302:	jmpq   407311 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x34a>
  407307:	movabs $0x0,%rdi
  407311:	mov    %rdi,%rax
  407314:	mov    -0x10(%rbp),%r12
  407318:	mov    -0x8(%rbp),%rbx
  40731c:	mov    -0x18(%rbp),%r13
  407320:	mov    -0x20(%rbp),%r14
  407324:	mov    %rbp,%rsp
  407327:	pop    %rbp
  407328:	retq   
  407329:	mov    %r12,%rdi
  40732c:	movabs $0x4,%rsi
  407336:	mov    %esi,%esi
  407338:	xor    %eax,%eax
  40733a:	callq  449ce0 <p111_rt_fail>
  40733f:	mov    %rax,-0x9a0(%rbp)
  407346:	movabs $0x0,%rax
  407350:	mov    -0x10(%rbp),%r12
  407354:	mov    -0x8(%rbp),%rbx
  407358:	mov    -0x18(%rbp),%r13
  40735c:	mov    -0x20(%rbp),%r14
  407360:	mov    %rbp,%rsp
  407363:	pop    %rbp
  407364:	retq   
  407365:	sub    $0x1,%rbx
  40736c:	jmpq   406ffa <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x33>
  407371:	mov    %r12,%rdi
  407374:	movabs $0x4,%rsi
  40737e:	mov    %esi,%esi
  407380:	xor    %eax,%eax
  407382:	callq  449ce0 <p111_rt_fail>
  407387:	mov    %rax,-0x9a0(%rbp)
  40738e:	movabs $0x0,%rax
  407398:	mov    -0x10(%rbp),%r12
  40739c:	mov    -0x8(%rbp),%rbx
  4073a0:	mov    -0x18(%rbp),%r13
  4073a4:	mov    -0x20(%rbp),%r14
  4073a8:	mov    %rbp,%rsp
  4073ab:	pop    %rbp
  4073ac:	retq   

Disassembly of section .fini:
