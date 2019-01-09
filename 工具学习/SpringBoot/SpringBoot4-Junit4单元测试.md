# SpringBoot4-Junit4单元测试

```java
/**
 * 提供单元测试
 * @author RunningHong
 * @since 2019-01-06 17:27
 */
// SpringJUnit支持，由此引入Spring-Test框架支持！
@RunWith(SpringJUnit4ClassRunner.class) 
@SpringBootTest
// 由于是Web项目，Junit需要模拟ServletContext，因此我们需要给我们的测试类加上此注解。
@WebAppConfiguration 
public class ReportTest {

    // 使用Autowired注入服务，不能用new的形式
	@Autowired
	private ModelFileService modelFileService;

	@Test
	public void configTest() {

		// 取得Config中的配置属性
		System.out.println(Config.uploadFileAddress);

		Map<String, List<ModelFile>> map =  modelFileService.findModelFilesByReportType("报表");

		System.out.println(map);


	}
}

```

