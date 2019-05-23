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

```xml
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

```java
public interface TransactionDefinition {
    // 返回事务的传播行为
    int getPropagationBehavior(); 
    
    // 返回事务的隔离级别，事务管理器根据它来控制另外一个事务可以看到本事务内的哪些数据
    int getIsolationLevel(); 
    
    //返回事务的名字
    String getName()；
        
    // 返回事务必须在多少秒内完成
    int getTimeout();  
    
    // 返回是否优化为只读事务。
    boolean isReadOnly();
} 
```

#### 2.3.1 并发事务带来的问题

1. **脏读**：一个事务访问了一个数据并进行了修改，但修改还没提交，另一个事务访问这个数据，这时读取的数据就是没有提交的数据，这就是脏读。
2. **丢失更新**：指在一个事务读取一个数据时，另外一个事务也访问了该数据，那么在第一个事务中修改了这个数据后，第二个事务也修改了这个数据。这样第一个事务内的修改结果就被丢失，因此称为丢失修改。
3. **不可重复读**：在一个事务内多次读同一数据。在这个事务还没有结束时，另一个事务也访问该数据。那么，在第一个事务中的两次读数据之间，由于第二个事务的修改导致第一个事务两次读取的数据可能不太一样。这就发生了在一个事务内两次读到的数据是不一样的情况，因此称为不可重复读。
4. **幻读**：幻读与不可重复读类似。它发生在一个事务（T1）读取了几行数据，接着另一个并发事务（T2）插入了一些数据时。在随后的查询中，第一个事务（T1）就会发现多了一些原本不存在的记录，就好像发生了幻觉一样，所以称为幻读。

#### 2.3.2 隔离级别

TransactionDefinition 接口中定义了五个表示隔离级别的常量：

**TransactionDefinition.ISOLATION_DEFAULT:**	使用后端数据库默认的隔离级别，Mysql 默认采用的 REPEATABLE_READ隔离级别 Oracle 默认采用的 READ_COMMITTED隔离级别.

**TransactionDefinition.ISOLATION_READ_UNCOMMITTED:** 最低的隔离级别，允许读取尚未提交的数据变更，**可能会导致脏读、幻读或不可重复读**

**TransactionDefinition.ISOLATION_READ_COMMITTED:** 	允许读取并发事务已经提交的数据，**可以阻止脏读，但是幻读或不可重复读仍有可能发生**

**TransactionDefinition.ISOLATION_REPEATABLE_READ:** 	对同一字段的多次读取结果都是一致的，除非数据是被本身事务自己所修改，**可以阻止脏读和不可重复读，但幻读仍有可能发生。**

**TransactionDefinition.ISOLATION_SERIALIZABLE:** 	最高的隔离级别，完全服从ACID的隔离级别。所有的事务依次逐个执行，这样事务之间就完全不可能产生干扰，也就是说，**该级别可以防止脏读、不可重复读以及幻读**。但是这将严重影响程序的性能。通常情况下也不会用到该级别。

#### 2.3.3 事务超时属性(一个事务允许执行的最长时间)

所谓事务超时，就是指一个事务所允许执行的最长时间，如果超过该时间限制但事务还没有完成，则自动回滚事务。在 TransactionDefinition 中以 int 的值来表示超时时间，其单位是秒。

#### 2.3.4 事务只读属性（对事物资源是否执行只读操作）

事务的只读属性是指，对事务性资源进行只读操作或者是读写操作。所谓事务性资源就是指那些被事务管理的资源，比如数据源、 JMS 资源，以及自定义的事务性资源等等。如果确定只对事务性资源进行只读操作，那么我们可以将事务标志为只读的，以提高事务处理的性能。在 TransactionDefinition 中以 boolean 类型来表示该事务是否只读。

#### 2.3.5 回滚规则（定义事务回滚规则）

这些规则定义了哪些异常会导致事务回滚而哪些不会。默认情况下，事务只有遇到运行期异常时才会回滚，而在遇到检查型异常时不会回滚（这一行为与EJB的回滚行为是一致的）。 但是你可以声明事务在遇到特定的检查型异常时像遇到运行期异常那样回滚。同样，你还可以声明事务遇到特定的异常不回滚，即使这些异常是运行期异常。

## 3 编程式和声明式事务

- **编程式事务：**所谓编程式事务指的是通过编码方式实现事务，即类似于JDBC编程实现事务管理。
- **声明式事务：** 代码侵入性最小，实际是通过AOP实现，其本质是对方法前后进行拦截，然后在目标方法开始之前创建或者加入一个事务，在执行完目标方法之后根据执行情况提交或者回滚事务。

### 3.1 优缺点

**声明式事务最大的优点就是不需要通过编程的方式管理事务，这样就不需要在业务逻辑代码中掺杂事务管理的代码，**只需在配置文件中做相关的事务规则声明(或通过基于@Transactional注解的方式)，便可以将事务规则应用到业务逻辑中。

**和编程式事务相比，声明式事务唯一不足地方是，后者的最细粒度只能作用到方法级别，无法做到像编程式事务那样可以作用到代码块级别**。

### 3.2 编程式事务写法

#### 3.2.1 配置

核心配置文件applicationContext.xml里配置事务管理器*transactionManager*，并定义事务管理模板*transactionTemplate*，将事物管理器*transactionManager*注入到事物管理模板，方便将那些操作放在事务管理模板中。

```xml
<!-- 配置事物管理器 -->
<bean id="transactionManager" 		 	     	class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
	<property name="dataSource"ref="dataSource"/>
</bean>

<!-- 定义事物管理的模板：Spring为了简化事务管理的代码而提供的类 -->
<bean id="transactionTemplate" 				class="org.springframework.transaction.support.TransactionTemplate">
	<property name="transactionManager"ref="transactionManager"></property>
</bean>  
```

#### 3.2.2 业务中使用方法

在AccountService中注入TransactionTemplate事物模板（TransactionTemplate依赖DataSourceTransactionManager，DataSourceTransactionmanager依赖DataSource构造） 

```java

public class AccountServiceImpl implements AccountService {
    //注入转账的Dao
    private AccountDao accountDao; 
    public void setAccountDao(AccountDao accountDao) {
        this.accountDao = accountDao;
    }
 
    //注入事务管理模板
    private TransactionTemplate transactionTemplate;   
    public void setTransactionTemplate(TransactionTemplatetransactionTemplate) {
        this.transactionTemplate = transactionTemplate;
    }
   
    /**
     * 编程式事务管理
     * 将操作绑定在一起，如果遇到异常，则发生事务回滚
     * final型变量，内部使用
     * @param out
     * @param in
     * @param money
     */
    public void transfer(final String out,final String in,final Double money) {
        //在事务模板中执行操作
        transactionTemplate.execute(new TransactionCallbackWithoutResult(){
        @Override
        protected void doInTransactionWithoutResult(TransactionStatustransactionstatus){
            accountDao.outMoney(out, money);
            int i=1/0;
            accountDao.inMoney(in, money);
         }
        });
    }
}
```

编程式事务管理需要手动改写代码，不便操作，在开发过程中不常用

### 3.3 声明式事务写法

#### 3.3.1 配置

 核心配置文件applicationContext.xml里注入事务管理器和开启注解事务实现注解驱动。

```xml
<!-- 1.配置事物管理器 -->
    <bean id="transactionManager" 	class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
    <property name="dataSource"ref="dataSource"></property>
    </bean>
    <!-- 2.开启注解事务 ,实现注解驱动-->
    <tx:annotation-driven transaction-manager="transactionManager"/>
```

#### 3.3.2 业务中使用方法

```java

/**
 * @Transactional注解中的属性
 * propagation:事务的传播行为
 * isolation:事务的隔离级别
 * readOnly:只读
 * rollbackFor:发生哪些异常事务回滚
 * noRollbackFor:发生哪些异常事务不回滚
 *
 */
@Transactional(propagation=Propagation.REQUIRED,isolation=Isolation.DEFAULT,readOnly=false)
public class AccountServiceImpl implements AccountService {
    //注入转账的Dao
    private AccountDao accountDao; 
    public void setAccountDao(AccountDao accountDao) {
        this.accountDao = accountDao;
    }  
    /**
     * @param out
     * @param in
     * @param money
     */
    public void transfer(String out,String in,Double money) {
            accountDao.outMoney(out, money);
            int i=1/0;
            accountDao.inMoney(in, money);
    }
}
```

