# JDK8时间工具类

新的日期和时间工具类都**不可变**的也是**线程安全**的。

整体包括：

- Instant - 表示的是时间戳，如2014-01-14T02:20:13.592Z。
- LocalDate - 表示的不带时间的日期，比如2014-01-14。
- LocalTime – 它表示的不带日期的时间。
- LocalDateTime – 它包含了时间与日期，不带时区的偏移量，如1998-03-04T14:33。

SimpleDateFormat 是非线程安全的，所以使其应用非常受限，在JDK8中可以使用DateTimeFormatter来代替（被final修饰，天然的线程安全）。

```java
import org.junit.Test;

import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

import lombok.extern.slf4j.Slf4j;

/**
 * 对JDK8中时间工具类的测试
 * @since 2019-05-22 11:21
 */
@Slf4j
public class TimeTest {

    @Test
    public void InstanceTest() {
        Instant current = Instant.now();
        log.info(current.toString()); // 2019-05-22T06:28:02.522Z
    }

    @Test
    public void localDateTest() {
        // 获取年月日
        LocalDate localDate = LocalDate.now();
        int year = localDate.getYear();
        int month = localDate.getMonthValue();
        int day = localDate.getDayOfMonth();
        log.info("{}年{}月{}日", year, month, day); // 2019年5月22日

        // 获取指定日期
        LocalDate designationDate = LocalDate.of(2019, 5, 22);
        log.info(designationDate.toString()); // 2019-05-22
    }

    @Test
    public void localTimeTest() {
        LocalTime localTime = LocalTime.now();
        log.info(localTime.toString()); // 14:43:21.736
    }

    @Test
    public void localDateTimeTest() {
        LocalDateTime localDateTime = LocalDateTime.now();
        log.info(localDateTime.toString()); // 2019-05-22T14:47:35.867
    }

    @Test
    public void dateTimeFormatterTest() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // 格式化输出
        LocalDateTime localDateTime = LocalDateTime.now();
        String timeFormat = localDateTime.format(formatter);
        log.info("{}", timeFormat); // 2019-05-22

        // 字符串转日期
        String dateStr = "2018-02-02";
        LocalDate parseDate = LocalDate.parse(dateStr, formatter);
        log.info("{}", parseDate); // 2018-02-02
    }
}
```

