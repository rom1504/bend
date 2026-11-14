
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-sequential/c/program:     file format elf64-x86-64


Disassembly of section .text:

0000000000009f90 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>:
    9f90:	push   %rbp
    9f91:	sub    $0x10,%rsp
    9f95:	mov    %rsi,%rdx
    9f98:	movabs $0xffff0000000000,%rax
    9fa2:	movabs $0xffffffff80,%rbp
    9fac:	mov    %rsi,%rcx
    9faf:	and    %rax,%rcx
    9fb2:	movabs $0x80000000000,%rbx
    9fbc:	cmp    %rbx,%rcx
    9fbf:	jne    a387 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3f7>
    9fc5:	lea    0x7f(%rbp),%r10
    9fc9:	mov    %rdx,%rsi
    9fcc:	and    %r10,%rsi
    9fcf:	test   %rdx,%rdx
    9fd2:	js     9fee <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x5e>
    9fd4:	mov    (%r12,%rsi,8),%r9
    9fd8:	mov    0x8(%r12,%rsi,8),%rdi
    9fdd:	mov    %rsi,%rcx
    9fe0:	cmp    $0x3108180,%rcx
    9fe7:	jae    a063 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0xd3>
    9fe9:	jmpq   a09b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    9fee:	mov    0x4(%r12,%rsi,8),%ecx
    9ff3:	mov    (%r12,%rsi,8),%edi
    9ff7:	mov    %edi,%r8d
    9ffa:	and    $0xffffff,%r8d
    a001:	cmp    $0x1,%r8d
    a005:	jne    a2d2 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x342>
    a00b:	mov    (%r12,%rsi,8),%edx
    a00f:	shl    $0x20,%rcx
    a013:	or     %rdi,%rcx
    a016:	shr    $0x18,%rcx
    a01a:	mov    (%r12,%rcx,8),%r9
    a01e:	mov    0x8(%r12,%rcx,8),%rdi
    a023:	mov    0x0(%r13),%rdx
    a027:	mov    %rdx,(%r12,%rsi,8)
    a02b:	mov    %rsi,0x0(%r13)
    a02f:	mov    0x100(%r13),%rdx
    a036:	inc    %rdx
    a039:	mov    %rdx,0x100(%r13)
    a040:	cmpb   $0x1,0x10bc49(%rip)        # 115c90 <KEEP_WORDS>
    a047:	jne    a33d <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3ad>
    a04d:	cmp    $0x8000,%rdx
    a054:	jae    a33d <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3ad>
    a05a:	cmp    $0x3108180,%rcx
    a061:	jb     a09b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    a063:	mov    0x8(%r13),%rdx
    a067:	mov    %rdx,(%r12,%rcx,8)
    a06b:	mov    %rcx,0x8(%r13)
    a06f:	mov    0x108(%r13),%rcx
    a076:	add    $0x2,%rcx
    a07a:	mov    %rcx,0x108(%r13)
    a081:	cmpb   $0x1,0x10bc08(%rip)        # 115c90 <KEEP_WORDS>
    a088:	jne    a29c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x30c>
    a08e:	cmp    $0x8000,%rcx
    a095:	jae    a29c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x30c>
    a09b:	and    %r9,%rax
    a09e:	cmp    %rbx,%rax
    a0a1:	jne    a3b9 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x429>
    a0a7:	mov    %r9,%rdx
    a0aa:	and    %r10,%rdx
    a0ad:	test   %r9,%r9
    a0b0:	js     a0cc <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x13c>
    a0b2:	mov    (%r12,%rdx,8),%rbx
    a0b6:	mov    0x8(%r12,%rdx,8),%rax
    a0bb:	mov    %rdx,%rcx
    a0be:	cmp    $0x3108180,%rcx
    a0c5:	jae    a13e <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1ae>
    a0c7:	jmpq   a176 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a0cc:	mov    0x4(%r12,%rdx,8),%ecx
    a0d1:	mov    (%r12,%rdx,8),%eax
    a0d5:	mov    %eax,%esi
    a0d7:	and    $0xffffff,%esi
    a0dd:	cmp    $0x1,%esi
    a0e0:	jne    a306 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x376>
    a0e6:	mov    (%r12,%rdx,8),%esi
    a0ea:	shl    $0x20,%rcx
    a0ee:	or     %rax,%rcx
    a0f1:	shr    $0x18,%rcx
    a0f5:	mov    (%r12,%rcx,8),%rbx
    a0f9:	mov    0x8(%r12,%rcx,8),%rax
    a0fe:	mov    0x0(%r13),%rsi
    a102:	mov    %rsi,(%r12,%rdx,8)
    a106:	mov    %rdx,0x0(%r13)
    a10a:	mov    0x100(%r13),%rdx
    a111:	inc    %rdx
    a114:	mov    %rdx,0x100(%r13)
    a11b:	cmpb   $0x1,0x10bb6e(%rip)        # 115c90 <KEEP_WORDS>
    a122:	jne    a362 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3d2>
    a128:	cmp    $0x8000,%rdx
    a12f:	jae    a362 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3d2>
    a135:	cmp    $0x3108180,%rcx
    a13c:	jb     a176 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a13e:	mov    0x8(%r13),%rdx
    a142:	mov    %rdx,(%r12,%rcx,8)
    a146:	mov    %rcx,0x8(%r13)
    a14a:	mov    0x108(%r13),%rcx
    a151:	add    $0x2,%rcx
    a155:	mov    %rcx,0x108(%r13)
    a15c:	cmpb   $0x1,0x10bb2d(%rip)        # 115c90 <KEEP_WORDS>
    a163:	jne    a2b7 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x327>
    a169:	cmp    $0x8000,%rcx
    a170:	jae    a2b7 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x327>
    a176:	mov    %rax,%rcx
    a179:	test   %rax,%rax
    a17c:	js     a1b1 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x221>
    a17e:	shr    $0x39,%rcx
    a182:	sete   %cl
    a185:	and    %rax,%rbp
    a188:	cmp    $0x3108180,%rbp
    a18f:	setb   %dl
    a192:	or     %cl,%dl
    a194:	jne    a1cd <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x23d>
    a196:	mov    %rdi,%r8
    a199:	mov    %r12,%rdi
    a19c:	mov    %r13,%rsi
    a19f:	mov    %rax,%rdx
    a1a2:	mov    $0x2,%ecx
    a1a7:	callq  1227e <rfc_wrap>
    a1ac:	mov    %r8,%rdi
    a1af:	jmp    a1cd <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x23d>
    a1b1:	and    %r10,%rcx
    a1b4:	mov    $0x1,%edx
    a1b9:	lock xadd %edx,(%r12,%rcx,8)
    a1bf:	not    %edx
    a1c1:	test   $0xfffffe,%edx
    a1c7:	je     a430 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x4a0>
    a1cd:	mov    %rbx,%rcx
    a1d0:	shr    $0x28,%rcx
    a1d4:	mov    $0xffffffff,%edx
    a1d9:	shl    %cl,%edx
    a1db:	not    %edx
    a1dd:	and    %eax,%edx
    a1df:	and    %rbx,%r10
    a1e2:	lea    (%r12,%r10,8),%rcx
    a1e6:	mov    (%rcx,%rdx,4),%r8d
    a1ea:	inc    %eax
    a1ec:	movzbl %al,%r9d
    a1f0:	mov    0x8(%r13),%rcx
    a1f4:	test   %rcx,%rcx
    a1f7:	je     a266 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x2d6>
    a1f9:	mov    (%r12,%rcx,8),%rax
    a1fd:	mov    %rax,0x8(%r13)
    a201:	addq   $0xfffffffffffffffe,0x108(%r13)
    a209:	mov    %rbx,(%r12,%rcx,8)
    a20d:	mov    %r9,0x8(%r12,%rcx,8)
    a212:	mov    0x8(%r13),%rsi
    a216:	test   %rsi,%rsi
    a219:	je     a281 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x2f1>
    a21b:	mov    (%r12,%rsi,8),%rax
    a21f:	mov    %rax,0x8(%r13)
    a223:	addq   $0xfffffffffffffffe,0x108(%r13)
    a22b:	movabs $0x200080000000000,%rax
    a235:	or     %rax,%rcx
    a238:	add    %edi,%r8d
    a23b:	mov    %rcx,(%r12,%rsi,8)
    a23f:	mov    %r8,0x8(%r12,%rsi,8)
    a244:	or     %rax,%rsi
    a247:	mov    -0x8(%r14),%eax
    a24b:	add    $0xfffffffffffffff8,%r14
    a24f:	lea    0xa18a(%rip),%rcx        # 143e0 <wl_tab>
    a256:	mov    (%rcx,%rax,8),%rax
    a25a:	mov    $0x1,%edi
    a25f:	add    $0x10,%rsp
    a263:	pop    %rbp
    a264:	jmpq   *%rax
    a266:	mov    %rdi,%rcx
    a269:	mov    %r12,%rdi
    a26c:	mov    %r13,%rsi
    a26f:	mov    $0x1,%edx
    a274:	callq  11f78 <heap_alloc_miss>
    a279:	mov    %rcx,%rdi
    a27c:	mov    %rax,%rcx
    a27f:	jmp    a209 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x279>
    a281:	mov    %rdi,%r9
    a284:	mov    %r12,%rdi
    a287:	mov    %r13,%rsi
    a28a:	mov    $0x1,%edx
    a28f:	callq  11f78 <heap_alloc_miss>
    a294:	mov    %r9,%rdi
    a297:	mov    %rax,%rsi
    a29a:	jmp    a22b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x29b>
    a29c:	mov    %rdi,%rcx
    a29f:	mov    %r12,%rdi
    a2a2:	mov    %r13,%rsi
    a2a5:	mov    $0x1,%edx
    a2aa:	callq  11e51 <heap_hand>
    a2af:	mov    %rcx,%rdi
    a2b2:	jmpq   a09b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    a2b7:	mov    %rdi,%rcx
    a2ba:	mov    %r12,%rdi
    a2bd:	mov    %r13,%rsi
    a2c0:	mov    $0x1,%edx
    a2c5:	callq  11e51 <heap_hand>
    a2ca:	mov    %rcx,%rdi
    a2cd:	jmpq   a176 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a2d2:	shl    $0x20,%rcx
    a2d6:	or     %rdi,%rcx
    a2d9:	shr    $0x18,%rcx
    a2dd:	mov    (%r12,%rcx,8),%r9
    a2e1:	mov    0x8(%r12,%rcx,8),%rsi
    a2e6:	mov    %rsi,0x8(%rsp)
    a2eb:	mov    %r12,%rdi
    a2ee:	mov    %r13,%rsi
    a2f1:	mov    $0x2,%r8d
    a2f7:	callq  11ee2 <span_fade>
    a2fc:	mov    0x8(%rsp),%rdi
    a301:	jmpq   a09b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    a306:	shl    $0x20,%rcx
    a30a:	or     %rax,%rcx
    a30d:	shr    $0x18,%rcx
    a311:	mov    (%r12,%rcx,8),%rbx
    a315:	mov    0x8(%r12,%rcx,8),%rax
    a31a:	mov    %rdi,0x8(%rsp)
    a31f:	mov    %r12,%rdi
    a322:	mov    %r13,%rsi
    a325:	mov    %r9,%rdx
    a328:	mov    $0x2,%r8d
    a32e:	callq  11ee2 <span_fade>
    a333:	mov    0x8(%rsp),%rdi
    a338:	jmpq   a176 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a33d:	mov    %rdi,%r8
    a340:	mov    %r12,%rdi
    a343:	mov    %r13,%rsi
    a346:	xor    %edx,%edx
    a348:	callq  11e51 <heap_hand>
    a34d:	mov    %r8,%rdi
    a350:	cmp    $0x3108180,%rcx
    a357:	jae    a063 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0xd3>
    a35d:	jmpq   a09b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    a362:	mov    %rdi,%r8
    a365:	mov    %r12,%rdi
    a368:	mov    %r13,%rsi
    a36b:	xor    %edx,%edx
    a36d:	callq  11e51 <heap_hand>
    a372:	mov    %r8,%rdi
    a375:	cmp    $0x3108180,%rcx
    a37c:	jae    a13e <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1ae>
    a382:	jmpq   a176 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a387:	movabs $0x7e00000000000000,%rax
    a391:	test   %rax,%rdx
    a394:	sete   %al
    a397:	cmp    $0xffffffffffffffff,%rdx
    a39b:	sete   %cl
    a39e:	or     %al,%cl
    a3a0:	and    %rdx,%rbp
    a3a3:	cmp    $0x3108180,%rbp
    a3aa:	setb   %al
    a3ad:	or     %cl,%al
    a3af:	jne    a424 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x494>
    a3b1:	mov    %r12,%rdi
    a3b4:	mov    %r13,%rsi
    a3b7:	jmp    a41f <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x48f>
    a3b9:	mov    %rdi,%r14
    a3bc:	movabs $0x7e00000000000000,%rbx
    a3c6:	test   %rbx,%r9
    a3c9:	sete   %al
    a3cc:	cmp    $0xffffffffffffffff,%r9
    a3d0:	sete   %cl
    a3d3:	or     %al,%cl
    a3d5:	mov    %r9,%rax
    a3d8:	and    %rbp,%rax
    a3db:	cmp    $0x3108180,%rax
    a3e1:	setb   %al
    a3e4:	or     %cl,%al
    a3e6:	jne    a3f6 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x466>
    a3e8:	mov    %r12,%rdi
    a3eb:	mov    %r13,%rsi
    a3ee:	mov    %r9,%rdx
    a3f1:	callq  6ac0 <term_drop>
    a3f6:	test   %rbx,%r14
    a3f9:	sete   %al
    a3fc:	cmp    $0xffffffffffffffff,%r14
    a400:	sete   %cl
    a403:	or     %al,%cl
    a405:	and    %r14,%rbp
    a408:	cmp    $0x3108180,%rbp
    a40f:	setb   %al
    a412:	or     %cl,%al
    a414:	jne    a424 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x494>
    a416:	mov    %r12,%rdi
    a419:	mov    %r13,%rsi
    a41c:	mov    %r14,%rdx
    a41f:	callq  6ac0 <term_drop>
    a424:	lea    -0x7f1b(%rip),%rdi        # 2510 <FID_RESW_T+0x310>
    a42b:	callq  11df0 <err_fail>
    a430:	lea    -0x795e(%rip),%rdi        # 2ad9 <FID_RESW_T+0x8d9>
    a437:	callq  11df0 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
