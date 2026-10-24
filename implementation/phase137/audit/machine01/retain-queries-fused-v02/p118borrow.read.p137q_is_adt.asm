
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p137-retain-query-builds01-wide-queries-fused-v02/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000409be0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_>:
  409be0:	endbr64 
  409be4:	push   %rbp
  409be5:	mov    %rsp,%rbp
  409be8:	sub    $0x800,%rsp
  409bef:	push   %rbx
  409bf0:	push   %r12
  409bf2:	mov    %rsi,%rax
  409bf5:	shr    $0x28,%rax
  409bf9:	mov    %rax,%r9
  409bfc:	and    $0xffff,%r9
  409c03:	cmp    $0x99,%r9
  409c0a:	sete   %al
  409c0d:	movzbl %al,%eax
  409c10:	cmp    $0x0,%eax
  409c13:	jne    409d9a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x1ba>
  409c19:	cs cs cs cs cmp $0x9a,%r9
  409c24:	cs cs sete %r10b
  409c2a:	movzbl %r10b,%r10d
  409c2e:	mov    %rsi,%rax
  409c31:	shr    $0x38,%rax
  409c35:	and    $0x7f,%rax
  409c39:	cmp    $0x2,%rax
  409c3d:	sete   %r8b
  409c41:	movzbl %r8b,%r8d
  409c45:	mov    %rsi,%rcx
  409c48:	shr    $0x3f,%rcx
  409c4c:	movabs $0xffffffffff,%rax
  409c56:	and    %rsi,%rax
  409c59:	mov    %rax,%rdx
  409c5c:	shl    $0x3,%rdx
  409c60:	cmp    $0x0,%r10d
  409c64:	jne    409d1f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x13f>
  409c6a:	cmp    $0x9b,%r9
  409c71:	sete   %r9b
  409c75:	movzbl %r9b,%r9d
  409c79:	je     409c8f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0xaf>
  409c7b:	mov    $0x4,%esi
  409c80:	callq  432730 <p111_rt_fail>
  409c85:	mov    $0x0,%eax
  409c8a:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  409c8f:	test   %r8d,%r9d
  409c92:	jne    409cb3 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0xd3>
  409c94:	mov    $0x4,%r8d
  409c9a:	mov    $0x9b,%ecx
  409c9f:	lea    -0x800(%rbp),%rdx
  409ca6:	mov    %rdi,%rbx
  409ca9:	callq  4369d0 <p118_rt_borrow_fields>
  409cae:	mov    %rbx,%rdi
  409cb1:	jmp    409d04 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x124>
  409cb3:	mov    %rcx,%rsi
  409cb6:	mov    (%rdi),%rcx
  409cb9:	cmp    $0x0,%rsi
  409cbd:	je     409cd1 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0xf1>
  409cbf:	mov    (%rdx,%rcx,1),%eax
  409cc2:	mov    0x4(%rdx,%rcx,1),%edx
  409cc6:	shl    $0x20,%rdx
  409cca:	or     %rdx,%rax
  409ccd:	shr    $0x18,%rax
  409cd1:	shl    $0x3,%rax
  409cd5:	mov    (%rax,%rcx,1),%rdx
  409cd9:	mov    %rdx,-0x800(%rbp)
  409ce0:	mov    0x8(%rax,%rcx,1),%rdx
  409ce5:	mov    %rdx,-0x7f8(%rbp)
  409cec:	mov    0x10(%rax,%rcx,1),%rdx
  409cf1:	mov    %rdx,-0x7f0(%rbp)
  409cf8:	mov    0x18(%rax,%rcx,1),%rax
  409cfd:	mov    %rax,-0x7e8(%rbp)
  409d04:	mov    $0x0,%ecx
  409d09:	lea    -0x800(%rbp),%rdx
  409d10:	mov    $0x1,%esi
  409d15:	callq  4338d0 <p111_rt_special_ctor>
  409d1a:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  409d1f:	mov    %r10d,%r9d
  409d22:	test   %r8d,%r9d
  409d25:	jne    409d46 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x166>
  409d27:	mov    $0x2,%r8d
  409d2d:	mov    $0x9a,%ecx
  409d32:	lea    -0x800(%rbp),%rdx
  409d39:	mov    %rdi,%rbx
  409d3c:	callq  4369d0 <p118_rt_borrow_fields>
  409d41:	mov    %rbx,%rdi
  409d44:	jmp    409d7f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x19f>
  409d46:	mov    %rcx,%rsi
  409d49:	mov    (%rdi),%rcx
  409d4c:	cmp    $0x0,%rsi
  409d50:	je     409d64 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x184>
  409d52:	mov    (%rdx,%rcx,1),%eax
  409d55:	mov    0x4(%rdx,%rcx,1),%edx
  409d59:	shl    $0x20,%rdx
  409d5d:	or     %rdx,%rax
  409d60:	shr    $0x18,%rax
  409d64:	shl    $0x3,%rax
  409d68:	mov    (%rax,%rcx,1),%rdx
  409d6c:	mov    %rdx,-0x800(%rbp)
  409d73:	mov    0x8(%rax,%rcx,1),%rax
  409d78:	mov    %rax,-0x7f8(%rbp)
  409d7f:	mov    $0x0,%ecx
  409d84:	lea    -0x800(%rbp),%rdx
  409d8b:	mov    $0x1,%esi
  409d90:	callq  4338d0 <p111_rt_special_ctor>
  409d95:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  409d9a:	mov    $0x9,%r8d
  409da0:	mov    $0x99,%ecx
  409da5:	lea    -0x800(%rbp),%rdx
  409dac:	mov    %rdi,%rbx
  409daf:	callq  4369d0 <p118_rt_borrow_fields>
  409db4:	mov    %rbx,%rdi
  409db7:	mov    -0x7f8(%rbp),%rsi
  409dbe:	mov    %rsi,%rax
  409dc1:	shr    $0x28,%rax
  409dc5:	and    $0xffff,%rax
  409dcb:	cmp    $0x18,%rax
  409dcf:	je     40a23a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x65a>
  409dd5:	cs cmp $0x19,%rax
  409dda:	sete   %cl
  409ddd:	movzbl %cl,%ecx
  409de0:	je     409df6 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x216>
  409de2:	mov    $0x4,%esi
  409de7:	callq  432730 <p111_rt_fail>
  409dec:	mov    $0x0,%eax
  409df1:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  409df6:	mov    %rsi,%rax
  409df9:	shr    $0x38,%rax
  409dfd:	and    $0x7f,%rax
  409e01:	cmp    $0x2,%rax
  409e05:	sete   %al
  409e08:	movzbl %al,%eax
  409e0b:	test   %eax,%ecx
  409e0d:	jne    409e2e <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x24e>
  409e0f:	mov    $0x2,%r8d
  409e15:	mov    $0x19,%ecx
  409e1a:	lea    -0x800(%rbp),%rdx
  409e21:	mov    %rdi,%rbx
  409e24:	callq  4369d0 <p118_rt_borrow_fields>
  409e29:	mov    %rbx,%rdi
  409e2c:	jmp    409e85 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x2a5>
  409e2e:	mov    (%rdi),%rcx
  409e31:	movabs $0xffffffffff,%rax
  409e3b:	and    %rsi,%rax
  409e3e:	mov    %rsi,%rdx
  409e41:	shr    $0x3f,%rdx
  409e45:	cmp    $0x0,%rdx
  409e49:	je     409e6a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x28a>
  409e4b:	cs cs cs cs mov %rax,%rdx
  409e52:	cs cs shl $0x3,%rdx
  409e58:	mov    (%rdx,%rcx,1),%eax
  409e5b:	mov    0x4(%rdx,%rcx,1),%edx
  409e5f:	shl    $0x20,%rdx
  409e63:	or     %rdx,%rax
  409e66:	shr    $0x18,%rax
  409e6a:	shl    $0x3,%rax
  409e6e:	mov    (%rax,%rcx,1),%rdx
  409e72:	mov    %rdx,-0x800(%rbp)
  409e79:	mov    0x8(%rax,%rcx,1),%rax
  409e7e:	mov    %rax,-0x7f8(%rbp)
  409e85:	mov    -0x800(%rbp),%r12
  409e8c:	mov    -0x7f8(%rbp),%rsi
  409e93:	mov    %rsi,%rax
  409e96:	shr    $0x28,%rax
  409e9a:	and    $0xffff,%rax
  409ea0:	cmp    $0x18,%rax
  409ea4:	je     40a222 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x642>
  409eaa:	cmp    $0x19,%rax
  409eae:	sete   %cl
  409eb1:	movzbl %cl,%ecx
  409eb4:	je     409eca <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x2ea>
  409eb6:	mov    $0x4,%esi
  409ebb:	callq  432730 <p111_rt_fail>
  409ec0:	mov    $0x0,%eax
  409ec5:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  409eca:	cs mov %rsi,%rax
  409ece:	shr    $0x38,%rax
  409ed2:	and    $0x7f,%rax
  409ed6:	cmp    $0x2,%rax
  409eda:	sete   %al
  409edd:	movzbl %al,%eax
  409ee0:	test   %eax,%ecx
  409ee2:	jne    409f03 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x323>
  409ee4:	mov    $0x2,%r8d
  409eea:	mov    $0x19,%ecx
  409eef:	lea    -0x800(%rbp),%rdx
  409ef6:	mov    %rdi,%rbx
  409ef9:	callq  4369d0 <p118_rt_borrow_fields>
  409efe:	mov    %rbx,%rdi
  409f01:	jmp    409f5a <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x37a>
  409f03:	cs cs cs mov %cs:(%rdi),%rcx
  409f0a:	cs cs movabs $0xffffffffff,%rax
  409f16:	and    %rsi,%rax
  409f19:	mov    %rsi,%rdx
  409f1c:	shr    $0x3f,%rdx
  409f20:	cmp    $0x0,%rdx
  409f24:	je     409f3f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x35f>
  409f26:	mov    %rax,%rdx
  409f29:	shl    $0x3,%rdx
  409f2d:	mov    (%rdx,%rcx,1),%eax
  409f30:	mov    0x4(%rdx,%rcx,1),%edx
  409f34:	shl    $0x20,%rdx
  409f38:	or     %rdx,%rax
  409f3b:	shr    $0x18,%rax
  409f3f:	shl    $0x3,%rax
  409f43:	mov    (%rax,%rcx,1),%rdx
  409f47:	mov    %rdx,-0x800(%rbp)
  409f4e:	mov    0x8(%rax,%rcx,1),%rax
  409f53:	mov    %rax,-0x7f8(%rbp)
  409f5a:	mov    -0x800(%rbp),%rbx
  409f61:	mov    -0x7f8(%rbp),%rsi
  409f68:	mov    %r12d,%eax
  409f6b:	cmp    $0x41,%rax
  409f6f:	sete   %al
  409f72:	movzbl %al,%eax
  409f75:	mov    %eax,%ecx
  409f77:	cmp    $0x1,%rcx
  409f7b:	sete   %al
  409f7e:	movzbl %al,%eax
  409f81:	shr    $0x28,%rcx
  409f85:	and    $0x7fffff,%rcx
  409f8c:	cmp    $0x10002,%rcx
  409f93:	sete   %cl
  409f96:	movzbl %cl,%ecx
  409f99:	mov    %eax,%edx
  409f9b:	or     %ecx,%edx
  409f9d:	xor    $0x1,%edx
  409fa0:	jne    40a208 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x628>
  409fa6:	or     %ecx,%eax
  409fa8:	jne    409fbe <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x3de>
  409faa:	mov    $0x4,%esi
  409faf:	callq  432730 <p111_rt_fail>
  409fb4:	mov    $0x0,%eax
  409fb9:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  409fbe:	mov    %rsi,%rax
  409fc1:	shr    $0x28,%rax
  409fc5:	and    $0xffff,%rax
  409fcb:	cmp    $0x18,%rax
  409fcf:	je     40a1f0 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x610>
  409fd5:	cs cmp $0x19,%rax
  409fda:	sete   %cl
  409fdd:	movzbl %cl,%ecx
  409fe0:	je     409ff6 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x416>
  409fe2:	mov    $0x4,%esi
  409fe7:	callq  432730 <p111_rt_fail>
  409fec:	mov    $0x0,%eax
  409ff1:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  409ff6:	mov    %rsi,%rax
  409ff9:	shr    $0x38,%rax
  409ffd:	and    $0x7f,%rax
  40a001:	cmp    $0x2,%rax
  40a005:	sete   %al
  40a008:	movzbl %al,%eax
  40a00b:	test   %eax,%ecx
  40a00d:	jne    40a02e <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x44e>
  40a00f:	mov    $0x2,%r8d
  40a015:	mov    $0x19,%ecx
  40a01a:	lea    -0x800(%rbp),%rdx
  40a021:	mov    %rdi,%r12
  40a024:	callq  4369d0 <p118_rt_borrow_fields>
  40a029:	mov    %r12,%rdi
  40a02c:	jmp    40a07f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x49f>
  40a02e:	mov    (%rdi),%rcx
  40a031:	movabs $0xffffffffff,%rax
  40a03b:	and    %rsi,%rax
  40a03e:	mov    %rsi,%rdx
  40a041:	shr    $0x3f,%rdx
  40a045:	cmp    $0x0,%rdx
  40a049:	je     40a064 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x484>
  40a04b:	mov    %rax,%rdx
  40a04e:	shl    $0x3,%rdx
  40a052:	mov    (%rdx,%rcx,1),%eax
  40a055:	mov    0x4(%rdx,%rcx,1),%edx
  40a059:	shl    $0x20,%rdx
  40a05d:	or     %rdx,%rax
  40a060:	shr    $0x18,%rax
  40a064:	shl    $0x3,%rax
  40a068:	mov    (%rax,%rcx,1),%rdx
  40a06c:	mov    %rdx,-0x800(%rbp)
  40a073:	mov    0x8(%rax,%rcx,1),%rax
  40a078:	mov    %rax,-0x7f8(%rbp)
  40a07f:	mov    -0x800(%rbp),%rax
  40a086:	mov    -0x7f8(%rbp),%rsi
  40a08d:	mov    %ebx,%ecx
  40a08f:	cmp    $0x44,%rcx
  40a093:	sete   %cl
  40a096:	movzbl %cl,%ecx
  40a099:	mov    %ecx,%edx
  40a09b:	cmp    $0x1,%rdx
  40a09f:	sete   %cl
  40a0a2:	movzbl %cl,%ecx
  40a0a5:	shr    $0x28,%rdx
  40a0a9:	and    $0x7fffff,%rdx
  40a0b0:	cmp    $0x10002,%rdx
  40a0b7:	sete   %dl
  40a0ba:	movzbl %dl,%edx
  40a0bd:	mov    %ecx,%r8d
  40a0c0:	or     %edx,%r8d
  40a0c3:	xor    $0x1,%r8d
  40a0c7:	jne    40a1d8 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x5f8>
  40a0cd:	or     %edx,%ecx
  40a0cf:	jne    40a0e5 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x505>
  40a0d1:	mov    $0x4,%esi
  40a0d6:	callq  432730 <p111_rt_fail>
  40a0db:	mov    $0x0,%eax
  40a0e0:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  40a0e5:	mov    %rax,%rcx
  40a0e8:	mov    %rsi,%rax
  40a0eb:	shr    $0x28,%rax
  40a0ef:	and    $0xffff,%rax
  40a0f5:	cmp    $0x18,%rax
  40a0f9:	je     40a1c5 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x5e5>
  40a0ff:	cmp    $0x19,%rax
  40a103:	sete   %cl
  40a106:	movzbl %cl,%ecx
  40a109:	je     40a11f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x53f>
  40a10b:	mov    $0x4,%esi
  40a110:	callq  432730 <p111_rt_fail>
  40a115:	mov    $0x0,%eax
  40a11a:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  40a11f:	mov    %rsi,%rax
  40a122:	shr    $0x38,%rax
  40a126:	and    $0x7f,%rax
  40a12a:	cmp    $0x2,%rax
  40a12e:	sete   %al
  40a131:	movzbl %al,%eax
  40a134:	test   %eax,%ecx
  40a136:	jne    40a157 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x577>
  40a138:	mov    $0x2,%r8d
  40a13e:	mov    $0x19,%ecx
  40a143:	lea    -0x800(%rbp),%rdx
  40a14a:	mov    %rdi,%rbx
  40a14d:	callq  4369d0 <p118_rt_borrow_fields>
  40a152:	mov    %rbx,%rdi
  40a155:	jmp    40a1aa <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x5ca>
  40a157:	mov    (%rdi),%rcx
  40a15a:	movabs $0xffffffffff,%rax
  40a164:	and    %rsi,%rax
  40a167:	mov    %rsi,%rdx
  40a16a:	shr    $0x3f,%rdx
  40a16e:	cmp    $0x0,%rdx
  40a172:	je     40a18f <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x5af>
  40a174:	cs cs mov %rax,%rdx
  40a179:	shl    $0x3,%rdx
  40a17d:	mov    (%rdx,%rcx,1),%eax
  40a180:	mov    0x4(%rdx,%rcx,1),%edx
  40a184:	shl    $0x20,%rdx
  40a188:	or     %rdx,%rax
  40a18b:	shr    $0x18,%rax
  40a18f:	shl    $0x3,%rax
  40a193:	mov    (%rax,%rcx,1),%rdx
  40a197:	mov    %rdx,-0x800(%rbp)
  40a19e:	mov    0x8(%rax,%rcx,1),%rax
  40a1a3:	mov    %rax,-0x7f8(%rbp)
  40a1aa:	mov    $0x0,%ecx
  40a1af:	lea    -0x800(%rbp),%rdx
  40a1b6:	mov    $0x1,%esi
  40a1bb:	callq  4338d0 <p111_rt_special_ctor>
  40a1c0:	jmpq   40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  40a1c5:	mov    %rcx,%rax
  40a1c8:	mov    %eax,%eax
  40a1ca:	cmp    $0x54,%rax
  40a1ce:	sete   %al
  40a1d1:	movzbl %al,%eax
  40a1d4:	mov    %eax,%eax
  40a1d6:	jmp    40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  40a1d8:	mov    $0x0,%ecx
  40a1dd:	lea    -0x800(%rbp),%rdx
  40a1e4:	mov    $0x1,%esi
  40a1e9:	callq  4338d0 <p111_rt_special_ctor>
  40a1ee:	jmp    40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  40a1f0:	mov    $0x0,%ecx
  40a1f5:	lea    -0x800(%rbp),%rdx
  40a1fc:	mov    $0x1,%esi
  40a201:	callq  4338d0 <p111_rt_special_ctor>
  40a206:	jmp    40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  40a208:	cs cs mov $0x0,%ecx
  40a20f:	lea    -0x800(%rbp),%rdx
  40a216:	mov    $0x1,%esi
  40a21b:	callq  4338d0 <p111_rt_special_ctor>
  40a220:	jmp    40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  40a222:	mov    $0x0,%ecx
  40a227:	lea    -0x800(%rbp),%rdx
  40a22e:	mov    $0x1,%esi
  40a233:	callq  4338d0 <p111_rt_special_ctor>
  40a238:	jmp    40a250 <p113d_FID_36_112_49_49_56_98_111_114_114_111_119_46_114_101_97_100_46_112_49_51_55_113_95_105_115_95_97_100_116_+0x670>
  40a23a:	mov    $0x0,%ecx
  40a23f:	lea    -0x800(%rbp),%rdx
  40a246:	mov    $0x1,%esi
  40a24b:	callq  4338d0 <p111_rt_special_ctor>
  40a250:	pop    %r12
  40a252:	pop    %rbx
  40a253:	leaveq 
  40a254:	retq   

Disassembly of section .fini:
