---
title: "Dynamic Programming 動態規劃"
date: 2026-09-09
draft: false
description: "DP 入門題,含 Climbing Stairs、Best Time to Buy and Sell Stock、Counting Bits"
tags: ["leetcode", "dynamic-programming"]
categories: ["演算法"]
---

## 53. Maximum Subarray

- 給定一個array，找出subarray sum的最大值
- Kadane's Algorithm
- 如果是暴力法，那就是兩層迴圈可以搞定的問題 O(n^2)
- 這題也可以使用prefix sum的觀念來解
  - 就會變成一個prefix_sum_array，要找出prefix_sum_array[i] - prefix_sum_array[j]最大值，當 i > j
  - 這就是被reduce成121題了
  - 邏輯就是prefix sum array elements相減，那就是該subarray的和
  - O(n)
- DP解法:
  - 定義sub是「以nums[i]結尾」的maximum subarray sum，注意不是「前i個元素」的答案
  - 走到i只有兩個選擇: 接在前一段後面，或是從自己重新開始一段
  - sub = max(sub + nums[i], nums[i])
  - 真正的答案再拿每一個sub去更新: res = max(res, sub)
  - O(n)

## 70. Climbing Stairs

- 爬梯子，一次只能走一步或兩步，給定n，回傳總共有幾種走法
- 仔細觀察
- 1: 1
- 2: 1+1, 2
- 3: 1+2, 1+1+1, 2+1
- 4: 1+1+2, 2+2, 1+2+1, 1+1+1+1, 2+1+1
- 也就是前兩項相加，這題算簡單就可以得出來

## 121. Best Time to Buy and Sell Stock

- 給定一個股價list，要找出買和賣可以賺最多錢的一次交易組合
    - 也就是只買賣一次，如果找不到賺錢組合，就回傳0
- Kadane's Algorithm
- 因為要最大化交易，就是要找出左邊最小，右邊最大的一組
- 可以透過一個for迴圈
    - 反向思考: index大到小
        - max_val = max(max_val, nums[i])
        - res = max(res, max_val - nums[i])
    - 正向思考: index小到大
        - min_val = min(min_val, nums[i])
        - res = max(res, nums[i] - min_val)
- O(n)

## 338. Counting Bits

- 給一個數字n ，回傳array size n+1，裡面是所有數字的binary表示法的1的數量
- 0 : 0b0, 1:0b1, 2:0b10, 3: 0b11 ，就是回傳[0,1,1,2]
- 數字mod == 1 → 1 + recursion (n/2)
- 數字mod == 0 → recursion (n/2)
    - 然後寫好recursion邊界條件
    - N==1 return 1
    - N==0 return 0
- 因為這樣的解法會有很多重複，所以用一個memory table去記憶
- 然後main function會有一個for迴圈，由小到大的去call recursion
- 簡化下來就會發現，用一個array，找array[n/2] + n&1就是答案了