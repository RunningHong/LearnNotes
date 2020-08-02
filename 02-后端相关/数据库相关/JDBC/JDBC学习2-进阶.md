[TOC]

# JDBC学习-进阶

## 1 存储过程相关

### 1.1 无参存储过程查询

```sql
# 存储过程代码：
create procedure dataBaseName.selectEmp()
BEGIN
	select * from employee;
END;
```

```java
/**
 * 使用存储过程查询Emp
 */
public void queryEmpByProcedure() {
    // 获取数据库连接
    Connection conn = DBUtil.getConnection();
    
    // 调用存储过程
    CallableStatement cs = conn.prepareCall("Call selectEmp"); 
    
    // 执行sql
    cs.execute();
    
    // 得到结果集
    ResultSet rs = cs.getResultSet();
}
```

### 1.2 有参存储过程查询（输入参数）

```sql
# 说明：参数为IN参数
create procedure dataBaseName.selectEmpById(In empId Long(20))
BEGIN
	select * from employee where id = empId;
END;
```

```java
/**
 * 使用存储过程查询Emp
 */
public void queryEmpById(Long empId) {
    // 获取数据库连接
    Connection conn = DBUtil.getConnection();
    
    // 调用存储过程
    CallableStatement cs = conn.prepareCall("call selectEmpById(?)"); 
    
    // 设置参数
    cs.setString(1, empId);
    
    // 执行sql
    cs.execute();
    
    // 得到结果集
    ResultSet rs = cs.getResultSet();
}
```

### 1.3 调用带输出参数的存储过程（输出参数）

```sql
# 说明：参数为Out参数而且在select语句中把查询结果赋给了输出参数（Into count这段代码）
CRATE procedure dataBaseName.countEmp(Out count int(20)) 
BEGIN
	select count(*) Into count from employee;
END;
```

```java
/**
 * 使用存储过程查询Emp数量
 */
public void getEmpNum() {
    // 获取数据库连接
    Connection conn = DBUtil.getConnection();
    
    // 调用存储过程
    CallableStatement cs = conn.prepareCall("call countEmp(?)"); 
    
    // 设置输出参数类型，类型需要和存储过程的输出参数类型对应
    cs.registerOutParamter(1, Types.INTEGER);
    
    // 执行sql
    cs.execute();
    
    // 得到查询返回结果
    Integer empNum = cs.getInt(1);
}
```

## 2 JDBC之事务管理

### 2.1 事务基础

事务（transaction）是作为单个逻辑工作单元执行的一系列操作。

这些操作要么执行，要么都不执行。

事务特性：

- 原子性（Atomicity）
- 一致性（Consistency）
- 隔离性（Isolation）
- 不可重复性（Durability）

### 2.2 JDBC对事务的支持

1. 通过提交commit()或是回滚rollback()来管理事务的操作。
2. 事务操作默认是自动提交的。
3. 可以调用setAutoCommit(false)来禁止自动提交。

## 3 数据库连接池

### 3.1 连接池背景

- 数据库连接是一种重要的资源。
- 频繁的连接数据库会增加数据库的压力。

### 3.2 常用的数据库连接池(dbcp/c3p0)

#### 3.2.1 dbcp的使用

1. 导入相应的jar包

   ```
   commons-dbcp2-xxxx.jar
   commons-pool2-xxxx.jar
   commons-logging-xx.jar
   ```

2. 在项目根目录增加配置文件：dbcp.properties

   - 配置驱动程序
   - 配置url
   - 配置username
   - 配置password
   - 配置连接数量
   - 配置等待超时时间

3. 编写相关的类创建连接池

   ```java
   public class DBCPUtil {
       private static DataSource ds;
       
       private static final String dbcpConfigFile = "/dbcp.rpoerties";
       
       public static Connection getConnection() {
           // 读取配置文件的参数
           ds = BasicDataSourceFactory.createDataSource(dbcpConfigFile);
           
           try {
               return ds.getConnection();
           } catch (ESQLException e) {
               throw new RuntimeException(e);
           }
       }
   }
   ```

#### 3.2.2 c3p0的使用

1. 导入相应的jar

   ```
   c3p0-xxx-pre4.jar
   mchange-commons-java-xxx.jar
   ```

2. 在项目根目录增加配置文件：c3p0.properties

3. 编写相关的类创建连接池

   ```java
   public class C3P0Util {
       private static ComboPooledDataSource ds = new ComboPooledDataSource();
       
       public static Connection getConnection() {
           try {
               return ds.getConnection();
           } catch (ESQLException e) {
               throw new RuntimeException(e);
           }
       }
   }
   ```

### 3.3 dbcp与c3p0区别

| dbcp                                         | c3p0                                                         |
| :------------------------------------------- | :----------------------------------------------------------- |
| Spring推荐使用                               | Hibernate推荐使用                                            |
| 强制关闭连接或者数据库重启后，无法自动重连。 | 强制关闭连接或者数据库重启后，可以自动重连。                 |
| 无法自动回收空闲连接。                       | 可以自动回收空闲连接。                                       |
| DBCP有着比C3P0更高的效率，可能出现丢失连接。 | C3P0稳定性高。                                               |
| DBCP提供最大连接数。                         | C3P0提供最大连接时间。                                       |
| DBCP无此功能。                               | C3P0可以控制数据源内加载的PreparedStatements<br />数量并且可以设置帮助线程的数量提升JDBC操作的速度 |







