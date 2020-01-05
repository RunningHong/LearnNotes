[TOC]

## 1 shell方法返回字符串

```shell
#!/bin/sh

# 示例方法
function get_str() {
	echo "string"
}

#写法一
echo `get_str` 

 #写法二
echo $(get_str)
```

