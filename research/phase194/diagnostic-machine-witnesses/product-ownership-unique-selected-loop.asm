
/home/ai/bend2/build/publish/bend/selfhost/build/phase194/diag-selected-build02/product-ownership-unique/machine/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000408fae <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_>:
  408fae:	push   %rbp
  408faf:	mov    %rsp,%rbp
  408fb2:	sub    $0xa00,%rsp
  408fb9:	mov    %r12,-0x10(%rbp)
  408fbd:	mov    %rbx,-0x8(%rbp)
  408fc1:	mov    %r13,-0x18(%rbp)
  408fc5:	mov    %r14,-0x20(%rbp)
  408fc9:	mov    %r15,-0x28(%rbp)
  408fcd:	mov    %rdi,%rax
  408fd0:	mov    %rax,%r12
  408fd3:	mov    %rsi,%rax
  408fd6:	mov    %rax,%rdi
  408fd9:	mov    %rdx,%rax
  408fdc:	mov    %rax,%rbx
  408fdf:	mov    %rcx,%rax
  408fe2:	mov    %rax,%r13
  408fe5:	mov    %r8,%rax
  408fe8:	mov    %rax,%r14
  408feb:	cmp    $0x0,%rdi
  408ff2:	jne    409014 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x66>
  408ff8:	mov    %r14,%rax
  408ffb:	mov    -0x10(%rbp),%r12
  408fff:	mov    -0x8(%rbp),%rbx
  409003:	mov    -0x18(%rbp),%r13
  409007:	mov    -0x20(%rbp),%r14
  40900b:	mov    -0x28(%rbp),%r15
  40900f:	mov    %rbp,%rsp
  409012:	pop    %rbp
  409013:	retq   
  409014:	mov    %rdi,%r15
  409017:	sub    $0x1,%r15
  40901e:	mov    %r12,%rdi
  409021:	mov    %rbx,%rsi
  409024:	movabs $0x0,%rdx
  40902e:	mov    %r13,%rcx
  409031:	xor    %eax,%eax
  409033:	callq  408773 <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_107_101_114_110_101_108_>
  409038:	mov    %rax,%rsi
  40903b:	mov    %r13d,%edi
  40903e:	cmp    $0x11,%rdi
  409045:	sete   %dil
  409049:	movzbl %dil,%edi
  40904d:	mov    %rdi,%r9
  409050:	mov    %ebx,%edi
  409052:	cmp    $0x20,%rdi
  409059:	sete   %dil
  40905d:	movzbl %dil,%edi
  409061:	mov    %rdi,%rdx
  409064:	mov    %esi,%edi
  409066:	cmp    $0x156ac00a,%rdi
  40906d:	sete   %dil
  409071:	movzbl %dil,%edi
  409075:	mov    %rdi,%r8
  409078:	mov    %rdx,%rdi
  40907b:	xor    $0x1,%edi
  409081:	mov    %rdi,%rax
  409084:	movabs $0x0,%r10
  40908e:	mov    %r8,%r11
  409091:	test   %eax,%eax
  409093:	cmovne %r10,%r11
  409097:	mov    %r11,%r8
  40909a:	mov    %ebx,%edi
  40909c:	cmp    $0x400,%rdi
  4090a3:	sete   %dil
  4090a7:	movzbl %dil,%edi
  4090ab:	mov    %rdi,%rdx
  4090ae:	mov    %esi,%edi
  4090b0:	movabs $0xc015696a,%r11
  4090ba:	cmp    %r11,%rdi
  4090bd:	sete   %dil
  4090c1:	movzbl %dil,%edi
  4090c5:	mov    %rdi,%rsi
  4090c8:	mov    %rdx,%rdi
  4090cb:	xor    $0x1,%edi
  4090d1:	mov    %rdi,%rax
  4090d4:	movabs $0x0,%r10
  4090de:	mov    %rsi,%r11
  4090e1:	test   %eax,%eax
  4090e3:	cmovne %r10,%r11
  4090e7:	mov    %r11,%rsi
  4090ea:	mov    %r8,%rdi
  4090ed:	cmp    $0x1,%rdi
  4090f4:	sete   %dil
  4090f8:	movzbl %dil,%edi
  4090fc:	cmp    $0x1,%rsi
  409103:	sete   %sil
  409107:	movzbl %sil,%esi
  40910b:	mov    %rsi,%r11
  40910e:	mov    %rdi,%rsi
  409111:	or     %r11d,%esi
  409114:	mov    %r9,%r10
  409117:	movabs $0x1,%r11
  409121:	cmp    %r11,%r10
  409124:	mov    %rsi,%rax
  409127:	movabs $0x0,%r11
  409131:	cmove  %rax,%r11
  409135:	mov    %r11,%rsi
  409138:	mov    %rsi,%rdi
  40913b:	cmp    $0x1,%rdi
  409142:	sete   %dil
  409146:	movzbl %dil,%edi
  40914a:	xor    $0x1,%edi
  409150:	mov    %rdi,%rsi
  409153:	xor    $0x1,%rsi
  40915a:	mov    %r14d,%edi
  40915d:	mov    %rdi,%r14
  409160:	add    %esi,%r14d
  409163:	mov    %r15,%rdi
  409166:	jmpq   408feb <p113d_FID_36_100_105_114_101_99_116_46_112_49_57_52_46_108_111_111_112_+0x3d>

Disassembly of section .fini:
