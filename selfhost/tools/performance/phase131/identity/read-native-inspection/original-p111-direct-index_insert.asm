
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-original-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041abe0 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_>:
  41abe0:	f3 0f 1e fa          	endbr64 
  41abe4:	55                   	push   %rbp
  41abe5:	48 89 e5             	mov    %rsp,%rbp
  41abe8:	48 81 ec 38 18 00 00 	sub    $0x1838,%rsp
  41abef:	53                   	push   %rbx
  41abf0:	41 54                	push   %r12
  41abf2:	41 55                	push   %r13
  41abf4:	41 56                	push   %r14
  41abf6:	41 57                	push   %r15
  41abf8:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  41abfc:	4c 8b 6f 30          	mov    0x30(%rdi),%r13
  41ac00:	4c 8b 67 38          	mov    0x38(%rdi),%r12
  41ac04:	48 8b 5f 40          	mov    0x40(%rdi),%rbx
  41ac08:	48 89 f0             	mov    %rsi,%rax
  41ac0b:	48 c1 e8 28          	shr    $0x28,%rax
  41ac0f:	48 25 ff ff 00 00    	and    $0xffff,%rax
  41ac15:	48 3d 99 00 00 00    	cmp    $0x99,%rax
  41ac1b:	0f 94 c1             	sete   %cl
  41ac1e:	0f b6 c9             	movzbl %cl,%ecx
  41ac21:	83 f9 00             	cmp    $0x0,%ecx
  41ac24:	0f 85 67 05 00 00    	jne    41b191 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x5b1>
  41ac2a:	48 3d 9a 00 00 00    	cmp    $0x9a,%rax
  41ac30:	0f 94 c1             	sete   %cl
  41ac33:	0f b6 c9             	movzbl %cl,%ecx
  41ac36:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  41ac3b:	49 89 de             	mov    %rbx,%r14
  41ac3e:	49 21 d6             	and    %rdx,%r14
  41ac41:	4c 89 75 f8          	mov    %r14,-0x8(%rbp)
  41ac45:	49 83 fe 00          	cmp    $0x0,%r14
  41ac49:	41 0f 94 c6          	sete   %r14b
  41ac4d:	45 0f b6 f6          	movzbl %r14b,%r14d
  41ac51:	44 89 75 dc          	mov    %r14d,-0x24(%rbp)
  41ac55:	83 f9 00             	cmp    $0x0,%ecx
  41ac58:	0f 85 7e 03 00 00    	jne    41afdc <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x3fc>
  41ac5e:	66 90                	xchg   %ax,%ax
  41ac60:	48 3d 9b 00 00 00    	cmp    $0x9b,%rax
  41ac66:	0f 84 87 00 00 00    	je     41acf3 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x113>
  41ac6c:	48 89 9d d0 e7 ff ff 	mov    %rbx,-0x1830(%rbp)
  41ac73:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41ac77:	48 89 18             	mov    %rbx,(%rax)
  41ac7a:	48 c7 40 08 f8 01 00 	movq   $0x1f8,0x8(%rax)
  41ac81:	00 
  41ac82:	48 83 c0 10          	add    $0x10,%rax
  41ac86:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41ac8a:	4c 89 a5 d0 e7 ff ff 	mov    %r12,-0x1830(%rbp)
  41ac91:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41ac95:	4c 89 20             	mov    %r12,(%rax)
  41ac98:	48 c7 40 08 f9 01 00 	movq   $0x1f9,0x8(%rax)
  41ac9f:	00 
  41aca0:	48 83 c0 10          	add    $0x10,%rax
  41aca4:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41aca8:	4c 89 ad d0 e7 ff ff 	mov    %r13,-0x1830(%rbp)
  41acaf:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41acb3:	4c 89 28             	mov    %r13,(%rax)
  41acb6:	48 c7 40 08 fa 01 00 	movq   $0x1fa,0x8(%rax)
  41acbd:	00 
  41acbe:	48 83 c0 10          	add    $0x10,%rax
  41acc2:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41acc6:	48 89 b5 d0 e7 ff ff 	mov    %rsi,-0x1830(%rbp)
  41accd:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41acd1:	48 89 30             	mov    %rsi,(%rax)
  41acd4:	48 c7 40 08 fb 01 00 	movq   $0x1fb,0x8(%rax)
  41acdb:	00 
  41acdc:	48 83 c0 10          	add    $0x10,%rax
  41ace0:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41ace4:	be 04 00 00 00       	mov    $0x4,%esi
  41ace9:	e8 62 a8 00 00       	callq  425550 <p111_rt_fail>
  41acee:	e9 81 05 00 00       	jmpq   41b274 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41acf3:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41acfa:	49 89 fe             	mov    %rdi,%r14
  41acfd:	e8 3e fd 00 00       	callq  42aa40 <p125_rt_take4>
  41ad02:	4c 89 f7             	mov    %r14,%rdi
  41ad05:	4c 8b bd d0 e7 ff ff 	mov    -0x1830(%rbp),%r15
  41ad0c:	4c 89 7d e0          	mov    %r15,-0x20(%rbp)
  41ad10:	48 8b b5 d8 e7 ff ff 	mov    -0x1828(%rbp),%rsi
  41ad17:	4c 8b b5 e0 e7 ff ff 	mov    -0x1820(%rbp),%r14
  41ad1e:	4c 89 75 e8          	mov    %r14,-0x18(%rbp)
  41ad22:	4d 89 e6             	mov    %r12,%r14
  41ad25:	4c 8b a5 e8 e7 ff ff 	mov    -0x1818(%rbp),%r12
  41ad2c:	4c 89 65 f0          	mov    %r12,-0x10(%rbp)
  41ad30:	49 89 fc             	mov    %rdi,%r12
  41ad33:	e8 f8 9f 00 00       	callq  424d30 <p111_rt_keep>
  41ad38:	4c 89 f9             	mov    %r15,%rcx
  41ad3b:	4c 89 e7             	mov    %r12,%rdi
  41ad3e:	4c 8b 7d e8          	mov    -0x18(%rbp),%r15
  41ad42:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  41ad47:	48 21 c2             	and    %rax,%rdx
  41ad4a:	48 83 fa 00          	cmp    $0x0,%rdx
  41ad4e:	49 89 c4             	mov    %rax,%r12
  41ad51:	0f 94 c0             	sete   %al
  41ad54:	0f b6 c0             	movzbl %al,%eax
  41ad57:	48 83 f8 01          	cmp    $0x1,%rax
  41ad5b:	0f 94 c2             	sete   %dl
  41ad5e:	0f b6 d2             	movzbl %dl,%edx
  41ad61:	48 89 c6             	mov    %rax,%rsi
  41ad64:	48 c1 ee 28          	shr    $0x28,%rsi
  41ad68:	48 81 e6 ff ff 7f 00 	and    $0x7fffff,%rsi
  41ad6f:	48 81 fe 02 00 01 00 	cmp    $0x10002,%rsi
  41ad76:	40 0f 94 c6          	sete   %sil
  41ad7a:	40 0f b6 f6          	movzbl %sil,%esi
  41ad7e:	09 f2                	or     %esi,%edx
  41ad80:	0f 85 b0 01 00 00    	jne    41af36 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x356>
  41ad86:	83 f2 01             	xor    $0x1,%edx
  41ad89:	75 7f                	jne    41ae0a <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x22a>
  41ad8b:	49 89 ce             	mov    %rcx,%r14
  41ad8e:	89 c3                	mov    %eax,%ebx
  41ad90:	4c 89 ee             	mov    %r13,%rsi
  41ad93:	49 89 fd             	mov    %rdi,%r13
  41ad96:	e8 25 a0 00 00       	callq  424dc0 <p111_rt_sink>
  41ad9b:	4c 89 f1             	mov    %r14,%rcx
  41ad9e:	4c 89 ef             	mov    %r13,%rdi
  41ada1:	4c 8b 75 f0          	mov    -0x10(%rbp),%r14
  41ada5:	48 89 ce             	mov    %rcx,%rsi
  41ada8:	49 89 fd             	mov    %rdi,%r13
  41adab:	e8 10 a0 00 00       	callq  424dc0 <p111_rt_sink>
  41adb0:	4c 89 ef             	mov    %r13,%rdi
  41adb3:	4c 89 e6             	mov    %r12,%rsi
  41adb6:	49 89 fc             	mov    %rdi,%r12
  41adb9:	e8 02 a0 00 00       	callq  424dc0 <p111_rt_sink>
  41adbe:	4c 89 e7             	mov    %r12,%rdi
  41adc1:	4c 89 fe             	mov    %r15,%rsi
  41adc4:	49 89 fc             	mov    %rdi,%r12
  41adc7:	e8 f4 9f 00 00       	callq  424dc0 <p111_rt_sink>
  41adcc:	4c 89 e7             	mov    %r12,%rdi
  41adcf:	4c 89 f6             	mov    %r14,%rsi
  41add2:	49 89 fc             	mov    %rdi,%r12
  41add5:	e8 e6 9f 00 00       	callq  424dc0 <p111_rt_sink>
  41adda:	4c 89 e7             	mov    %r12,%rdi
  41addd:	48 89 9d d0 e7 ff ff 	mov    %rbx,-0x1830(%rbp)
  41ade4:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41ade8:	48 89 18             	mov    %rbx,(%rax)
  41adeb:	48 c7 40 08 f7 01 00 	movq   $0x1f7,0x8(%rax)
  41adf2:	00 
  41adf3:	48 83 c0 10          	add    $0x10,%rax
  41adf7:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41adfb:	be 04 00 00 00       	mov    $0x4,%esi
  41ae00:	e8 4b a7 00 00       	callq  425550 <p111_rt_fail>
  41ae05:	e9 6a 04 00 00       	jmpq   41b274 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41ae0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  41ae0f:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41ae16:	be 00 00 00 00       	mov    $0x0,%esi
  41ae1b:	49 89 ff             	mov    %rdi,%r15
  41ae1e:	e8 0d a0 00 00       	callq  424e30 <p111_rt_ctor>
  41ae23:	4c 89 ff             	mov    %r15,%rdi
  41ae26:	48 89 c6             	mov    %rax,%rsi
  41ae29:	49 89 ff             	mov    %rdi,%r15
  41ae2c:	e8 8f 9f 00 00       	callq  424dc0 <p111_rt_sink>
  41ae31:	4c 89 ff             	mov    %r15,%rdi
  41ae34:	4c 89 e0             	mov    %r12,%rax
  41ae37:	4c 8b 7d e0          	mov    -0x20(%rbp),%r15
  41ae3b:	48 89 c6             	mov    %rax,%rsi
  41ae3e:	49 89 fc             	mov    %rdi,%r12
  41ae41:	e8 ea 9e 00 00       	callq  424d30 <p111_rt_keep>
  41ae46:	4c 89 f9             	mov    %r15,%rcx
  41ae49:	4c 89 f2             	mov    %r14,%rdx
  41ae4c:	4c 89 e7             	mov    %r12,%rdi
  41ae4f:	49 89 c4             	mov    %rax,%r12
  41ae52:	4c 8b 75 f0          	mov    -0x10(%rbp),%r14
  41ae56:	4c 8b 7d e8          	mov    -0x18(%rbp),%r15
  41ae5a:	8b 75 dc             	mov    -0x24(%rbp),%esi
  41ae5d:	48 89 d8             	mov    %rbx,%rax
  41ae60:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  41ae64:	4c 89 ad d0 e7 ff ff 	mov    %r13,-0x1830(%rbp)
  41ae6b:	48 89 95 d8 e7 ff ff 	mov    %rdx,-0x1828(%rbp)
  41ae72:	48 89 85 e0 e7 ff ff 	mov    %rax,-0x1820(%rbp)
  41ae79:	48 89 8d e8 e7 ff ff 	mov    %rcx,-0x1818(%rbp)
  41ae80:	4c 89 a5 f0 e7 ff ff 	mov    %r12,-0x1810(%rbp)
  41ae87:	4c 89 bd f8 e7 ff ff 	mov    %r15,-0x1808(%rbp)
  41ae8e:	4c 89 b5 00 e8 ff ff 	mov    %r14,-0x1800(%rbp)
  41ae95:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41ae99:	4c 89 28             	mov    %r13,(%rax)
  41ae9c:	48 8b 8d d8 e7 ff ff 	mov    -0x1828(%rbp),%rcx
  41aea3:	48 89 48 08          	mov    %rcx,0x8(%rax)
  41aea7:	48 8b 8d e0 e7 ff ff 	mov    -0x1820(%rbp),%rcx
  41aeae:	48 89 48 10          	mov    %rcx,0x10(%rax)
  41aeb2:	48 8b 8d e8 e7 ff ff 	mov    -0x1818(%rbp),%rcx
  41aeb9:	48 89 48 18          	mov    %rcx,0x18(%rax)
  41aebd:	48 8b 8d f0 e7 ff ff 	mov    -0x1810(%rbp),%rcx
  41aec4:	48 89 48 20          	mov    %rcx,0x20(%rax)
  41aec8:	48 8b 8d f8 e7 ff ff 	mov    -0x1808(%rbp),%rcx
  41aecf:	48 89 48 28          	mov    %rcx,0x28(%rax)
  41aed3:	48 8b 8d 00 e8 ff ff 	mov    -0x1800(%rbp),%rcx
  41aeda:	48 89 48 30          	mov    %rcx,0x30(%rax)
  41aede:	48 c7 40 38 f1 01 00 	movq   $0x1f1,0x38(%rax)
  41aee5:	00 
  41aee6:	48 83 c0 40          	add    $0x40,%rax
  41aeea:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41aeee:	41 89 f7             	mov    %esi,%r15d
  41aef1:	49 89 fd             	mov    %rdi,%r13
  41aef4:	e8 07 1b ff ff       	callq  40ca00 <p112w_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_110_111_116_>
  41aef9:	4c 89 ef             	mov    %r13,%rdi
  41aefc:	48 89 85 d0 f7 ff ff 	mov    %rax,-0x830(%rbp)
  41af03:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  41af08:	4c 21 e0             	and    %r12,%rax
  41af0b:	48 39 c3             	cmp    %rax,%rbx
  41af0e:	0f 92 c0             	setb   %al
  41af11:	0f b6 c0             	movzbl %al,%eax
  41af14:	48 89 85 d8 f7 ff ff 	mov    %rax,-0x828(%rbp)
  41af1b:	b9 02 00 00 00       	mov    $0x2,%ecx
  41af20:	48 8d 95 d0 f7 ff ff 	lea    -0x830(%rbp),%rdx
  41af27:	be cc 01 00 00       	mov    $0x1cc,%esi
  41af2c:	e8 4f a4 00 00       	callq  425380 <p111_rt_jump>
  41af31:	e9 3e 03 00 00       	jmpq   41b274 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41af36:	4d 87 e6             	xchg   %r12,%r14
  41af39:	b9 00 00 00 00       	mov    $0x0,%ecx
  41af3e:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41af45:	be 00 00 00 00       	mov    $0x0,%esi
  41af4a:	49 89 ff             	mov    %rdi,%r15
  41af4d:	e8 de 9e 00 00       	callq  424e30 <p111_rt_ctor>
  41af52:	4c 89 ff             	mov    %r15,%rdi
  41af55:	48 89 c6             	mov    %rax,%rsi
  41af58:	49 89 ff             	mov    %rdi,%r15
  41af5b:	e8 60 9e 00 00       	callq  424dc0 <p111_rt_sink>
  41af60:	4c 89 ff             	mov    %r15,%rdi
  41af63:	4c 89 f0             	mov    %r14,%rax
  41af66:	4c 8b 75 f0          	mov    -0x10(%rbp),%r14
  41af6a:	4c 8b 7d e8          	mov    -0x18(%rbp),%r15
  41af6e:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  41af72:	48 89 8d d0 e7 ff ff 	mov    %rcx,-0x1830(%rbp)
  41af79:	48 89 85 d8 e7 ff ff 	mov    %rax,-0x1828(%rbp)
  41af80:	4c 89 bd e0 e7 ff ff 	mov    %r15,-0x1820(%rbp)
  41af87:	4c 89 b5 e8 e7 ff ff 	mov    %r14,-0x1818(%rbp)
  41af8e:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41af95:	be 9b 00 00 00       	mov    $0x9b,%esi
  41af9a:	49 89 fe             	mov    %rdi,%r14
  41af9d:	e8 ce f9 00 00       	callq  42a970 <p125_rt_ctor4>
  41afa2:	4c 89 f7             	mov    %r14,%rdi
  41afa5:	48 89 85 d0 e7 ff ff 	mov    %rax,-0x1830(%rbp)
  41afac:	4c 89 ad d8 e7 ff ff 	mov    %r13,-0x1828(%rbp)
  41afb3:	4c 89 a5 e0 e7 ff ff 	mov    %r12,-0x1820(%rbp)
  41afba:	48 89 9d e8 e7 ff ff 	mov    %rbx,-0x1818(%rbp)
  41afc1:	b9 04 00 00 00       	mov    $0x4,%ecx
  41afc6:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41afcd:	be d4 01 00 00       	mov    $0x1d4,%esi
  41afd2:	e8 a9 a3 00 00       	callq  425380 <p111_rt_jump>
  41afd7:	e9 98 02 00 00       	jmpq   41b274 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41afdc:	45 89 f7             	mov    %r14d,%r15d
  41afdf:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41afe6:	49 89 fe             	mov    %rdi,%r14
  41afe9:	e8 82 f5 00 00       	callq  42a570 <p125_rt_take2>
  41afee:	44 89 fe             	mov    %r15d,%esi
  41aff1:	4c 89 f7             	mov    %r14,%rdi
  41aff4:	48 8b 85 d0 e7 ff ff 	mov    -0x1830(%rbp),%rax
  41affb:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  41afff:	4c 8b b5 d8 e7 ff ff 	mov    -0x1828(%rbp),%r14
  41b006:	49 89 ff             	mov    %rdi,%r15
  41b009:	e8 f2 19 ff ff       	callq  40ca00 <p112w_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_110_111_116_>
  41b00e:	4c 89 ff             	mov    %r15,%rdi
  41b011:	49 89 c7             	mov    %rax,%r15
  41b014:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  41b018:	49 83 ff 01          	cmp    $0x1,%r15
  41b01c:	0f 94 c1             	sete   %cl
  41b01f:	0f b6 c9             	movzbl %cl,%ecx
  41b022:	4c 89 fa             	mov    %r15,%rdx
  41b025:	48 c1 ea 28          	shr    $0x28,%rdx
  41b029:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  41b030:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  41b037:	0f 94 c2             	sete   %dl
  41b03a:	0f b6 d2             	movzbl %dl,%edx
  41b03d:	09 d1                	or     %edx,%ecx
  41b03f:	89 4d d8             	mov    %ecx,-0x28(%rbp)
  41b042:	83 f9 00             	cmp    $0x0,%ecx
  41b045:	0f 85 bc 00 00 00    	jne    41b107 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x527>
  41b04b:	4c 89 fb             	mov    %r15,%rbx
  41b04e:	48 89 c6             	mov    %rax,%rsi
  41b051:	49 89 ff             	mov    %rdi,%r15
  41b054:	e8 67 9d 00 00       	callq  424dc0 <p111_rt_sink>
  41b059:	4c 89 ff             	mov    %r15,%rdi
  41b05c:	8b 45 d8             	mov    -0x28(%rbp),%eax
  41b05f:	83 f0 01             	xor    $0x1,%eax
  41b062:	75 49                	jne    41b0ad <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x4cd>
  41b064:	4c 89 ee             	mov    %r13,%rsi
  41b067:	49 89 fc             	mov    %rdi,%r12
  41b06a:	e8 51 9d 00 00       	callq  424dc0 <p111_rt_sink>
  41b06f:	4c 89 e7             	mov    %r12,%rdi
  41b072:	4c 89 f6             	mov    %r14,%rsi
  41b075:	49 89 fc             	mov    %rdi,%r12
  41b078:	e8 43 9d 00 00       	callq  424dc0 <p111_rt_sink>
  41b07d:	4c 89 e7             	mov    %r12,%rdi
  41b080:	48 89 9d d0 ef ff ff 	mov    %rbx,-0x1030(%rbp)
  41b087:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41b08b:	48 89 18             	mov    %rbx,(%rax)
  41b08e:	48 c7 40 08 f0 01 00 	movq   $0x1f0,0x8(%rax)
  41b095:	00 
  41b096:	48 83 c0 10          	add    $0x10,%rax
  41b09a:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41b09e:	be 04 00 00 00       	mov    $0x4,%esi
  41b0a3:	e8 a8 a4 00 00       	callq  425550 <p111_rt_fail>
  41b0a8:	e9 c7 01 00 00       	jmpq   41b274 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41b0ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  41b0b2:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b0b9:	be 00 00 00 00       	mov    $0x0,%esi
  41b0be:	48 89 fb             	mov    %rdi,%rbx
  41b0c1:	e8 6a 9d 00 00       	callq  424e30 <p111_rt_ctor>
  41b0c6:	48 89 df             	mov    %rbx,%rdi
  41b0c9:	48 89 c6             	mov    %rax,%rsi
  41b0cc:	48 89 fb             	mov    %rdi,%rbx
  41b0cf:	e8 ec 9c 00 00       	callq  424dc0 <p111_rt_sink>
  41b0d4:	48 89 df             	mov    %rbx,%rdi
  41b0d7:	4c 89 ad d0 ef ff ff 	mov    %r13,-0x1030(%rbp)
  41b0de:	4c 89 a5 d8 ef ff ff 	mov    %r12,-0x1028(%rbp)
  41b0e5:	4c 89 b5 e0 ef ff ff 	mov    %r14,-0x1020(%rbp)
  41b0ec:	b9 03 00 00 00       	mov    $0x3,%ecx
  41b0f1:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b0f8:	be 14 02 00 00       	mov    $0x214,%esi
  41b0fd:	e8 7e a2 00 00       	callq  425380 <p111_rt_jump>
  41b102:	e9 6d 01 00 00       	jmpq   41b274 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41b107:	b9 00 00 00 00       	mov    $0x0,%ecx
  41b10c:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b113:	be 00 00 00 00       	mov    $0x0,%esi
  41b118:	49 89 ff             	mov    %rdi,%r15
  41b11b:	e8 10 9d 00 00       	callq  424e30 <p111_rt_ctor>
  41b120:	4c 89 ff             	mov    %r15,%rdi
  41b123:	48 89 c6             	mov    %rax,%rsi
  41b126:	49 89 ff             	mov    %rdi,%r15
  41b129:	e8 92 9c 00 00       	callq  424dc0 <p111_rt_sink>
  41b12e:	4c 89 ff             	mov    %r15,%rdi
  41b131:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  41b135:	48 89 85 d0 ef ff ff 	mov    %rax,-0x1030(%rbp)
  41b13c:	4c 89 b5 d8 ef ff ff 	mov    %r14,-0x1028(%rbp)
  41b143:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b14a:	be 9a 00 00 00       	mov    $0x9a,%esi
  41b14f:	49 89 fe             	mov    %rdi,%r14
  41b152:	e8 29 f3 00 00       	callq  42a480 <p125_rt_ctor2>
  41b157:	4c 89 f7             	mov    %r14,%rdi
  41b15a:	48 89 85 d0 ef ff ff 	mov    %rax,-0x1030(%rbp)
  41b161:	4c 89 ad d8 ef ff ff 	mov    %r13,-0x1028(%rbp)
  41b168:	4c 89 a5 e0 ef ff ff 	mov    %r12,-0x1020(%rbp)
  41b16f:	48 89 9d e8 ef ff ff 	mov    %rbx,-0x1018(%rbp)
  41b176:	b9 04 00 00 00       	mov    $0x4,%ecx
  41b17b:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b182:	be b3 01 00 00       	mov    $0x1b3,%esi
  41b187:	e8 f4 a1 00 00       	callq  425380 <p111_rt_jump>
  41b18c:	e9 e3 00 00 00       	jmpq   41b274 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41b191:	b9 09 00 00 00       	mov    $0x9,%ecx
  41b196:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41b19d:	49 89 fe             	mov    %rdi,%r14
  41b1a0:	e8 0b 9e 00 00       	callq  424fb0 <p111_rt_take>
  41b1a5:	4c 89 f7             	mov    %r14,%rdi
  41b1a8:	4c 8b b5 d0 e7 ff ff 	mov    -0x1830(%rbp),%r14
  41b1af:	4c 8b 9d d8 e7 ff ff 	mov    -0x1828(%rbp),%r11
  41b1b6:	4c 8b 95 e0 e7 ff ff 	mov    -0x1820(%rbp),%r10
  41b1bd:	4c 8b 8d e8 e7 ff ff 	mov    -0x1818(%rbp),%r9
  41b1c4:	4c 8b 85 f0 e7 ff ff 	mov    -0x1810(%rbp),%r8
  41b1cb:	48 8b b5 f8 e7 ff ff 	mov    -0x1808(%rbp),%rsi
  41b1d2:	48 8b 95 00 e8 ff ff 	mov    -0x1800(%rbp),%rdx
  41b1d9:	48 8b 8d 08 e8 ff ff 	mov    -0x17f8(%rbp),%rcx
  41b1e0:	48 8b 85 10 e8 ff ff 	mov    -0x17f0(%rbp),%rax
  41b1e7:	4c 89 b5 d0 e7 ff ff 	mov    %r14,-0x1830(%rbp)
  41b1ee:	4c 89 9d d8 e7 ff ff 	mov    %r11,-0x1828(%rbp)
  41b1f5:	4c 89 95 e0 e7 ff ff 	mov    %r10,-0x1820(%rbp)
  41b1fc:	4c 89 8d e8 e7 ff ff 	mov    %r9,-0x1818(%rbp)
  41b203:	4c 89 85 f0 e7 ff ff 	mov    %r8,-0x1810(%rbp)
  41b20a:	48 89 b5 f8 e7 ff ff 	mov    %rsi,-0x1808(%rbp)
  41b211:	48 89 95 00 e8 ff ff 	mov    %rdx,-0x1800(%rbp)
  41b218:	48 89 8d 08 e8 ff ff 	mov    %rcx,-0x17f8(%rbp)
  41b21f:	48 89 85 10 e8 ff ff 	mov    %rax,-0x17f0(%rbp)
  41b226:	b9 09 00 00 00       	mov    $0x9,%ecx
  41b22b:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41b232:	be 99 00 00 00       	mov    $0x99,%esi
  41b237:	49 89 fe             	mov    %rdi,%r14
  41b23a:	e8 f1 9b 00 00       	callq  424e30 <p111_rt_ctor>
  41b23f:	4c 89 f7             	mov    %r14,%rdi
  41b242:	48 89 85 d0 e7 ff ff 	mov    %rax,-0x1830(%rbp)
  41b249:	4c 89 ad d8 e7 ff ff 	mov    %r13,-0x1828(%rbp)
  41b250:	4c 89 a5 e0 e7 ff ff 	mov    %r12,-0x1820(%rbp)
  41b257:	48 89 9d e8 e7 ff ff 	mov    %rbx,-0x1818(%rbp)
  41b25e:	b9 04 00 00 00       	mov    $0x4,%ecx
  41b263:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41b26a:	be d4 01 00 00       	mov    $0x1d4,%esi
  41b26f:	e8 0c a1 00 00       	callq  425380 <p111_rt_jump>
  41b274:	41 5f                	pop    %r15
  41b276:	41 5e                	pop    %r14
  41b278:	41 5d                	pop    %r13
  41b27a:	41 5c                	pop    %r12
  41b27c:	5b                   	pop    %rbx
  41b27d:	c9                   	leaveq 
  41b27e:	c3                   	retq   

Disassembly of section .fini:
