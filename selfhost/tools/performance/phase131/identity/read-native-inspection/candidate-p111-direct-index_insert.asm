
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

000000000041ac00 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_>:
  41ac00:	f3 0f 1e fa          	endbr64 
  41ac04:	55                   	push   %rbp
  41ac05:	48 89 e5             	mov    %rsp,%rbp
  41ac08:	48 81 ec 38 18 00 00 	sub    $0x1838,%rsp
  41ac0f:	53                   	push   %rbx
  41ac10:	41 54                	push   %r12
  41ac12:	41 55                	push   %r13
  41ac14:	41 56                	push   %r14
  41ac16:	41 57                	push   %r15
  41ac18:	48 8b 77 28          	mov    0x28(%rdi),%rsi
  41ac1c:	4c 8b 6f 30          	mov    0x30(%rdi),%r13
  41ac20:	4c 8b 67 38          	mov    0x38(%rdi),%r12
  41ac24:	48 8b 5f 40          	mov    0x40(%rdi),%rbx
  41ac28:	48 89 f0             	mov    %rsi,%rax
  41ac2b:	48 c1 e8 28          	shr    $0x28,%rax
  41ac2f:	48 25 ff ff 00 00    	and    $0xffff,%rax
  41ac35:	48 3d 99 00 00 00    	cmp    $0x99,%rax
  41ac3b:	0f 94 c1             	sete   %cl
  41ac3e:	0f b6 c9             	movzbl %cl,%ecx
  41ac41:	83 f9 00             	cmp    $0x0,%ecx
  41ac44:	0f 85 67 05 00 00    	jne    41b1b1 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x5b1>
  41ac4a:	48 3d 9a 00 00 00    	cmp    $0x9a,%rax
  41ac50:	0f 94 c1             	sete   %cl
  41ac53:	0f b6 c9             	movzbl %cl,%ecx
  41ac56:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  41ac5b:	49 89 de             	mov    %rbx,%r14
  41ac5e:	49 21 d6             	and    %rdx,%r14
  41ac61:	4c 89 75 f8          	mov    %r14,-0x8(%rbp)
  41ac65:	49 83 fe 00          	cmp    $0x0,%r14
  41ac69:	41 0f 94 c6          	sete   %r14b
  41ac6d:	45 0f b6 f6          	movzbl %r14b,%r14d
  41ac71:	44 89 75 dc          	mov    %r14d,-0x24(%rbp)
  41ac75:	83 f9 00             	cmp    $0x0,%ecx
  41ac78:	0f 85 7e 03 00 00    	jne    41affc <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x3fc>
  41ac7e:	66 90                	xchg   %ax,%ax
  41ac80:	48 3d 9b 00 00 00    	cmp    $0x9b,%rax
  41ac86:	0f 84 87 00 00 00    	je     41ad13 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x113>
  41ac8c:	48 89 9d d0 e7 ff ff 	mov    %rbx,-0x1830(%rbp)
  41ac93:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41ac97:	48 89 18             	mov    %rbx,(%rax)
  41ac9a:	48 c7 40 08 e2 01 00 	movq   $0x1e2,0x8(%rax)
  41aca1:	00 
  41aca2:	48 83 c0 10          	add    $0x10,%rax
  41aca6:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41acaa:	4c 89 a5 d0 e7 ff ff 	mov    %r12,-0x1830(%rbp)
  41acb1:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41acb5:	4c 89 20             	mov    %r12,(%rax)
  41acb8:	48 c7 40 08 e3 01 00 	movq   $0x1e3,0x8(%rax)
  41acbf:	00 
  41acc0:	48 83 c0 10          	add    $0x10,%rax
  41acc4:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41acc8:	4c 89 ad d0 e7 ff ff 	mov    %r13,-0x1830(%rbp)
  41accf:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41acd3:	4c 89 28             	mov    %r13,(%rax)
  41acd6:	48 c7 40 08 e4 01 00 	movq   $0x1e4,0x8(%rax)
  41acdd:	00 
  41acde:	48 83 c0 10          	add    $0x10,%rax
  41ace2:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41ace6:	48 89 b5 d0 e7 ff ff 	mov    %rsi,-0x1830(%rbp)
  41aced:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41acf1:	48 89 30             	mov    %rsi,(%rax)
  41acf4:	48 c7 40 08 e5 01 00 	movq   $0x1e5,0x8(%rax)
  41acfb:	00 
  41acfc:	48 83 c0 10          	add    $0x10,%rax
  41ad00:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41ad04:	be 04 00 00 00       	mov    $0x4,%esi
  41ad09:	e8 62 a8 00 00       	callq  425570 <p111_rt_fail>
  41ad0e:	e9 81 05 00 00       	jmpq   41b294 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41ad13:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41ad1a:	49 89 fe             	mov    %rdi,%r14
  41ad1d:	e8 3e fd 00 00       	callq  42aa60 <p125_rt_take4>
  41ad22:	4c 89 f7             	mov    %r14,%rdi
  41ad25:	4c 8b bd d0 e7 ff ff 	mov    -0x1830(%rbp),%r15
  41ad2c:	4c 89 7d e0          	mov    %r15,-0x20(%rbp)
  41ad30:	48 8b b5 d8 e7 ff ff 	mov    -0x1828(%rbp),%rsi
  41ad37:	4c 8b b5 e0 e7 ff ff 	mov    -0x1820(%rbp),%r14
  41ad3e:	4c 89 75 e8          	mov    %r14,-0x18(%rbp)
  41ad42:	4d 89 e6             	mov    %r12,%r14
  41ad45:	4c 8b a5 e8 e7 ff ff 	mov    -0x1818(%rbp),%r12
  41ad4c:	4c 89 65 f0          	mov    %r12,-0x10(%rbp)
  41ad50:	49 89 fc             	mov    %rdi,%r12
  41ad53:	e8 f8 9f 00 00       	callq  424d50 <p111_rt_keep>
  41ad58:	4c 89 f9             	mov    %r15,%rcx
  41ad5b:	4c 89 e7             	mov    %r12,%rdi
  41ad5e:	4c 8b 7d e8          	mov    -0x18(%rbp),%r15
  41ad62:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  41ad67:	48 21 c2             	and    %rax,%rdx
  41ad6a:	48 83 fa 00          	cmp    $0x0,%rdx
  41ad6e:	49 89 c4             	mov    %rax,%r12
  41ad71:	0f 94 c0             	sete   %al
  41ad74:	0f b6 c0             	movzbl %al,%eax
  41ad77:	48 83 f8 01          	cmp    $0x1,%rax
  41ad7b:	0f 94 c2             	sete   %dl
  41ad7e:	0f b6 d2             	movzbl %dl,%edx
  41ad81:	48 89 c6             	mov    %rax,%rsi
  41ad84:	48 c1 ee 28          	shr    $0x28,%rsi
  41ad88:	48 81 e6 ff ff 7f 00 	and    $0x7fffff,%rsi
  41ad8f:	48 81 fe 02 00 01 00 	cmp    $0x10002,%rsi
  41ad96:	40 0f 94 c6          	sete   %sil
  41ad9a:	40 0f b6 f6          	movzbl %sil,%esi
  41ad9e:	09 f2                	or     %esi,%edx
  41ada0:	0f 85 b0 01 00 00    	jne    41af56 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x356>
  41ada6:	83 f2 01             	xor    $0x1,%edx
  41ada9:	75 7f                	jne    41ae2a <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x22a>
  41adab:	49 89 ce             	mov    %rcx,%r14
  41adae:	89 c3                	mov    %eax,%ebx
  41adb0:	4c 89 ee             	mov    %r13,%rsi
  41adb3:	49 89 fd             	mov    %rdi,%r13
  41adb6:	e8 25 a0 00 00       	callq  424de0 <p111_rt_sink>
  41adbb:	4c 89 f1             	mov    %r14,%rcx
  41adbe:	4c 89 ef             	mov    %r13,%rdi
  41adc1:	4c 8b 75 f0          	mov    -0x10(%rbp),%r14
  41adc5:	48 89 ce             	mov    %rcx,%rsi
  41adc8:	49 89 fd             	mov    %rdi,%r13
  41adcb:	e8 10 a0 00 00       	callq  424de0 <p111_rt_sink>
  41add0:	4c 89 ef             	mov    %r13,%rdi
  41add3:	4c 89 e6             	mov    %r12,%rsi
  41add6:	49 89 fc             	mov    %rdi,%r12
  41add9:	e8 02 a0 00 00       	callq  424de0 <p111_rt_sink>
  41adde:	4c 89 e7             	mov    %r12,%rdi
  41ade1:	4c 89 fe             	mov    %r15,%rsi
  41ade4:	49 89 fc             	mov    %rdi,%r12
  41ade7:	e8 f4 9f 00 00       	callq  424de0 <p111_rt_sink>
  41adec:	4c 89 e7             	mov    %r12,%rdi
  41adef:	4c 89 f6             	mov    %r14,%rsi
  41adf2:	49 89 fc             	mov    %rdi,%r12
  41adf5:	e8 e6 9f 00 00       	callq  424de0 <p111_rt_sink>
  41adfa:	4c 89 e7             	mov    %r12,%rdi
  41adfd:	48 89 9d d0 e7 ff ff 	mov    %rbx,-0x1830(%rbp)
  41ae04:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41ae08:	48 89 18             	mov    %rbx,(%rax)
  41ae0b:	48 c7 40 08 e1 01 00 	movq   $0x1e1,0x8(%rax)
  41ae12:	00 
  41ae13:	48 83 c0 10          	add    $0x10,%rax
  41ae17:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41ae1b:	be 04 00 00 00       	mov    $0x4,%esi
  41ae20:	e8 4b a7 00 00       	callq  425570 <p111_rt_fail>
  41ae25:	e9 6a 04 00 00       	jmpq   41b294 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41ae2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  41ae2f:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41ae36:	be 00 00 00 00       	mov    $0x0,%esi
  41ae3b:	49 89 ff             	mov    %rdi,%r15
  41ae3e:	e8 0d a0 00 00       	callq  424e50 <p111_rt_ctor>
  41ae43:	4c 89 ff             	mov    %r15,%rdi
  41ae46:	48 89 c6             	mov    %rax,%rsi
  41ae49:	49 89 ff             	mov    %rdi,%r15
  41ae4c:	e8 8f 9f 00 00       	callq  424de0 <p111_rt_sink>
  41ae51:	4c 89 ff             	mov    %r15,%rdi
  41ae54:	4c 89 e0             	mov    %r12,%rax
  41ae57:	4c 8b 7d e0          	mov    -0x20(%rbp),%r15
  41ae5b:	48 89 c6             	mov    %rax,%rsi
  41ae5e:	49 89 fc             	mov    %rdi,%r12
  41ae61:	e8 ea 9e 00 00       	callq  424d50 <p111_rt_keep>
  41ae66:	4c 89 f9             	mov    %r15,%rcx
  41ae69:	4c 89 f2             	mov    %r14,%rdx
  41ae6c:	4c 89 e7             	mov    %r12,%rdi
  41ae6f:	49 89 c4             	mov    %rax,%r12
  41ae72:	4c 8b 75 f0          	mov    -0x10(%rbp),%r14
  41ae76:	4c 8b 7d e8          	mov    -0x18(%rbp),%r15
  41ae7a:	8b 75 dc             	mov    -0x24(%rbp),%esi
  41ae7d:	48 89 d8             	mov    %rbx,%rax
  41ae80:	48 8b 5d f8          	mov    -0x8(%rbp),%rbx
  41ae84:	4c 89 ad d0 e7 ff ff 	mov    %r13,-0x1830(%rbp)
  41ae8b:	48 89 95 d8 e7 ff ff 	mov    %rdx,-0x1828(%rbp)
  41ae92:	48 89 85 e0 e7 ff ff 	mov    %rax,-0x1820(%rbp)
  41ae99:	48 89 8d e8 e7 ff ff 	mov    %rcx,-0x1818(%rbp)
  41aea0:	4c 89 a5 f0 e7 ff ff 	mov    %r12,-0x1810(%rbp)
  41aea7:	4c 89 bd f8 e7 ff ff 	mov    %r15,-0x1808(%rbp)
  41aeae:	4c 89 b5 00 e8 ff ff 	mov    %r14,-0x1800(%rbp)
  41aeb5:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41aeb9:	4c 89 28             	mov    %r13,(%rax)
  41aebc:	48 8b 8d d8 e7 ff ff 	mov    -0x1828(%rbp),%rcx
  41aec3:	48 89 48 08          	mov    %rcx,0x8(%rax)
  41aec7:	48 8b 8d e0 e7 ff ff 	mov    -0x1820(%rbp),%rcx
  41aece:	48 89 48 10          	mov    %rcx,0x10(%rax)
  41aed2:	48 8b 8d e8 e7 ff ff 	mov    -0x1818(%rbp),%rcx
  41aed9:	48 89 48 18          	mov    %rcx,0x18(%rax)
  41aedd:	48 8b 8d f0 e7 ff ff 	mov    -0x1810(%rbp),%rcx
  41aee4:	48 89 48 20          	mov    %rcx,0x20(%rax)
  41aee8:	48 8b 8d f8 e7 ff ff 	mov    -0x1808(%rbp),%rcx
  41aeef:	48 89 48 28          	mov    %rcx,0x28(%rax)
  41aef3:	48 8b 8d 00 e8 ff ff 	mov    -0x1800(%rbp),%rcx
  41aefa:	48 89 48 30          	mov    %rcx,0x30(%rax)
  41aefe:	48 c7 40 38 db 01 00 	movq   $0x1db,0x38(%rax)
  41af05:	00 
  41af06:	48 83 c0 40          	add    $0x40,%rax
  41af0a:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41af0e:	41 89 f7             	mov    %esi,%r15d
  41af11:	49 89 fd             	mov    %rdi,%r13
  41af14:	e8 b7 2a ff ff       	callq  40d9d0 <p112w_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_110_111_116_>
  41af19:	4c 89 ef             	mov    %r13,%rdi
  41af1c:	48 89 85 d0 f7 ff ff 	mov    %rax,-0x830(%rbp)
  41af23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  41af28:	4c 21 e0             	and    %r12,%rax
  41af2b:	48 39 c3             	cmp    %rax,%rbx
  41af2e:	0f 92 c0             	setb   %al
  41af31:	0f b6 c0             	movzbl %al,%eax
  41af34:	48 89 85 d8 f7 ff ff 	mov    %rax,-0x828(%rbp)
  41af3b:	b9 02 00 00 00       	mov    $0x2,%ecx
  41af40:	48 8d 95 d0 f7 ff ff 	lea    -0x830(%rbp),%rdx
  41af47:	be b6 01 00 00       	mov    $0x1b6,%esi
  41af4c:	e8 4f a4 00 00       	callq  4253a0 <p111_rt_jump>
  41af51:	e9 3e 03 00 00       	jmpq   41b294 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41af56:	4d 87 e6             	xchg   %r12,%r14
  41af59:	b9 00 00 00 00       	mov    $0x0,%ecx
  41af5e:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41af65:	be 00 00 00 00       	mov    $0x0,%esi
  41af6a:	49 89 ff             	mov    %rdi,%r15
  41af6d:	e8 de 9e 00 00       	callq  424e50 <p111_rt_ctor>
  41af72:	4c 89 ff             	mov    %r15,%rdi
  41af75:	48 89 c6             	mov    %rax,%rsi
  41af78:	49 89 ff             	mov    %rdi,%r15
  41af7b:	e8 60 9e 00 00       	callq  424de0 <p111_rt_sink>
  41af80:	4c 89 ff             	mov    %r15,%rdi
  41af83:	4c 89 f0             	mov    %r14,%rax
  41af86:	4c 8b 75 f0          	mov    -0x10(%rbp),%r14
  41af8a:	4c 8b 7d e8          	mov    -0x18(%rbp),%r15
  41af8e:	48 8b 4d e0          	mov    -0x20(%rbp),%rcx
  41af92:	48 89 8d d0 e7 ff ff 	mov    %rcx,-0x1830(%rbp)
  41af99:	48 89 85 d8 e7 ff ff 	mov    %rax,-0x1828(%rbp)
  41afa0:	4c 89 bd e0 e7 ff ff 	mov    %r15,-0x1820(%rbp)
  41afa7:	4c 89 b5 e8 e7 ff ff 	mov    %r14,-0x1818(%rbp)
  41afae:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41afb5:	be 9b 00 00 00       	mov    $0x9b,%esi
  41afba:	49 89 fe             	mov    %rdi,%r14
  41afbd:	e8 ce f9 00 00       	callq  42a990 <p125_rt_ctor4>
  41afc2:	4c 89 f7             	mov    %r14,%rdi
  41afc5:	48 89 85 d0 e7 ff ff 	mov    %rax,-0x1830(%rbp)
  41afcc:	4c 89 ad d8 e7 ff ff 	mov    %r13,-0x1828(%rbp)
  41afd3:	4c 89 a5 e0 e7 ff ff 	mov    %r12,-0x1820(%rbp)
  41afda:	48 89 9d e8 e7 ff ff 	mov    %rbx,-0x1818(%rbp)
  41afe1:	b9 04 00 00 00       	mov    $0x4,%ecx
  41afe6:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41afed:	be be 01 00 00       	mov    $0x1be,%esi
  41aff2:	e8 a9 a3 00 00       	callq  4253a0 <p111_rt_jump>
  41aff7:	e9 98 02 00 00       	jmpq   41b294 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41affc:	45 89 f7             	mov    %r14d,%r15d
  41afff:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41b006:	49 89 fe             	mov    %rdi,%r14
  41b009:	e8 82 f5 00 00       	callq  42a590 <p125_rt_take2>
  41b00e:	44 89 fe             	mov    %r15d,%esi
  41b011:	4c 89 f7             	mov    %r14,%rdi
  41b014:	48 8b 85 d0 e7 ff ff 	mov    -0x1830(%rbp),%rax
  41b01b:	48 89 45 d0          	mov    %rax,-0x30(%rbp)
  41b01f:	4c 8b b5 d8 e7 ff ff 	mov    -0x1828(%rbp),%r14
  41b026:	49 89 ff             	mov    %rdi,%r15
  41b029:	e8 a2 29 ff ff       	callq  40d9d0 <p112w_FID_36_100_105_114_101_99_116_46_66_111_111_108_46_110_111_116_>
  41b02e:	4c 89 ff             	mov    %r15,%rdi
  41b031:	49 89 c7             	mov    %rax,%r15
  41b034:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  41b038:	49 83 ff 01          	cmp    $0x1,%r15
  41b03c:	0f 94 c1             	sete   %cl
  41b03f:	0f b6 c9             	movzbl %cl,%ecx
  41b042:	4c 89 fa             	mov    %r15,%rdx
  41b045:	48 c1 ea 28          	shr    $0x28,%rdx
  41b049:	48 81 e2 ff ff 7f 00 	and    $0x7fffff,%rdx
  41b050:	48 81 fa 02 00 01 00 	cmp    $0x10002,%rdx
  41b057:	0f 94 c2             	sete   %dl
  41b05a:	0f b6 d2             	movzbl %dl,%edx
  41b05d:	09 d1                	or     %edx,%ecx
  41b05f:	89 4d d8             	mov    %ecx,-0x28(%rbp)
  41b062:	83 f9 00             	cmp    $0x0,%ecx
  41b065:	0f 85 bc 00 00 00    	jne    41b127 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x527>
  41b06b:	4c 89 fb             	mov    %r15,%rbx
  41b06e:	48 89 c6             	mov    %rax,%rsi
  41b071:	49 89 ff             	mov    %rdi,%r15
  41b074:	e8 67 9d 00 00       	callq  424de0 <p111_rt_sink>
  41b079:	4c 89 ff             	mov    %r15,%rdi
  41b07c:	8b 45 d8             	mov    -0x28(%rbp),%eax
  41b07f:	83 f0 01             	xor    $0x1,%eax
  41b082:	75 49                	jne    41b0cd <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x4cd>
  41b084:	4c 89 ee             	mov    %r13,%rsi
  41b087:	49 89 fc             	mov    %rdi,%r12
  41b08a:	e8 51 9d 00 00       	callq  424de0 <p111_rt_sink>
  41b08f:	4c 89 e7             	mov    %r12,%rdi
  41b092:	4c 89 f6             	mov    %r14,%rsi
  41b095:	49 89 fc             	mov    %rdi,%r12
  41b098:	e8 43 9d 00 00       	callq  424de0 <p111_rt_sink>
  41b09d:	4c 89 e7             	mov    %r12,%rdi
  41b0a0:	48 89 9d d0 ef ff ff 	mov    %rbx,-0x1030(%rbp)
  41b0a7:	48 8b 47 10          	mov    0x10(%rdi),%rax
  41b0ab:	48 89 18             	mov    %rbx,(%rax)
  41b0ae:	48 c7 40 08 da 01 00 	movq   $0x1da,0x8(%rax)
  41b0b5:	00 
  41b0b6:	48 83 c0 10          	add    $0x10,%rax
  41b0ba:	48 89 47 10          	mov    %rax,0x10(%rdi)
  41b0be:	be 04 00 00 00       	mov    $0x4,%esi
  41b0c3:	e8 a8 a4 00 00       	callq  425570 <p111_rt_fail>
  41b0c8:	e9 c7 01 00 00       	jmpq   41b294 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41b0cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  41b0d2:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b0d9:	be 00 00 00 00       	mov    $0x0,%esi
  41b0de:	48 89 fb             	mov    %rdi,%rbx
  41b0e1:	e8 6a 9d 00 00       	callq  424e50 <p111_rt_ctor>
  41b0e6:	48 89 df             	mov    %rbx,%rdi
  41b0e9:	48 89 c6             	mov    %rax,%rsi
  41b0ec:	48 89 fb             	mov    %rdi,%rbx
  41b0ef:	e8 ec 9c 00 00       	callq  424de0 <p111_rt_sink>
  41b0f4:	48 89 df             	mov    %rbx,%rdi
  41b0f7:	4c 89 ad d0 ef ff ff 	mov    %r13,-0x1030(%rbp)
  41b0fe:	4c 89 a5 d8 ef ff ff 	mov    %r12,-0x1028(%rbp)
  41b105:	4c 89 b5 e0 ef ff ff 	mov    %r14,-0x1020(%rbp)
  41b10c:	b9 03 00 00 00       	mov    $0x3,%ecx
  41b111:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b118:	be fe 01 00 00       	mov    $0x1fe,%esi
  41b11d:	e8 7e a2 00 00       	callq  4253a0 <p111_rt_jump>
  41b122:	e9 6d 01 00 00       	jmpq   41b294 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41b127:	b9 00 00 00 00       	mov    $0x0,%ecx
  41b12c:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b133:	be 00 00 00 00       	mov    $0x0,%esi
  41b138:	49 89 ff             	mov    %rdi,%r15
  41b13b:	e8 10 9d 00 00       	callq  424e50 <p111_rt_ctor>
  41b140:	4c 89 ff             	mov    %r15,%rdi
  41b143:	48 89 c6             	mov    %rax,%rsi
  41b146:	49 89 ff             	mov    %rdi,%r15
  41b149:	e8 92 9c 00 00       	callq  424de0 <p111_rt_sink>
  41b14e:	4c 89 ff             	mov    %r15,%rdi
  41b151:	48 8b 45 d0          	mov    -0x30(%rbp),%rax
  41b155:	48 89 85 d0 ef ff ff 	mov    %rax,-0x1030(%rbp)
  41b15c:	4c 89 b5 d8 ef ff ff 	mov    %r14,-0x1028(%rbp)
  41b163:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b16a:	be 9a 00 00 00       	mov    $0x9a,%esi
  41b16f:	49 89 fe             	mov    %rdi,%r14
  41b172:	e8 29 f3 00 00       	callq  42a4a0 <p125_rt_ctor2>
  41b177:	4c 89 f7             	mov    %r14,%rdi
  41b17a:	48 89 85 d0 ef ff ff 	mov    %rax,-0x1030(%rbp)
  41b181:	4c 89 ad d8 ef ff ff 	mov    %r13,-0x1028(%rbp)
  41b188:	4c 89 a5 e0 ef ff ff 	mov    %r12,-0x1020(%rbp)
  41b18f:	48 89 9d e8 ef ff ff 	mov    %rbx,-0x1018(%rbp)
  41b196:	b9 04 00 00 00       	mov    $0x4,%ecx
  41b19b:	48 8d 95 d0 ef ff ff 	lea    -0x1030(%rbp),%rdx
  41b1a2:	be 9d 01 00 00       	mov    $0x19d,%esi
  41b1a7:	e8 f4 a1 00 00       	callq  4253a0 <p111_rt_jump>
  41b1ac:	e9 e3 00 00 00       	jmpq   41b294 <p111_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_105_110_115_101_114_116_+0x694>
  41b1b1:	b9 09 00 00 00       	mov    $0x9,%ecx
  41b1b6:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41b1bd:	49 89 fe             	mov    %rdi,%r14
  41b1c0:	e8 0b 9e 00 00       	callq  424fd0 <p111_rt_take>
  41b1c5:	4c 89 f7             	mov    %r14,%rdi
  41b1c8:	4c 8b b5 d0 e7 ff ff 	mov    -0x1830(%rbp),%r14
  41b1cf:	4c 8b 9d d8 e7 ff ff 	mov    -0x1828(%rbp),%r11
  41b1d6:	4c 8b 95 e0 e7 ff ff 	mov    -0x1820(%rbp),%r10
  41b1dd:	4c 8b 8d e8 e7 ff ff 	mov    -0x1818(%rbp),%r9
  41b1e4:	4c 8b 85 f0 e7 ff ff 	mov    -0x1810(%rbp),%r8
  41b1eb:	48 8b b5 f8 e7 ff ff 	mov    -0x1808(%rbp),%rsi
  41b1f2:	48 8b 95 00 e8 ff ff 	mov    -0x1800(%rbp),%rdx
  41b1f9:	48 8b 8d 08 e8 ff ff 	mov    -0x17f8(%rbp),%rcx
  41b200:	48 8b 85 10 e8 ff ff 	mov    -0x17f0(%rbp),%rax
  41b207:	4c 89 b5 d0 e7 ff ff 	mov    %r14,-0x1830(%rbp)
  41b20e:	4c 89 9d d8 e7 ff ff 	mov    %r11,-0x1828(%rbp)
  41b215:	4c 89 95 e0 e7 ff ff 	mov    %r10,-0x1820(%rbp)
  41b21c:	4c 89 8d e8 e7 ff ff 	mov    %r9,-0x1818(%rbp)
  41b223:	4c 89 85 f0 e7 ff ff 	mov    %r8,-0x1810(%rbp)
  41b22a:	48 89 b5 f8 e7 ff ff 	mov    %rsi,-0x1808(%rbp)
  41b231:	48 89 95 00 e8 ff ff 	mov    %rdx,-0x1800(%rbp)
  41b238:	48 89 8d 08 e8 ff ff 	mov    %rcx,-0x17f8(%rbp)
  41b23f:	48 89 85 10 e8 ff ff 	mov    %rax,-0x17f0(%rbp)
  41b246:	b9 09 00 00 00       	mov    $0x9,%ecx
  41b24b:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41b252:	be 99 00 00 00       	mov    $0x99,%esi
  41b257:	49 89 fe             	mov    %rdi,%r14
  41b25a:	e8 f1 9b 00 00       	callq  424e50 <p111_rt_ctor>
  41b25f:	4c 89 f7             	mov    %r14,%rdi
  41b262:	48 89 85 d0 e7 ff ff 	mov    %rax,-0x1830(%rbp)
  41b269:	4c 89 ad d8 e7 ff ff 	mov    %r13,-0x1828(%rbp)
  41b270:	4c 89 a5 e0 e7 ff ff 	mov    %r12,-0x1820(%rbp)
  41b277:	48 89 9d e8 e7 ff ff 	mov    %rbx,-0x1818(%rbp)
  41b27e:	b9 04 00 00 00       	mov    $0x4,%ecx
  41b283:	48 8d 95 d0 e7 ff ff 	lea    -0x1830(%rbp),%rdx
  41b28a:	be be 01 00 00       	mov    $0x1be,%esi
  41b28f:	e8 0c a1 00 00       	callq  4253a0 <p111_rt_jump>
  41b294:	41 5f                	pop    %r15
  41b296:	41 5e                	pop    %r14
  41b298:	41 5d                	pop    %r13
  41b29a:	41 5c                	pop    %r12
  41b29c:	5b                   	pop    %rbx
  41b29d:	c9                   	leaveq 
  41b29e:	c3                   	retq   

Disassembly of section .fini:
