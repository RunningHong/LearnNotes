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

