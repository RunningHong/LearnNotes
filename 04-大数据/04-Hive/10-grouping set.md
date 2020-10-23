[TOC]

# grouping sets

GROUP BY GROUPING SETS 是对 GROUP BY 子句的扩展，它能够在一个 GROUP BY 子句中一次实现多个集合的分组。其结果等价于将多个相应 GROUP BY 子句进行 UNION 操作。

特别地，一个空的子集意味着将所有的行聚集到一个分组。 GROUP BY 子句是只含有一个元素的 GROUP BY GROUPING SETS 的特例。

## 1 grouping set举例

GROUPING SETS 语句：

```text
SELECT k1, k2, SUM( k3 ) FROM t GROUP BY GROUPING SETS ( (k1, k2), (k1), (k2), ( ) );
```

其查询结果等价于：

```text
SELECT k1, k2, SUM( k3 ) FROM t GROUP BY k1, k2
UNION
SELECT k1, null, SUM( k3 ) FROM t GROUP BY k1
UNION
SELECT null, k2, SUM( k3 ) FROM t GROUP BY k2
UNION
SELECT null, null, SUM( k3 ) FROM t
```

例子：

```text
mysql> SELECT * FROM t;
+------+------+------+
| k1   | k2   | k3   |
+------+------+------+
| a    | A    |    1 |
| a    | A    |    2 |
| a    | B    |    1 |
| a    | B    |    3 |
| b    | A    |    1 |
| b    | A    |    4 |
| b    | B    |    1 |
| b    | B    |    5 |
+------+------+------+
8 rows in set (0.01 sec)

mysql> SELECT k1, k2, SUM(k3) FROM t GROUP BY GROUPING SETS ( (k1, k2), (k2), (k1), ( ) );
+------+------+-----------+
| k1   | k2   | sum(`k3`) |
+------+------+-----------+
| b    | B    |         6 |
| a    | B    |         4 |
| a    | A    |         3 |
| b    | A    |         5 |
| NULL | B    |        10 |
| NULL | A    |         8 |
| a    | NULL |         7 |
| b    | NULL |        11 |
| NULL | NULL |        18 |
+------+------+-----------+
9 rows in set (0.06 sec)
```

## 2 rollup

ROLLUP 是对 GROUPING SETS 的扩展。

```text
SELECT a, b,c, SUM( d ) FROM tab1 GROUP BY ROLLUP(a,b,c)
```

这个 ROLLUP 等价于下面的 GROUPING SETS：

```text
GROUPING SETS (
(a,b,c),
( a, b ),
( a),
( )
)
```

## 3 cube

CUBE 也是对 GROUPING SETS 的扩展。

```text
CUBE ( e1, e2, e3, ... )
```

其含义是 GROUPING SETS 后面列表中的所有子集。

例如，CUBE ( a, b, c ) 等价于下面的 GROUPING SETS：

```text
GROUPING SETS (
( a, b, c ),
( a, b ),
( a,    c ),
( a       ),
(    b, c ),
(    b    ),
(       c ),
(         )
)
```

## 