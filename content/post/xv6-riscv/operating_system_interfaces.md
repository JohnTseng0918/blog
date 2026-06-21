---
title: "Operating system interfaces"
date: 2026-06-19T17:49:49+08:00
draft: false
description: "MIT 6.S081 / xv6-riscv Operating system interfaces"
tags: ["xv6", "riscv", "kernel"]
categories: ["作業系統"]
---

## Operating system interfaces

- OS Job:
  - 讓多個 program 可以共享電腦
  - provide service
- OS 要將 low-level hardware 抽象化
- OS 會透過 interface 提供服務給 user programs
  - 設計一個好的 interface 是困難的
    - 希望 interface 簡單易實作
    - 希望提供較複雜的 feature 給應用程式
    - 解法:設計依賴少數幾種機制的介面,這些機制可以組合起來提供很強的通用性
- Unix 提供了一個簡潔的 interface,其機制組合良好,又有高通用性
  - 這個 interface 非常成功,以至於 Modern OS 都擁有 Unix-like interfaces
  - xv6 是理解 Modern OS 的好起點
- kernel:
  - A special program that provides services to running programs.
  - 執行中的 program,稱之為 **process**
    - 它的記憶體包含:instructions, data, and a stack
    - instruction: program's computation
    - data: variables on which the computation acts
    - stack: organizes the program's procedure calls
  - 一台電腦通常會同時擁有許多 process,但只會有一個 kernel
- System call:
  - process 需要請求 kernel 的服務,就要透過呼叫 system call
  - 呼叫 system call 會進入 kernel,kernel 執行服務後會 return
  - process 會在 user space 和 kernel space 來回轉換
- kernel 利用 CPU 提供的硬體保護機制,確保在 user space 執行的每個 process 只能存取自己的記憶體。
- kernel 會以 hardware privilege 執行這些保護機制
  - user program 則不具備這些 privilege
  - 當 user program 呼叫 system call,hardware 會提升 privilege level,並執行 kernel 中預先設定的 function。

## Processes and memory

- 一個 xv6 process 由 user space 中的記憶體(包含 instruction, data, and stack)以及屬於該 process、只有 kernel 能存取的 state 所構成
- xv6 使用 time-sharing 機制
  - 它會在多個等待執行的 process 之間,切換可用的 CPU
  - 當某個 process 未執行時,xv6 會保存該 process 的 CPU register,並在下次執行該 process 時恢復這些 register。
  - kernel 會為每個 process 分配一個編號:process identifier, or PID

### System call introduction

#### fork
- fork 會為新產生的 child process 建立一份與 parent process 一模一樣的 memory copy,這包含了 parent process 的 instructions, data, stack
- return value:
  - Original process: return the new process's PID
  - New process: return zero
- The original and new processes 通常被稱為 parent and child。

#### exit
- exit 使呼叫的 process 停止執行並且釋放資源:
  - 例如釋放記憶體,或是開啟的檔案(open files)等資源
- return value:
  - conventionally 0 代表成功
  - 1 代表失敗

#### wait
- return 該 process 中已經離開或被殺掉的 child process 的 PID,並且 copy exit status 給傳入 wait 的 address
- 如果沒有 child process 已經 exit,就會等到有 child exit
- 如果沒有 children,wait 會 return -1
- 如果 parent 不在乎 child process 的 exit status,可以傳入位址 0 給 wait
- 儘管 child process 和 parent process 有一樣的記憶體內容,但它們執行在分別不同的記憶體和 register
  - 所以改變 variable 內容是不會影響到彼此的

#### exec
- exec 會從檔案系統中的 file 載入 memory image 取代 calling process's memory
  - 這個 file 通常有特定格式
    - 會定義哪些區塊是 instruction,哪些是 data,還有從哪一個 instruction 開始執行
    - xv6 使用 ELF
    - 通常這個 file 就是從 program's source code compile 的結果
- exec 成功,它不會回到呼叫它的 process
  - 會從 ELF 的 entry point 開始執行
- exec 有兩個參數,一個是 executable name,另一個是 array of strings
- 多數程式會忽略 argv 陣列的第一個元素,它慣例上是程式名稱

#### read
- read(fd, buf, n)
  - fd: file descriptor
  - copy file 資料到 buf
  - 最多 n bytes
  - return 讀到的 bytes 數
- 每個 file descriptor 都有一個 offset，每次 read 都會從現在的 file offset 開始讀，read 完會把 offset 再加上實際讀到的 byte 數，下次 read 就會從新的 offset 繼續讀
  - 沒有 byte 可以讀的就會 return 0，代表是 end of the file

#### write
- write(fd, buf, n)
  - fd: file descriptor
  - copy buf 資料到 file
  - copy n bytes
  - return 寫的 bytes 數
- return 少於 n 就代表有 error 發生
- 就像是 read，write 也是會從 current file offset 開始寫，write 之後 offset 也會位移實際寫入的 byte 數，每次 write 也是從上次結束的地方繼續寫

#### close
- release a file descriptor
  - 使可以被之後的 open, pipe, dup 使用

#### open
- 有一系列參數可以控制 open 行為:
  - O_RDONLY (read), O_WRONLY (write), O_RDWR (read and write), O_CREATE (create file if not exist), O_TRUNC (truncate file to 0)
    - truncate 通常是覆寫用

#### dup
- duplicates an existing file descriptor
- return new one 指到同一個 I/O object
- shared offset

## I/O and File descriptors
- file descriptor 是一個 small integer，代表的是 process 可以讀或是可以寫的一個 kernel 管理的物件
- Process 可以透過 open a file, directory, device 或是 create a pipe,又或者是 duplicate an existing descriptor 來獲得 file descriptor
- file descriptor interface 將這些不同的 file, pipe, device 都抽象化，讓它們看起來都是 streams of bytes
  - input, output: I/O
  - file: the object a file descriptor refers to
- By convention, file descriptor:
  - 0: standard input
  - 1: standard output
  - 2: standard error
- 新 alloc 的 file descriptor 都從該 process 最小且沒有使用的編號開始
- File descriptor 和 fork 就會讓 I/O redirection 變得很好實作
  - fork copy parent file descriptor table
  - child 就可以從同一個 file 開始
  - exec 可以把 memory 取代掉，但卻保留 file table
- 所以 fork and exec 之所以要分開實作，就是保留 I/O redirection 的彈性
- 儘管 fork 會 copy file descriptor，但是 file descriptor 的 offset 是共享的
  - 這樣才能做 sequential output
- 透過 fork 或是 dup，從同一個 file descriptor 生成的會共享 offset，其他的 file descriptor 不會，即使它們是對同一個 file 使用 open
```
ls existing-file non-existing-file > tmp1 2>&1
```
- 2>&1 的意思是要把 file descriptor 2 輸出的位置導到 file descriptor 1，也就是會一起寫到同個地方
  - xv6 沒有實作 error message 的 I/O redirection，但這樣應該也知道要怎麼實作了
