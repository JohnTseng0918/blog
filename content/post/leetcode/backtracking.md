---
title: "Backtracking 回溯法"
date: 2026-08-15
lastmod: 2026-10-23
draft: false
description: "回溯法列舉所有組合/路徑,含 Combination Sum、Word Search"
tags: ["leetcode", "backtracking"]
categories: ["演算法"]
---

## 39. Combination Sum

- 這題是給定一個數字 array，以及一個 target，要回傳所有組合總和是 target
- 要列出所有組合，很明顯就是 backtracking 的題目
- 所以先寫一個 backtracking 的 function，參數除了原先的 input 以外，也要記錄 path，以及走到第幾個 array index，還有數字總和
- 判斷基本上就是如果總和和 target 相同就加入 result 並 return
- 超出 target or index 超出範圍也 return
- Solution 1:
    - 加入 path
    - backtracking 同個 index
    - pop path
    - backtracking 下一個 index
- Solution 2:
    - for loop
        - 加入 path
        - backtracking i
        - pop path

## 79. Word Search

- 這題是給一個 2D 地圖，裡面有英文字母，並且給定一個英文單字，要找出地圖中是否有這個英文單字(必須相鄰，垂直相鄰或是水平相鄰)
- 這個就標準的 backtracking 題目
- 每一個點都要 call 一次 backtracking function
- backtracking function 的參數要有地圖，英文單字，座標，單字的 index
    - 因為 C++ string 不容易取 substring，因此使用 index 比較方便
    - function 內部就先檢查座標不要出界，index 不要超出單字長度
    - 還有字母和預期的單字[index]就 return false
    - 字母和單字的最後一個字(前面都檢查一樣了)相同就 return true
    - function 本體需要先把地圖的字母變成不存在的字元，避免重複被走過
    - 接下來就 if ( backtracking 1 || backtracking 2 || backtracking 3 || backtracking 4) return true
    - 最後把地圖復原
    - 都沒有找到就 return false