[toc]

# Stream流式计算

## 1 简介

Java 8 引入了流式操作（Stream），通过该操作可以实现对集合（Collection）的并行处理和函数式操作。根据操作返回的结果不同，流式操作分为中间操作和最终操作两种。最终操作返回一特定类型的结果，而中间操作返回流本身，这样就可以将多个操作依次串联起来。根据流的并发性，流又可以分为串行和并行两种。流式操作实现了集合的过滤、排序、映射等功能。

流有串行和并行两种，串行流上的操作是在一个线程中依次完成，而并行流则是在多个线程上同时执行。并行与串行的流可以相互切换：通过 stream.sequential() 返回串行的流，通过 stream.parallel() 返回并行的流。相比较串行的流，并行的流可以很大程度上提高程序的执行效率

Stream 和Collection集合的区别：Collection是一种静态的数据结构，而Stream是有关计算的，前者主要面向内存，存储在内存中，后者主要面向CPU，通过CPU计算 

## 2 Stream

Stream操作分为**中间操作**或者**末尾操作**两种：

- 中间操作：返回Stream本身，这样就可以将多个操作依次串起来

    ```
    例如：
    map、flatMap、filter、distinct、sorted、peek、limit、skip、parallel、sequential、unordered
    ```

- 末尾操作：返回一特定类型的计算结果

    ```
    例如：
    forEach、forEachOrdered、toArray、reduce、collect、min、max、count、anyMatch、allMatch、noneMatch、findFirst、findAny、iterator
    ```

```java
public class StreamTest {
    List<User> list;
 
    @Before
    public void init() {
        list = new ArrayList<User>(){
            {
                add(new User(1l,"张三",10, "清华大学"));
                add(new User(2l,"李四",12, "清华大学"));
                add(new User(3l,"王五",15, "清华大学"));
                add(new User(4l,"赵六",12, "清华大学"));
                add(new User(5l,"田七",25, "北京大学"));
                add(new User(6l,"小明",16, "北京大学"));
                add(new User(7l,"小红",14, "北京大学"));
                add(new User(8l,"小华",14, "浙江大学"));
                add(new User(9l,"小丽",17, "浙江大学"));
                add(new User(10l,"小何",10, "浙江大学"));
            }
        };
    }
}
 
class User {
    public Long id;       //主键id
    public String name;   //姓名
    public Integer age;   //年龄
    public String school; //学校
 
    public User(Long id, String name, Integer age, String school) {
        this.id = id;
        this.name = name;
        this.age = age;
        this.school = school;
    }
 
    public Long getId() {
        return id;
    }
 
    public void setId(Long id) {
        this.id = id;
    }
 
    public String getName() {
        return name;
    }
 
    public void setName(String name) {
        this.name = name;
    }
 
    public Integer getAge() {
        return age;
    }
 
    public void setAge(Integer age) {
        this.age = age;
    }
 
    public String getSchool() {
        return school;
    }
 
    public void setSchool(String school) {
        this.school = school;
    }
 
    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", age=" + age +
                ", school='" + school + '\'' +
                '}';
    }
}
```

### 2.1 中间操作

#### 1 filter -  过滤 

```java
    @Test
    public void test4() {
        // 过滤list得到user的school是清欢大学的人
        List<User> userList1 = list.stream().filter(user -> "清华大学".equals(user.getSchool())).collect(Collectors.toList());
        
        userList1.forEach(user -> System.out.println(user.name));
    }
```

#### 2 distinct -  去重

```java
    @Test
    public void test5() {
        System.out.println("按年龄去重得到去重年龄list");
        List<Integer> userAgeList = list.stream().map(User::getAge).distinct().collect(Collectors.toList());
        System.out.println("userAgeList = " + userAgeList);
    }
```

#### 3 limit - 限制条数

```java
    @Test
    public void test6() {
        System.out.println("年龄是偶数的前两位user");
        List<User> userList3 = list.stream().filter(user -> user.getAge() % 2 == 0).limit(2).collect(Collectors.toList());
        userList3.forEach(user -> System.out.print(user.name + '、'));
    }
```

#### 4 sorted - 排序

```java
    @Test
    public void test7() {
        System.out.println("按年龄从大到小排序");
        List<User> userList4 = list.stream().sorted((s1,s2) -> s2.age - s1.age).collect(Collectors.toList());
        userList4.forEach(user -> System.out.print(user.name + '、'));
    }
```

#### 5 skip -  跳过n个元素后再输出 

```java
    @Test
    public void test8() {
        System.out.println("跳过前面两个user的其他所有user");
        List<User> userList5 = list.stream().skip(2).collect(Collectors.toList());
        userList5.forEach(user -> System.out.print(user.name + '、'));
    }
```

#### 6 map - 对每个元素做特定的操作

```java
    @Test
    public void test9() {
        System.out.println("学校是清华大学的user的名字");
        List<String> userList6 = list.stream().filter(user -> "清华大学".equals(user.school)).map(User::getName).collect(Collectors.toList());
        userList6.forEach(user -> System.out.print(user + '、'));
    }
```

- mapToInt(ToIntFunction<? super T> mapper)
- mapToDouble(ToDoubleFunction<? super T> mapper)
- mapToInt(ToIntFunction<? super T> mapper)

map做一些事情后，这些映射分别返回对应类型的流

```java
@Test
public void test10() {
    System.out.println("学校是清华大学的user的年龄总和");
    int userList7 = list.stream().filter(user -> "清华大学".equals(user.school)).mapToInt(User::getAge).sum();
    System.out.println( "学校是清华大学的user的年龄总和为： "+userList7);
}
```
#### 7 flatMap -  将遍历的值转成一个新的流 

```java
    @Test
    public void test11() {
        String[] strings = {"Hello", "World"};
        String s = "hello";
        String[] split = s.split("");
        List l1 = Arrays.stream(strings).map(str -> str.split("")).map(Arrays::stream).distinct().collect(Collectors.toList());
//        List l1 = Arrays.stream(split).distinct().collect(Collectors.toList());
        List l2 = Arrays.asList(strings).stream().map(str -> str.split("")).flatMap(Arrays::stream).distinct().collect(Collectors.toList());
        System.out.println(l1.toString());
        System.out.println(l2.toString());
    }
```

### 2.2 终端操作

#### 1 allMatch -  检测是否全部都满足指定的条件，如果全部满足则返回true。 

```java
    @Test
    public void test12() {
        System.out.println("判断是否所有user的年龄都大于9岁");
        Boolean b = list.stream().allMatch(user -> user.age >9);
        System.out.println(b);
    }
```

#### 2 anyMatch -  检测是否存在一个或多个满足指定的参数行为，如果满足则返回true。 

```java
    @Test
    public void test13() {
        System.out.println("判断是否有user的年龄是大于15岁");
        Boolean bo = list.stream().anyMatch(user -> user.age >15);
        System.out.println(bo);
    }
```

#### 3 noneMatch -  检测是否不存在满足指定行为的元素，如果不存在则返回true。 

```java
    @Test
    public void test14() {
        System.out.println("判断是否不存在年龄是15岁的user");
        Boolean boo = list.stream().noneMatch(user -> user.age == 15);
        System.out.println(boo);
    }
```

#### 4 findFirst -  返回满足条件的第一个元素

```java
   @Test
    public void test15() {
        System.out.println("返回年龄大于12岁的user中的第一个");
        Optional<User> first = list.stream().filter(u -> u.age > 10).findFirst();
        User user = first.get();
        System.out.println(user.toString());
    }
```

#### 5 findAny - 返回满足条件的任意一个元素

 findAny相对于findFirst的区别在于，findAny不一定返回第一个，而是返回任意一个 

```java
@Test
public void test16() {
    System.out.println("返回年龄大于12岁的user中的任意一个");
    Optional<User> anyOne = list.stream().filter(u -> u.age > 10).findAny();
    User user2 = anyOne.get();
    System.out.println(user2.toString());
```

6 reduce - 

现在的目标不是返回一个新的集合，而是希望对经过参数化操作后的集合进行进一步的运算，那么我们可用对集合实施归约操作。java8的流式处理提供了reduce方法来达到这一目的。 

```java

    @Test
    public void test17() {
        Integer ages = list.stream().filter(student -> "清华大学".equals(student.school)).mapToInt(User::getAge).sum();
        System.out.println(ages);
        System.out.println("归约 - - 》 start ");
        Integer ages2 = list.stream().filter(student -> "清华大学".equals(student.school)).map(User::getAge).reduce(0,(a,c)->a+c);
        Integer ages3 = list.stream().filter(student -> "清华大学".equals(student.school)).map(User::getAge).reduce(0,Integer::sum);
//        Integer ages4 = list.stream().filter(student -> "清华大学".equals(student.school)).map(User::getAge).reduce(Integer::sum).get();
        Integer ages4 = list.stream().map(User::getAge).reduce(Integer::sum).get();
        System.out.println(ages2);
        System.out.println(ages3);
        System.out.println(ages4);
        System.out.println("归约 - - 》 end ");
    }
```

#### 6 counting - 计数

```java

    @Test
    public void test18() {
        System.out.println("user的总人数");
        long COUNT = list.stream().count();//简化版本
        long COUNT2 = list.stream().filter( user -> user.age > 10).collect(Collectors.counting());//原始版本
        System.out.println(COUNT);
        System.out.println(COUNT2);
    }
```

#### 7 maxBy、minBy 最值

```java
   @Test
    public void test19() {
        System.out.println("user的年龄最大值和最小值");
        Integer maxAge =list.stream().collect(Collectors.maxBy((s1, s2) -> s1.getAge() - s2.getAge())).get().age;
        Integer maxAge2 = list.stream().collect(Collectors.maxBy(Comparator.comparing(User::getAge))).get().age;
        Integer minAge = list.stream().collect(Collectors.minBy((S1,S2) -> S1.getAge()- S2.getAge())).get().age;
        Integer minAge2 = list.stream().collect(Collectors.minBy(Comparator.comparing(User::getAge))).get().age;
        System.out.println("maxAge = " + maxAge);
        System.out.println("maxAge2 = " + maxAge2);
        System.out.println("minAge = " + minAge);
        System.out.println("minAge2 = " + minAge2);
    }
```

#### 8 summingInt、summingLong、summingDouble 聚合

```java
    @Test
    public void test20() {
        System.out.println("user的年龄总和");
        Integer sumAge =list.stream().collect(Collectors.summingInt(User::getAge));
        System.out.println("sumAge = " + sumAge);
    }
```

#### 9 averageInt、averageLong、averageDouble 平均值

```java
    @Test
    public void test21() {
        System.out.println("user的年龄平均值");
        double averageAge = list.stream().collect(Collectors.averagingDouble(User::getAge));
        System.out.println("averageAge = " + averageAge);
    }
```

#### 10 joining - 拼接

```java
@Test
public void test23() {
    System.out.println("字符串拼接");
    String names = list.stream().map(User::getName).collect(Collectors.joining(","));
    System.out.println("names = " + names);
}
```
#### 11 groupingBy - 分组

```java

    @Test
    public void test24() {
        System.out.println("分组");
        Map<String, List<User>> collect1 = list.stream().collect(Collectors.groupingBy(User::getSchool));
        Map<String, Map<Integer, Long>> collect2 = list.stream().collect(Collectors.groupingBy(User::getSchool, Collectors.groupingBy(User::getAge, Collectors.counting())));
        Map<String, Long> collect3 = list.stream().collect(Collectors.groupingBy(User::getSchool, Collectors.counting()));
        Map<String, Map<Integer, Map<String, Long>>> collect4 = list.stream().collect(Collectors.groupingBy(User::getSchool, Collectors.groupingBy(User::getAge, Collectors.groupingBy(User::getName,Collectors.counting()))));
        System.out.println("collect1 = " + collect1);
        System.out.println("collect2 = " + collect2);
        System.out.println("collect3 = " + collect3);
        System.out.println("collect4 = " + collect4);
    }
```

## 3 举例

```java
/**
 * 现有5个用户，需要做一下一系列事情：
 * 1. ID偶数的
 * 2. 年纪大于23岁
 * 3. 用户名转为大写字母
 * 4. 用户名字母倒排序
 * 5. 只输出一个用户
 */
    @Test
    public void test24() {
        System.out.println("分组");
        Map<String, List<User>> collect1 = list.stream().collect(Collectors.groupingBy(User::getSchool));
        Map<String, Map<Integer, Long>> collect2 = list.stream().collect(Collectors.groupingBy(User::getSchool, Collectors.groupingBy(User::getAge, Collectors.counting())));
        Map<String, Long> collect3 = list.stream().collect(Collectors.groupingBy(User::getSchool, Collectors.counting()));
        Map<String, Map<Integer, Map<String, Long>>> collect4 = list.stream().collect(Collectors.groupingBy(User::getSchool, Collectors.groupingBy(User::getAge, Collectors.groupingBy(User::getName,Collectors.counting()))));
        System.out.println("collect1 = " + collect1);
        System.out.println("collect2 = " + collect2);
        System.out.println("collect3 = " + collect3);
        System.out.println("collect4 = " + collect4);
    }
```



## ps-相关引用

https://blog.csdn.net/u010365717/article/details/107716199