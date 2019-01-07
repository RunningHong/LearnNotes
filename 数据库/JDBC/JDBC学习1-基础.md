[TOC]

# JDBC学习-基础

## 1 基础知识

JDBC（Java Data Base Connectivity）(Java数据库连接)。

可以为数据库（Mysql,Oracle）提供统一的访问。

## 2 JDBC编程步骤

- 加载驱动程序：Class.forName(“驱动名称”)
  加载Mysql驱动：Class.forName("com.mysql.jdbc.Driver")
  加载Oracle驱动：Class.forName("oracle.jdbc.driver.OracleDriver")
- 获取数据库连接:
  DriverManager.getConnection("jdbc:mysql://localhost:3306/数据库名称", "用户名", "密码")
- 创建Statement对象:
  conn.createStatement();

```java
import java.sql.DriverManager;

public class DBUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/test";
    private static final String USER = "root";
    private static final String PASSWORD = "root";
    
    private static Connection conn;
    
    static { // 静态代码块，在类加载时获取数据库连接
        // 1.加载驱动程序
        Class.forName("com.mysql.jdbc.Driver");
        
        // 2.获取数据库连接
        conn = DriverManager.getConnection(URL, USER, PASSWORD);
    }
    
    /**
     * 获取数据库连接
     */
    public static Connection getConnection() {
        return conn;
    }
    
    /**
     * 新增employee
     */
    public static void addUser(Employee employee) {
        Connection conn = DBUtil.getConnection();
        
        String sql = "insert employee set name=?, age=?, sex=?";
        
        // 下标从1开始
        ptmt.setString(1, employee.getName());
        ptmt.setInt(2, employee.getAge());
        ptmt.setString(3, employee.getSex());
        
        ptmt.execute();
    }
    
    /**
     * 删除employee
     */
    public static void addUser(Employee employee) {
        Connection conn = DBUtil.getConnection();
        
        String sql = "insert employee set name=?, age=?, sex=?";
        
        // 下标从1开始
        ptmt.setString(1, employee.getName());

        ptmt.execute();
    }
    
    /**
     * 修改employee
     */
    public static void updateUser(Employee employee) {
        Connection conn = DBUtil.getConnection();
        
        String sql = "update employee set name=?, age=?, sex=? where id=?";
        
        PreparedStatement ptmt = conn.prepareStatement(sql);
        // 下标从1开始
        ptmt.setString(1, employee.getName());
        ptmt.setInt(2, employee.getAge());
        ptmt.setString(3, employee.getSex());
        ptmt.setLong(4, employee.getId());
        
        ptmt.execute();
    }
    
     /**
     * 查询employee
     */
    public static void updateUser(Long empId) {
        Connection conn = DBUtil.getConnection();
        
        String sql = "select * from employee where id=?";
        
        PreparedStatement ptmt = conn.prepareStatement(sql);
        // 下标从1开始
        ptmt.setLong(1, empId);
        
        ResultSet rs = ptmt.executeQuery("select * from user");
        while(rs.next()) {
            System.out.println(rs.getString("userName")); // user表中的字段
        }
    } 
    
}
```

