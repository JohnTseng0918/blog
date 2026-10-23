---
title: "RISC-V CLIC (Core-Local Interrupt Controller)"
date: 2026-10-03
lastmod: 2026-10-23
draft: false
description: "CLIC 規格閱讀筆記"
tags: ["riscv", "clic", "interrupt"]
categories: ["計算機架構"]
---

## CLIC

> The Core-Local Interrupt Controller (CLIC) Privileged Architecture Extensions are designed to provide low-latency, vectored, pre-emptive interrupts for RISC-V systems. When activated the CLIC subsumes and replaces the original RISC-V basic local interrupt scheme (known as the CLINT in this document). The CLIC has a base design that requires minimal hardware, but supports additional extensions to provide hardware acceleration. The goal of the CLIC is to provide support for a variety of software ABI and interrupt models, without complex hardware that can impact high-performance implementations.

- CLIC 目標是low-latency, vectored, pre-emptive的中斷處理機制
- 啟用CLIC後，會接管並取代RISC-V 基本的local中斷系統 (CLINT)
  - exception 的行為不會改變
- CLIC的基礎設計只需要很小的硬體資源，有保留擴充去提供硬體加速

> The CLIC also supports a Selective Hardware Vectoring extension that allow users to optimize each interrupt for either faster response or smaller code size.

- 支援 Selective Hardware Vectoring 擴充，每個interrupt可以各自選擇要更快的回應還是更小的code size

### CLINT
> A simple interrupt controller that provides inter-processor interrupts and timer functionalities for this RISC-V interrupt scheme has been called CLINT. This specification will use the term CLINT mode when xtvec.mode is set to either 00 or 01.
- CLINT 是一個簡單的 interrupt controller，負責 inter-processor interrupt (IPI) 和 timer
  - `xtvec.mode` == `00` 或是 `01` 時，稱之為 CLINT mode
- CLINT mode 支援 interrupt preemption，但只能依 privilege mode 來 preempt：只有更高 privilege 的 interrupt 能打斷目前的執行，同 privilege 的 interrupt 不能互相 preempt（CLIC 才加入同 privilege 的 horizontal preemption）
- global interrupt enable bit `xstatus.xie` 用來控制目前 privilege mode 的 interrupt 能不能發生
  - 較低 privilege mode 的 interrupt 一律 disabled
  - 更高 privilege mode 的 interrupt 不管該 mode 的 `xie` 設定為何，一律 enabled
- 從 higher-privilege 來的 interrupt 會停止 current privilege mode 的執行，然後進去 higher privilege mode 的 handler
  - 每一個 privilege mode 有自己的 interrupt state registers，例如 M-mode 的 `mepc`/`mcause`、S-mode 的 `sepc`/`scause`（統稱 `xepc`/`xcause`）
- 被 higher-privilege-mode interrupt preempt 時，目前的 privilege mode 和 interrupt enable 狀態會分別存進 higher-privilege mode 的 `xstatus.xpp` 和 `xstatus.xpie`
- `xtvec`: 決定 interrupt mode，並存放 interrupt vector table 的 base address
  - 低位元 (mode 欄位，WARL) 決定使用哪種 interrupt model
  - 高位元存放 vector table 的 base address（至少 4-byte aligned）
- CLINT mode: `xtvec.mode` = `00` (direct) 或 `01` (vectored)
  - **00（Direct 模式）**：所有 trap（包含 exception）都跳到同一個 base address
  - **01（Vectored 模式）**：interrupt 依 cause 跳到 vector table 中對應的 entry；exception 仍跳到 base address
- CLIC mode: `xtvec.mode` = `11` 且 `xtvec.submode` = `0000`

### CLIC compared to CLINT
- CLINT mode interrupt controller（小型 unit）
  - 提供 local interrupt，管理 software / timer / external interrupt（`xip` 中的 `xsip`/`xtip`/`xeip`）
  - 可以在 `xip` register 的 bit 16 及以上位置加入 custom fast local interrupt signals
  - local interrupt 的 priority 是固定的
  - `xtvec` 有 direct 和 vectored 模式
    - direct：所有 interrupt 都跳到同一個 base address
    - vectored：使用放**跳轉指令**的 vector table
- CLIC
  - 允許軟體針對**每一個 individual interrupt** 個別控制 interrupt mode、trigger type、priority 以及 CLIC mode vectoring behavior
    - interrupt mode：每個 interrupt 要在哪個 privilege mode 處理，由 `clicintattr[i].mode` 設定
  - CLIC mode vector table 直接存放 **addresses**，因此**沒有 jump instruction 的 ±1MiB 範圍限制**
  - 支援 **same privilege mode interrupt preemption（horizontal interrupts）**
  - 減少 interrupt handler 內的 memory 或 CSR 存取次數
- Platform profile 可能要求支援 CLINT mode、CLIC mode 其中之一或兩者都要

### CLIC compared to PLIC
- **PLIC** 提供 centralized interrupt prioritization，負責在多個 hart 之間 route shared platform-level interrupts
  - 但每個 hart 的每個 privilege mode 只會收到**一條** external interrupt signal（`xeip`），hart 要再透過 claim 才知道是哪個 source
- PLIC 的 routing 機制採用 **notification / claim / response / completion** 的處理序列，將 interrupt 派送給各個 hart
  - 這個流程需要在 interrupt handler 裡額外做 memory 存取（claim / complete 都要讀寫 PLIC 的 register）
- **CLIC 與 PLIC 是互補關係**
  - 小型單核系統可以只有 CLIC；多核系統可以每個 core 一個 CLIC，再共用一個 PLIC
  - PLIC 傳來的 **`xeip` signal 會被各 core 的 CLIC 當成 hart-local interrupt source**

### CLIC compared to Advanced Interrupt Architecture
- AIA 支援 message-signaled interrupts（MSI）和 Advanced PLIC（APLIC），目標是多 hart 系統以及 virtualization
- 與 CLIC 相同，AIA 允許軟體配置**所有 interrupt** 的相對優先順序，而不僅限於 external interrupt
- CLIC 的定位是 per-core 的 interrupt controller
  - 可選擇讓每個 interrupt source 有各自的 trap entry address
  - 支援 interrupt preemption（nesting），並可用 priority threshold 調整
  - 減少 back-to-back interrupt 時的 context switching
- 總結：AIA 偏重多 hart、MSI、virtualization 等系統層級需求；CLIC 偏重單一 core 內的 low-latency、nesting 與 vectoring

## Overview

- CLIC supports up to 4096 interrupt inputs per hart.
- 每個interrupt input i 有4個control registers
  - interrupt-pending bit (`clicintip[i]`)
  - interrupt-enable bit (`clicintie[i]`)
  - interrupt attribute (`clicintattr[i]`): privilege mode, trigger type
  - interrupt control bits (`clicintctl[i]`, 8-bit): level and priority
- 如果要和CLINT mode相容，前16個interrupt input 保留給CLINT mode interrupt (對應 `xip`/`xie` 的低16 bits，保留原本的cause值)，剩下4080個是用來擴充的

### interrupt preemption
- CLIC 對每個privilege mode 支援256個interrupt level
  - 數字大的interrupt level可以搶數字比較小的interrupt level
  - Level 0 代表是一般程式執行
  - Level 1 - 255 對應的是interrupt handler level
  - 要配置多少個level是平台決定的
- 同個privilege底下，high interrupt level 可以搶奪 active low interrupt level
  - 前提是這個privilege mode的global interrupt enable (`xstatus.xie`) 有開
- 沿用原本RISC-V的行為：higher privilege mode interrupt 可以搶奪 lower privilege mode interrupt
  - 不管lower privilege mode的 `xstatus.xie` 有沒有開
- level 和 priority 的差別 (§3.1.2)
  - level 決定能不能搶占 (preemption)
  - priority 不影響搶占，只是同一個level有多個pending interrupt時的tie-breaker
  - privilege mode, level, priority 都一樣時，編號大的interrupt先處理 (跟CLINT一樣，跟PLIC相反)

### CLIC interaction with other local interrupts
- CLIC 會把basic local interrupt整合進來
  - 原本在 `xip`/`xie` bits 16 以上的local interrupt 就不再可見 (§2.2)
  - 在CLIC mode 下整個 `mie`/`mip` 讀起來都是0，寫入會被忽略 (§3.8.3)
- timer, software, external interrupt 都會被當作additional local interrupt source
  - privilege mode, interrupt level, priority 就會被描述在 `clicintattr[i]`, `clicintctl[i]` 這些register裡
  - delegation 不再由 `mideleg` 控制，改由 `clicintattr[i].mode` 決定interrupt在哪個privilege mode處理

### CLIC extension summary
- smclic: clic support for m-mode
- ssclic: clic support for s-mode
- smclicshv: selective hardware vectoring for m-mode
- smclicconfig: allows implementations to support different parameterizations of CLIC extensions
