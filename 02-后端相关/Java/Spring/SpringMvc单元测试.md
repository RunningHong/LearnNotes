[TOC]

# SpringMvc单元测试

我们要测试controller层，不能总重启服务器（重启tomcat花费的时间太多），那么我们就用junit4模拟请求，测试controller层的方法。

## 1 单元测试

```java
package XXX.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import XXX.UserModel;
import XXX.UserController;
import lombok.extern.slf4j.Slf4j;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

/**
 * 利用junit对springMVC的Controller进行测试
 * 我们要测试controller层，不能总重启服务器（重启tomcat花费的时间太多），那么我们就用junit4模拟请求，测试controller层的方法。
 * 前提：pom需要引入spring-test依赖
 * @author RunningHong
 * @since 2019-04-28 17:42
 */
@Slf4j
@WebAppConfiguration // 调用java web的组件，比如自动注入ServletContext Bean等等
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration({"classpath*:/spring.xml","classpath*:/spring-mvc.xml"}) // 加载Spring配置文件
public class UserControllerTest {

	/**
	 * SpringMVC提供的Controller测试类
	 * @author RunningHong at 2019/4/28 18:39
	 */
	MockMvc mockMvc;

	@Autowired
	private UserController userController ;

	/**
	 * 注意：一定要把待测试的Controller实例进行MockMvcBuilders.standaloneSetup(xxxxController).build();
	 * 否则会抛出无法找到@RequestMapping路径的异常
	 * @author RunningHong at 2019/4/28 18:40
	 */
	@Before
	public void setUp() {
		mockMvc = MockMvcBuilders.standaloneSetup(userController).build();
	}


    /**
    * post 请求，就收json格式的参数，方法接收参数使用@RequestBody注解
    */
	@Test
	public void addUserTest() throws Exception {
		UserModel userModel = new UserModel();
		userModel.setName("test");
		userModel.setAge(22);
		userModel.setSex("男");
		userModel.setRemark("这是一个测试");
		userModel.setState(1);

		// 将对象转换为json串
		ObjectMapper mapper = new ObjectMapper();
		String postJson = mapper.writeValueAsString(userModel);

		ResultActions resultActions = this.mockMvc.perform(MockMvcRequestBuilders
				.post("/user/addUser")
				.accept(MediaType.APPLICATION_JSON) // 设置成功时接收数据的类型
                .contentType(MediaType.APPLICATION_JSON_UTF8) // 设置contentType
				.param(postJson)); // 发送json数据

		MvcResult mvcResult = resultActions.andReturn();

		// 使用@ResponseBody注解修饰Controller时可使用getResponse().getContentAsString()获取响应body中的json内容
		String result = mvcResult.getResponse().getContentAsString();

		log.info("结果：{}", result);
	}

    /**
    * get 请求,方法接收参数被@RequestParam修饰
    */
	@Test
	public void queryTest() throws Exception {
		MvcResult mvcResult = this.mockMvc.perform(MockMvcRequestBuilders
				.get("/user/query") 
				.accept(MediaType.APPLICATION_JSON) // 指定请求的Accept头信息
				.param("offset", "0") // 指定请求参数
				.param("limit", "5")).andReturn();

		// 使用@ResponseBody注解修饰Controller时可使用getResponse().getContentAsString()获取响应body中的json内容
		String result = mvcResult.getResponse().getContentAsString();

		log.info("结果：{}", result);
	}
    
    	@Test
	public void getTotalNumTest() throws Exception {
		MvcResult mvcResult = this.mockMvc.perform(MockMvcRequestBuilders
				.get("/user/getTotalNum")  // 发送get请求
				.accept(MediaType.APPLICATION_JSON)).andReturn();
		// 获取返回内容
		String result = mvcResult.getResponse().getContentAsString();

		log.info("结果：{}", result);
	}

}

```

## 2 关于测试回滚

很多时候我们只是对数据机型测试，当我们不想测试数据写入数据库的时候我们可以使用回滚机制，springMVC的回滚只需在方法头上加上`@Transaction` 注解即可

```java
    @Test
    @Transactional // 使用该注解使事务回滚
    public void changeActiveTest() throws Exception {
        try {
            MvcResult mvcResult = this.mockMvc.perform(MockMvcRequestBuilders
                    .post("/model/changeActive")  // 发送post请求
                    .accept(MediaType.APPLICATION_JSON) // 指定请求的Accept头信息
                    .param("id", CHANGE_ACTIVE_MODEL_ID) // 指定请求参数
                    .param("active", CHANGE_ACTIVE_ACTIVE)).andReturn();
            String result = mvcResult.getResponse().getContentAsString();
            log.info("结果：{}", result);
        } catch (Exception e) {
            log.error("changeActiveTest测试失败", e);
        }

    }
```

