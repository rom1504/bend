
/home/ai/bend2/build/publish/bend/selfhost/build/phase184/bend-products01/editdist/bend-c/program:     file format elf64-x86-64


Disassembly of section .text:

000000000000ab40 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_>:
    ab40:	push   %rbp
    ab41:	sub    $0x10,%rsp
    ab45:	mov    %r13,%r10
    ab48:	movabs $0x7e00000000000000,%r8
    ab52:	movabs $0xffffffff80,%r13
    ab5c:	movabs $0xffff0000000000,%rax
    ab66:	and    %rsi,%rax
    ab69:	movabs $0xa40000000000,%rcx
    ab73:	cmp    %rcx,%rax
    ab76:	mov    %r10,(%rsp)
    ab7a:	jne    ae14 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x2d4>
    ab80:	mov    %r15d,0xc(%rsp)
    ab85:	lea    0x7f(%r13),%rcx
    ab89:	mov    %rsi,%rax
    ab8c:	and    %rcx,%rax
    ab8f:	test   %rsi,%rsi
    ab92:	js     abbc <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x7c>
    ab94:	mov    (%r12,%rax,8),%rdx
    ab98:	mov    0x8(%r12,%rax,8),%rbp
    ab9d:	mov    0x10(%r12,%rax,8),%rbx
    aba2:	mov    0x18(%r12,%rax,8),%r15
    aba7:	mov    %rax,%rcx
    abaa:	cmp    $0x3108180,%rcx
    abb1:	jae    ac3b <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0xfb>
    abb7:	jmpq   ac72 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x132>
    abbc:	mov    0x4(%r12,%rax,8),%ecx
    abc1:	mov    (%r12,%rax,8),%edx
    abc5:	mov    %edx,%edi
    abc7:	and    $0xffffff,%edi
    abcd:	cmp    $0x1,%rdi
    abd1:	jne    abd7 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x97>
    abd3:	mov    (%r12,%rax,8),%ebx
    abd7:	shl    $0x20,%rcx
    abdb:	or     %rdx,%rcx
    abde:	shr    $0x18,%rcx
    abe2:	mov    (%r12,%rcx,8),%rdx
    abe6:	mov    0x8(%r12,%rcx,8),%rbp
    abeb:	mov    0x10(%r12,%rcx,8),%rbx
    abf0:	mov    0x18(%r12,%rcx,8),%r15
    abf5:	cmp    $0x1,%edi
    abf8:	jne    adc3 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x283>
    abfe:	mov    (%r10),%rsi
    ac01:	mov    %rsi,(%r12,%rax,8)
    ac05:	mov    %rax,(%r10)
    ac08:	mov    0x100(%r10),%rax
    ac0f:	inc    %rax
    ac12:	mov    %rax,0x100(%r10)
    ac19:	cmpb   $0x1,0x10cef0(%rip)        # 117b10 <KEEP_WORDS>
    ac20:	jne    adef <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x2af>
    ac26:	cmp    $0x8000,%rax
    ac2c:	jae    adef <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x2af>
    ac32:	cmp    $0x3108180,%rcx
    ac39:	jb     ac72 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x132>
    ac3b:	mov    0x10(%r10),%rax
    ac3f:	mov    %rax,(%r12,%rcx,8)
    ac43:	mov    %rcx,0x10(%r10)
    ac47:	mov    0x110(%r10),%rax
    ac4e:	add    $0x4,%rax
    ac52:	mov    %rax,0x110(%r10)
    ac59:	cmpb   $0x1,0x10ceb0(%rip)        # 117b10 <KEEP_WORDS>
    ac60:	jne    ada8 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x268>
    ac66:	cmp    $0x8000,%rax
    ac6c:	jae    ada8 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x268>
    ac72:	test   %r8,%rdx
    ac75:	sete   %al
    ac78:	cmp    $0xffffffffffffffff,%rdx
    ac7c:	sete   %cl
    ac7f:	or     %al,%cl
    ac81:	mov    %rdx,%rax
    ac84:	and    %r13,%rax
    ac87:	cmp    $0x3108180,%rax
    ac8d:	setb   %al
    ac90:	or     %cl,%al
    ac92:	jne    acad <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x16d>
    ac94:	mov    %r12,%rdi
    ac97:	mov    %r10,%rsi
    ac9a:	callq  7130 <term_drop>
    ac9f:	movabs $0x7e00000000000000,%r8
    aca9:	mov    (%rsp),%r10
    acad:	test   %r8,%rbp
    acb0:	sete   %al
    acb3:	cmp    $0xffffffffffffffff,%rbp
    acb7:	sete   %cl
    acba:	or     %al,%cl
    acbc:	mov    %rbp,%rax
    acbf:	and    %r13,%rax
    acc2:	cmp    $0x3108180,%rax
    acc8:	setb   %al
    accb:	or     %cl,%al
    accd:	jne    aceb <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x1ab>
    accf:	mov    %r12,%rdi
    acd2:	mov    %r10,%rsi
    acd5:	mov    %rbp,%rdx
    acd8:	callq  7130 <term_drop>
    acdd:	movabs $0x7e00000000000000,%r8
    ace7:	mov    (%rsp),%r10
    aceb:	test   %r8,%r15
    acee:	sete   %al
    acf1:	cmp    $0xffffffffffffffff,%r15
    acf5:	sete   %cl
    acf8:	or     %al,%cl
    acfa:	mov    %r15,%rax
    acfd:	and    %r13,%rax
    ad00:	cmp    $0x3108180,%rax
    ad06:	setb   %al
    ad09:	or     %cl,%al
    ad0b:	jne    ad29 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x1e9>
    ad0d:	mov    %r12,%rdi
    ad10:	mov    %r10,%rsi
    ad13:	mov    %r15,%rdx
    ad16:	callq  7130 <term_drop>
    ad1b:	movabs $0x7e00000000000000,%r8
    ad25:	mov    (%rsp),%r10
    ad29:	mov    %rbx,%rcx
    ad2c:	shr    $0x28,%rcx
    ad30:	mov    $0xffffffff,%eax
    ad35:	shl    %cl,%eax
    ad37:	not    %eax
    ad39:	and    $0x100,%eax
    ad3e:	lea    0x7f(%r13),%rcx
    ad42:	and    %rbx,%rcx
    ad45:	lea    (%r12,%rcx,8),%rcx
    ad49:	mov    (%rcx,%rax,4),%ebp
    ad4c:	test   %r8,%rbx
    ad4f:	sete   %al
    ad52:	cmp    $0xffffffffffffffff,%rbx
    ad56:	sete   %cl
    ad59:	or     %al,%cl
    ad5b:	and    %rbx,%r13
    ad5e:	cmp    $0x3108180,%r13
    ad65:	setb   %al
    ad68:	or     %cl,%al
    ad6a:	jne    ad7e <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x23e>
    ad6c:	mov    %r12,%rdi
    ad6f:	mov    %r10,%rsi
    ad72:	mov    %rbx,%rdx
    ad75:	callq  7130 <term_drop>
    ad7a:	mov    (%rsp),%r10
    ad7e:	mov    -0x8(%r14),%eax
    ad82:	add    $0xfffffffffffffff8,%r14
    ad86:	lea    0xb423(%rip),%rcx        # 161b0 <wl_tab>
    ad8d:	mov    (%rcx,%rax,8),%rax
    ad91:	mov    %r10,%r13
    ad94:	mov    0xc(%rsp),%r15d
    ad99:	mov    $0x1,%edi
    ad9e:	mov    %rbp,%rsi
    ada1:	add    $0x10,%rsp
    ada5:	pop    %rbp
    ada6:	jmpq   *%rax
    ada8:	mov    %r12,%rdi
    adab:	mov    %r10,%rsi
    adae:	mov    %rdx,%rax
    adb1:	mov    $0x2,%edx
    adb6:	callq  13c21 <heap_hand>
    adbb:	mov    %rax,%rdx
    adbe:	jmpq   ac72 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x132>
    adc3:	mov    %r12,%rdi
    adc6:	mov    %rsi,%rax
    adc9:	mov    %r10,%rsi
    adcc:	mov    %rdx,%r9
    adcf:	mov    %rax,%rdx
    add2:	mov    $0x4,%r8d
    add8:	callq  13cb2 <span_fade>
    addd:	movabs $0x7e00000000000000,%r8
    ade7:	mov    %r9,%rdx
    adea:	jmpq   ac72 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x132>
    adef:	mov    %r12,%rdi
    adf2:	mov    %r10,%rsi
    adf5:	mov    %rdx,%rax
    adf8:	xor    %edx,%edx
    adfa:	callq  13c21 <heap_hand>
    adff:	mov    %rax,%rdx
    ae02:	cmp    $0x3108180,%rcx
    ae09:	jae    ac3b <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0xfb>
    ae0f:	jmpq   ac72 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x132>
    ae14:	test   %r8,%rsi
    ae17:	sete   %al
    ae1a:	cmp    $0xffffffffffffffff,%rsi
    ae1e:	sete   %cl
    ae21:	or     %al,%cl
    ae23:	and    %rsi,%r13
    ae26:	cmp    $0x3108180,%r13
    ae2d:	setb   %al
    ae30:	or     %cl,%al
    ae32:	jne    ae43 <WL_FID_36_100_105_114_101_99_116_46_100_105_115_116_+0x303>
    ae34:	mov    %rsi,%rdx
    ae37:	mov    %r12,%rdi
    ae3a:	mov    (%rsp),%rsi
    ae3e:	callq  7130 <term_drop>
    ae43:	lea    -0x861a(%rip),%rdi        # 2830 <FID_RESW_T+0x330>
    ae4a:	callq  13bc0 <err_fail>

Disassembly of section .init:

Disassembly of section .fini:

Disassembly of section .plt:
