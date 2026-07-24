---
title: "Operating system organization"
date: 2026-07-24T23:57:00+08:00
draft: false
description: "MIT 6.S081 / xv6-riscv Operating system organization"
tags: ["xv6", "riscv", "kernel"]
categories: ["作業系統"]
---

## Operating system organization

- 作業系統的關鍵是同時 support 多個活動,因此必須 time-share 資源
  - 例如 process 之間要能分享 CPU 和 memory
- 除了 time-sharing,還有兩個重要議題:
  - process 之間的 isolation
  - process 之間的 interaction
- xv6 是用 LP64 C 語言寫的
  - 意思是 long and pointer 是 64 bits,但 int 是 32 bits

## Abstract physical resource

- 第一個問題是:為什麼要有作業系統?
- 如果 application 可以直接和 hardware 互動,可以達成 high performance
- 但作業系統要支援多個 application 執行:
  - cooperative time-sharing 可以讓多個 application 信任彼此沒有 bug、不會互相影響
  - 但通常 application 彼此互不信任,所以才有強烈的 isolation 需求
- 為達到 isolation,就是要避免讓 application 直接觸碰到 hardware resource
  - 作法是把 hardware resource 抽象化成服務
  - 透過作業系統的服務,使用者可以用更方便的介面,而作業系統直接管理 hardware resource

## User mode, supervisor mode, and system calls

- Strong isolation 需要在 application 和 operating system 之間有強的 boundary
- application 不允許影響到作業系統和其他應用程式,特別是萬一有 bug 或者是惡意程式
  - 作業系統必須不能讓 application 修改作業系統的 data structure and instructions
  - 也不能讓 application 碰到其他 process 的 memory
- CPU 也有提供 hardware support for isolation
  - 例如 RISC-V 就有 3 種 privilege level
  - **Machine mode**:有 full privilege,通常在 boot 時 set up computer,然後就會切到 supervisor mode
  - **Supervisor mode**:可以執行一些 privilege instruction,例如 enable/disable interrupt、read or write control register
  - **User mode**:若在 user mode 想執行 privilege instruction,CPU 不會執行,而是 trap 到 supervisor mode 的 special code,然後終止這個 application
- 名詞:
  - application 執行 user-mode instruction,通常被稱為在 **user space** 中執行
  - software 在 supervisor mode 執行 privilege instruction,通常被稱為在 **kernel space** 中執行,kernel space 也被稱為 kernel
- RISC-V 有 `ecall` 這個指令 for system call
  - 可以從 user 切到 supervisor mode,然後跳到 kernel 指定的 entry point
  - kernel 可以拿到 argument,決定要執行或者否決掉
  - 實際從 `ecall` trap 進 kernel、跑完 `sys_open` 再 `sret` 回 user 的完整流程,參見 [Trace xv6:system call flow]({{< ref "trace_xv6.md#system-call-flow" >}})
- 由 kernel 決定 entry point 是很重要的事
  - 如果一般 user process 可以決定,那麼惡意程式也可以決定,就失去保護意義

## Kernel organization

- 關鍵的問題是:operating system 的什麼部分要執行在 supervisor mode 上?
- **Monolithic kernel**
  - operating system 的所有部分都在 kernel,所以所有的 system call 都 run 在 supervisor mode
  - 就是一支 program 包含著整個 operating system 運行在 supervisor mode 之上
  - 優點:對 OS designer 來說很方便
    - 不用切成很多個 part,也不用要求升級成 supervisor mode
    - 不同 part 之間也很方便合作
  - 缺點:kernel 會長得很大而且很複雜,沒有開發者可以完全懂每一個 part 的互動
- **Microkernel**
  - 目標是降低 kernel 裡面的 bug
  - 作法是把最小的 code 放入 kernel 之中,讓最少的 code 在 supervisor mode 執行
  - 剩下的 operating system 就在 user mode 執行
- xv6 屬於 monolithic kernel

## Process overview

- Isolation 的單位是 **process**(xv6 和其他 unix-like 系統都是)
- 為了達成 isolation,process abstraction 要讓 program 看起來像擁有 private machine
  - 也有自己的 private memory,也可以說有自己的 address space
  - 其他 process 不能對其進行 read / write
- xv6 使用 page table 讓每個 process 有自己的 address space
  - RISC-V page table 把 virtual address translate 成 physical address
  - **Virtual address**:the address that RISC-V instruction manipulates
  - **Physical address**:an address that the CPU sends to main memory
  - xv6 對每個 process 會 maintain separate page table,定義 process 的 address space

### Address space layout

- User memory 從 virtual address 0 開始,由低位址往高位址依序是:
  - **text**:program 的 instruction
  - **data**:global variable(initialized data)
  - **guard page**:一頁 inaccessible 的 page(`exec` 用 `uvmclear` 清掉 `PTE_U`)
    - 目的是偵測 user stack overflow:一旦 stack 長太多踩到 guard page,就會觸發 page fault,而不是默默蓋掉 data
    - 註:xv6 有兩個 guard page,分屬不同 address space,別搞混:
      - 這裡是 **user stack** 下方的 guard page,在 user address space
      - 另外每個 process 的 **kernel stack**(`kstack`)下方也有一個 guard page,在 kernel address space(Chapter 3 才展開)
  - **stack**:xv6 的 user stack 是固定一頁大小
    - `argc` / `argv` 等 exec 傳進來的參數放在 stack 最上方
  - **heap**:給 `malloc` 用的區域,位在 stack 之上
    - heap 是唯一會動態成長的部分,透過 `sbrk` system call 往高位址擴張
    - 因此 stack 是固定小塊、heap 才是往上長的那塊
- 有很多因素會限制 process 的最大 address space
  - RISC-V pointer 是 64 bits wide
  - hardware(Sv39)只會用 low 39 bits 去查 page table 裡的 virtual address
  - 而 xv6 只用 38 bits
- 在 address space 的最上方,xv6 放了 trampoline page 和 trapframe page
  - xv6 使用這兩個 page 去 translate into kernel and back
  - **Trampoline page**:包含 code 去 transition in and out of the kernel
  - **Trapframe page**:kernel 用來 save 這個 process 的 user register

### Process

- xv6 kernel 對每個 process 的 state,是把資料收集在 `struct proc`
- 每個 process 有一個控制執行的執行緒(thread),保存 process 所需的狀態
- 在任何時間點,一個 thread 都有可能被 CPU 執行,或是中止(不執行,但未來可能會被繼續執行)
- CPU 在 process 間切換時,kernel 就必須中止 thread 在 CPU 上的執行,並保存狀態,再恢復另一個 process 被中止的 thread 的狀態
  - 大多數 thread state(local variable、function call return address)都被存在 thread stack
  - 每個 process 有兩個 stack:user stack 和 kernel stack
    - 當 process 正在執行 user instruction,只會用到 user stack,這時候的 kernel stack 是空的
    - 當 process 進到 kernel(system call or interrupt),kernel code 就會執行在 process 的 kernel stack
      - process 在 kernel 時,user stack 依然保有儲存的資料,只是不會被使用
  - process 的 thread 會在 user stack 與 kernel stack 之間交替使用
  - kernel stack 是分開且受保護的,所以即使 process 損壞了 user stack,kernel 仍能正常執行
- process 的 user code 可以透過 RISC-V 指令 `ecall` 來呼叫 system call
  - 這個指令會切換到 supervisor mode,並改變 program counter 進入 kernel 定義好的入口
  - entry point 的 code 會切換到 process 的 kernel stack,並執行 kernel instruction
  - system call 完成後,kernel 用 `sret` 指令切換回 user mode,並繼續執行 user instruction
  - 一個 process 的 thread 可能會在 kernel 中 block 去等待 I/O,直到 I/O 完成才繼續
  - 這整段 trap → syscall → return 的 source code trace,參見 [Trace xv6:system call flow]({{< ref "trace_xv6.md#system-call-flow" >}})

### struct proc

- `p->state`
  - process 的狀態:allocated、ready to run、currently running on a CPU、waiting for I/O、exiting
- `p->pagetable`
  - process 的 page table,格式是 RISC-V hardware 期待的格式
  - xv6 在 user space 中執行時,會讓 paging hardware 使用該 process 的 `p->pagetable`
  - page table 也記錄了配置給該 process memory 所對應的 physical page 的 address
- process 結合了兩個 design idea:
  - **address space**:process 有自己的記憶體
  - **thread**:process 有自己的 CPU
  - 在 xv6 中,一個 process 有一個 address space 和 one thread
  - 實際的作業系統中,一個 process 可能有多個 thread 來妥善運用多個 CPU