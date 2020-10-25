[toc]

# Hbase常用Java API

 http://c.biancheng.net/view/3599.html 

```java
package com.hong.hbase;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.CellUtil;
import org.apache.hadoop.hbase.HColumnDescriptor;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Get;
import org.apache.hadoop.hbase.client.HBaseAdmin;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.Put;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.ResultScanner;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.filter.CompareFilter;
import org.apache.hadoop.hbase.filter.FilterList;
import org.apache.hadoop.hbase.filter.SingleColumnValueFilter;
import org.apache.hadoop.hbase.util.Bytes;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

/**
 * @author hongzh.zhang on 2020/10/25
 */
public class HBaseDemo {
    HBaseAdmin admin;
    HTable htable;
    String tableName="student";

    @Before
    public void init() throws Exception {
        Configuration conf = new Configuration();
        conf.set("hbase.zookeeper.quorum", "node01,node02,node03");
        admin = new HBaseAdmin(conf);
        htable = new HTable(conf, tableName.getBytes());
    }


    /**
     * 创建hbase表
     */
    @Test
    public void createTable() throws Exception {
        if (admin.tableExists(tableName)) {
            admin.disableTable(tableName);
            admin.deleteTable(tableName);
        }

        // 表描述
        HTableDescriptor desc = new HTableDescriptor(TableName.valueOf(tableName));
        // 列族描述
        HColumnDescriptor cf = new HColumnDescriptor("cf".getBytes());
        // 将列族加入表中
        desc.addFamily(cf);
        admin.createTable(desc);
    }

    /**
     * 插入数据
     */
    @Test
    public void insertDB() throws IOException {
        String rowKey = "111";
        Put putMes = new Put(rowKey.getBytes());

        putMes.addColumn("cf".getBytes(), "name".getBytes(), "tom".getBytes());
        putMes.addColumn("cf".getBytes(), "age".getBytes(), "12".getBytes());
        putMes.addColumn("cf".getBytes(), "sex".getBytes(), "male".getBytes());

        htable.put(putMes);
    }

    /**
     * 插入数据-循环
     */
    @Test
    public void insertDB2() throws IOException {
        List<Put> putList = new ArrayList();
        Random random = new Random();
        for (int i = 0; i < 100; i++) {
            String rowKey = String.format("%03d", i);

            Put putMes = new Put(rowKey.getBytes());

            String studentName="student" + String.format("%03d", i);
            putMes.addColumn("cf".getBytes(), "name".getBytes(), studentName.getBytes());
            String studentAge = String.format("%2d", random.nextInt(22));
            putMes.addColumn("cf".getBytes(), "age".getBytes(), studentAge.getBytes());
            String studentSex;
            if (random.nextBoolean()) {
                studentSex="female";
            } else {
                studentSex = "male";
            }
            putMes.addColumn("cf".getBytes(), "sex".getBytes(), studentSex.getBytes());

            putList.add(putMes);
        }

        htable.put(putList);
    }


    /**
     * 查询-get
     */
    @Test
    public void getDB() throws IOException {
        String rowKey = "111";
        Get getMes = new Get(rowKey.getBytes());

        // 指定需要读取的列（可以不指定即全部读出来）
        getMes.addColumn("cf".getBytes(), "name".getBytes());
        getMes.addColumn("cf".getBytes(), "age".getBytes());
        getMes.addColumn("cf".getBytes(), "sex".getBytes());

        Result rs = htable.get(getMes);
        Cell cell_name = rs.getColumnLatestCell("cf".getBytes(), "name".getBytes());
        Cell cell_age = rs.getColumnLatestCell("cf".getBytes(), "age".getBytes());
        Cell cell_sex = rs.getColumnLatestCell("cf".getBytes(), "sex".getBytes());

        System.out.println(new String(CellUtil.cloneValue(cell_name)));
        System.out.println(new String(CellUtil.cloneValue(cell_age)));
        System.out.println(new String(CellUtil.cloneValue(cell_sex)));
    }

    /**
     * 查询-scan
     */
    @Test
    public void scanDB() throws IOException {
        Scan scan = new Scan();

        // 设置需要扫描的rowkey范围(begin_row<=row_key<stop_row)
        scan.setStartRow("000".getBytes());
        scan.setStopRow("050".getBytes());

        ResultScanner scanner = htable.getScanner(scan);
        Iterator<Result> iter = scanner.iterator();
        while (iter.hasNext()) {
            Result rs = iter.next();

            Cell cell_name = rs.getColumnLatestCell("cf".getBytes(), "name".getBytes());
            Cell cell_age = rs.getColumnLatestCell("cf".getBytes(), "age".getBytes());
            Cell cell_sex = rs.getColumnLatestCell("cf".getBytes(), "sex".getBytes());

            System.out.println(new String(CellUtil.cloneValue(cell_name))+"-"
                    +new String(CellUtil.cloneValue(cell_age))+"-"
                    +new String(CellUtil.cloneValue(cell_sex)));
        }

    }

    /**
     * 查询-scan-使用过滤器
     */
    @Test
    public void scanWithFilter() throws IOException {
        // 过滤器列表
        FilterList filterList = new FilterList(FilterList.Operator.MUST_PASS_ALL);
        // 指定列过滤器
        SingleColumnValueFilter filter1 = new SingleColumnValueFilter(
                "cf".getBytes(),
                "sex".getBytes(),
                CompareFilter.CompareOp.EQUAL,
                Bytes.toBytes("male"));
        filterList.addFilter(filter1);
        Scan scan = new Scan();
        scan.setFilter(filterList);

        ResultScanner scanner = htable.getScanner(scan);
        Iterator<Result> iter = scanner.iterator();
        while (iter.hasNext()) {
            Result rs = iter.next();

            Cell cell_name = rs.getColumnLatestCell("cf".getBytes(), "name".getBytes());
            Cell cell_age = rs.getColumnLatestCell("cf".getBytes(), "age".getBytes());
            Cell cell_sex = rs.getColumnLatestCell("cf".getBytes(), "sex".getBytes());

            System.out.println(new String(CellUtil.cloneValue(cell_name))+"-"
                    +new String(CellUtil.cloneValue(cell_age))+"-"
                    +new String(CellUtil.cloneValue(cell_sex)));
        }

    }



    @After
    public void after() throws IOException {
        if (admin != null) {
            admin.close();
        }
    }

}

```

