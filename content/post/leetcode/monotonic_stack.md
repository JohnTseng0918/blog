---
title: "Monotonic Stack 單調堆疊"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "單調堆疊解法,含 Trapping Rain Water、Maximum Subarray Min-Product"
tags: ["leetcode", "monotonic-stack", "stack"]
categories: ["演算法"]
---

## 42. Trapping Rain Water

- 給定一個 `vector<int>`，代表的意義是牆壁高度，目標是要回傳可以裝多少水
- 例如[3,0,1]就代表可以裝 1 的水
- 這題思維可以使用 monotonic stack
- 順著 vector index 前進的話，如果我遇到一個高牆，就會想要知道上一堵高牆在哪裡
- 兩個高牆之間可以裝多少水，所以是一個非遞增的 stack
- 也就是說，現在牆壁比 stack 高，我就 pop stack，這裡是用一個 while loop 去判斷
- 被 pop 的數字，代表的是上一個高牆位置
    - 如果這時候 stack 是空，那就可以 return，因為現在比較高，左邊比較矮，但是更左邊沒牆壁，所以裝不了水
- 所以要再往前看一個數字，也就是 stack top，左邊的左邊，這樣就有辦法形成一個裝水的容器了
    - 左邊的左邊一定比左邊高，而現在也一定比左邊高
    - 所以比較一下左邊的左邊-左邊，現在-左邊，兩個取 Min，就代表裝水的高度
    - 現在的位置-左邊的左邊的位置，代表的是裝水的寬度
    - 所以答案+=長*寬

## 1856. Maximum Subarray Min-Product

- 這題題目給定一個 array，要尋找出最大值的 min-product
- Min-product 是 subarray 最小值乘上 subarray 總和
- 這題需要用到 prefix sum 的觀念，因為要查詢 subarray 總和
- 另一個想法是要記錄比較小的數字的 index 的位置
- 計算的時候需要知道該 subarray 最小值是誰，以及上一個最小值在哪裡
- 這個時候會需要用到 monotonic stack 的觀念，也就是 maintain 一個 stack，他要非遞減
- 如果發現當下的數值比 stack top 小，那就 pop stack
    - Pop 的數值是該 subarray 最小值
    - 計算 subarray sum 的範圍是 pop 後的 stack 位置+1
    - 也就是上一個更小的值到現在這個 index 都是計算範圍