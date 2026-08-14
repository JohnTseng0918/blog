---
title: "Monotonic Stack 單調堆疊"
date: 2026-08-15
draft: false
description: "單調堆疊解法,含 Trapping Rain Water、Maximum Subarray Min-Product"
tags: ["leetcode", "monotonic-stack", "stack"]
categories: ["演算法"]
---

## 42. Trapping Rain Water

- 給定一個vector<int>，代表的意義是牆壁高度，目標是要回傳可以裝多少水
- 例如[3,0,1]就代表可以裝1的水
- 這題思維可以使用monotonic stack
- 順著vector index前進的話，如果我遇到一個高牆，就會想要知道上一堵高牆在哪裡
- 兩個高牆之間可以裝多少水，所以是一個非遞增的stack
- 也就是說，現在牆壁比stack高，我就pop stack，這裡是用一個while loop去判斷
- 被pop的數字，代表的是上一個高牆位址
    - 如果這時候stack是空，那就可以return，因為現在比較高，左邊比較矮，但是更左邊沒牆壁，所以裝不了水
- 所以要再往前看一個數字，也就是stack top，左邊的左邊，這樣就有辦法形成一個裝水的容器了
    - 左邊的左邊一定比左邊高，而現在也一定比左邊高
    - 所以比較一下左邊的左邊-左邊，現在-左邊，兩個取Min，就代表裝水的高度
    - 現在的位置-左邊的左邊的位址，代表的是裝水的寬度
    - 所以答案+=長*寬

## 1856. Maximum Subarray Min-Product

- 這題題目給定一個array，要尋找出最大值的min-product
- Min-product是subarray最小值乘上subarray總和
- 這題需要用到prefix sum的觀念，因為要查詢subarray總和
- 另一個想法是要記錄比較小的數字的index的位置
- 計算的時候需要知道該subarray最小值是誰，以及上一個最小值在哪裡
- 這個時候會需要用到monotonic stack的觀念，也就是maintain一個stack，他要非遞減
- 如果發現當下的數值比stack top小，那就pop stack
    - Pop的數值是該subarray最小值
    - 計算subarray sum的範圍是pop後的stack位置+1
    - 也就是上一個更小的值到現在這個index都是計算範圍