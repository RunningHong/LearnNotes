[TOC]

# Spring事务

一说到事务我一开始想到的是数据库的事务，事务指的是满足 ACID 特性的一组操作，可以通过 Commit 提交一个事务，也可以使用 Rollback 进行回滚。

在对数据库进行插入或者更新操作的时候我们通常会使用到事务。

## 1 Spring事务的本质

Spring事务的本质其实就是数据库对事务的支持，没有数据库的事务支持，spring是无法提供事务功能的。对于纯JDBC操作数据库，想要用到事务，可以按照以下步骤进行：

```
获取连接 Connection con = DriverManager.getConnection()
开启事务con.setAutoCommit(true/false);
执行CRUD
提交事务/回滚事务 con.commit() / con.rollback();
关闭连接 conn.close();
```

使用Spring的事务管理功能后，可以不再写步骤 2 和 4 的代码，而是由Spirng 自动完成。 Spring配置事务：

1. 配置文件开启注解驱动，在相关的类和方法上通过注解**@Transactional**标识。
2. spring 在启动的时候会去解析生成相关的bean，这时候会查看拥有相关注解的类和方法，并且为这些类和方法生成代理，并根据@Transaction的相关参数进行相关配置注入，这样就在代理中为我们把相关的事务处理掉了（开启正常提交事务，异常回滚事务）。
3. 真正的数据库层的事务提交和回滚是通过binlog或者redo log实现的。

## 2 Spring事务管理

**Spring并不直接管理事务，而是提供了多种事务管理器** ，他们将事务管理的职责委托给Hibernate或者JTA等持久化机制所提供的相关平台框架的事务来实现。 Spring事务管理器的接口是： **org.springframework.transaction.PlatformTransactionManager** ，通过这个接口，Spring为各个平台如JDBC、Hibernate等都提供了对应的事务管理器，但是具体的实现就是各个平台自己的事情了。

### 2.1 常用事务管理配置

在配置Spring事务管理器的时候我们通常会配置这样的代码：

```
	<bean id="transactionManager"
          class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSourceDruid"/>
    </bean>
    <tx:annotation-driven transaction-manager="transactionManager"/>
```

其中：`org.springframework.jdbc.datasource.DataSourceTransactionManager` 是Spring中PlatformTransactionManager的实现类，常用于Spring JDBC或者Mybatis进行数据持久化使用。

### 2.2 PlatformTransactionManager接口

spring中PlatformTransactionManager接口是这样定义的：

```java
package org.springframework.transaction;

public interface PlatformTransactionManager {
    // 获取一个事务
    TransactionStatus getTransaction(TransactionDefinition var1) throws TransactionException;

    // 提交事务
    void commit(TransactionStatus var1) throws TransactionException;

    // 事务回滚
    void rollback(TransactionStatus var1) throws TransactionException;
}
```

### 2.3 TransactionDefinition接口

在PlatformTransactionManager中getTransaction方法中有TransactionDefinition var1的参数。

