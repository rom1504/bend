
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-references02/memory-dependence-dependent/c/program:     file format elf64-x86-64


Disassembly of section .text:

0000000000009f70 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_>:
    9f70:	push   %rbp
    9f71:	sub    $0x10,%rsp
    9f75:	mov    %rsi,%rdx
    9f78:	movabs $0xffff0000000000,%rax
    9f82:	movabs $0xffffffff80,%rbp
    9f8c:	mov    %rsi,%rcx
    9f8f:	and    %rax,%rcx
    9f92:	movabs $0x80000000000,%rbx
    9f9c:	cmp    %rbx,%rcx
    9f9f:	jne    a361 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3f1>
    9fa5:	lea    0x7f(%rbp),%r10
    9fa9:	mov    %rdx,%rsi
    9fac:	and    %r10,%rsi
    9faf:	test   %rdx,%rdx
    9fb2:	js     9fce <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x5e>
    9fb4:	mov    (%r12,%rsi,8),%r9
    9fb8:	mov    0x8(%r12,%rsi,8),%rdi
    9fbd:	mov    %rsi,%rcx
    9fc0:	cmp    $0x3108180,%rcx
    9fc7:	jae    a043 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0xd3>
    9fc9:	jmpq   a07b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    9fce:	mov    0x4(%r12,%rsi,8),%ecx
    9fd3:	mov    (%r12,%rsi,8),%edi
    9fd7:	mov    %edi,%r8d
    9fda:	and    $0xffffff,%r8d
    9fe1:	cmp    $0x1,%r8d
    9fe5:	jne    a2ac <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x33c>
    9feb:	mov    (%r12,%rsi,8),%edx
    9fef:	shl    $0x20,%rcx
    9ff3:	or     %rdi,%rcx
    9ff6:	shr    $0x18,%rcx
    9ffa:	mov    (%r12,%rcx,8),%r9
    9ffe:	mov    0x8(%r12,%rcx,8),%rdi
    a003:	mov    0x0(%r13),%rdx
    a007:	mov    %rdx,(%r12,%rsi,8)
    a00b:	mov    %rsi,0x0(%r13)
    a00f:	mov    0x100(%r13),%rdx
    a016:	inc    %rdx
    a019:	mov    %rdx,0x100(%r13)
    a020:	cmpb   $0x1,0x10bce9(%rip)        # 115d10 <KEEP_WORDS>
    a027:	jne    a317 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3a7>
    a02d:	cmp    $0x8000,%rdx
    a034:	jae    a317 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3a7>
    a03a:	cmp    $0x3108180,%rcx
    a041:	jb     a07b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    a043:	mov    0x8(%r13),%rdx
    a047:	mov    %rdx,(%r12,%rcx,8)
    a04b:	mov    %rcx,0x8(%r13)
    a04f:	mov    0x108(%r13),%rcx
    a056:	add    $0x2,%rcx
    a05a:	mov    %rcx,0x108(%r13)
    a061:	cmpb   $0x1,0x10bca8(%rip)        # 115d10 <KEEP_WORDS>
    a068:	jne    a276 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x306>
    a06e:	cmp    $0x8000,%rcx
    a075:	jae    a276 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x306>
    a07b:	and    %r9,%rax
    a07e:	cmp    %rbx,%rax
    a081:	jne    a393 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x423>
    a087:	mov    %r9,%rdx
    a08a:	and    %r10,%rdx
    a08d:	test   %r9,%r9
    a090:	js     a0ac <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x13c>
    a092:	mov    (%r12,%rdx,8),%rbx
    a096:	mov    0x8(%r12,%rdx,8),%rax
    a09b:	mov    %rdx,%rcx
    a09e:	cmp    $0x3108180,%rcx
    a0a5:	jae    a11e <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1ae>
    a0a7:	jmpq   a156 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a0ac:	mov    0x4(%r12,%rdx,8),%ecx
    a0b1:	mov    (%r12,%rdx,8),%eax
    a0b5:	mov    %eax,%esi
    a0b7:	and    $0xffffff,%esi
    a0bd:	cmp    $0x1,%esi
    a0c0:	jne    a2e0 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x370>
    a0c6:	mov    (%r12,%rdx,8),%esi
    a0ca:	shl    $0x20,%rcx
    a0ce:	or     %rax,%rcx
    a0d1:	shr    $0x18,%rcx
    a0d5:	mov    (%r12,%rcx,8),%rbx
    a0d9:	mov    0x8(%r12,%rcx,8),%rax
    a0de:	mov    0x0(%r13),%rsi
    a0e2:	mov    %rsi,(%r12,%rdx,8)
    a0e6:	mov    %rdx,0x0(%r13)
    a0ea:	mov    0x100(%r13),%rdx
    a0f1:	inc    %rdx
    a0f4:	mov    %rdx,0x100(%r13)
    a0fb:	cmpb   $0x1,0x10bc0e(%rip)        # 115d10 <KEEP_WORDS>
    a102:	jne    a33c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3cc>
    a108:	cmp    $0x8000,%rdx
    a10f:	jae    a33c <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x3cc>
    a115:	cmp    $0x3108180,%rcx
    a11c:	jb     a156 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a11e:	mov    0x8(%r13),%rdx
    a122:	mov    %rdx,(%r12,%rcx,8)
    a126:	mov    %rcx,0x8(%r13)
    a12a:	mov    0x108(%r13),%rcx
    a131:	add    $0x2,%rcx
    a135:	mov    %rcx,0x108(%r13)
    a13c:	cmpb   $0x1,0x10bbcd(%rip)        # 115d10 <KEEP_WORDS>
    a143:	jne    a291 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x321>
    a149:	cmp    $0x8000,%rcx
    a150:	jae    a291 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x321>
    a156:	mov    %rax,%rcx
    a159:	test   %rax,%rax
    a15c:	js     a191 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x221>
    a15e:	shr    $0x39,%rcx
    a162:	sete   %cl
    a165:	and    %rax,%rbp
    a168:	cmp    $0x3108180,%rbp
    a16f:	setb   %dl
    a172:	or     %cl,%dl
    a174:	jne    a1ad <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x23d>
    a176:	mov    %rdi,%r8
    a179:	mov    %r12,%rdi
    a17c:	mov    %r13,%rsi
    a17f:	mov    %rax,%rdx
    a182:	mov    $0x2,%ecx
    a187:	callq  122de <rfc_wrap>
    a18c:	mov    %r8,%rdi
    a18f:	jmp    a1ad <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x23d>
    a191:	and    %r10,%rcx
    a194:	mov    $0x1,%edx
    a199:	lock xadd %edx,(%r12,%rcx,8)
    a19f:	not    %edx
    a1a1:	test   $0xfffffe,%edx
    a1a7:	je     a40a <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x49a>
    a1ad:	mov    %rbx,%rcx
    a1b0:	shr    $0x28,%rcx
    a1b4:	mov    $0xffffffff,%edx
    a1b9:	shl    %cl,%edx
    a1bb:	not    %edx
    a1bd:	and    %eax,%edx
    a1bf:	and    %rbx,%r10
    a1c2:	lea    (%r12,%r10,8),%rax
    a1c6:	mov    (%rax,%rdx,4),%r8d
    a1ca:	mov    0x8(%r13),%rcx
    a1ce:	test   %rcx,%rcx
    a1d1:	je     a240 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x2d0>
    a1d3:	mov    (%r12,%rcx,8),%rax
    a1d7:	mov    %rax,0x8(%r13)
    a1db:	addq   $0xfffffffffffffffe,0x108(%r13)
    a1e3:	mov    %rbx,(%r12,%rcx,8)
    a1e7:	mov    %r8,0x8(%r12,%rcx,8)
    a1ec:	mov    0x8(%r13),%rsi
    a1f0:	test   %rsi,%rsi
    a1f3:	je     a25b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x2eb>
    a1f5:	mov    (%r12,%rsi,8),%rax
    a1f9:	mov    %rax,0x8(%r13)
    a1fd:	addq   $0xfffffffffffffffe,0x108(%r13)
    a205:	movabs $0x200080000000000,%rax
    a20f:	or     %rax,%rcx
    a212:	add    %r8d,%edi
    a215:	mov    %rcx,(%r12,%rsi,8)
    a219:	mov    %rdi,0x8(%r12,%rsi,8)
    a21e:	or     %rax,%rsi
    a221:	mov    -0x8(%r14),%eax
    a225:	add    $0xfffffffffffffff8,%r14
    a229:	lea    0xa210(%rip),%rcx        # 14440 <wl_tab>
    a230:	mov    (%rcx,%rax,8),%rax
    a234:	mov    $0x1,%edi
    a239:	add    $0x10,%rsp
    a23d:	pop    %rbp
    a23e:	jmpq   *%rax
    a240:	mov    %rdi,%rcx
    a243:	mov    %r12,%rdi
    a246:	mov    %r13,%rsi
    a249:	mov    $0x1,%edx
    a24e:	callq  11fd8 <heap_alloc_miss>
    a253:	mov    %rcx,%rdi
    a256:	mov    %rax,%rcx
    a259:	jmp    a1e3 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x273>
    a25b:	mov    %rdi,%r9
    a25e:	mov    %r12,%rdi
    a261:	mov    %r13,%rsi
    a264:	mov    $0x1,%edx
    a269:	callq  11fd8 <heap_alloc_miss>
    a26e:	mov    %r9,%rdi
    a271:	mov    %rax,%rsi
    a274:	jmp    a205 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x295>
    a276:	mov    %rdi,%rcx
    a279:	mov    %r12,%rdi
    a27c:	mov    %r13,%rsi
    a27f:	mov    $0x1,%edx
    a284:	callq  11eb1 <heap_hand>
    a289:	mov    %rcx,%rdi
    a28c:	jmpq   a07b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    a291:	mov    %rdi,%rcx
    a294:	mov    %r12,%rdi
    a297:	mov    %r13,%rsi
    a29a:	mov    $0x1,%edx
    a29f:	callq  11eb1 <heap_hand>
    a2a4:	mov    %rcx,%rdi
    a2a7:	jmpq   a156 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a2ac:	shl    $0x20,%rcx
    a2b0:	or     %rdi,%rcx
    a2b3:	shr    $0x18,%rcx
    a2b7:	mov    (%r12,%rcx,8),%r9
    a2bb:	mov    0x8(%r12,%rcx,8),%rsi
    a2c0:	mov    %rsi,0x8(%rsp)
    a2c5:	mov    %r12,%rdi
    a2c8:	mov    %r13,%rsi
    a2cb:	mov    $0x2,%r8d
    a2d1:	callq  11f42 <span_fade>
    a2d6:	mov    0x8(%rsp),%rdi
    a2db:	jmpq   a07b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    a2e0:	shl    $0x20,%rcx
    a2e4:	or     %rax,%rcx
    a2e7:	shr    $0x18,%rcx
    a2eb:	mov    (%r12,%rcx,8),%rbx
    a2ef:	mov    0x8(%r12,%rcx,8),%rax
    a2f4:	mov    %rdi,0x8(%rsp)
    a2f9:	mov    %r12,%rdi
    a2fc:	mov    %r13,%rsi
    a2ff:	mov    %r9,%rdx
    a302:	mov    $0x2,%r8d
    a308:	callq  11f42 <span_fade>
    a30d:	mov    0x8(%rsp),%rdi
    a312:	jmpq   a156 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a317:	mov    %rdi,%r8
    a31a:	mov    %r12,%rdi
    a31d:	mov    %r13,%rsi
    a320:	xor    %edx,%edx
    a322:	callq  11eb1 <heap_hand>
    a327:	mov    %r8,%rdi
    a32a:	cmp    $0x3108180,%rcx
    a331:	jae    a043 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0xd3>
    a337:	jmpq   a07b <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x10b>
    a33c:	mov    %rdi,%r8
    a33f:	mov    %r12,%rdi
    a342:	mov    %r13,%rsi
    a345:	xor    %edx,%edx
    a347:	callq  11eb1 <heap_hand>
    a34c:	mov    %r8,%rdi
    a34f:	cmp    $0x3108180,%rcx
    a356:	jae    a11e <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1ae>
    a35c:	jmpq   a156 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x1e6>
    a361:	movabs $0x7e00000000000000,%rax
    a36b:	test   %rax,%rdx
    a36e:	sete   %al
    a371:	cmp    $0xffffffffffffffff,%rdx
    a375:	sete   %cl
    a378:	or     %al,%cl
    a37a:	and    %rdx,%rbp
    a37d:	cmp    $0x3108180,%rbp
    a384:	setb   %al
    a387:	or     %cl,%al
    a389:	jne    a3fe <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x48e>
    a38b:	mov    %r12,%rdi
    a38e:	mov    %r13,%rsi
    a391:	jmp    a3f9 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x489>
    a393:	mov    %rdi,%r14
    a396:	movabs $0x7e00000000000000,%rbx
    a3a0:	test   %rbx,%r9
    a3a3:	sete   %al
    a3a6:	cmp    $0xffffffffffffffff,%r9
    a3aa:	sete   %cl
    a3ad:	or     %al,%cl
    a3af:	mov    %r9,%rax
    a3b2:	and    %rbp,%rax
    a3b5:	cmp    $0x3108180,%rax
    a3bb:	setb   %al
    a3be:	or     %cl,%al
    a3c0:	jne    a3d0 <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x460>
    a3c2:	mov    %r12,%rdi
    a3c5:	mov    %r13,%rsi
    a3c8:	mov    %r9,%rdx
    a3cb:	callq  6ad0 <term_drop>
    a3d0:	test   %rbx,%r14
    a3d3:	sete   %al
    a3d6:	cmp    $0xffffffffffffffff,%r14
    a3da:	sete   %cl
    a3dd:	or     %al,%cl
    a3df:	and    %r14,%rbp
    a3e2:	cmp    $0x3108180,%rbp
    a3e9:	setb   %al
    a3ec:	or     %cl,%al
    a3ee:	jne    a3fe <WL_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_114_101_97_100_95_99_101_108_108_+0x48e>
    a3f0:	mov    %r12,%rdi
    a3f3:	mov    %r13,%rsi
    a3f6:	mov    %r14,%rdx
    a3f9:	callq  6ad0 <term_drop>
    a3fe:	lea    -0x7ef5(%rip),%rdi        # 2510 <FID_RESW_T+0x310>
    a405:	callq  11e50 <err_fail>
    a40a:	lea    -0x7938(%rip),%rdi        # 2ad9 <FID_RESW_T+0x8d9>
    a411:	callq  11e50 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
