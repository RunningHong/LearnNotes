[toc]

# Canal代码示例

## 1 CanalClient

```java
package com.hong;

import com.alibaba.otter.canal.client.CanalConnector;
import com.alibaba.otter.canal.client.CanalConnectors;
import com.alibaba.otter.canal.protocol.CanalEntry;
import com.alibaba.otter.canal.protocol.CanalEntry.Column;
import com.alibaba.otter.canal.protocol.CanalEntry.Entry;
import com.alibaba.otter.canal.protocol.CanalEntry.EntryType;
import com.alibaba.otter.canal.protocol.CanalEntry.EventType;
import com.alibaba.otter.canal.protocol.CanalEntry.RowChange;
import com.alibaba.otter.canal.protocol.CanalEntry.RowData;
import com.alibaba.otter.canal.protocol.Message;
import com.hong.canal.CanalClientPrintMes;

import java.net.InetSocketAddress;
import java.util.List;

/**
 * @author hongzh.zhang on 2020/11/15
 */
public class CanalClient {
    public static void main(String args[]) {
        System.out.println("开始获取变更的binlog信息");

        CanalClientPrintMes canalClientPrintMes = new CanalClientPrintMes();

        // 创建链接
        CanalConnector connector = CanalConnectors.newSingleConnector(
                new InetSocketAddress("node01", 11111),
                "example", "canal", "canal");
        int batchSize = 1000;

        try {
            connector.connect();
            connector.subscribe(".*\\..*");
            connector.rollback();

            int line_num=0;
            while (true) {
                Message message = connector.getWithoutAck(batchSize); // 获取指定数量的数据
                long batchId = message.getId();
                int size = message.getEntries().size();
                if (batchId == -1 || size == 0) { // 没有消息就睡眠一秒
                    try {
                        Thread.sleep(1000);
                        if (line_num % 80 == 0) { // 定时换行打印
                            System.out.print("\n等待消息中.");
                        } else {
                            System.out.print(".");
                        }
                        line_num++;
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    connector.ack(batchId); // 提交确认
                } else { // 有消息这接打印
                    long millis = System.currentTimeMillis();
                    System.out.println("\n###################### "+millis+" ######################");

                    // print demo1
                    // printEntry(message.getEntries());

                    // print demo2
                    printEntry2(message.getEntries());

                    // 官方print案例更改
                    // canalClientPrintMes.printEntry(message.getEntries());

                    System.out.println("\n");
                    line_num=0;
                }
            }

        } finally {
            connector.disconnect();
        }
    }

    private static void printEntry(List<Entry> entrys) {
        for (Entry entry : entrys) {
            // 跳过事务的开始以及结束
            if (entry.getEntryType() == EntryType.TRANSACTIONBEGIN || entry.getEntryType() == EntryType.TRANSACTIONEND) {
                continue;
            }

            RowChange rowChange = null;
            try {
                rowChange = RowChange.parseFrom(entry.getStoreValue());
            } catch (Exception e) {
                throw new RuntimeException("ERROR ## parser of eromanga-event has an error , data:" + entry.toString(),
                        e);
            }

            EventType eventType = rowChange.getEventType();
            System.out.println(String.format("================&gt; binlog[%s:%s] , name[%s,%s] , eventType : %s",
                    entry.getHeader().getLogfileName(), entry.getHeader().getLogfileOffset(),
                    entry.getHeader().getSchemaName(), entry.getHeader().getTableName(),
                    eventType));


            // 如果是DDL语句--打印变更的sql
            if (rowChange.getIsDdl()) {
                System.out.println(rowChange.getSql());
            }

            // 打印变更的字段信息
            printRowDataMes(rowChange, eventType);
        }
    }


    private static void printEntry2(List<Entry> entrys) {
        for (Entry entry : entrys) {

            // 只关注ROWDATA类型的Entry
            if (entry.getEntryType() != EntryType.ROWDATA) {
                continue;
            }

            // 获取header
            CanalEntry.Header header = entry.getHeader();
            // 忽略QUERY，如果binlog设置为row也不会出现QUERY的eventType
            if (header.getEventType() == EventType.QUERY) {
                continue;
            }

            // 从header获取信息
            EventType eventType = header.getEventType();
            long eventLength = header.getEventLength();
            long executeTime = header.getExecuteTime();
            String logFileName = header.getLogfileName();
            long logfileOffset = header.getLogfileOffset();
            String schemaName = header.getSchemaName();
            String tableName = header.getTableName();

            //获取rowChange
            RowChange rowChange;
            try {
                rowChange = RowChange.parseFrom(entry.getStoreValue());
            } catch (Exception e) {
                throw new RuntimeException("parse event occurs an error , data:" + entry.toString(), e);
            }

            int rowDataCount = rowChange.getRowDatasCount();

            String mes = String.format("=========== logFileName[%s], logfileOffset[%s], " +
                            "\n\t\t\tschemaName[%s], tableName[%s], " +
                            "\n\t\t\teventType[%s], eventLength[%s], " +
                            "\n\t\t\texecuteTime[%s], rowDatasCount[%s]",
                    logFileName, logfileOffset,
                    schemaName, tableName,
                    eventType, eventLength,
                    executeTime, rowDataCount);
            System.out.println(mes);

            // 打印变更的字段信息
            printRowDataMes(rowChange, eventType);
        }

    }

    /**
     * 打印变更的字段信息
     */
    private static void printRowDataMes(RowChange rowChange, EventType eventType) {
        // 根据类型[DELETE||INSERT||other]打印变更的字段
        for (RowData rowData : rowChange.getRowDatasList()) {
            if (eventType == EventType.DELETE) {
                printColumn(rowData.getBeforeColumnsList());
            } else if (eventType == EventType.INSERT) {
                printColumn(rowData.getAfterColumnsList());
            } else {
                System.out.println("\n-------更改前字段信息如下：");
                printColumn(rowData.getBeforeColumnsList());
                System.out.println("-------更改后字段信息如下：");
                printColumn(rowData.getAfterColumnsList());
                System.out.println("\n");
            }
        }

    }


    /**
     * 打印字段信息
     */
    private static void printColumn(List<Column> columns) {
        for (Column column : columns) {
            String colName = column.getName(); // 字段名称
            String colType = column.getMysqlType(); // 字段类型
            String colValue = column.getValue(); // 字段值
            boolean isUpdate = column.getUpdated(); // 这次该字段是否更新

            System.out.println(String.format(
                    "\t\t\tcolName[%s]\tcolType[%s]\tcolValue[%s]\tisUpdate[%s]",
                    colName, colType, colValue, isUpdate));
        }
    }

}

```

## 2 CanalClientPrintMes

```java
package com.hong.canal;

import com.google.protobuf.InvalidProtocolBufferException;

import com.alibaba.otter.canal.client.CanalConnector;
import com.alibaba.otter.canal.protocol.CanalEntry;
import com.alibaba.otter.canal.protocol.CanalEntry.Column;
import com.alibaba.otter.canal.protocol.CanalEntry.Entry;
import com.alibaba.otter.canal.protocol.CanalEntry.EntryType;
import com.alibaba.otter.canal.protocol.CanalEntry.EventType;
import com.alibaba.otter.canal.protocol.CanalEntry.Pair;
import com.alibaba.otter.canal.protocol.CanalEntry.RowChange;
import com.alibaba.otter.canal.protocol.CanalEntry.RowData;
import com.alibaba.otter.canal.protocol.CanalEntry.TransactionBegin;
import com.alibaba.otter.canal.protocol.CanalEntry.TransactionEnd;
import com.alibaba.otter.canal.protocol.Message;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.SystemUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.CollectionUtils;

import java.io.UnsupportedEncodingException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * canal打印官方案例--更改了部分信息
 * @author hongzh.zhang on 2020/11/22
 */
public class CanalClientPrintMes {
    public final static Logger logger             = LoggerFactory.getLogger(CanalClientPrintMes.class);
    public static final String             SEP                = SystemUtils.LINE_SEPARATOR;
    public static final String             DATE_FORMAT        = "yyyy-MM-dd HH:mm:ss";
    public volatile boolean                running            = false;
    public Thread.UncaughtExceptionHandler handler            = (t, e) -> logger.error("parse events has an error", e);
    public Thread                          thread             = null;
    public CanalConnector                  connector;
    public static String                   context_format     = null;
    public static String                   row_format         = null;
    public static String                   transaction_format = null;
    public String                          destination;

    static {
        context_format = SEP + "****************************************************" + SEP;
        context_format += "* Batch Id: [{}] ,count : [{}] , memsize : [{}] , Time : {}" + SEP;
        context_format += "* Start : [{}] " + SEP;
        context_format += "* End : [{}] " + SEP;
        context_format += "****************************************************" + SEP;

        row_format = SEP
                + "----------------> binlog[{}:{}] , name[{},{}] , eventType : {} , executeTime : {}({}) , gtid : ({}) , delay : {} ms"
                + SEP;

        transaction_format = SEP
                + "================> binlog[{}:{}] , executeTime : {}({}) , gtid : ({}) , delay : {}ms"
                + SEP;

    }

    public void printSummary(Message message, long batchId, int size) {
        long memsize = 0;
        for (Entry entry : message.getEntries()) {
            memsize += entry.getHeader().getEventLength();
        }

        String startPosition = null;
        String endPosition = null;
        if (!CollectionUtils.isEmpty(message.getEntries())) {
            startPosition = buildPositionForDump(message.getEntries().get(0));
            endPosition = buildPositionForDump(message.getEntries().get(message.getEntries().size() - 1));
        }

        SimpleDateFormat format = new SimpleDateFormat(DATE_FORMAT);
        logger.info(context_format, new Object[] { batchId, size, memsize, format.format(new Date()), startPosition,
                endPosition });
    }

    public String buildPositionForDump(Entry entry) {
        long time = entry.getHeader().getExecuteTime();
        Date date = new Date(time);
        SimpleDateFormat format = new SimpleDateFormat(DATE_FORMAT);
        String position = entry.getHeader().getLogfileName() + ":" + entry.getHeader().getLogfileOffset() + ":"
                + entry.getHeader().getExecuteTime() + "(" + format.format(date) + ")";
        if (StringUtils.isNotEmpty(entry.getHeader().getGtid())) {
            position += " gtid(" + entry.getHeader().getGtid() + ")";
        }
        return position;
    }

    public void printEntry(List<Entry> entrys) {
        for (Entry entry : entrys) {
            long executeTime = entry.getHeader().getExecuteTime();
            long delayTime = new Date().getTime() - executeTime;
            Date date = new Date(entry.getHeader().getExecuteTime());
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

            // 事务开始以及结束的信息（如果引擎是innodb就会有事务，分为[事务开始]和[事务结束],这里获取相关信息）
            if (entry.getEntryType() == EntryType.TRANSACTIONBEGIN || entry.getEntryType() == EntryType.TRANSACTIONEND) {
                if (entry.getEntryType() == EntryType.TRANSACTIONBEGIN) {
                        TransactionBegin begin = null;
                    try {
                        begin = TransactionBegin.parseFrom(entry.getStoreValue());
                    } catch (InvalidProtocolBufferException e) {
                        throw new RuntimeException("parse event has an error , data:" + entry.toString(), e);
                    }
                    // 打印事务头信息，执行的线程id，事务耗时
                    logger.info(transaction_format,
                            new Object[] { entry.getHeader().getLogfileName(),
                                    String.valueOf(entry.getHeader().getLogfileOffset()),
                                    String.valueOf(entry.getHeader().getExecuteTime()), simpleDateFormat.format(date),
                                    entry.getHeader().getGtid(), String.valueOf(delayTime) });
                    logger.info(" BEGIN ----> Thread id: {}", begin.getThreadId());
                    printXAInfo(begin.getPropsList());
                } else if (entry.getEntryType() == EntryType.TRANSACTIONEND) {
                    TransactionEnd end = null;
                    try {
                        end = TransactionEnd.parseFrom(entry.getStoreValue());
                    } catch (InvalidProtocolBufferException e) {
                        throw new RuntimeException("parse event has an error , data:" + entry.toString(), e);
                    }
                    // 打印事务提交信息，事务id
                    logger.info("----------------\n");
                    logger.info(" END ----> transaction id: {}", end.getTransactionId());
                    printXAInfo(end.getPropsList());
                    logger.info(transaction_format,
                            new Object[] { entry.getHeader().getLogfileName(),
                                    String.valueOf(entry.getHeader().getLogfileOffset()),
                                    String.valueOf(entry.getHeader().getExecuteTime()), simpleDateFormat.format(date),
                                    entry.getHeader().getGtid(), String.valueOf(delayTime) });
                }
                continue;
            }

            // 一次更改
            if (entry.getEntryType() == EntryType.ROWDATA) {
                RowChange rowChage = null;
                try {
                    rowChage = RowChange.parseFrom(entry.getStoreValue());
                } catch (Exception e) {
                    throw new RuntimeException("parse event has an error , data:" + entry.toString(), e);
                }

                EventType eventType = rowChage.getEventType();

                logger.info(row_format,
                        new Object[] { entry.getHeader().getLogfileName(),
                                String.valueOf(entry.getHeader().getLogfileOffset()), entry.getHeader().getSchemaName(),
                                entry.getHeader().getTableName(), eventType,
                                String.valueOf(entry.getHeader().getExecuteTime()), simpleDateFormat.format(date),
                                entry.getHeader().getGtid(), String.valueOf(delayTime) });


                // mysql设置了row模式后query不会触发，ddl会打印sql
                if (eventType == EventType.QUERY || rowChage.getIsDdl()) {
                    logger.info(" sql ----> " + rowChage.getSql() + SEP);
                    continue;
                }


                // 根据类型[DELETE||INSERT||other]打印变更的字段
                for (RowData rowData : rowChage.getRowDatasList()) {
                    if (eventType == EventType.DELETE) {
                        printColumn(rowData.getBeforeColumnsList());
                    } else if (eventType == EventType.INSERT) {
                        printColumn(rowData.getAfterColumnsList());
                    } else {
                        printColumn(rowData.getBeforeColumnsList());
                        printColumn(rowData.getAfterColumnsList());
                    }
                }
            }
        }
    }

    public void printColumn(List<Column> columns) {
        for (Column column : columns) {
            StringBuilder builder = new StringBuilder();
            try {
                if (StringUtils.containsIgnoreCase(column.getMysqlType(), "BLOB")
                        || StringUtils.containsIgnoreCase(column.getMysqlType(), "BINARY")) {
                    // get value bytes
                    builder.append(column.getName() + " : "
                            + new String(column.getValue().getBytes("ISO-8859-1"), "UTF-8"));
                } else {
                    // 字段名称&&字段值
                    builder.append(column.getName() + " : " + column.getValue());
                }
            } catch (UnsupportedEncodingException e) {
            }

            // 字段类型
            builder.append("    type=" + column.getMysqlType());
            // 这次该字段是否更新
            if (column.getUpdated()) {
                builder.append("    update=" + column.getUpdated());
            }
            builder.append(SEP);
            logger.info(builder.toString());
        }
    }

    public void printXAInfo(List<Pair> pairs) {
        if (pairs == null) {
            return;
        }

        String xaType = null;
        String xaXid = null;
        for (Pair pair : pairs) {
            String key = pair.getKey();
            if (StringUtils.endsWithIgnoreCase(key, "XA_TYPE")) {
                xaType = pair.getValue();
            } else if (StringUtils.endsWithIgnoreCase(key, "XA_XID")) {
                xaXid = pair.getValue();
            }
        }

        if (xaType != null && xaXid != null) {
            logger.info(" ------> " + xaType + " " + xaXid);
        }
    }

    public void setConnector(CanalConnector connector) {
        this.connector = connector;
    }

    /**
     * 获取当前Entry的 GTID信息示例
     *
     * @param header
     * @return
     */
    public static String getCurrentGtid(CanalEntry.Header header) {
        List<CanalEntry.Pair> props = header.getPropsList();
        if (props != null && props.size() > 0) {
            for (CanalEntry.Pair pair : props) {
                if ("curtGtid".equals(pair.getKey())) {
                    return pair.getValue();
                }
            }
        }
        return "";
    }

    /**
     * 获取当前Entry的 GTID Sequence No信息示例
     *
     * @param header
     * @return
     */
    public static String getCurrentGtidSn(CanalEntry.Header header) {
        List<CanalEntry.Pair> props = header.getPropsList();
        if (props != null && props.size() > 0) {
            for (CanalEntry.Pair pair : props) {
                if ("curtGtidSn".equals(pair.getKey())) {
                    return pair.getValue();
                }
            }
        }
        return "";
    }

    /**
     * 获取当前Entry的 GTID Last Committed信息示例
     *
     * @param header
     * @return
     */
    public static String getCurrentGtidLct(CanalEntry.Header header) {
        List<CanalEntry.Pair> props = header.getPropsList();
        if (props != null && props.size() > 0) {
            for (CanalEntry.Pair pair : props) {
                if ("curtGtidLct".equals(pair.getKey())) {
                    return pair.getValue();
                }
            }
        }
        return "";
    }
}

```

