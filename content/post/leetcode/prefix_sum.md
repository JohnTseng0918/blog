---
title: "Prefix Sum 前綴和"
date: 2026-08-15
draft: false
description: "前綴和搭配雜湊表解 subarray 總和問題,含 560、525、974、1658 等"
tags: ["leetcode", "prefix-sum"]
categories: ["演算法"]
---

## 238. Product of Array Except Self

- 這題的目標是給定一個array，然後回傳output是其他elements的乘積
- 並且限定要在時間複雜度O(n)
- 暴力法太簡單了就先跳過，直接從prefix sum的解題手法開始思考
  - prefix sum 通常是一路加到該項元素
  - 這題要乘積，我們就是一路乘到該項元素
  - 但我們要排除這項元素，那當然就是可以做"位移"
    - elememt 1 的 prefix product 就是 第0項，也就是1
    - elememt n 的 prefix product 就是 第n-1項，也就是1~n-1乘積
  - 另一個方向來思考，那第n項也需要n+1項，當然也就是1
  - 第一項的 suffix product 就是 2~n的乘積
- 最後把兩個相乘即是解答
- 時間複雜度是兩個for迴圈，也就是O(n)
- 接下來的follow up 可以optimize空間複雜度
  - 計算prefix/suffix product可以不用把東西記下來
  - 第一個迴圈計算prefix product，只要記錄前一個是多少，然後把結果也乘進去解答裡面就好了
  - 第二個迴圈計算suffix product同理

## 525. Contiguous Array

- 這題的目標是給定一個vector<int>，都是boolean，也就是0或1
- 目標是找出一個最長的subarray，使0的數目和1的數目是相等的，回傳總長
- 這題也有利用到prefix sum的觀念
- 我們可以把0和1總和加起來，把0當作-1，1還是1，所以總和是0的時候，就代表等數目
- 用一個map去記錄總和的index，而且是最早出現的index
- 後面如果出現相同總和，那和index相減就是一段subarray總和是0
- 注意mp[0] = -1，不然碰到第一個0會無法找出長度

## 560. Subarray Sum Equals K

- 目標是輸入一個vector<int>，以及一個target K
- 要回傳總共有幾個subarray的總和等於K
- 使用prefix sum可以快速query兩個index之間的總和
- 但是因為每一個subarray都有可能總和是K
- 這樣就會導致O(N^2)的複雜度
- 所以使用一個map去做紀錄，記錄的是這個prefix sum數字出現的次數
- 並且每一個迴圈在看的時候，就是看該prefix sum[index] - K有沒有出現過
- 有的話就把出現次數加到答案裡面

## 930. Binary Subarrays With Sum

- 目標是輸入一個vector<int>，以及一個target goal
- 要回傳總共有幾個subarray的總和等於goal
- 特別的是這一題的input都是boolean，也就是0或1
- 一樣有點類似prefix sum的概念，但我們不用每個都存起來(當然要存起來也行)
- 宣告一個unordered map，一樣用來記錄prefix sum出現的次數，先讓0次數為1
- 使用一個for loop去做判斷，先加到total裡面，並且判斷這個減去goal有沒有在map出現過
- 有的話就res += 次數
- 最後把mp[total]++

## 974. Subarray Sums Divisible by K

- 目標是輸入一個vector<int>，以及一個target K
- 要回傳總共有幾個subarray的總和可以被K整除
- 有range query的需求都先想到prefix sum
- 處理完prefix sum之後，因為目標是找可以被整除的，所以我們只要處理餘數就好，然後餘數都要把他處理到正數
- 一樣使用一個map來記錄，該餘數有沒有出現過，只要有出現過，就代表這個range是可以被整除的
- 記得餘數0要先給1，不然第一個可以單純被整除的數字會出錯

## 1658. Minimum Operations to Reduce X to Zero

- 給定一個vector<int>，以及一個x，可以從最左邊或最右邊選擇數字來做減法，使X等於0
- 找出最少要選出幾個元素
- 這題有兩種解，可以用sliding window，也可以使用prefix sum，這裡使用prefix sum概念來解
- 把題目換另一個角度來想，就是找出最大的subarray，使總和等於sum - x
- 那就是每次for loop做加總，然後使用一個map去記錄暫時總和減去num[i]有沒有出現在map裡面
- map裡面記錄的是該總和出現的index
- 如果有找到，就max res
- 接下來判斷map裡面有沒有出現暫時的總和，沒有的話就把index記錄起來