
/home/ai/bend2/build/publish/bend/selfhost/build/phase111/p131-read-lookup01-identity-candidate-build/program:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .text:

0000000000407d40 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_>:
  407d40:	f3 0f 1e fa          	endbr64 
  407d44:	55                   	push   %rbp
  407d45:	48 89 e5             	mov    %rsp,%rbp
  407d48:	48 81 ec 58 09 00 00 	sub    $0x958,%rsp
  407d4f:	53                   	push   %rbx
  407d50:	41 54                	push   %r12
  407d52:	41 55                	push   %r13
  407d54:	41 56                	push   %r14
  407d56:	41 57                	push   %r15
  407d58:	48 89 d3             	mov    %rdx,%rbx
  407d5b:	48 89 da             	mov    %rbx,%rdx
  407d5e:	66 90                	xchg   %ax,%ax
  407d60:	48 89 f0             	mov    %rsi,%rax
  407d63:	48 c1 e8 28          	shr    $0x28,%rax
  407d67:	48 25 ff ff 00 00    	and    $0xffff,%rax
  407d6d:	48 83 f8 11          	cmp    $0x11,%rax
  407d71:	0f 84 b7 03 00 00    	je     40812e <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x3ee>
  407d77:	66 0f 1f 84 00 00 00 	nopw   0x0(%rax,%rax,1)
  407d7e:	00 00 
  407d80:	48 83 f8 12          	cmp    $0x12,%rax
  407d84:	0f 85 90 03 00 00    	jne    40811a <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x3da>
  407d8a:	49 89 d4             	mov    %rdx,%r12
  407d8d:	48 8d 95 b0 f6 ff ff 	lea    -0x950(%rbp),%rdx
  407d94:	48 89 fb             	mov    %rdi,%rbx
  407d97:	e8 f4 27 02 00       	callq  42a590 <p125_rt_take2>
  407d9c:	4c 89 e2             	mov    %r12,%rdx
  407d9f:	48 89 df             	mov    %rbx,%rdi
  407da2:	48 8b b5 b0 f6 ff ff 	mov    -0x950(%rbp),%rsi
  407da9:	4c 8b ad b8 f6 ff ff 	mov    -0x948(%rbp),%r13
  407db0:	4c 89 6d c0          	mov    %r13,-0x40(%rbp)
  407db4:	49 89 f4             	mov    %rsi,%r12
  407db7:	48 89 d6             	mov    %rdx,%rsi
  407dba:	48 89 fb             	mov    %rdi,%rbx
  407dbd:	e8 8e cf 01 00       	callq  424d50 <p111_rt_keep>
  407dc2:	4c 89 e6             	mov    %r12,%rsi
  407dc5:	48 89 df             	mov    %rbx,%rdi
  407dc8:	49 89 c5             	mov    %rax,%r13
  407dcb:	48 89 fb             	mov    %rdi,%rbx
  407dce:	e8 7d cf 01 00       	callq  424d50 <p111_rt_keep>
  407dd3:	48 89 df             	mov    %rbx,%rdi
  407dd6:	48 89 c6             	mov    %rax,%rsi
  407dd9:	48 89 f0             	mov    %rsi,%rax
  407ddc:	48 c1 e8 28          	shr    $0x28,%rax
  407de0:	48 25 ff ff 00 00    	and    $0xffff,%rax
  407de6:	48 3d 99 00 00 00    	cmp    $0x99,%rax
  407dec:	0f 84 d3 00 00 00    	je     407ec5 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x185>
  407df2:	48 3d 9a 00 00 00    	cmp    $0x9a,%rax
  407df8:	0f 84 7e 00 00 00    	je     407e7c <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x13c>
  407dfe:	66 90                	xchg   %ax,%ax
  407e00:	48 3d 9b 00 00 00    	cmp    $0x9b,%rax
  407e06:	74 20                	je     407e28 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0xe8>
  407e08:	49 89 f4             	mov    %rsi,%r12
  407e0b:	be 04 00 00 00       	mov    $0x4,%esi
  407e10:	48 89 fb             	mov    %rdi,%rbx
  407e13:	e8 58 d7 01 00       	callq  425570 <p111_rt_fail>
  407e18:	4c 89 ea             	mov    %r13,%rdx
  407e1b:	48 89 df             	mov    %rbx,%rdi
  407e1e:	4c 89 e6             	mov    %r12,%rsi
  407e21:	bb 00 00 00 00       	mov    $0x0,%ebx
  407e26:	eb 4f                	jmp    407e77 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x137>
  407e28:	49 89 f4             	mov    %rsi,%r12
  407e2b:	4c 89 ea             	mov    %r13,%rdx
  407e2e:	49 89 d5             	mov    %rdx,%r13
  407e31:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  407e38:	4c 89 e6             	mov    %r12,%rsi
  407e3b:	48 89 fb             	mov    %rdi,%rbx
  407e3e:	e8 1d 2c 02 00       	callq  42aa60 <p125_rt_take4>
  407e43:	48 89 df             	mov    %rbx,%rdi
  407e46:	48 8b 75 88          	mov    -0x78(%rbp),%rsi
  407e4a:	4c 8b 75 90          	mov    -0x70(%rbp),%r14
  407e4e:	48 89 fb             	mov    %rdi,%rbx
  407e51:	e8 8a cf 01 00       	callq  424de0 <p111_rt_sink>
  407e56:	4c 89 f6             	mov    %r14,%rsi
  407e59:	48 89 df             	mov    %rbx,%rdi
  407e5c:	48 89 fb             	mov    %rdi,%rbx
  407e5f:	e8 7c cf 01 00       	callq  424de0 <p111_rt_sink>
  407e64:	4c 89 ea             	mov    %r13,%rdx
  407e67:	4c 89 e6             	mov    %r12,%rsi
  407e6a:	48 89 df             	mov    %rbx,%rdi
  407e6d:	48 bb 00 00 00 00 00 	movabs $0x100180000000000,%rbx
  407e74:	18 00 01 
  407e77:	49 89 f7             	mov    %rsi,%r15
  407e7a:	eb 3e                	jmp    407eba <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x17a>
  407e7c:	2e 4c 89 ea          	cs mov %r13,%rdx
  407e80:	49 89 d4             	mov    %rdx,%r12
  407e83:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  407e8a:	49 89 f5             	mov    %rsi,%r13
  407e8d:	48 89 fb             	mov    %rdi,%rbx
  407e90:	e8 fb 26 02 00       	callq  42a590 <p125_rt_take2>
  407e95:	4c 89 ee             	mov    %r13,%rsi
  407e98:	48 89 df             	mov    %rbx,%rdi
  407e9b:	49 89 f7             	mov    %rsi,%r15
  407e9e:	48 8b 75 80          	mov    -0x80(%rbp),%rsi
  407ea2:	48 89 fb             	mov    %rdi,%rbx
  407ea5:	e8 36 cf 01 00       	callq  424de0 <p111_rt_sink>
  407eaa:	4c 89 e2             	mov    %r12,%rdx
  407ead:	48 89 df             	mov    %rbx,%rdi
  407eb0:	48 bb 00 00 00 00 00 	movabs $0x100180000000000,%rbx
  407eb7:	18 00 01 
  407eba:	48 89 de             	mov    %rbx,%rsi
  407ebd:	49 89 d5             	mov    %rdx,%r13
  407ec0:	e9 eb 00 00 00       	jmpq   407fb0 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x270>
  407ec5:	2e 49 89 f7          	cs mov %rsi,%r15
  407ec9:	4c 89 ea             	mov    %r13,%rdx
  407ecc:	b9 09 00 00 00       	mov    $0x9,%ecx
  407ed1:	49 89 d5             	mov    %rdx,%r13
  407ed4:	48 8d 95 78 ff ff ff 	lea    -0x88(%rbp),%rdx
  407edb:	4c 89 fe             	mov    %r15,%rsi
  407ede:	48 89 fb             	mov    %rdi,%rbx
  407ee1:	e8 ea d0 01 00       	callq  424fd0 <p111_rt_take>
  407ee6:	48 89 df             	mov    %rbx,%rdi
  407ee9:	4c 8b a5 78 ff ff ff 	mov    -0x88(%rbp),%r12
  407ef0:	48 8b 75 80          	mov    -0x80(%rbp),%rsi
  407ef4:	4c 8b 75 88          	mov    -0x78(%rbp),%r14
  407ef8:	48 8b 5d 90          	mov    -0x70(%rbp),%rbx
  407efc:	48 89 5d f0          	mov    %rbx,-0x10(%rbp)
  407f00:	48 8b 5d 98          	mov    -0x68(%rbp),%rbx
  407f04:	48 89 5d e8          	mov    %rbx,-0x18(%rbp)
  407f08:	48 8b 5d a0          	mov    -0x60(%rbp),%rbx
  407f0c:	48 89 5d e0          	mov    %rbx,-0x20(%rbp)
  407f10:	48 8b 5d a8          	mov    -0x58(%rbp),%rbx
  407f14:	48 89 5d d8          	mov    %rbx,-0x28(%rbp)
  407f18:	48 8b 5d b0          	mov    -0x50(%rbp),%rbx
  407f1c:	48 89 5d d0          	mov    %rbx,-0x30(%rbp)
  407f20:	48 8b 5d b8          	mov    -0x48(%rbp),%rbx
  407f24:	48 89 5d c8          	mov    %rbx,-0x38(%rbp)
  407f28:	48 89 fb             	mov    %rdi,%rbx
  407f2b:	e8 b0 ce 01 00       	callq  424de0 <p111_rt_sink>
  407f30:	4c 89 f6             	mov    %r14,%rsi
  407f33:	48 89 df             	mov    %rbx,%rdi
  407f36:	4c 8b 75 f0          	mov    -0x10(%rbp),%r14
  407f3a:	48 89 fb             	mov    %rdi,%rbx
  407f3d:	e8 9e ce 01 00       	callq  424de0 <p111_rt_sink>
  407f42:	4c 89 f6             	mov    %r14,%rsi
  407f45:	48 89 df             	mov    %rbx,%rdi
  407f48:	4c 8b 75 e8          	mov    -0x18(%rbp),%r14
  407f4c:	48 89 fb             	mov    %rdi,%rbx
  407f4f:	e8 8c ce 01 00       	callq  424de0 <p111_rt_sink>
  407f54:	4c 89 f6             	mov    %r14,%rsi
  407f57:	48 89 df             	mov    %rbx,%rdi
  407f5a:	4c 8b 75 e0          	mov    -0x20(%rbp),%r14
  407f5e:	48 89 fb             	mov    %rdi,%rbx
  407f61:	e8 7a ce 01 00       	callq  424de0 <p111_rt_sink>
  407f66:	4c 89 f6             	mov    %r14,%rsi
  407f69:	48 89 df             	mov    %rbx,%rdi
  407f6c:	4c 8b 75 d8          	mov    -0x28(%rbp),%r14
  407f70:	48 89 fb             	mov    %rdi,%rbx
  407f73:	e8 68 ce 01 00       	callq  424de0 <p111_rt_sink>
  407f78:	4c 89 f6             	mov    %r14,%rsi
  407f7b:	48 89 df             	mov    %rbx,%rdi
  407f7e:	4c 8b 75 d0          	mov    -0x30(%rbp),%r14
  407f82:	48 89 fb             	mov    %rdi,%rbx
  407f85:	e8 56 ce 01 00       	callq  424de0 <p111_rt_sink>
  407f8a:	4c 89 f6             	mov    %r14,%rsi
  407f8d:	48 89 df             	mov    %rbx,%rdi
  407f90:	4c 8b 75 c8          	mov    -0x38(%rbp),%r14
  407f94:	48 89 fb             	mov    %rdi,%rbx
  407f97:	e8 44 ce 01 00       	callq  424de0 <p111_rt_sink>
  407f9c:	4c 89 f6             	mov    %r14,%rsi
  407f9f:	48 89 df             	mov    %rbx,%rdi
  407fa2:	48 89 fb             	mov    %rdi,%rbx
  407fa5:	e8 36 ce 01 00       	callq  424de0 <p111_rt_sink>
  407faa:	4c 89 e6             	mov    %r12,%rsi
  407fad:	48 89 df             	mov    %rbx,%rdi
  407fb0:	48 89 fb             	mov    %rdi,%rbx
  407fb3:	e8 98 cd 01 00       	callq  424d50 <p111_rt_keep>
  407fb8:	48 89 df             	mov    %rbx,%rdi
  407fbb:	48 89 c6             	mov    %rax,%rsi
  407fbe:	49 89 f4             	mov    %rsi,%r12
  407fc1:	4c 89 ee             	mov    %r13,%rsi
  407fc4:	48 89 fb             	mov    %rdi,%rbx
  407fc7:	e8 84 cd 01 00       	callq  424d50 <p111_rt_keep>
  407fcc:	4c 89 ea             	mov    %r13,%rdx
  407fcf:	4c 89 e6             	mov    %r12,%rsi
  407fd2:	48 89 df             	mov    %rbx,%rdi
  407fd5:	49 89 c5             	mov    %rax,%r13
  407fd8:	b9 01 00 00 00       	mov    $0x1,%ecx
  407fdd:	49 89 d6             	mov    %rdx,%r14
  407fe0:	4c 89 ea             	mov    %r13,%rdx
  407fe3:	49 89 f4             	mov    %rsi,%r12
  407fe6:	48 89 fb             	mov    %rdi,%rbx
  407fe9:	e8 12 dc ff ff       	callq  405c00 <p113d_FID_36_100_105_114_101_99_116_46_112_56_56_95_115_116_114_105_110_103_95_101_113_95_103_111_>
  407fee:	4c 89 e6             	mov    %r12,%rsi
  407ff1:	48 89 df             	mov    %rbx,%rdi
  407ff4:	48 89 c3             	mov    %rax,%rbx
  407ff7:	49 89 fc             	mov    %rdi,%r12
  407ffa:	e8 e1 cd 01 00       	callq  424de0 <p111_rt_sink>
  407fff:	4c 89 ee             	mov    %r13,%rsi
  408002:	4c 89 e7             	mov    %r12,%rdi
  408005:	4c 8b 6d c0          	mov    -0x40(%rbp),%r13
  408009:	49 89 fc             	mov    %rdi,%r12
  40800c:	e8 cf cd 01 00       	callq  424de0 <p111_rt_sink>
  408011:	4c 89 fe             	mov    %r15,%rsi
  408014:	4c 89 e7             	mov    %r12,%rdi
  408017:	48 83 fb 01          	cmp    $0x1,%rbx
  40801b:	0f 94 c0             	sete   %al
  40801e:	0f b6 c0             	movzbl %al,%eax
  408021:	48 89 d9             	mov    %rbx,%rcx
  408024:	48 c1 e9 28          	shr    $0x28,%rcx
  408028:	48 81 e1 ff ff 7f 00 	and    $0x7fffff,%rcx
  40802f:	48 81 f9 02 00 01 00 	cmp    $0x10002,%rcx
  408036:	0f 94 c1             	sete   %cl
  408039:	0f b6 c9             	movzbl %cl,%ecx
  40803c:	89 c3                	mov    %eax,%ebx
  40803e:	09 cb                	or     %ecx,%ebx
  408040:	0f 85 89 00 00 00    	jne    4080cf <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x38f>
  408046:	49 89 fc             	mov    %rdi,%r12
  408049:	e8 92 cd 01 00       	callq  424de0 <p111_rt_sink>
  40804e:	4c 89 f2             	mov    %r14,%rdx
  408051:	4c 89 ee             	mov    %r13,%rsi
  408054:	4c 89 e7             	mov    %r12,%rdi
  408057:	89 d8                	mov    %ebx,%eax
  408059:	83 f0 01             	xor    $0x1,%eax
  40805c:	74 3b                	je     408099 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x359>
  40805e:	b9 00 00 00 00       	mov    $0x0,%ecx
  408063:	49 89 d5             	mov    %rdx,%r13
  408066:	48 8d 95 b0 f6 ff ff 	lea    -0x950(%rbp),%rdx
  40806d:	49 89 f4             	mov    %rsi,%r12
  408070:	be 00 00 00 00       	mov    $0x0,%esi
  408075:	48 89 fb             	mov    %rdi,%rbx
  408078:	e8 d3 cd 01 00       	callq  424e50 <p111_rt_ctor>
  40807d:	48 89 df             	mov    %rbx,%rdi
  408080:	48 89 c6             	mov    %rax,%rsi
  408083:	48 89 fb             	mov    %rdi,%rbx
  408086:	e8 55 cd 01 00       	callq  424de0 <p111_rt_sink>
  40808b:	4c 89 ea             	mov    %r13,%rdx
  40808e:	4c 89 e6             	mov    %r12,%rsi
  408091:	48 89 df             	mov    %rbx,%rdi
  408094:	e9 c7 fc ff ff       	jmpq   407d60 <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x20>
  408099:	49 89 f4             	mov    %rsi,%r12
  40809c:	48 89 d6             	mov    %rdx,%rsi
  40809f:	48 89 fb             	mov    %rdi,%rbx
  4080a2:	e8 39 cd 01 00       	callq  424de0 <p111_rt_sink>
  4080a7:	4c 89 e6             	mov    %r12,%rsi
  4080aa:	48 89 df             	mov    %rbx,%rdi
  4080ad:	49 89 f5             	mov    %rsi,%r13
  4080b0:	48 89 fb             	mov    %rdi,%rbx
  4080b3:	e8 28 cd 01 00       	callq  424de0 <p111_rt_sink>
  4080b8:	48 89 df             	mov    %rbx,%rdi
  4080bb:	be 04 00 00 00       	mov    $0x4,%esi
  4080c0:	e8 ab d4 01 00       	callq  425570 <p111_rt_fail>
  4080c5:	b8 00 00 00 00       	mov    $0x0,%eax
  4080ca:	e9 0b 02 00 00       	jmpq   4082da <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x59a>
  4080cf:	48 89 f3             	mov    %rsi,%rbx
  4080d2:	4c 89 f6             	mov    %r14,%rsi
  4080d5:	49 89 fc             	mov    %rdi,%r12
  4080d8:	e8 03 cd 01 00       	callq  424de0 <p111_rt_sink>
  4080dd:	4c 89 ee             	mov    %r13,%rsi
  4080e0:	4c 89 e7             	mov    %r12,%rdi
  4080e3:	49 89 fc             	mov    %rdi,%r12
  4080e6:	e8 f5 cc 01 00       	callq  424de0 <p111_rt_sink>
  4080eb:	4c 89 e7             	mov    %r12,%rdi
  4080ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  4080f3:	48 8d 95 b0 f6 ff ff 	lea    -0x950(%rbp),%rdx
  4080fa:	be 00 00 00 00       	mov    $0x0,%esi
  4080ff:	49 89 fc             	mov    %rdi,%r12
  408102:	e8 49 cd 01 00       	callq  424e50 <p111_rt_ctor>
  408107:	4c 89 e7             	mov    %r12,%rdi
  40810a:	48 89 c6             	mov    %rax,%rsi
  40810d:	e8 ce cc 01 00       	callq  424de0 <p111_rt_sink>
  408112:	48 89 d8             	mov    %rbx,%rax
  408115:	e9 c0 01 00 00       	jmpq   4082da <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x59a>
  40811a:	be 04 00 00 00       	mov    $0x4,%esi
  40811f:	e8 4c d4 01 00       	callq  425570 <p111_rt_fail>
  408124:	b8 00 00 00 00       	mov    $0x0,%eax
  408129:	e9 ac 01 00 00       	jmpq   4082da <p113d_FID_36_100_105_114_101_99_116_46_105_110_100_101_120_95_98_117_99_107_101_116_+0x59a>
  40812e:	48 89 d6             	mov    %rdx,%rsi
  408131:	48 89 fb             	mov    %rdi,%rbx
  408134:	e8 a7 cc 01 00       	callq  424de0 <p111_rt_sink>
  408139:	48 89 df             	mov    %rbx,%rdi
  40813c:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  408143:	19 00 02 
  408146:	48 89 85 f8 fe ff ff 	mov    %rax,-0x108(%rbp)
  40814d:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  408154:	18 00 01 
  408157:	48 89 85 00 ff ff ff 	mov    %rax,-0x100(%rbp)
  40815e:	48 c7 85 08 ff ff ff 	movq   $0x0,-0xf8(%rbp)
  408165:	00 00 00 00 
  408169:	48 c7 85 10 ff ff ff 	movq   $0x0,-0xf0(%rbp)
  408170:	00 00 00 00 
  408174:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40817b:	11 00 01 
  40817e:	48 89 85 18 ff ff ff 	mov    %rax,-0xe8(%rbp)
  408185:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40818c:	11 00 01 
  40818f:	48 89 85 20 ff ff ff 	mov    %rax,-0xe0(%rbp)
  408196:	48 c7 85 28 ff ff ff 	movq   $0x0,-0xd8(%rbp)
  40819d:	00 00 00 00 
  4081a1:	48 c7 85 30 ff ff ff 	movq   $0x0,-0xd0(%rbp)
  4081a8:	00 00 00 00 
  4081ac:	b9 08 00 00 00       	mov    $0x8,%ecx
  4081b1:	48 8d 95 f8 fe ff ff 	lea    -0x108(%rbp),%rdx
  4081b8:	be 96 00 00 00       	mov    $0x96,%esi
  4081bd:	48 89 fb             	mov    %rdi,%rbx
  4081c0:	e8 8b cc 01 00       	callq  424e50 <p111_rt_ctor>
  4081c5:	48 89 df             	mov    %rbx,%rdi
  4081c8:	48 89 c3             	mov    %rax,%rbx
  4081cb:	48 b8 2c 82 10 03 00 	movabs $0x20019000310822c,%rax
  4081d2:	19 00 02 
  4081d5:	48 89 85 38 ff ff ff 	mov    %rax,-0xc8(%rbp)
  4081dc:	48 b8 00 00 00 00 00 	movabs $0x100180000000000,%rax
  4081e3:	18 00 01 
  4081e6:	48 89 85 40 ff ff ff 	mov    %rax,-0xc0(%rbp)
  4081ed:	48 c7 85 48 ff ff ff 	movq   $0x0,-0xb8(%rbp)
  4081f4:	00 00 00 00 
  4081f8:	48 c7 85 50 ff ff ff 	movq   $0x0,-0xb0(%rbp)
  4081ff:	00 00 00 00 
  408203:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40820a:	11 00 01 
  40820d:	48 89 85 58 ff ff ff 	mov    %rax,-0xa8(%rbp)
  408214:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  40821b:	11 00 01 
  40821e:	48 89 85 60 ff ff ff 	mov    %rax,-0xa0(%rbp)
  408225:	48 c7 85 68 ff ff ff 	movq   $0x0,-0x98(%rbp)
  40822c:	00 00 00 00 
  408230:	48 c7 85 70 ff ff ff 	movq   $0x0,-0x90(%rbp)
  408237:	00 00 00 00 
  40823b:	b9 08 00 00 00       	mov    $0x8,%ecx
  408240:	48 8d 95 38 ff ff ff 	lea    -0xc8(%rbp),%rdx
  408247:	be 96 00 00 00       	mov    $0x96,%esi
  40824c:	49 89 fc             	mov    %rdi,%r12
  40824f:	e8 fc cb 01 00       	callq  424e50 <p111_rt_ctor>
  408254:	4c 89 e7             	mov    %r12,%rdi
  408257:	48 b9 00 00 00 00 00 	movabs $0x100180000000000,%rcx
  40825e:	18 00 01 
  408261:	48 89 8d b0 fe ff ff 	mov    %rcx,-0x150(%rbp)
  408268:	48 b9 2c 82 10 03 00 	movabs $0x20019000310822c,%rcx
  40826f:	19 00 02 
  408272:	48 89 8d b8 fe ff ff 	mov    %rcx,-0x148(%rbp)
  408279:	48 c7 85 c0 fe ff ff 	movq   $0x0,-0x140(%rbp)
  408280:	00 00 00 00 
  408284:	48 c7 85 c8 fe ff ff 	movq   $0x0,-0x138(%rbp)
  40828b:	00 00 00 00 
  40828f:	48 89 9d d0 fe ff ff 	mov    %rbx,-0x130(%rbp)
  408296:	48 89 85 d8 fe ff ff 	mov    %rax,-0x128(%rbp)
  40829d:	48 b8 00 00 00 00 00 	movabs $0x100110000000000,%rax
  4082a4:	11 00 01 
  4082a7:	48 89 85 e0 fe ff ff 	mov    %rax,-0x120(%rbp)
  4082ae:	48 c7 85 e8 fe ff ff 	movq   $0x0,-0x118(%rbp)
  4082b5:	00 00 00 00 
  4082b9:	48 c7 85 f0 fe ff ff 	movq   $0x0,-0x110(%rbp)
  4082c0:	00 00 00 00 
  4082c4:	b9 09 00 00 00       	mov    $0x9,%ecx
  4082c9:	48 8d 95 b0 fe ff ff 	lea    -0x150(%rbp),%rdx
  4082d0:	be 99 00 00 00       	mov    $0x99,%esi
  4082d5:	e8 76 cb 01 00       	callq  424e50 <p111_rt_ctor>
  4082da:	41 5f                	pop    %r15
  4082dc:	41 5e                	pop    %r14
  4082de:	41 5d                	pop    %r13
  4082e0:	41 5c                	pop    %r12
  4082e2:	5b                   	pop    %rbx
  4082e3:	c9                   	leaveq 
  4082e4:	c3                   	retq   

Disassembly of section .fini:
