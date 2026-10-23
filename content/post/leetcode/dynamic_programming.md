---
title: "Dynamic Programming 動態規劃"
date: 2026-09-09
lastmod: 2026-10-23
draft: false
description: "DP 入門題,含 Climbing Stairs、Best Time to Buy and Sell Stock、Counting Bits"
tags: ["leetcode", "dynamic-programming"]
categories: ["演算法"]
---

## 53. Maximum Subarray

- 給定一個 array，找出 subarray sum 的最大值
- Kadane's Algorithm
- 如果是暴力法，那就是兩層迴圈可以搞定的問題 O(n^2)
- 這題也可以使用 prefix sum 的觀念來解
  - 就會變成一個 prefix_sum_array，要找出 prefix_sum_array[i] - prefix_sum_array[j]最大值，當 i > j
  - 這就是被 reduce 成 121 題了
  - 邏輯就是 prefix sum array elements 相減，那就是該 subarray 的和
  - O(n)
- DP 解法:
  - 定義 sub 是「以 nums[i]結尾」的 maximum subarray sum，注意不是「前 i 個元素」的答案
  - 走到 i 只有兩個選擇: 接在前一段後面，或是從自己重新開始一段
  - sub = max(sub + nums[i], nums[i])
  - 真正的答案再拿每一個 sub 去更新: res = max(res, sub)
  - O(n)

## 70. Climbing Stairs

- 爬梯子，一次只能走一步或兩步，給定 n，回傳總共有幾種走法
- 仔細觀察
- 1: 1
- 2: 1+1, 2
- 3: 1+2, 1+1+1, 2+1
- 4: 1+1+2, 2+2, 1+2+1, 1+1+1+1, 2+1+1
- 也就是前兩項相加，這題算簡單就可以得出來

## 121. Best Time to Buy and Sell Stock

- 給定一個股價 list，要找出買和賣可以賺最多錢的一次交易組合
    - 也就是只買賣一次，如果找不到賺錢組合，就回傳 0
- Kadane's Algorithm
- 因為要最大化交易，就是要找出左邊最小，右邊最大的一組
- 可以透過一個 for 迴圈
    - 反向思考: index 大到小
        - max_val = max(max_val, nums[i])
        - res = max(res, max_val - nums[i])
    - 正向思考: index 小到大
        - min_val = min(min_val, nums[i])
        - res = max(res, nums[i] - min_val)
- O(n)

## 338. Counting Bits

- 給一個數字 n，回傳 array size n+1，裡面是所有數字的 binary 表示法的 1 的數量
- 0 : 0b0, 1:0b1, 2:0b10, 3: 0b11，就是回傳[0,1,1,2]
- 數字 mod == 1 → 1 + recursion (n/2)
- 數字 mod == 0 → recursion (n/2)
    - 然後寫好 recursion 邊界條件
    - N==1 return 1
    - N==0 return 0
- 因為這樣的解法會有很多重複，所以用一個 memory table 去記憶
- 然後 main function 會有一個 for 迴圈，由小到大的去 call recursion
- 簡化下來就會發現，用一個 array，找 array[n/2] + n&1 就是答案了