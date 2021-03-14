# Sets源码阅读

Sets主要是Java中Set的封装类，并提供了一些常用的操作。

## 1 union方法

```java
 public static <E> SetView<E> union(
      final Set<? extends E> set1, final Set<? extends E> set2) {
    checkNotNull(set1, "set1");
    checkNotNull(set2, "set2");

    final Set<? extends E> set2minus1 = difference(set2, set1);

    return new SetView<E>() {
      // 直接返回两个size的总和
      @Override public int size() {
        return set1.size() + set2minus1.size();
      }
      @Override public boolean isEmpty() {
       	// 两次判断，判断是否两个set都为空
        return set1.isEmpty() && set2.isEmpty();
      }
      @Override public Iterator<E> iterator() {
        // 在这使用Iterators.concat，对两个Set的迭代器进行融合
        return Iterators.unmodifiableIterator(
            Iterators.concat(set1.iterator(), set2minus1.iterator()));
      }
        
      // 单纯的从每个set中判断是否存在
      @Override public boolean contains(Object object) {
        return set1.contains(object) || set2.contains(object);
      }
        
      // 分别把集合加入其中
      @Override public <S extends Set<E>> S copyInto(S set) {
        set.addAll(set1);
        set.addAll(set2);
        return set;
      }
      @Override public ImmutableSet<E> immutableCopy() {
        return new ImmutableSet.Builder<E>()
            .addAll(set1).addAll(set2).build();
      }
    };
  }
```

union主要对Set进行合并操作，其实Sets并没有对Set进行真正意义上的合并，而是通过一个SetView类巧妙的对Set几个常用的方法进行了实现。

## 2 intersection

```java
  public static <E> SetView<E> intersection(
      final Set<E> set1, final Set<?> set2) {
    checkNotNull(set1, "set1");
    checkNotNull(set2, "set2");

    // 创建一个过滤规则（规则为：全部set2元素）
    final Predicate<Object> inSet2 = Predicates.in(set2);
    
    return new SetView<E>() {
      // 返回set1中包含set2中的所有元素
      @Override public Iterator<E> iterator() {
        return Iterators.filter(set1.iterator(), inSet2);
      }
        
      // 返回迭代器的需要迭代的大小
      @Override public int size() {
        return Iterators.size(iterator());
      }
        
      // 根据迭代器判断是否为空
      @Override public boolean isEmpty() {
        return !iterator().hasNext();
      }
        
      @Override public boolean contains(Object object) {
        return set1.contains(object) && set2.contains(object);
      }
      @Override public boolean containsAll(Collection<?> collection) {
        return set1.containsAll(collection)
            && set2.containsAll(collection);
      }
    };
  }
```

返回两组交集的不可修改视图。返回的集合包含两个支持集合包含的所有元素。

## 3 difference

```java
public static <E> Sets.SetView<E> difference(final Set<E> set1, final Set<?> set2) {
    Preconditions.checkNotNull(set1, "set1");
    Preconditions.checkNotNull(set2, "set2");
    // 创建一个过滤规则（规则为，不能包含set2中的元素）
    final Predicate notInSet2 = Predicates.not(Predicates.in(set2));
    
    return new Sets.SetView(null) {
        //重写iterator，使用Iterators.filter过滤出不含set2元素的一个迭代器
        public Iterator<E> iterator() {
            return Iterators.filter(set1.iterator(), notInSet2);
        }
        
        //根据最终返回的迭代器计算长度
        public int size() {
            return Iterators.size(this.iterator());
        }
        
        //如果set1和set2中全部相等，就为空
        public boolean isEmpty() {
            return set2.containsAll(set1);
        }
        
        public boolean contains(Object element) {
            return set1.contains(element) && !set2.contains(element);
        }
    };
```

使用Predicates创建一个过滤规则。使用规则达到自己的目的。

## 总结

当我们做交并补集操作的时候可以使用Guava的Sets工具类。

