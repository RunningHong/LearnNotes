[toc]

# Spring单元测试

```java
package XXX.dao.impl;

import XXX.UserDao;
import XXX.model.User;
import lombok.extern.slf4j.Slf4j;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.List;


@RunWith(SpringJUnit4ClassRunner.class) //使用junit4进行测试
@ContextConfiguration(locations={"classpath:spring.xml"})
@Slf4j
public class UserDaoImplTest {
   @Autowired
   private UserDao userDao;

   @Test
   public void test() {
      List<User> list = userDao.query(0, 10);
      log.info(list.toString());
   }
}
```