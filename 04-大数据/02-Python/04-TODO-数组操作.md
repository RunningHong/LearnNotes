[TOC]

# 数组操作

## 1 数组遍历

### 1.1 for xx in xx

```python
colours = ["red","green","blue"]
for colour in colours:
    print colour
    
# red
# green
# blue
```

### 1.2 下标遍历

```python
colours = ["red","green","blue"]
for i in range(0, len(colours)):
    print i, colour[i]
 
# 0 red
# 1 green
# 2 blue


可简写为以下格式：
for i, item in enumerate(colours):
  print i, item
  
# 0 red
# 1 green
# 2 blue
```

## 2 添加元素

