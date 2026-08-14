---
title: "Priority Queue 優先佇列"
date: 2026-08-15
draft: false
description: "以優先佇列(heap)解 Top-K 類問題,含 347、373、378"
tags: ["leetcode", "priority-queue", "heap"]
categories: ["演算法"]
---

## 347. Top K Frequent Elements

- 這題是給定一個array，回傳出現頻率最高的K個數字
- 那這題就是先用一個map把頻率記錄起來
- 然後每個map的key value pair放到priority queue裡面
- 這個困難點是要知道C++ priority queue怎麼寫
- 最後把K個item從priority queue中取出來就是答案

## 373. Find K Pairs with Smallest Sums

- 這題是給定兩個array，從兩個array各取一個元素可以得到一個pair
- 目標是要回傳K個pair相加起來總和最小的pair
- 這題最簡單的想法就是把所有的pair放到priority queue裡面之後直接取出K個pair來
- 這個方法是可以work但會因為使用的memory過大所以fail
- 因為兩個array都是有sort過的，所以要利用這一點
- 我們只把第一個array放進priority queue，(sums, array 2 index)
- 也就是第一個是array 1 + array 2 [0], array 2 index 0
- 取出一個item後，就可以更新成array 1 + array 2 [1], array 2 index 1
- 因為排序過，所以array後面的東西沒太多意義，只要把index記錄起來就好
- Priority queue size就會從 m*n 降低到變成m

## 378. Kth Smallest Elements in a Sorted Matrix

- 這題給定的一個matrix的row, column都是遞增，要回傳第k個elements
- 因為有使用memory爆炸的經驗，所以只紀錄座標和value，放進priorty queue裡面就好
- 另一個解法是binary search，left是0,0的value，right是最大的value
    - 然後mid找出來之後，就計算有多少個點比他小於等於