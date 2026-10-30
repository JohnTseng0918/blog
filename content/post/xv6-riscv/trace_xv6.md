---
title: "Trace xv6 source code note"
date: 2026-06-30
lastmod: 2026-10-23
draft: false
description: "MIT 6.S081 / trace xv6-riscv source code 的隨意筆記"
tags: ["xv6", "riscv", "kernel"]
categories: ["作業系統"]
---

## Trace Note

### Homework 1 due: file descriptors

#### cat.c

這個作業要 trace `cat` 的實作方式，並且要 track `argv[i]` 是如何 pass 給 `open()`，以及 file descriptor 的 result 是什麼、file descriptor 這個 integer 是指向什麼？

首先 `cat.c` 是個 user program，很輕鬆就可以看到 `main` 入口

一開始先有一個判斷，如果 `argc <= 1`，代表只有 `argv[0]`（按照慣例是執行檔的名稱）、沒有輸入任何檔名，所以就呼叫了 `cat(0)`，參數是 file descriptor，0 也就是 standard input

```c
void cat(int fd){
  int n;

  while ((n = read(fd, buf, sizeof(buf))) > 0) {
    if (write(1, buf, n) != n) {
      fprintf(2, "cat: write error\n");
      exit(1);
    }
  }
  if (n < 0) {
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
```

實作可以清楚看到用一個 `while` 去做 `read()`，並且把 read 到的 byte 數 assign 給 `n`，如果 `n > 0`，代表有讀到 data，接下來就會進入裡面執行 `write()`

回到 `main` function，如果 `argc > 1`，就會去 open `argv[i]`，然後將 file descriptor 傳入 `cat()`

<!-- TODO: cat() 用完 fd 之後 main 做了什麼？ -->

#### system call flow

有一個很有趣的問題，是 user program 呼叫 system call `open()`，但是 kernel code 只有找到 `sys_open()`，中間是發生什麼事情？

首先，`open` 不是用 C 寫的 function，而是 `usys.pl` 產生的 `usys.S` 裡的一段 assembly stub

```asm
.global open
open:
    li a7, SYS_open   # 把 system call 編號 15 放進 a7 register
    ecall             # 觸發 trap 進入 kernel
    ret               # 回到 cat，回傳值已經在 a0
```

參數的傳遞方式：就是依照 RISC-V calling convention，進到 `open` 的時候 `path` 在 `a0`，`mode` 在 `a1`；`a7` 是 system call 編號，kernel 會依據此數值來查表

`ecall` 完會跳轉到 `stvec` register 裡的 address，也就是 trampoline page 中的 `uservec`（`TRAMPOLINE + (uservec - trampoline)`），這個值是上次從 kernel 切換到 user 的時候、在 `prepare_return()` 裡用 `w_stvec()` 設定的

進入 `uservec`，也就是 assembly，會把 register（除了 `x0`/`zero` 共 31 個）都存進 trapframe，最後呼叫 C function `usertrap()`。其中 `a0` 比較特別，不是直接存：會先 `csrw sscratch, a0` 把它暫存到 `sscratch`，因為需要用 `a0` 載入 `TRAPFRAME` 位址當基底，最後才把 `sscratch`（原本的 `a0`）寫回 trapframe

<!-- TODO: 補 uservec 換 page table 的部分（後面說和 userret 對稱，這裡還沒寫）。看 trampoline.S 存完 register 之後、jalr t0 之前，從 trapframe 載入了哪些值？ -->

`usertrap()` 裡頭會判斷是不是 system call，然後就跳進去 `syscall()`

<!-- TODO: 補 usertrap() 的 system call 分支：w_stvec(kernelvec)、epc = r_sepc()、scause == 8、epc += 4、intr_on() 各自在做什麼？（epc += 4 和後面「sret 跳回 ecall 結束的地方」有關） -->

`syscalls` 是個 function pointer array，最後進入 `sys_open()`

做完 system call 會把 return value 放到 `p->trapframe->a0`

這時候就會回到 `usertrap()` 繼續執行 `prepare_return()`

`prepare_return()` 會先把 interrupt disable，接著用 `w_stvec()` 把 `stvec` 設回 `uservec`（下次 `ecall` 的入口），這個上面有提過

會設定 trapframe values

<!-- TODO: 寫清楚 prepare_return() 設了 trapframe 的哪四個欄位，和上面 uservec 載入的值有什麼關係？ -->

接著把 `sstatus` 讀出來，把 `sstatus.SPP` 清成 0（代表 user mode）、`sstatus.SPIE` 設成 1，再把這個值寫回 `sstatus`。要注意這時候 interrupt 還沒有打開，要等之後執行 `sret` 時，硬體才會依 `SPP` 切回 user mode，並把 `SPIE` 複製到 `SIE`

最後設定 `sepc`，把 `p->trapframe->epc` 寫進去

當初在 `uservec` 是使用 `jalr` 跳進去 `usertrap()`，所以 `usertrap()` 做完就會回到 `uservec` 的最後，asm 往下繼續執行就會碰到 `userret`（另外 `usertrap()` 的 return value 是 user page table 的 `satp`，會透過 `a0` 傳給 `userret` 用）

這裡做的事情是：先用 `usertrap()` 回傳的 `satp` 換回 user page table（`csrw satp, a0`），再把 trapframe 存的 register 都 restore 回來，最後執行 `sret`，剛好跟去程 `uservec`「換 kernel page table + 存 register」對稱

要特別注意 `a0` 是最後才 restore 的（因為前面一直用 `a0` 當 `TRAPFRAME` 的基底位址），而還原進 `a0` 的值，正是前面 `sys_open()` 回傳、被存進 `p->trapframe->a0` 的那個 fd，所以 fd 一路藏在 `p->trapframe->a0`，到這裡才被載回真正的 `a0` register

`sret` 跳轉回到 `ecall` 結束的地方，下一步的 `ret` 就會依 calling convention 從 `a0` 把 fd 交回 `cat` 的 `open()`

<!-- TODO: 說明為什麼 sret 會回到 ecall 的下一條：sepc 原本指向哪一條指令？是誰改的？ -->

#### sys_open()

`sys_open()` 取得 file name 和 open mode 的方式是使用 `argint()` 和 `argstr()` function

內部都會有 `argraw()`，會從 process 的 trapframe 取值，因為 `uservec` 已經把 register 的值存進 trapframe，這時候就取出來用

<!-- TODO: 作業問題「argv[i] 怎麼傳給 open()」：a0 裡只是 user virtual address，kernel 能直接 dereference 嗎？從 argstr() 往下追 fetchstr() / copyinstr() -->

進入 open 實際處理的功能以前會有 `begin_op()`，結束會有 `end_op()`，這是檔案系統的 logging / transaction，保證一組磁碟寫入的原子性（當機也不會只做一半），對應 `kernel/log.c`，細節等以後 trace 完再補充

之後會判斷是不是 `O_CREATE`，因為 trace 的是 `O_RDONLY`，所以就進去 `namei(path)`

然後會發現 access inode 之前，都要做 `ilock()`。要注意結束時分兩種情況：

- 成功路徑用的是 `iunlock()`，只解鎖但保留 inode 的引用，因為引用被接下來的 `f->ip` 接手持有，要等以後 `close(fd)` → `fileclose()` 才會真正 `iput()` 釋放
- 錯誤路徑才用 `iunlockput()`（= `iunlock()` + `iput()`，解鎖並釋放引用）

`ilock()`/`iput()` 的細節等以後 trace 完再補充

接著會進行 `filealloc()`，在 `ftable` 中找到一個可用的 entry（`ref == 0`），找到後會馬上設 `f->ref = 1` 才 release 鎖（避免競爭），然後 return

`ftable` 的用意也是以後探討。access `ftable` 的時候要進行 `acquire()`，結束要 `release()`，這是一把 spinlock：`ftable` 是所有 process 共用的，多個 CPU 可能同時呼叫 `filealloc()`，所以需要 mutual exclusion

如果 `filealloc()` 成功，接下來就會進行 `fdalloc()`，這個就是在 `myproc()->ofile`（也就是 `p->ofile`，per-process 的 array）中找到最小可用的 file descriptor index return

如果 `fdalloc()` 成功，就會往下檢查 file type，以此設定 `ftable` entry 的 `type`，以及其 `readable`/`writable` 屬性，以及指向的 inode（`f->ip`），最後 return file descriptor

<!-- TODO: 補 O_TRUNC 的處理（itrunc），以及最後的 iunlock() / end_op() -->

<!-- TODO: 作業問題「fd 這個 integer 指向什麼」還沒總結：把 p->ofile[fd] → struct file（ftable）→ f->ip 這條鏈串起來，參考 kernel/file.h 的 struct file -->

### Homework 3 due: kernel design

這次作業是 trace xv6 實作：

- `kernel/proc.h`
- `kernel/defs.h`
- `kernel/entry.S`
- `kernel/main.c`
- `user/init.c`

並且瀏覽 process 實作：

- `kernel/proc.c`
- `kernel/exec.c`

假設 xv6 用完 `struct proc proc[NPROC]` table 中的所有 proc entry，如果有一個 process 呼叫了 `exec()` 或 `fork()`，會發生什麼事情？

如果一個 process 對一個存在的 PID 呼叫 `kill()`，然後又呼叫 `fork()`，會發生什麼事情？

<!-- TODO: 回答上面兩題。第一題：exec() 會配置新的 proc entry 嗎？比較 kexec() 和 kfork() 有沒有呼叫 allocproc()，以及 allocproc() 找不到 UNUSED 時回傳什麼（同時對照原題確認題意）。第二題：kkill() 改了什麼？那個值在哪裡被檢查？（提示：usertrap()） -->

首先 `kernel/main.c` 都是在做 init，`cpuid() == 0` 的 hart 和 proc 有關的就是 `procinit()`

`procinit()` 內容是先 init `pid_lock`（name 是 `"nextpid"`）和 `wait_lock` 兩個 spinlock，然後把 `struct proc proc[NPROC]` 使用 for loop 做 init，會去 init spinlock，以及設定 process state 成 `UNUSED`，然後設定 kernel stack 的 address

這裡使用 `KSTACK` 這個 macro 去算出 address，用法就是 `KSTACK(p)`，就是 process p 的 kernel stack address

`TRAMPOLINE` 是一個固定的 VA，它是 virtual address space 位址最高的一個 page

```c
#define TRAMPOLINE (MAXVA - PGSIZE)
#define MAXVA (1L << (9 + 9 + 9 + 12 - 1))
#define PGSIZE  4096 // bytes per page
#define KSTACK(p) (TRAMPOLINE - ((p) + 1) * 2 * PGSIZE)
```

page size 是熟悉的 4KB page

然後仔細看 `KSTACK` 的算式，有一個乘 2，主要是放入 guard page，如果有使用過界的行為，就不會碰到其他的 kernel stack

| 名稱         | 虛擬位址         | 內容                      |
| ------------ | ---------------- | ------------------------- |
| `TRAMPOLINE` | `0x3FFFFFF000`   | trampoline 程式碼         |
| guard page   | `0x3FFFFFE000`   | 沒有 map                  |
| `KSTACK(0)`  | `0x3FFFFFD000`   | `proc[0]` 的 kernel stack |
| guard page   | `0x3FFFFFC000`   | 沒有 map                  |
| `KSTACK(1)`  | `0x3FFFFFB000`   | `proc[1]` 的 kernel stack |

<!-- TODO: KSTACK() 只是算出位址，真正配置並 map kernel stack page 的 function 就在 proc.c（procinit() 上面），它是被 vm.c 的 kvmmake() 呼叫的；vm.c 細節可以之後再 trace -->

`cpuid() != 0` 的 hart 也是做 init，只是需要 init 的資源比較少

<!-- TODO: 其他 hart 在等什麼（started）？為什麼只需要 kvminithart / trapinithart / plicinithart？想想哪些是共用的、哪些是 per-hart 的 -->

然後就會進入 `scheduler()` 去做排程

<!-- TODO: 還沒 trace：entry.S → start.c → main() 的路徑、userinit() 和 user/init.c -->
