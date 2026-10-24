
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-query-v02-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000040cd80 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_>:
  40cd80:	endbr64 
  40cd84:	push   %rbp
  40cd85:	mov    %rsp,%rbp
  40cd88:	sub    $0x9b8,%rsp
  40cd8f:	push   %rbx
  40cd90:	push   %r12
  40cd92:	push   %r13
  40cd94:	push   %r14
  40cd96:	push   %r15
  40cd98:	mov    %rdx,%rbx
  40cd9b:	mov    %rbx,%rdx
  40cd9e:	xchg   %ax,%ax
  40cda0:	mov    %rdx,-0x40(%rbp)
  40cda4:	mov    %rsi,%rax
  40cda7:	shr    $0x28,%rax
  40cdab:	and    $0xffff,%rax
  40cdb1:	cmp    $0x11,%rax
  40cdb5:	je     40d8e4 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb64>
  40cdbb:	nopl   0x0(%rax,%rax,1)
  40cdc0:	cmp    $0x12,%rax
  40cdc4:	jne    40d8d3 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb53>
  40cdca:	mov    %rdx,%r15
  40cdcd:	lea    -0x9a8(%rbp),%rdx
  40cdd4:	mov    %rdi,%rbx
  40cdd7:	callq  43aab0 <p125_rt_take2>
  40cddc:	mov    %rbx,%rdi
  40cddf:	mov    -0x9a8(%rbp),%rsi
  40cde6:	mov    -0x9a0(%rbp),%r12
  40cded:	mov    %r12,-0x90(%rbp)
  40cdf4:	mov    %rdi,%rbx
  40cdf7:	callq  435270 <p111_rt_keep>
  40cdfc:	mov    %r12,%rsi
  40cdff:	mov    %rbx,%rdi
  40ce02:	mov    %rax,%r14
  40ce05:	mov    %r14,%rax
  40ce08:	shr    $0x28,%rax
  40ce0c:	mov    %rax,%rbx
  40ce0f:	and    $0xffff,%rbx
  40ce16:	cmp    $0x99,%rbx
  40ce1d:	sete   %al
  40ce20:	movzbl %al,%eax
  40ce23:	cmp    $0x0,%eax
  40ce26:	jne    40cf08 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x188>
  40ce2c:	cmp    $0x9a,%rbx
  40ce33:	je     40cec2 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x142>
  40ce39:	nopl   0x0(%rax)
  40ce40:	cmp    $0x9b,%rbx
  40ce47:	je     40ce64 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xe4>
  40ce49:	mov    %rsi,%r13
  40ce4c:	mov    $0x4,%esi
  40ce51:	mov    %rdi,%r12
  40ce54:	callq  435a90 <p111_rt_fail>
  40ce59:	mov    %r15,%rdx
  40ce5c:	mov    %r12,%rdi
  40ce5f:	mov    %r13,%rsi
  40ce62:	jmp    40ceba <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x13a>
  40ce64:	mov    %rsi,%r13
  40ce67:	mov    %r15,%rdx
  40ce6a:	mov    %rdx,%r15
  40ce6d:	lea    -0x1a8(%rbp),%rdx
  40ce74:	mov    %r14,%rsi
  40ce77:	mov    %rdi,%r12
  40ce7a:	callq  43af80 <p125_rt_take4>
  40ce7f:	mov    %r12,%rdi
  40ce82:	mov    -0x198(%rbp),%rsi
  40ce89:	mov    -0x190(%rbp),%rax
  40ce90:	mov    %rax,-0x8(%rbp)
  40ce94:	mov    %rdi,%r12
  40ce97:	callq  435300 <p111_rt_sink>
  40ce9c:	mov    %r13,%rsi
  40ce9f:	mov    %r12,%rdi
  40cea2:	mov    %rsi,%r13
  40cea5:	mov    -0x8(%rbp),%rsi
  40cea9:	mov    %rdi,%r12
  40ceac:	callq  435300 <p111_rt_sink>
  40ceb1:	mov    %r15,%rdx
  40ceb4:	mov    %r13,%rsi
  40ceb7:	mov    %r12,%rdi
  40ceba:	mov    %rsi,%r13
  40cebd:	mov    %rdx,%r15
  40cec0:	jmp    40cef8 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x178>
  40cec2:	mov    %r15,%rdx
  40cec5:	mov    %rdx,%r15
  40cec8:	lea    -0x1a8(%rbp),%rdx
  40cecf:	mov    %rsi,%r13
  40ced2:	mov    %r14,%rsi
  40ced5:	mov    %rdi,%r12
  40ced8:	callq  43aab0 <p125_rt_take2>
  40cedd:	mov    %r13,%rsi
  40cee0:	mov    %r12,%rdi
  40cee3:	mov    %rsi,%r13
  40cee6:	mov    -0x1a0(%rbp),%rsi
  40ceed:	mov    %rdi,%r12
  40cef0:	callq  435300 <p111_rt_sink>
  40cef5:	mov    %r12,%rdi
  40cef8:	mov    %r14,%rsi
  40cefb:	mov    %r15,%rdx
  40cefe:	mov    $0x0,%ecx
  40cf03:	jmpq   40d07c <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x2fc>
  40cf08:	cs cs cs cs mov $0x9,%ecx
  40cf11:	lea    -0x1a8(%rbp),%rdx
  40cf18:	mov    %r14,%rsi
  40cf1b:	mov    %rdi,%r12
  40cf1e:	callq  4354f0 <p111_rt_take>
  40cf23:	mov    %r12,%rdi
  40cf26:	mov    -0x1a8(%rbp),%rsi
  40cf2d:	mov    -0x1a0(%rbp),%r13
  40cf34:	mov    -0x198(%rbp),%r15
  40cf3b:	mov    -0x190(%rbp),%r12
  40cf42:	mov    %r12,-0x10(%rbp)
  40cf46:	mov    -0x188(%rbp),%r12
  40cf4d:	mov    %r12,-0x18(%rbp)
  40cf51:	mov    -0x180(%rbp),%r12
  40cf58:	mov    %r12,-0x20(%rbp)
  40cf5c:	mov    -0x178(%rbp),%r12
  40cf63:	mov    %r12,-0x28(%rbp)
  40cf67:	mov    -0x170(%rbp),%r12
  40cf6e:	mov    %r12,-0x30(%rbp)
  40cf72:	mov    -0x168(%rbp),%r12
  40cf79:	mov    %r12,-0x38(%rbp)
  40cf7d:	mov    %rdi,%r12
  40cf80:	callq  435300 <p111_rt_sink>
  40cf85:	mov    %r15,%rsi
  40cf88:	mov    %r12,%rdi
  40cf8b:	mov    -0x10(%rbp),%r15
  40cf8f:	mov    %rdi,%r12
  40cf92:	callq  435300 <p111_rt_sink>
  40cf97:	mov    %r15,%rsi
  40cf9a:	mov    %r12,%rdi
  40cf9d:	mov    -0x18(%rbp),%r15
  40cfa1:	mov    %rdi,%r12
  40cfa4:	callq  435300 <p111_rt_sink>
  40cfa9:	mov    %r15,%rsi
  40cfac:	mov    %r12,%rdi
  40cfaf:	mov    -0x20(%rbp),%r15
  40cfb3:	mov    %rdi,%r12
  40cfb6:	callq  435300 <p111_rt_sink>
  40cfbb:	mov    %r15,%rsi
  40cfbe:	mov    %r12,%rdi
  40cfc1:	mov    -0x28(%rbp),%r15
  40cfc5:	mov    %rdi,%r12
  40cfc8:	callq  435300 <p111_rt_sink>
  40cfcd:	mov    %r15,%rsi
  40cfd0:	mov    %r12,%rdi
  40cfd3:	mov    -0x30(%rbp),%r15
  40cfd7:	mov    %rdi,%r12
  40cfda:	callq  435300 <p111_rt_sink>
  40cfdf:	mov    %r15,%rsi
  40cfe2:	mov    %r12,%rdi
  40cfe5:	mov    -0x38(%rbp),%r15
  40cfe9:	mov    %rdi,%r12
  40cfec:	callq  435300 <p111_rt_sink>
  40cff1:	mov    %r15,%rsi
  40cff4:	mov    %r12,%rdi
  40cff7:	mov    %rdi,%r12
  40cffa:	callq  435300 <p111_rt_sink>
  40cfff:	mov    %r13,%rsi
  40d002:	mov    %r12,%rdi
  40d005:	mov    %rdi,%r12
  40d008:	callq  435270 <p111_rt_keep>
  40d00d:	mov    %r12,%rdi
  40d010:	mov    %rax,%rsi
  40d013:	mov    %rsi,%r13
  40d016:	movabs $0x20019000310867c,%rsi
  40d020:	mov    %rdi,%r12
  40d023:	callq  435270 <p111_rt_keep>
  40d028:	mov    %r13,%rsi
  40d02b:	mov    %r12,%rdi
  40d02e:	mov    %rax,%r13
  40d031:	mov    $0x1,%ecx
  40d036:	mov    %r13,%rdx
  40d039:	mov    %rsi,%r15
  40d03c:	mov    %rdi,%r12
  40d03f:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40d044:	mov    %r15,%rsi
  40d047:	mov    %r12,%rdi
  40d04a:	mov    %rax,-0x48(%rbp)
  40d04e:	mov    -0x40(%rbp),%r15
  40d052:	mov    %rdi,%r12
  40d055:	callq  435300 <p111_rt_sink>
  40d05a:	mov    %r13,%rsi
  40d05d:	mov    %r12,%rdi
  40d060:	mov    -0x90(%rbp),%r13
  40d067:	mov    %rdi,%r12
  40d06a:	callq  435300 <p111_rt_sink>
  40d06f:	mov    %r15,%rdx
  40d072:	mov    %r14,%rsi
  40d075:	mov    %r12,%rdi
  40d078:	mov    -0x48(%rbp),%rcx
  40d07c:	cmp    $0x1,%rcx
  40d080:	sete   %al
  40d083:	movzbl %al,%eax
  40d086:	shr    $0x28,%rcx
  40d08a:	and    $0x7fffff,%rcx
  40d091:	cmp    $0x10002,%rcx
  40d098:	sete   %cl
  40d09b:	movzbl %cl,%ecx
  40d09e:	or     %ecx,%eax
  40d0a0:	jne    40d5ba <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x83a>
  40d0a6:	xor    $0x1,%eax
  40d0a9:	je     40d570 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x7f0>
  40d0af:	cs cs cs cs cs mov $0x0,%ecx
  40d0b9:	cs mov %rdx,%r14
  40d0bd:	lea    -0x9a8(%rbp),%rdx
  40d0c4:	mov    %rsi,%r12
  40d0c7:	mov    $0x0,%esi
  40d0cc:	mov    %rdi,%rbx
  40d0cf:	callq  435370 <p111_rt_ctor>
  40d0d4:	mov    %rbx,%rdi
  40d0d7:	mov    %rax,%rsi
  40d0da:	mov    %rdi,%rbx
  40d0dd:	callq  435300 <p111_rt_sink>
  40d0e2:	mov    %r14,%rdx
  40d0e5:	mov    %r12,%rsi
  40d0e8:	mov    %rbx,%rdi
  40d0eb:	mov    %rsi,%r12
  40d0ee:	mov    %rdx,%rsi
  40d0f1:	mov    %rdi,%rbx
  40d0f4:	callq  435270 <p111_rt_keep>
  40d0f9:	mov    %r12,%rsi
  40d0fc:	mov    %rbx,%rdi
  40d0ff:	mov    %rax,%r12
  40d102:	mov    %rdi,%rbx
  40d105:	callq  435270 <p111_rt_keep>
  40d10a:	mov    %r13,%rsi
  40d10d:	mov    %rbx,%rdi
  40d110:	mov    %rax,%r15
  40d113:	mov    %r15,%rax
  40d116:	shr    $0x28,%rax
  40d11a:	and    $0xffff,%rax
  40d120:	cmp    $0x99,%rax
  40d126:	je     40d2ed <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x56d>
  40d12c:	cmp    $0x9a,%rax
  40d132:	je     40d23c <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x4bc>
  40d138:	nopl   0x0(%rax,%rax,1)
  40d140:	cmp    $0x9b,%rax
  40d146:	je     40d17c <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x3fc>
  40d148:	mov    %rsi,%r13
  40d14b:	mov    %r12,%rsi
  40d14e:	mov    %rdi,%rbx
  40d151:	callq  435300 <p111_rt_sink>
  40d156:	mov    %r13,%rsi
  40d159:	mov    %rbx,%rdi
  40d15c:	mov    %rsi,%r13
  40d15f:	mov    $0x4,%esi
  40d164:	mov    %rdi,%rbx
  40d167:	callq  435a90 <p111_rt_fail>
  40d16c:	mov    %r12,%rdx
  40d16f:	mov    %rbx,%rdi
  40d172:	mov    $0x0,%ebx
  40d177:	jmpq   40d2e2 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x562>
  40d17c:	mov    %r12,%rdx
  40d17f:	mov    %rdx,%r13
  40d182:	lea    -0x108(%rbp),%rdx
  40d189:	mov    %r15,%rsi
  40d18c:	mov    %rdi,%rbx
  40d18f:	callq  43af80 <p125_rt_take4>
  40d194:	mov    %rbx,%rdi
  40d197:	mov    -0xf8(%rbp),%rsi
  40d19e:	mov    -0xf0(%rbp),%r12
  40d1a5:	mov    %rdi,%rbx
  40d1a8:	callq  435300 <p111_rt_sink>
  40d1ad:	mov    %r12,%rsi
  40d1b0:	mov    %rbx,%rdi
  40d1b3:	mov    %rdi,%rbx
  40d1b6:	callq  435300 <p111_rt_sink>
  40d1bb:	mov    %rbx,%rdi
  40d1be:	movabs $0x100180000000000,%rsi
  40d1c8:	mov    %rdi,%rbx
  40d1cb:	callq  435270 <p111_rt_keep>
  40d1d0:	mov    %rbx,%rdi
  40d1d3:	mov    %rax,%rsi
  40d1d6:	mov    %rsi,%r12
  40d1d9:	mov    %r13,%rsi
  40d1dc:	mov    %rdi,%rbx
  40d1df:	callq  435270 <p111_rt_keep>
  40d1e4:	mov    %r13,%rdx
  40d1e7:	mov    %r12,%rsi
  40d1ea:	mov    %rbx,%rdi
  40d1ed:	mov    %rax,%r12
  40d1f0:	mov    $0x1,%ecx
  40d1f5:	mov    %rdx,%r14
  40d1f8:	mov    %r12,%rdx
  40d1fb:	mov    %rsi,%r13
  40d1fe:	mov    %rdi,%rbx
  40d201:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40d206:	mov    %r13,%rsi
  40d209:	mov    %rbx,%rdi
  40d20c:	mov    %rax,-0x50(%rbp)
  40d210:	mov    -0x90(%rbp),%r13
  40d217:	mov    %rdi,%rbx
  40d21a:	callq  435300 <p111_rt_sink>
  40d21f:	mov    %r12,%rsi
  40d222:	mov    %rbx,%rdi
  40d225:	mov    -0x50(%rbp),%rbx
  40d229:	mov    %rdi,%r12
  40d22c:	callq  435300 <p111_rt_sink>
  40d231:	mov    %r14,%rdx
  40d234:	mov    %r12,%rdi
  40d237:	jmpq   40d2e2 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x562>
  40d23c:	mov    %r12,%rdx
  40d23f:	mov    %rdx,%r13
  40d242:	lea    -0x108(%rbp),%rdx
  40d249:	mov    %r15,%rsi
  40d24c:	mov    %rdi,%rbx
  40d24f:	callq  43aab0 <p125_rt_take2>
  40d254:	mov    %rbx,%rdi
  40d257:	mov    -0x100(%rbp),%rsi
  40d25e:	mov    %rdi,%rbx
  40d261:	callq  435300 <p111_rt_sink>
  40d266:	mov    %rbx,%rdi
  40d269:	movabs $0x100180000000000,%rsi
  40d273:	mov    %rdi,%rbx
  40d276:	callq  435270 <p111_rt_keep>
  40d27b:	mov    %rbx,%rdi
  40d27e:	mov    %rax,%rsi
  40d281:	mov    %rsi,%r12
  40d284:	mov    %r13,%rsi
  40d287:	mov    %rdi,%rbx
  40d28a:	callq  435270 <p111_rt_keep>
  40d28f:	mov    %r13,%rdx
  40d292:	mov    %r12,%rsi
  40d295:	mov    %rbx,%rdi
  40d298:	mov    %rax,%r12
  40d29b:	mov    $0x1,%ecx
  40d2a0:	mov    %rdx,%r14
  40d2a3:	mov    %r12,%rdx
  40d2a6:	mov    %rsi,%r13
  40d2a9:	mov    %rdi,%rbx
  40d2ac:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40d2b1:	mov    %r13,%rsi
  40d2b4:	mov    %rbx,%rdi
  40d2b7:	mov    %rax,-0x58(%rbp)
  40d2bb:	mov    -0x90(%rbp),%r13
  40d2c2:	mov    %rdi,%rbx
  40d2c5:	callq  435300 <p111_rt_sink>
  40d2ca:	mov    %r12,%rsi
  40d2cd:	mov    %rbx,%rdi
  40d2d0:	mov    -0x58(%rbp),%rbx
  40d2d4:	mov    %rdi,%r12
  40d2d7:	callq  435300 <p111_rt_sink>
  40d2dc:	mov    %r14,%rdx
  40d2df:	mov    %r12,%rdi
  40d2e2:	mov    %r15,%rsi
  40d2e5:	mov    %rdx,%r14
  40d2e8:	jmpq   40d467 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x6e7>
  40d2ed:	mov    %r12,%rdx
  40d2f0:	mov    $0x9,%ecx
  40d2f5:	mov    %rdx,%r13
  40d2f8:	lea    -0x108(%rbp),%rdx
  40d2ff:	mov    %r15,%rsi
  40d302:	mov    %rdi,%rbx
  40d305:	callq  4354f0 <p111_rt_take>
  40d30a:	mov    %rbx,%rdi
  40d30d:	mov    -0x108(%rbp),%r12
  40d314:	mov    -0x100(%rbp),%rsi
  40d31b:	mov    -0xf8(%rbp),%r14
  40d322:	mov    -0xf0(%rbp),%rbx
  40d329:	mov    %rbx,-0x60(%rbp)
  40d32d:	mov    -0xe8(%rbp),%rbx
  40d334:	mov    %rbx,-0x68(%rbp)
  40d338:	mov    -0xe0(%rbp),%rbx
  40d33f:	mov    %rbx,-0x70(%rbp)
  40d343:	mov    -0xd8(%rbp),%rbx
  40d34a:	mov    %rbx,-0x78(%rbp)
  40d34e:	mov    -0xd0(%rbp),%rbx
  40d355:	mov    %rbx,-0x80(%rbp)
  40d359:	mov    -0xc8(%rbp),%rbx
  40d360:	mov    %rbx,-0x88(%rbp)
  40d367:	mov    %rdi,%rbx
  40d36a:	callq  435300 <p111_rt_sink>
  40d36f:	mov    %r14,%rsi
  40d372:	mov    %rbx,%rdi
  40d375:	mov    -0x60(%rbp),%r14
  40d379:	mov    %rdi,%rbx
  40d37c:	callq  435300 <p111_rt_sink>
  40d381:	mov    %r14,%rsi
  40d384:	mov    %rbx,%rdi
  40d387:	mov    -0x68(%rbp),%r14
  40d38b:	mov    %rdi,%rbx
  40d38e:	callq  435300 <p111_rt_sink>
  40d393:	mov    %r14,%rsi
  40d396:	mov    %rbx,%rdi
  40d399:	mov    -0x70(%rbp),%r14
  40d39d:	mov    %rdi,%rbx
  40d3a0:	callq  435300 <p111_rt_sink>
  40d3a5:	mov    %r14,%rsi
  40d3a8:	mov    %rbx,%rdi
  40d3ab:	mov    -0x78(%rbp),%r14
  40d3af:	mov    %rdi,%rbx
  40d3b2:	callq  435300 <p111_rt_sink>
  40d3b7:	mov    %r14,%rsi
  40d3ba:	mov    %rbx,%rdi
  40d3bd:	mov    -0x80(%rbp),%r14
  40d3c1:	mov    %rdi,%rbx
  40d3c4:	callq  435300 <p111_rt_sink>
  40d3c9:	mov    %r14,%rsi
  40d3cc:	mov    %rbx,%rdi
  40d3cf:	mov    -0x88(%rbp),%r14
  40d3d6:	mov    %rdi,%rbx
  40d3d9:	callq  435300 <p111_rt_sink>
  40d3de:	mov    %r14,%rsi
  40d3e1:	mov    %rbx,%rdi
  40d3e4:	mov    %rdi,%rbx
  40d3e7:	callq  435300 <p111_rt_sink>
  40d3ec:	mov    %r12,%rsi
  40d3ef:	mov    %rbx,%rdi
  40d3f2:	mov    %rdi,%rbx
  40d3f5:	callq  435270 <p111_rt_keep>
  40d3fa:	mov    %rbx,%rdi
  40d3fd:	mov    %rax,%rsi
  40d400:	mov    %rsi,%r12
  40d403:	mov    %r13,%rsi
  40d406:	mov    %rdi,%rbx
  40d409:	callq  435270 <p111_rt_keep>
  40d40e:	mov    %r13,%rdx
  40d411:	mov    %r12,%rsi
  40d414:	mov    %rbx,%rdi
  40d417:	mov    %rax,%r12
  40d41a:	mov    $0x1,%ecx
  40d41f:	mov    %rdx,%r14
  40d422:	mov    %r12,%rdx
  40d425:	mov    %rsi,%r13
  40d428:	mov    %rdi,%rbx
  40d42b:	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  40d430:	mov    %r13,%rsi
  40d433:	mov    %rbx,%rdi
  40d436:	mov    %rax,-0x98(%rbp)
  40d43d:	mov    -0x90(%rbp),%r13
  40d444:	mov    %rdi,%rbx
  40d447:	callq  435300 <p111_rt_sink>
  40d44c:	mov    %r12,%rsi
  40d44f:	mov    %rbx,%rdi
  40d452:	mov    -0x98(%rbp),%rbx
  40d459:	mov    %rdi,%r12
  40d45c:	callq  435300 <p111_rt_sink>
  40d461:	mov    %r15,%rsi
  40d464:	mov    %r12,%rdi
  40d467:	cmp    $0x1,%rbx
  40d46b:	sete   %al
  40d46e:	movzbl %al,%eax
  40d471:	mov    %rbx,%rcx
  40d474:	shr    $0x28,%rcx
  40d478:	and    $0x7fffff,%rcx
  40d47f:	cmp    $0x10002,%rcx
  40d486:	sete   %cl
  40d489:	movzbl %cl,%ecx
  40d48c:	mov    %eax,%ebx
  40d48e:	or     %ecx,%ebx
  40d490:	jne    40d51f <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x79f>
  40d496:	mov    %rdi,%r12
  40d499:	callq  435300 <p111_rt_sink>
  40d49e:	mov    %r14,%rdx
  40d4a1:	mov    %r13,%rsi
  40d4a4:	mov    %r12,%rdi
  40d4a7:	mov    %ebx,%eax
  40d4a9:	xor    $0x1,%eax
  40d4ac:	je     40d4e9 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x769>
  40d4ae:	mov    $0x0,%ecx
  40d4b3:	mov    %rdx,%r13
  40d4b6:	lea    -0x9a8(%rbp),%rdx
  40d4bd:	mov    %rsi,%r12
  40d4c0:	mov    $0x0,%esi
  40d4c5:	mov    %rdi,%rbx
  40d4c8:	callq  435370 <p111_rt_ctor>
  40d4cd:	mov    %rbx,%rdi
  40d4d0:	mov    %rax,%rsi
  40d4d3:	mov    %rdi,%rbx
  40d4d6:	callq  435300 <p111_rt_sink>
  40d4db:	mov    %r13,%rdx
  40d4de:	mov    %r12,%rsi
  40d4e1:	mov    %rbx,%rdi
  40d4e4:	jmpq   40cda0 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x20>
  40d4e9:	mov    %rsi,%r12
  40d4ec:	mov    %rdx,%rsi
  40d4ef:	mov    %rdi,%rbx
  40d4f2:	callq  435300 <p111_rt_sink>
  40d4f7:	mov    %r12,%rsi
  40d4fa:	mov    %rbx,%rdi
  40d4fd:	mov    %rsi,%r13
  40d500:	mov    %rdi,%rbx
  40d503:	callq  435300 <p111_rt_sink>
  40d508:	mov    %rbx,%rdi
  40d50b:	mov    $0x4,%esi
  40d510:	callq  435a90 <p111_rt_fail>
  40d515:	mov    $0x0,%eax
  40d51a:	jmpq   40d8f6 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb76>
  40d51f:	mov    %rsi,%rbx
  40d522:	mov    %r14,%rsi
  40d525:	mov    %rsi,%r12
  40d528:	mov    %rdi,%r12
  40d52b:	callq  435300 <p111_rt_sink>
  40d530:	mov    %r13,%rsi
  40d533:	mov    %r12,%rdi
  40d536:	mov    %rsi,%r12
  40d539:	mov    %rdi,%r12
  40d53c:	callq  435300 <p111_rt_sink>
  40d541:	mov    %r12,%rdi
  40d544:	mov    $0x0,%ecx
  40d549:	lea    -0x9a8(%rbp),%rdx
  40d550:	mov    $0x0,%esi
  40d555:	mov    %rdi,%r12
  40d558:	callq  435370 <p111_rt_ctor>
  40d55d:	mov    %r12,%rdi
  40d560:	mov    %rax,%rsi
  40d563:	callq  435300 <p111_rt_sink>
  40d568:	mov    %rbx,%rax
  40d56b:	jmpq   40d8f6 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb76>
  40d570:	mov    %r13,%r12
  40d573:	mov    %rsi,%r13
  40d576:	mov    %rdx,%rsi
  40d579:	mov    %rsi,%rbx
  40d57c:	mov    %rdi,%rbx
  40d57f:	callq  435300 <p111_rt_sink>
  40d584:	mov    %r13,%rsi
  40d587:	mov    %rbx,%rdi
  40d58a:	mov    %rsi,%r14
  40d58d:	mov    %rdi,%rbx
  40d590:	callq  435300 <p111_rt_sink>
  40d595:	mov    %r12,%rsi
  40d598:	mov    %rbx,%rdi
  40d59b:	mov    %rdi,%rbx
  40d59e:	callq  435300 <p111_rt_sink>
  40d5a3:	mov    %rbx,%rdi
  40d5a6:	mov    $0x4,%esi
  40d5ab:	callq  435a90 <p111_rt_fail>
  40d5b0:	mov    $0x0,%eax
  40d5b5:	jmpq   40d8f6 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb76>
  40d5ba:	mov    %rsi,%r14
  40d5bd:	mov    %r13,%rsi
  40d5c0:	mov    %rbx,%r12
  40d5c3:	mov    %rdx,%rbx
  40d5c6:	mov    %rdi,%r13
  40d5c9:	callq  435300 <p111_rt_sink>
  40d5ce:	mov    %r14,%rsi
  40d5d1:	mov    %r13,%rdi
  40d5d4:	mov    $0x0,%ecx
  40d5d9:	lea    -0x9a8(%rbp),%rdx
  40d5e0:	mov    %rsi,%r14
  40d5e3:	mov    $0x0,%esi
  40d5e8:	mov    %rdi,%r13
  40d5eb:	callq  435370 <p111_rt_ctor>
  40d5f0:	mov    %r13,%rdi
  40d5f3:	mov    %rax,%rsi
  40d5f6:	mov    %rdi,%r13
  40d5f9:	callq  435300 <p111_rt_sink>
  40d5fe:	mov    %r14,%rsi
  40d601:	mov    %r13,%rdi
  40d604:	cmp    $0x99,%r12
  40d60b:	je     40d705 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x985>
  40d611:	cmp    $0x9a,%r12
  40d618:	je     40d6d4 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x954>
  40d61e:	xchg   %ax,%ax
  40d620:	cmp    $0x9b,%r12
  40d627:	je     40d649 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x8c9>
  40d629:	mov    %rbx,%rsi
  40d62c:	mov    %rsi,%r12
  40d62f:	mov    $0x4,%esi
  40d634:	mov    %rdi,%rbx
  40d637:	callq  435a90 <p111_rt_fail>
  40d63c:	mov    %rbx,%rdi
  40d63f:	mov    $0x0,%esi
  40d644:	jmpq   40d6cf <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x94f>
  40d649:	mov    %rbx,%r12
  40d64c:	lea    -0x160(%rbp),%rdx
  40d653:	mov    %rdi,%rbx
  40d656:	callq  43af80 <p125_rt_take4>
  40d65b:	mov    %r12,%rsi
  40d65e:	mov    %rbx,%rdi
  40d661:	mov    -0x150(%rbp),%rbx
  40d668:	mov    -0x148(%rbp),%rax
  40d66f:	mov    %rax,-0x160(%rbp)
  40d676:	movabs $0x100110000000000,%rax
  40d680:	mov    %rax,-0x158(%rbp)
  40d687:	lea    -0x160(%rbp),%rdx
  40d68e:	mov    %rsi,%r13
  40d691:	mov    $0x12,%esi
  40d696:	mov    %rdi,%r12
  40d699:	callq  43a9c0 <p125_rt_ctor2>
  40d69e:	mov    %r13,%rsi
  40d6a1:	mov    %r12,%rdi
  40d6a4:	mov    %rbx,-0x160(%rbp)
  40d6ab:	mov    %rax,-0x158(%rbp)
  40d6b2:	lea    -0x160(%rbp),%rdx
  40d6b9:	mov    %rsi,%r12
  40d6bc:	mov    $0x12,%esi
  40d6c1:	mov    %rdi,%rbx
  40d6c4:	callq  43a9c0 <p125_rt_ctor2>
  40d6c9:	mov    %rbx,%rdi
  40d6cc:	mov    %rax,%rsi
  40d6cf:	mov    %r12,%r13
  40d6d2:	jmp    40d6fa <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0x97a>
  40d6d4:	cs cs cs cs mov %rbx,%r12
  40d6db:	lea    -0x160(%rbp),%rdx
  40d6e2:	mov    %rdi,%rbx
  40d6e5:	callq  43aab0 <p125_rt_take2>
  40d6ea:	mov    %r12,%rsi
  40d6ed:	mov    %rbx,%rdi
  40d6f0:	mov    %rsi,%r13
  40d6f3:	mov    -0x158(%rbp),%rsi
  40d6fa:	mov    %rsi,%rbx
  40d6fd:	mov    %r13,%rsi
  40d700:	jmpq   40d814 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xa94>
  40d705:	mov    %rbx,%r13
  40d708:	mov    $0x9,%ecx
  40d70d:	lea    -0x160(%rbp),%rdx
  40d714:	mov    %rdi,%rbx
  40d717:	callq  4354f0 <p111_rt_take>
  40d71c:	mov    %rbx,%rdi
  40d71f:	mov    -0x160(%rbp),%rsi
  40d726:	mov    -0x158(%rbp),%r15
  40d72d:	mov    -0x150(%rbp),%r14
  40d734:	mov    -0x148(%rbp),%r12
  40d73b:	mov    -0x140(%rbp),%rbx
  40d742:	mov    %rbx,-0xa0(%rbp)
  40d749:	mov    -0x138(%rbp),%rbx
  40d750:	mov    %rbx,-0xa8(%rbp)
  40d757:	mov    -0x130(%rbp),%rbx
  40d75e:	mov    %rbx,-0xb0(%rbp)
  40d765:	mov    -0x128(%rbp),%rbx
  40d76c:	mov    %rbx,-0xb8(%rbp)
  40d773:	mov    -0x120(%rbp),%rbx
  40d77a:	mov    %rbx,-0xc0(%rbp)
  40d781:	mov    %rdi,%rbx
  40d784:	callq  435300 <p111_rt_sink>
  40d789:	mov    %r15,%rsi
  40d78c:	mov    %rbx,%rdi
  40d78f:	mov    -0xa0(%rbp),%r15
  40d796:	mov    %rdi,%rbx
  40d799:	callq  435300 <p111_rt_sink>
  40d79e:	mov    %r14,%rsi
  40d7a1:	mov    %rbx,%rdi
  40d7a4:	mov    -0xa8(%rbp),%r14
  40d7ab:	mov    %rdi,%rbx
  40d7ae:	callq  435300 <p111_rt_sink>
  40d7b3:	mov    %r12,%rsi
  40d7b6:	mov    %rbx,%rdi
  40d7b9:	mov    -0xb0(%rbp),%rbx
  40d7c0:	mov    %rdi,%r12
  40d7c3:	callq  435300 <p111_rt_sink>
  40d7c8:	mov    %r15,%rsi
  40d7cb:	mov    %r12,%rdi
  40d7ce:	mov    -0xb8(%rbp),%r15
  40d7d5:	mov    %rdi,%r12
  40d7d8:	callq  435300 <p111_rt_sink>
  40d7dd:	mov    %r14,%rsi
  40d7e0:	mov    %r12,%rdi
  40d7e3:	mov    -0xc0(%rbp),%r14
  40d7ea:	mov    %rdi,%r12
  40d7ed:	callq  435300 <p111_rt_sink>
  40d7f2:	mov    %r15,%rsi
  40d7f5:	mov    %r12,%rdi
  40d7f8:	mov    %rdi,%r12
  40d7fb:	callq  435300 <p111_rt_sink>
  40d800:	mov    %r14,%rsi
  40d803:	mov    %r12,%rdi
  40d806:	mov    %rdi,%r12
  40d809:	callq  435300 <p111_rt_sink>
  40d80e:	mov    %r13,%rsi
  40d811:	mov    %r12,%rdi
  40d814:	mov    %rbx,%rax
  40d817:	shr    $0x28,%rax
  40d81b:	and    $0xffff,%rax
  40d821:	cmp    $0x11,%rax
  40d825:	je     40d886 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb06>
  40d827:	cmp    $0x12,%rax
  40d82b:	je     40d84a <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xaca>
  40d82d:	mov    %rsi,%r12
  40d830:	mov    $0x4,%esi
  40d835:	mov    %rdi,%rbx
  40d838:	callq  435a90 <p111_rt_fail>
  40d83d:	mov    %rbx,%rdi
  40d840:	mov    %r12,%rsi
  40d843:	mov    $0x0,%ebx
  40d848:	jmp    40d890 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb10>
  40d84a:	mov    %rsi,%r12
  40d84d:	mov    %rbx,%rsi
  40d850:	lea    -0x118(%rbp),%rdx
  40d857:	mov    %rdi,%rbx
  40d85a:	callq  43aab0 <p125_rt_take2>
  40d85f:	mov    %r12,%rsi
  40d862:	mov    %rbx,%rdi
  40d865:	mov    -0x118(%rbp),%rbx
  40d86c:	mov    %rsi,%r13
  40d86f:	mov    -0x110(%rbp),%rsi
  40d876:	mov    %rdi,%r12
  40d879:	callq  435300 <p111_rt_sink>
  40d87e:	mov    %r13,%rsi
  40d881:	mov    %r12,%rdi
  40d884:	jmp    40d890 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb10>
  40d886:	movabs $0x2009900031086df,%rbx
  40d890:	mov    %rbx,%r12
  40d893:	mov    %rdi,%rbx
  40d896:	callq  435270 <p111_rt_keep>
  40d89b:	mov    %r12,%rsi
  40d89e:	mov    %rbx,%rdi
  40d8a1:	mov    %rax,%rdx
  40d8a4:	mov    %rdx,%r13
  40d8a7:	mov    $0x811c9dc5,%edx
  40d8ac:	mov    %rsi,%r12
  40d8af:	mov    %r13,%rsi
  40d8b2:	mov    %rdi,%rbx
  40d8b5:	callq  405590 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_104_97_115_104_>
  40d8ba:	mov    %r13,%rdx
  40d8bd:	mov    %r12,%rsi
  40d8c0:	mov    %rbx,%rdi
  40d8c3:	mov    %rax,%rcx
  40d8c6:	mov    $0x20,%r8d
  40d8cc:	callq  40c170 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_>
  40d8d1:	jmp    40d8f6 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb76>
  40d8d3:	mov    $0x4,%esi
  40d8d8:	callq  435a90 <p111_rt_fail>
  40d8dd:	mov    $0x0,%eax
  40d8e2:	jmp    40d8f6 <p113d_FID_36_100_105_114_101_99_116_46_108_111_111_107_117_112_+0xb76>
  40d8e4:	mov    %rdx,%rsi
  40d8e7:	callq  435300 <p111_rt_sink>
  40d8ec:	movabs $0x2009900031086df,%rax
  40d8f6:	pop    %r15
  40d8f8:	pop    %r14
  40d8fa:	pop    %r13
  40d8fc:	pop    %r12
  40d8fe:	pop    %rbx
  40d8ff:	leaveq 
  40d900:	retq   

Disassembly of section .fini:
