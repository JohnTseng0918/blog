---
title: "Priority Queue 優先佇列"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "以優先佇列(heap)解 Top-K 類問題,含 373、378"
tags: ["leetcode", "priority-queue", "heap"]
categories: ["演算法"]
---

## 373. Find K Pairs with Smallest Sums

- 這題是給定兩個 array，從兩個 array 各取一個元素可以得到一個 pair
- 目標是要回傳 K 個 pair 相加起來總和最小的 pair
- 這題最簡單的想法就是把所有的 pair 放到 priority queue 裡面之後直接取出 K 個 pair 來
- 這個方法是可以 work 但會因為使用的 memory 過大所以 fail
- 因為兩個 array 都是有 sort 過的，所以要利用這一點
- 我們只把第一個 array 放進 priority queue，(sums, array 2 index)
- 也就是第一個是 array 1 + array 2 [0], array 2 index 0
- 取出一個 item 後，就可以更新成 array 1 + array 2 [1], array 2 index 1
- 因為排序過，所以 array 後面的東西沒太多意義，只要把 index 記錄起來就好
- Priority queue size 就會從 m*n 降低到變成 m

## 378. Kth Smallest Elements in a Sorted Matrix

- 這題給定的一個 matrix 的 row, column 都是遞增，要回傳第 k 個 elements
- 因為有使用 memory 爆炸的經驗，所以只記錄座標和 value，放進 priority queue 裡面就好
- 另一個解法是 binary search，left 是 0,0 的 value，right 是最大的 value
    - 然後 mid 找出來之後，就計算有多少個點比他小於等於