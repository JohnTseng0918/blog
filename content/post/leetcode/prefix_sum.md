---
title: "Prefix Sum 前綴和"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "前綴和搭配雜湊表解 subarray 總和問題,含 560、525、974、1658 等"
tags: ["leetcode", "prefix-sum"]
categories: ["演算法"]
---

## 238. Product of Array Except Self

- 這題的目標是給定一個 array，然後回傳 output 是其他 elements 的乘積
- 並且限定要在時間複雜度 O(n)
- 暴力法太簡單了就先跳過，直接從 prefix sum 的解題手法開始思考
  - prefix sum 通常是一路加到該項元素
  - 這題要乘積，我們就是一路乘到該項元素
  - 但我們要排除這項元素，那當然就是可以做"位移"
    - element 1 的 prefix product 就是第 0 項，也就是 1
    - element n 的 prefix product 就是第 n-1 項，也就是 1~n-1 乘積
  - 另一個方向來思考，那第 n 項也需要 n+1 項，當然也就是 1
  - 第一項的 suffix product 就是 2~n 的乘積
- 最後把兩個相乘即是解答
- 時間複雜度是兩個 for 迴圈，也就是 O(n)
- 接下來的 follow up 可以 optimize 空間複雜度
  - 計算 prefix/suffix product 可以不用把東西記下來
  - 第一個迴圈計算 prefix product，只要記錄前一個是多少，然後把結果也乘進去解答裡面就好了
  - 第二個迴圈計算 suffix product 同理

## 525. Contiguous Array

- 這題的目標是給定一個 `vector<int>`，都是 boolean，也就是 0 或 1
- 目標是找出一個最長的 subarray，使 0 的數目和 1 的數目是相等的，回傳總長
- 這題也有利用到 prefix sum 的觀念
- 我們可以把 0 和 1 總和加起來，把 0 當作-1，1 還是 1，所以總和是 0 的時候，就代表等數目
- 用一個 map 去記錄總和的 index，而且是最早出現的 index
- 後面如果出現相同總和，那和 index 相減就是一段 subarray 總和是 0
- 注意 mp[0] = -1，不然碰到第一個 0 會無法找出長度

## 560. Subarray Sum Equals K

- 目標是輸入一個 `vector<int>`，以及一個 target K
- 要回傳總共有幾個 subarray 的總和等於 K
- 使用 prefix sum 可以快速 query 兩個 index 之間的總和
- 但是因為每一個 subarray 都有可能總和是 K
- 這樣就會導致 O(N^2)的複雜度
- 所以使用一個 map 去做紀錄，記錄的是這個 prefix sum 數字出現的次數
- 並且每一個迴圈在看的時候，就是看該 prefix sum[index] - K 有沒有出現過
- 有的話就把出現次數加到答案裡面

## 930. Binary Subarrays With Sum

- 目標是輸入一個 `vector<int>`，以及一個 target goal
- 要回傳總共有幾個 subarray 的總和等於 goal
- 特別的是這一題的 input 都是 boolean，也就是 0 或 1
- 一樣有點類似 prefix sum 的概念，但我們不用每個都存起來(當然要存起來也行)
- 宣告一個 unordered map，一樣用來記錄 prefix sum 出現的次數，先讓 0 次數為 1
- 使用一個 for loop 去做判斷，先加到 total 裡面，並且判斷這個減去 goal 有沒有在 map 出現過
- 有的話就 res += 次數
- 最後把 mp[total]++

## 974. Subarray Sums Divisible by K

- 目標是輸入一個 `vector<int>`，以及一個 target K
- 要回傳總共有幾個 subarray 的總和可以被 K 整除
- 有 range query 的需求都先想到 prefix sum
- 處理完 prefix sum 之後，因為目標是找可以被整除的，所以我們只要處理餘數就好，然後餘數都要把他處理到正數
- 一樣使用一個 map 來記錄，該餘數有沒有出現過，只要有出現過，就代表這個 range 是可以被整除的
- 記得餘數 0 要先給 1，不然第一個可以單純被整除的數字會出錯

## 1658. Minimum Operations to Reduce X to Zero

- 給定一個 `vector<int>`，以及一個 x，可以從最左邊或最右邊選擇數字來做減法，使 X 等於 0
- 找出最少要選出幾個元素
- 這題有兩種解，可以用 sliding window，也可以使用 prefix sum，這裡使用 prefix sum 概念來解
- 把題目換另一個角度來想，就是找出最大的 subarray，使總和等於 sum - x
- 那就是每次 for loop 做加總，然後使用一個 map 去記錄暫時總和減去 num[i]有沒有出現在 map 裡面
- map 裡面記錄的是該總和出現的 index
- 如果有找到，就 max res
- 接下來判斷 map 裡面有沒有出現暫時的總和，沒有的話就把 index 記錄起來