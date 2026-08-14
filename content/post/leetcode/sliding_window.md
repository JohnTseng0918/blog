---
title: "Sliding Window 滑動視窗"
date: 2026-08-15
draft: false
description: "滑動視窗解連續子陣列/子字串,含 Longest Substring、Reduce X to Zero"
tags: ["leetcode", "sliding-window", "two-pointers"]
categories: ["演算法"]
---

## 3. Longest Substring Without Repeating Characters

- 給定一個字串，找出最長的子字串長度，並且子字串沒有重複的字元，回傳子字串長度
- 這題的思維是，應該會需要一個for迴圈從左掃到右，並且與此同時，也要把左邊的index記錄起來
    - 這樣右-左+1就是一個沒有重複的子字串
- 所以需要一個map去記錄遇到的字元，它最後出現的位址
- 每一次掃過去的時候，先檢查map，沒有查找到就是沒有repeat
    - 如果有找到，就要把左邊index移到該字串上一次出現的位址的右邊一個

## 1658. Minimum Operations to Reduce X to Zero

- 給定一個vector<int>，以及一個x，可以從最左邊或最右邊選擇數字來做減法，使X等於0
- 找出最少要選出幾個元素
- 這題有兩種解，可以用sliding window，也可以使用prefix sum，這裡使用sliding window來解
- 一樣想法是把題目換一個角度看，就是找出最大的subarray總和是sum - x
- 用兩個index指標，left and right，先令left = 0
- right放在for loop裡面iterate，每次都先把nums[right]加到暫時的總和裡面
- 然後判斷這個暫時總和有沒有超過sum - x
- 超過就用一個for loop去判斷，每次右移一個left，新的總和是多少
- 然後判斷一下暫時總和有沒有相等sum - x，有的話就取一下max