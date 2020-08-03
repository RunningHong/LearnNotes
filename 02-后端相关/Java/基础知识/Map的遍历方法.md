[TOC]

# 1 Map的遍历方法

Map的遍历方法总是写了忘，忘了再记，在这再总结一波。

## 1.1 使用entries来遍历（推荐）

```java
    /**
     * 使用Map的内部类来遍历map
     */
    public void mapErgodicByEntries(Map<String, String> map) {
        for(Map.Entry<String, String> entry:map.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue();
            System.out.println("【"+key+":"+value+"】");
        }
    }
```

如果你遍历的是一个空的map对象，for-each循环将抛出NullPointerException，因此在遍历前你总是应该检查空引用。

## 1.2 for-each单独遍历key或value

```java
	/**
	 * 单独遍历key或value
	 */
	public void mapErgodicKeysOrValues(Map<String, String> map) {
		// 根据keySet单独遍历key
		for(String key: map.keySet()) {
			System.out.println("key:"+key);
		}
		
		// 根据values单独遍历values
		for(String value : map.values()) {
			System.out.println(" value:"+ value);
		}
	}
```

## 1.3 使用Iterator迭代entries

```java
	/**
	 * 使用Iterator迭代entries
	 * @param map
	 */
	public void mapErgodicByIterator(Map<String, String> map) {
		Iterator<Map.Entry<String, String>> iter = map.entrySet().iterator();
		
		while(iter.hasNext()) {
			Map.Entry<String, String> entry = iter.next();
			
			String key = entry.getKey();
			String value = entry.getValue();
			
			String message = "【"+key+":"+value+"】";
			System.out.println(message);
		}
	}
```

## 1.4 通过键找值遍历（效率低）

```java
	/**
	 * 通过键找值遍历（效率低）
	 */
	public void mapErgodicByKeyFoundValue(Map<String, String> map) {
		for(String key : map.keySet()) {
			String value = map.get(key);
			System.out.println("【"+key+":"+value+"】");
		}
	}
```

