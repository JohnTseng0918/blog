---
title: "Bit Manipulation 位元運算"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "位元運算技巧,含 Reverse Bits、Number of 1 Bits、Missing Number 等"
tags: ["leetcode", "bit-manipulation"]
categories: ["演算法"]
---

## 190. Reverse Bits

- Input 是一個 32bit int，return 頭尾反轉的 32bit int
- 想法很簡單，就是先宣告一個 return_val = 0
- input n & 1 == 1 → return_val | = 1
- 然後 n = n >> 1，下一輪 return_val = return_val << 1;
- 就會得到:
    - return_val = return_val << 1;
    - return_val |= (n&1)
    - n = n >> 1
- 第一行要先位移，是因為第一輪左移沒差，0 還是 0，但下一輪開始會需要先空出空間來放

## 191. Number of 1 Bits

- 這題要回傳 int 中用二進位表示法有多少個 1
- 使用到的技巧是 n = n & (n - 1)
    - 想像 n-1 就是把 n 最小的 1 刪掉，然後往右放成一堆 11111….
    - 兩者 and 完後，就是刪掉一個 1
    - 0110 0100 → n
    - 0110 0011 → n - 1
    - 0110 0000 → new n
    - 這樣就可以知道有多少個 1 了

## 268. Missing Number

- 給定一個 array，找出[0, n]中少的那個數字
- 例如[3,0,1] → 2
- XOR solution:
    - 利用兩個相同數字 XOR，會變成 0 的特色
    - 所以 0~n 都要 XOR 過
    - array 也要 XOR 過，這樣就會得到答案
- 數學解:
    - n (n + 1) / 2 就是總和
    - 然後 for 迴圈也可以得到總和，相減就是答案

## 371. Sum of Two Integers

- 這題要做事情是兩個 int 不使用+來做加法
- 用 bit 的觀點來看 0, 0 → 0
- 0, 1 → 1
- 1, 0→ 1
- 1, 1→1
- 所以是使用 exclusive or 來做，但是還有 carry 要處理
- carry 只有在兩者都是 1 才有 carry
- 所以一開始就先做 and 存到 carry 並左移
- 然後做 XOR
- 直到沒有任何的 carry 即完成