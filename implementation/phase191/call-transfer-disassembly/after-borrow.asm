
/home/ai/bend2/build/publish/bend/selfhost/build/phase191/call-dev-build01/coverage-map-churn-32/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000406ed2 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_>:
  406ed2:	push   %rbp
  406ed3:	mov    %rsp,%rbp
  406ed6:	sub    $0xa30,%rsp
  406edd:	mov    %r12,-0x10(%rbp)
  406ee1:	mov    %rbx,-0x8(%rbp)
  406ee5:	mov    %r13,-0x18(%rbp)
  406ee9:	mov    %r14,-0x20(%rbp)
  406eed:	mov    %rdi,%rax
  406ef0:	mov    %rax,%r12
  406ef3:	mov    %rsi,%rax
  406ef6:	mov    %rax,%rdi
  406ef9:	mov    %rdx,%rax
  406efc:	mov    %rax,%rbx
  406eff:	mov    %rcx,%rax
  406f02:	mov    %rax,%r13
  406f05:	mov    %rdi,%rsi
  406f08:	shr    $0x28,%rsi
  406f0c:	and    $0xffff,%rsi
  406f13:	movabs $0x18,%r11
  406f1d:	cmp    %r11,%rsi
  406f20:	jne    406f6a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x98>
  406f26:	mov    %r12,%rdi
  406f29:	movabs $0x1,%rsi
  406f33:	mov    %esi,%esi
  406f35:	lea    -0x840(%rbp),%rdx
  406f3c:	movabs $0x0,%rcx
  406f46:	mov    %ecx,%ecx
  406f48:	xor    %eax,%eax
  406f4a:	callq  448370 <p111_rt_special_ctor>
  406f4f:	mov    %rax,%rdi
  406f52:	mov    %rdi,%rax
  406f55:	mov    -0x10(%rbp),%r12
  406f59:	mov    -0x8(%rbp),%rbx
  406f5d:	mov    -0x18(%rbp),%r13
  406f61:	mov    -0x20(%rbp),%r14
  406f65:	mov    %rbp,%rsp
  406f68:	pop    %rbp
  406f69:	retq   
  406f6a:	mov    %rdi,%rsi
  406f6d:	shr    $0x28,%rsi
  406f71:	and    $0xffff,%rsi
  406f78:	movabs $0x19,%r11
  406f82:	cmp    %r11,%rsi
  406f85:	jne    407249 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x377>
  406f8b:	mov    %rdi,%rsi
  406f8e:	shr    $0x38,%rsi
  406f92:	and    $0x7f,%rsi
  406f99:	mov    %rsi,%rdx
  406f9c:	cmp    $0x2,%rdx
  406fa3:	sete   %dl
  406fa6:	movzbl %dl,%edx
  406fa9:	mov    %rdi,%rsi
  406fac:	shr    $0x28,%rsi
  406fb0:	and    $0xffff,%rsi
  406fb7:	movabs $0x19,%r11
  406fc1:	cmp    %r11,%rsi
  406fc4:	sete   %sil
  406fc8:	movzbl %sil,%esi
  406fcc:	mov    %rsi,%r11
  406fcf:	mov    %rdx,%rsi
  406fd2:	and    %r11d,%esi
  406fd5:	mov    %rsi,%r10
  406fd8:	test   %r10d,%r10d
  406fdb:	je     40706b <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x199>
  406fe1:	mov    (%r12),%rdx
  406fe5:	movabs $0xffffffffff,%r11
  406fef:	mov    %rdi,%rsi
  406ff2:	and    %r11,%rsi
  406ff5:	shr    $0x3f,%rdi
  406ff9:	cmp    $0x0,%rdi
  407000:	je     407034 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x162>
  407006:	mov    %rsi,%rdi
  407009:	shl    $0x3,%rdi
  40700d:	mov    %rdi,%r11
  407010:	mov    %rdx,%rdi
  407013:	add    %r11,%rdi
  407016:	mov    (%rdi),%esi
  407018:	mov    0x4(%rdi),%edi
  40701b:	shl    $0x20,%rdi
  40701f:	mov    %rdi,%r11
  407022:	mov    %rsi,%rdi
  407025:	or     %r11,%rdi
  407028:	mov    %rdi,%rsi
  40702b:	shr    $0x18,%rsi
  40702f:	jmpq   407034 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x162>
  407034:	mov    %rsi,%rdi
  407037:	shl    $0x3,%rdi
  40703b:	mov    %rdi,%r11
  40703e:	mov    %rdx,%rdi
  407041:	add    %r11,%rdi
  407044:	mov    (%rdi),%rsi
  407047:	lea    -0x840(%rbp),%r10
  40704e:	mov    %rsi,%r11
  407051:	mov    %r11,(%r10)
  407054:	mov    0x8(%rdi),%rdi
  407058:	lea    -0x840(%rbp),%r10
  40705f:	mov    %rdi,%r11
  407062:	mov    %r11,0x8(%r10)
  407066:	jmpq   40709f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x1cd>
  40706b:	mov    %rdi,%rsi
  40706e:	mov    %r12,%rdi
  407071:	lea    -0x840(%rbp),%rdx
  407078:	movabs $0x19,%rcx
  407082:	mov    %ecx,%ecx
  407084:	movabs $0x2,%r8
  40708e:	mov    %r8d,%r8d
  407091:	xor    %eax,%eax
  407093:	callq  44ba00 <p118_rt_borrow_fields>
  407098:	mov    %rax,-0x968(%rbp)
  40709f:	lea    -0x840(%rbp),%r10
  4070a6:	mov    (%r10),%r14
  4070a9:	lea    -0x840(%rbp),%r10
  4070b0:	mov    0x8(%r10),%rdi
  4070b4:	cmp    $0x0,%rbx
  4070bb:	jne    40723d <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x36b>
  4070c1:	cmp    %r14,%r14
  4070c4:	jne    407201 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x32f>
  4070ca:	cmp    $0x0,%r13
  4070d1:	jne    40711b <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x249>
  4070d7:	mov    %r12,%rdi
  4070da:	movabs $0x2,%rsi
  4070e4:	mov    %esi,%esi
  4070e6:	lea    -0x840(%rbp),%rdx
  4070ed:	movabs $0x0,%rcx
  4070f7:	mov    %ecx,%ecx
  4070f9:	xor    %eax,%eax
  4070fb:	callq  448370 <p111_rt_special_ctor>
  407100:	mov    %rax,%rdi
  407103:	mov    %rdi,%rax
  407106:	mov    -0x10(%rbp),%r12
  40710a:	mov    -0x8(%rbp),%rbx
  40710e:	mov    -0x18(%rbp),%r13
  407112:	mov    -0x20(%rbp),%r14
  407116:	mov    %rbp,%rsp
  407119:	pop    %rbp
  40711a:	retq   
  40711b:	mov    %r13,%rdi
  40711e:	sub    $0x1,%rdi
  407125:	lea    -0x840(%rbp),%r10
  40712c:	movabs $0x1f,%r11
  407136:	mov    %r11,(%r10)
  407139:	lea    -0x840(%rbp),%r10
  407140:	mov    %rdi,%r11
  407143:	mov    %r11,0x8(%r10)
  407147:	mov    %r12,%rdi
  40714a:	movabs $0x3f,%rsi
  407154:	mov    %esi,%esi
  407156:	lea    -0x840(%rbp),%rdx
  40715d:	movabs $0x2,%rcx
  407167:	mov    %ecx,%ecx
  407169:	xor    %eax,%eax
  40716b:	callq  447190 <p111_rt_op>
  407170:	mov    %rax,%rdi
  407173:	mov    %r14,%r10
  407176:	mov    %r10d,%r10d
  407179:	mov    %r10,-0x988(%rbp)
  407180:	mov    %rdi,%r10
  407183:	mov    %r10,-0x990(%rbp)
  40718a:	cmp    $0x20,%rdi
  407191:	jae    4071b2 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x2e0>
  407197:	mov    -0x990(%rbp),%r11
  40719e:	mov    -0x988(%rbp),%rdi
  4071a5:	mov    %r11d,%ecx
  4071a8:	shr    %cl,%rdi
  4071ab:	mov    %edi,%edi
  4071ad:	jmpq   4071bc <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x2ea>
  4071b2:	movabs $0x0,%rdi
  4071bc:	and    $0x1,%rdi
  4071c3:	cmp    $0x0,%rdi
  4071ca:	je     4071df <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x30d>
  4071d0:	movabs $0x1,%rdi
  4071da:	jmpq   4071e9 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x317>
  4071df:	movabs $0x0,%rdi
  4071e9:	mov    %rdi,%rax
  4071ec:	mov    -0x10(%rbp),%r12
  4071f0:	mov    -0x8(%rbp),%rbx
  4071f4:	mov    -0x18(%rbp),%r13
  4071f8:	mov    -0x20(%rbp),%r14
  4071fc:	mov    %rbp,%rsp
  4071ff:	pop    %rbp
  407200:	retq   
  407201:	mov    %r12,%rdi
  407204:	movabs $0x4,%rsi
  40720e:	mov    %esi,%esi
  407210:	xor    %eax,%eax
  407212:	callq  447170 <p111_rt_fail>
  407217:	mov    %rax,-0x9a0(%rbp)
  40721e:	movabs $0x0,%rax
  407228:	mov    -0x10(%rbp),%r12
  40722c:	mov    -0x8(%rbp),%rbx
  407230:	mov    -0x18(%rbp),%r13
  407234:	mov    -0x20(%rbp),%r14
  407238:	mov    %rbp,%rsp
  40723b:	pop    %rbp
  40723c:	retq   
  40723d:	sub    $0x1,%rbx
  407244:	jmpq   406f05 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_77_97_112_46_98_105_116_46_103_111_+0x33>
  407249:	mov    %r12,%rdi
  40724c:	movabs $0x4,%rsi
  407256:	mov    %esi,%esi
  407258:	xor    %eax,%eax
  40725a:	callq  447170 <p111_rt_fail>
  40725f:	mov    %rax,-0x9a0(%rbp)
  407266:	movabs $0x0,%rax
  407270:	mov    -0x10(%rbp),%r12
  407274:	mov    -0x8(%rbp),%rbx
  407278:	mov    -0x18(%rbp),%r13
  40727c:	mov    -0x20(%rbp),%r14
  407280:	mov    %rbp,%rsp
  407283:	pop    %rbp
  407284:	retq   

Disassembly of section .fini:
