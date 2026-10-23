
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p130-native01-n1/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000049ab30 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_>:
  49ab30:	f3 0f 1e fa          	endbr64 
  49ab34:	55                   	push   %rbp
  49ab35:	48 89 e5             	mov    %rsp,%rbp
  49ab38:	48 81 ec 48 01 00 00 	sub    $0x148,%rsp
  49ab3f:	53                   	push   %rbx
  49ab40:	41 54                	push   %r12
  49ab42:	41 55                	push   %r13
  49ab44:	41 56                	push   %r14
  49ab46:	41 57                	push   %r15
  49ab48:	49 89 d4             	mov    %rdx,%r12
  49ab4b:	48 83 f9 01          	cmp    $0x1,%rcx
  49ab4f:	0f 94 c0             	sete   %al
  49ab52:	0f b6 c0             	movzbl %al,%eax
  49ab55:	48 c1 e9 28          	shr    $0x28,%rcx
  49ab59:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  49ab60:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  49ab67:	0f 94 c1             	sete   %cl
  49ab6a:	0f b6 c9             	movzbl %cl,%ecx
  49ab6d:	89 c3                	mov    %eax,%ebx
  49ab6f:	09 cb                	or     %ecx,%ebx
  49ab71:	0f 85 b6 01 00 00    	jne    49ad2d <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x1fd>
  49ab77:	49 89 fd             	mov    %rdi,%r13
  49ab7a:	e8 c1 c6 94 00       	callq  de7240 <p111_rt_sink>
  49ab7f:	4c 89 ef             	mov    %r13,%rdi
  49ab82:	4c 89 e6             	mov    %r12,%rsi
  49ab85:	49 89 fc             	mov    %rdi,%r12
  49ab88:	e8 b3 c6 94 00       	callq  de7240 <p111_rt_sink>
  49ab8d:	4c 89 e7             	mov    %r12,%rdi
  49ab90:	89 d8                	mov    %ebx,%eax
  49ab92:	83 f0 01             	xor    $0x1,%eax
  49ab95:	75 14                	jne    49abab <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x7b>
  49ab97:	be 04 00 00 00       	mov    $0x4,%esi
  49ab9c:	e8 2f ce 94 00       	callq  de79d0 <p111_rt_fail>
  49aba1:	b8 00 00 00 00       	mov    $0x0,%eax
  49aba6:	e9 8e 03 00 00       	jmpq   49af39 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x409>
  49abab:	48 b8 0a 82 10 03 00 	movabs $0x20019000310820a,%rax
  49abb2:	19 00 02 
  49abb5:	48 89 85 50 ff ff ff 	mov    %rax,-0xb0(%rbp)
  49abbc:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  49abc3:	18 00 01 
  49abc6:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  49abcd:	48 c7 85 60 ff ff ff 	movq   $0x0,-0xa0(%rbp)
  49abd4:	00 00 00 00 
  49abd8:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  49abdf:	00 00 00 00 
  49abe3:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49abea:	11 00 01 
  49abed:	48 89 85 70 ff ff ff 	mov    %rax,-0x90(%rbp)
  49abf4:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49abfb:	11 00 01 
  49abfe:	48 89 85 78 ff ff ff 	mov    %rax,-0x88(%rbp)
  49ac05:	48 c7 45 80 00 00 00 	movq   $0x0,-0x80(%rbp)
  49ac0c:	00 
  49ac0d:	48 c7 45 88 00 00 00 	movq   $0x0,-0x78(%rbp)
  49ac14:	00 
  49ac15:	b9 08 00 00 00       	mov    $0x8,%ecx
  49ac1a:	48 8d 95 50 ff ff ff 	lea    -0xb0(%rbp),%rdx
  49ac21:	be 96 00 00 00       	mov    $0x96,%esi
  49ac26:	48 89 fb             	mov    %rdi,%rbx
  49ac29:	e8 82 c6 94 00       	callq  de72b0 <p111_rt_ctor>
  49ac2e:	48 89 df             	mov    %rbx,%rdi
  49ac31:	48 89 c3             	mov    %rax,%rbx
  49ac34:	48 b8 0a 82 10 03 00 	movabs $0x20019000310820a,%rax
  49ac3b:	19 00 02 
  49ac3e:	48 89 45 90          	mov    %rax,-0x70(%rbp)
  49ac42:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  49ac49:	18 00 01 
  49ac4c:	48 89 45 98          	mov    %rax,-0x68(%rbp)
  49ac50:	48 c7 45 a0 00 00 00 	movq   $0x0,-0x60(%rbp)
  49ac57:	00 
  49ac58:	48 c7 45 a8 00 00 00 	movq   $0x0,-0x58(%rbp)
  49ac5f:	00 
  49ac60:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49ac67:	11 00 01 
  49ac6a:	48 89 45 b0          	mov    %rax,-0x50(%rbp)
  49ac6e:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49ac75:	11 00 01 
  49ac78:	48 89 45 b8          	mov    %rax,-0x48(%rbp)
  49ac7c:	48 c7 45 c0 00 00 00 	movq   $0x0,-0x40(%rbp)
  49ac83:	00 
  49ac84:	48 c7 45 c8 00 00 00 	movq   $0x0,-0x38(%rbp)
  49ac8b:	00 
  49ac8c:	b9 08 00 00 00       	mov    $0x8,%ecx
  49ac91:	48 8d 55 90          	lea    -0x70(%rbp),%rdx
  49ac95:	be 96 00 00 00       	mov    $0x96,%esi
  49ac9a:	49 89 fc             	mov    %rdi,%r12
  49ac9d:	e8 0e c6 94 00       	callq  de72b0 <p111_rt_ctor>
  49aca2:	4c 89 e7             	mov    %r12,%rdi
  49aca5:	48 b9 00 00 00 00 00 	movabs $0x100180000000000,%rcx
  49acac:	18 00 01 
  49acaf:	48 89 8d 08 ff ff ff 	mov    %rcx,-0xf8(%rbp)
  49acb6:	48 b9 0a 82 10 03 00 	movabs $0x20019000310820a,%rcx
  49acbd:	19 00 02 
  49acc0:	48 89 8d 10 ff ff ff 	mov    %rcx,-0xf0(%rbp)
  49acc7:	48 c7 85 18 ff ff ff 	movq   $0x0,-0xe8(%rbp)
  49acce:	00 00 00 00 
  49acd2:	48 c7 85 20 ff ff ff 	movq   $0x0,-0xe0(%rbp)
  49acd9:	00 00 00 00 
  49acdd:	48 89 9d 28 ff ff ff 	mov    %rbx,-0xd8(%rbp)
  49ace4:	48 89 85 30 ff ff ff 	mov    %rax,-0xd0(%rbp)
  49aceb:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49acf2:	11 00 01 
  49acf5:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  49acfc:	48 c7 85 40 ff ff ff 	movq   $0x0,-0xc0(%rbp)
  49ad03:	00 00 00 00 
  49ad07:	48 c7 85 48 ff ff ff 	movq   $0x0,-0xb8(%rbp)
  49ad0e:	00 00 00 00 
  49ad12:	b9 09 00 00 00       	mov    $0x9,%ecx
  49ad17:	48 8d 95 08 ff ff ff 	lea    -0xf8(%rbp),%rdx
  49ad1e:	be 99 00 00 00       	mov    $0x99,%esi
  49ad23:	e8 88 c5 94 00       	callq  de72b0 <p111_rt_ctor>
  49ad28:	e9 0c 02 00 00       	jmpq   49af39 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x409>
  49ad2d:	48 89 f0             	mov    %rsi,%rax
  49ad30:	48 c1 e8 28          	shr    $0x28,%rax
  49ad34:	48 25 ff ff 00 00    	and    $0xffff,%rax
  49ad3a:	48 3d 99 00 00 00    	cmp    $0x99,%rax
  49ad40:	0f 94 c1             	sete   %cl
  49ad43:	0f b6 c9             	movzbl %cl,%ecx
  49ad46:	83 f9 00             	cmp    $0x0,%ecx
  49ad49:	0f 85 ee 00 00 00    	jne    49ae3d <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x30d>
  49ad4f:	48 3d 9a 00 00 00    	cmp    $0x9a,%rax
  49ad55:	0f 84 bb 00 00 00    	je     49ae16 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x2e6>
  49ad5b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
  49ad60:	48 3d 9b 00 00 00    	cmp    $0x9b,%rax
  49ad66:	74 1d                	je     49ad85 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x255>
  49ad68:	be 04 00 00 00       	mov    $0x4,%esi
  49ad6d:	48 89 fb             	mov    %rdi,%rbx
  49ad70:	e8 5b cc 94 00       	callq  de79d0 <p111_rt_fail>
  49ad75:	4c 89 e2             	mov    %r12,%rdx
  49ad78:	48 89 df             	mov    %rbx,%rdi
  49ad7b:	be 00 00 00 00       	mov    $0x0,%esi
  49ad80:	e9 af 01 00 00       	jmpq   49af34 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x404>
  49ad85:	4c 89 e2             	mov    %r12,%rdx
  49ad88:	49 89 d4             	mov    %rdx,%r12
  49ad8b:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  49ad92:	48 89 fb             	mov    %rdi,%rbx
  49ad95:	e8 26 21 95 00       	callq  decec0 <p125_rt_take4>
  49ad9a:	4c 89 e2             	mov    %r12,%rdx
  49ad9d:	48 89 df             	mov    %rbx,%rdi
  49ada0:	48 8b 9d d0 fe ff ff 	mov    -0x130(%rbp),%rbx
  49ada7:	48 8b 85 d8 fe ff ff 	mov    -0x128(%rbp),%rax
  49adae:	48 89 85 c0 fe ff ff 	mov    %rax,-0x140(%rbp)
  49adb5:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  49adbc:	11 00 01 
  49adbf:	48 89 85 c8 fe ff ff 	mov    %rax,-0x138(%rbp)
  49adc6:	49 89 d5             	mov    %rdx,%r13
  49adc9:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  49add0:	be 12 00 00 00       	mov    $0x12,%esi
  49add5:	49 89 fc             	mov    %rdi,%r12
  49add8:	e8 23 1b 95 00       	callq  dec900 <p125_rt_ctor2>
  49addd:	4c 89 ea             	mov    %r13,%rdx
  49ade0:	4c 89 e7             	mov    %r12,%rdi
  49ade3:	48 89 9d c0 fe ff ff 	mov    %rbx,-0x140(%rbp)
  49adea:	48 89 85 c8 fe ff ff 	mov    %rax,-0x138(%rbp)
  49adf1:	49 89 d4             	mov    %rdx,%r12
  49adf4:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  49adfb:	be 12 00 00 00       	mov    $0x12,%esi
  49ae00:	48 89 fb             	mov    %rdi,%rbx
  49ae03:	e8 f8 1a 95 00       	callq  dec900 <p125_rt_ctor2>
  49ae08:	4c 89 e2             	mov    %r12,%rdx
  49ae0b:	48 89 df             	mov    %rbx,%rdi
  49ae0e:	48 89 c6             	mov    %rax,%rsi
  49ae11:	e9 1e 01 00 00       	jmpq   49af34 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x404>
  49ae16:	4c 89 e2             	mov    %r12,%rdx
  49ae19:	49 89 d4             	mov    %rdx,%r12
  49ae1c:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  49ae23:	48 89 fb             	mov    %rdi,%rbx
  49ae26:	e8 c5 1b 95 00       	callq  dec9f0 <p125_rt_take2>
  49ae2b:	4c 89 e2             	mov    %r12,%rdx
  49ae2e:	48 89 df             	mov    %rbx,%rdi
  49ae31:	48 8b b5 c8 fe ff ff 	mov    -0x138(%rbp),%rsi
  49ae38:	e9 f7 00 00 00       	jmpq   49af34 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_102_105_110_100_95_104_97_115_104_+0x404>
  49ae3d:	4c 89 e2             	mov    %r12,%rdx
  49ae40:	b9 09 00 00 00       	mov    $0x9,%ecx
  49ae45:	49 89 d5             	mov    %rdx,%r13
  49ae48:	48 8d 95 c0 fe ff ff 	lea    -0x140(%rbp),%rdx
  49ae4f:	48 89 fb             	mov    %rdi,%rbx
  49ae52:	e8 d9 c5 94 00       	callq  de7430 <p111_rt_take>
  49ae57:	48 89 df             	mov    %rbx,%rdi
  49ae5a:	48 8b b5 c0 fe ff ff 	mov    -0x140(%rbp),%rsi
  49ae61:	4c 8b bd c8 fe ff ff 	mov    -0x138(%rbp),%r15
  49ae68:	4c 8b b5 d0 fe ff ff 	mov    -0x130(%rbp),%r14
  49ae6f:	4c 8b a5 d8 fe ff ff 	mov    -0x128(%rbp),%r12
  49ae76:	48 8b 9d e0 fe ff ff 	mov    -0x120(%rbp),%rbx
  49ae7d:	48 89 5d f0          	mov    %rbx,-0x10(%rbp)
  49ae81:	48 8b 9d e8 fe ff ff 	mov    -0x118(%rbp),%rbx
  49ae88:	48 89 5d e8          	mov    %rbx,-0x18(%rbp)
  49ae8c:	48 8b 9d f0 fe ff ff 	mov    -0x110(%rbp),%rbx
  49ae93:	48 89 5d e0          	mov    %rbx,-0x20(%rbp)
  49ae97:	48 8b 9d f8 fe ff ff 	mov    -0x108(%rbp),%rbx
  49ae9e:	48 89 5d d8          	mov    %rbx,-0x28(%rbp)
  49aea2:	48 8b 9d 00 ff ff ff 	mov    -0x100(%rbp),%rbx
  49aea9:	48 89 5d d0          	mov    %rbx,-0x30(%rbp)
  49aead:	48 89 fb             	mov    %rdi,%rbx
  49aeb0:	e8 8b c3 94 00       	callq  de7240 <p111_rt_sink>
  49aeb5:	4c 89 fe             	mov    %r15,%rsi
  49aeb8:	48 89 df             	mov    %rbx,%rdi
  49aebb:	4c 8b 7d f0          	mov    -0x10(%rbp),%r15
  49aebf:	48 89 fb             	mov    %rdi,%rbx
  49aec2:	e8 79 c3 94 00       	callq  de7240 <p111_rt_sink>
  49aec7:	4c 89 f6             	mov    %r14,%rsi
  49aeca:	48 89 df             	mov    %rbx,%rdi
  49aecd:	4c 8b 75 e8          	mov    -0x18(%rbp),%r14
  49aed1:	48 89 fb             	mov    %rdi,%rbx
  49aed4:	e8 67 c3 94 00       	callq  de7240 <p111_rt_sink>
  49aed9:	4c 89 e6             	mov    %r12,%rsi
  49aedc:	48 89 df             	mov    %rbx,%rdi
  49aedf:	4c 8b 65 e0          	mov    -0x20(%rbp),%r12
  49aee3:	48 89 fb             	mov    %rdi,%rbx
  49aee6:	e8 55 c3 94 00       	callq  de7240 <p111_rt_sink>
  49aeeb:	4c 89 fe             	mov    %r15,%rsi
  49aeee:	48 89 df             	mov    %rbx,%rdi
  49aef1:	4c 8b 7d d8          	mov    -0x28(%rbp),%r15
  49aef5:	48 89 fb             	mov    %rdi,%rbx
  49aef8:	e8 43 c3 94 00       	callq  de7240 <p111_rt_sink>
  49aefd:	4c 89 f6             	mov    %r14,%rsi
  49af00:	48 89 df             	mov    %rbx,%rdi
  49af03:	4c 8b 75 d0          	mov    -0x30(%rbp),%r14
  49af07:	48 89 fb             	mov    %rdi,%rbx
  49af0a:	e8 31 c3 94 00       	callq  de7240 <p111_rt_sink>
  49af0f:	4c 89 fe             	mov    %r15,%rsi
  49af12:	48 89 df             	mov    %rbx,%rdi
  49af15:	48 89 fb             	mov    %rdi,%rbx
  49af18:	e8 23 c3 94 00       	callq  de7240 <p111_rt_sink>
  49af1d:	4c 89 f6             	mov    %r14,%rsi
  49af20:	48 89 df             	mov    %rbx,%rdi
  49af23:	48 89 fb             	mov    %rdi,%rbx
  49af26:	e8 15 c3 94 00       	callq  de7240 <p111_rt_sink>
  49af2b:	4c 89 ea             	mov    %r13,%rdx
  49af2e:	4c 89 e6             	mov    %r12,%rsi
  49af31:	48 89 df             	mov    %rbx,%rdi
  49af34:	e8 47 f6 ff ff       	callq  49a580 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>
  49af39:	41 5f                	pop    %r15
  49af3b:	41 5e                	pop    %r14
  49af3d:	41 5d                	pop    %r13
  49af3f:	41 5c                	pop    %r12
  49af41:	5b                   	pop    %rbx
  49af42:	c9                   	leaveq 
  49af43:	c3                   	retq   

Disassembly of section .fini:
