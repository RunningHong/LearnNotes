# SimpleDateFormat使用详解

符号代表的意思：

```txt
  G 年代标志符
  y 年
  M 月
  d 日
  h 时 在上午或下午 (1~12)
  H 时 在一天中 (0~23)
  m 分
  s 秒
  S 毫秒
  E 星期
  D 一年中的第几天
  F 一月中第几个星期几
  w 一年中第几个星期
  W 一月中第几个星期
  a 上午 / 下午 标记符 
  k 时 在一天中 (1~24)
  K 时 在上午或下午 (0~11)
  z 时区
```



输出示例：

```java
// 输出【2018年11月12日 20时33分12秒】
SimpleDateFormat myFmt=new SimpleDateFormat("yyyy年MM月dd日 HH时mm分ss秒");
String timeMessage = myFmt.format(new Date());
System.out.println(timeMessage);

// 输出【18/11/12 20:33】
SimpleDateFormat myFmt1=new SimpleDateFormat("yy/MM/dd HH:mm"); 

// 输出【2018-11-12 20:33:12】
SimpleDateFormat myFmt2=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");


// 输出【2018年11月12日 20时33分12秒 1】
SimpleDateFormat myFmt3=new SimpleDateFormat("yyyy年MM月dd日 HH时mm分ss秒 E ");
```

