​	

作业详情：

 1、使用archetype插件生成一个webapp项目答案写对应的命令，可以加上执行步骤和部分执行过程

```shell
mvn archetype:generate -DgroupId=com.quanr.fresh -DartifactId="maven-homework" -DarchetypeArtifactId="maven-archetype-quickstart"
```

2、开发一个父子工程项目，并能够正确构建，添加单元测试代码，要求：父子工程的父工程继承公司的父pmo（qunar-supom-generic），版本大于1.3.8，子工程中同时引入com.ning:async-http-client 1.6.0   和 com.alibaba:dubbo 2.0.13  ，实际项目中使用 org.jboss.netty:netty 3.9.5.Final 且解决Found Banned Dependency: commons-logging:commons-logging:jar:1.1.1 版本冲突， 提示：有归类依赖使用（占位符properties标签），有依赖管理（dependencyManagement），有excludes

父子工程的父工程继承公司的父pmo（qunar-supom-generic）:

```
<parent>
    <artifactId>qunar-supom-generic</artifactId>
    <groupId>qunar.common</groupId>
    <version>1.3.9</version>
  </parent>
```

子工程中同时引入com.ning:async-http-client 1.6.0   和 com.alibaba:dubbo 2.0.13并解决冲突

```
	<dependencies>
		<dependency>
			<groupId>junit</groupId>
			<artifactId>junit</artifactId>
			<exclusions>
				<exclusion>
					<artifactId>hamcrest-core</artifactId>
					<groupId>org.hamcrest</groupId>
				</exclusion>
			</exclusions>
		</dependency>
		<dependency>
			<groupId>com.ning</groupId>
			<artifactId>async-http-client</artifactId>
		</dependency>
		<dependency>
			<groupId>com.alibaba</groupId>
			<artifactId>dubbo</artifactId>
			<exclusions>
				<exclusion>
					<artifactId>netty</artifactId>
					<groupId>org.jboss.netty</groupId>
				</exclusion>
				<exclusion>
					<artifactId>commons-logging</artifactId>
					<groupId>commons-logging</groupId>
				</exclusion>
			</exclusions>
		</dependency>
	</dependencies>
```

3、使用maven命令执行单元测试/单元测试逻辑不编译，不执行，直接跳过/单元测试编译，只跳过测试过程
答案写对应的命令，可以加上执行步骤和部分执行过程

maven命令执行单元测试：

```
mvn test
```

单元测试逻辑不编译，不执行，直接跳过：

```
mvn test -Dmaven.test.skip=true
```

元测试编译，只跳过测试过程：

```
mvn test -DskipTests
```

4、使用assembly插件把依赖的所有jar包打到同一个包里面

在<pulgins>节点下添加：

```
<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-dependency-plugin</artifactId>
				<executions>
					<execution>
						<id>copy-dependencies</id>
						<phase>package</phase>
						<goals>
							<goal>copy-dependencies</goal>
						</goals>
						<configuration>
							<outputDirectory>${project.build.directory}/lib</outputDirectory>
							<overWriteReleases>false</overWriteReleases>
							<overWriteSnapshots>false</overWriteSnapshots>
							<overWriteIfNewer>true</overWriteIfNewer>
						</configuration>
					</execution>
				</executions>
			</plugin>
			<plugin>
				<artifactId>maven-assembly-plugin</artifactId>
				<configuration>
					<archive>
						<manifest>
							<mainClass>cn.xx.Aes.xxEncode</mainClass>
						</manifest>
						<manifestEntries>
							<Class-Path>.</Class-Path>
						</manifestEntries>
					</archive>
					<descriptorRefs>
						<descriptorRef>jar-with-dependencies</descriptorRef>
					</descriptorRefs>
				</configuration>
				<executions>
					<execution>
						<id>make-assembly</id>
						<phase>package</phase>
						<goals>
							<goal>single</goal>
						</goals>
					</execution>
				</executions>
			</plugin>
		</plugins>
```

再执行：mvn clean 再执行：mvn package
结果：
在父工程/target生成了：maven-homework-1.0-SNAPSHOT-jar-with-dependencies.jar
以及在子工程/target生成了：maven-homework-child-1.0-SNAPSHOT-jar-with-dependencies.jar

5、（新增）在继承了（qunar-supom-generic）把jar包中的resources下的system.properties文件打入到jar中(提示覆盖父类的插件引入）

```
<plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <configuration>
          <includes>
            <include>**/*.properties</include>
          </includes>
        </configuration>
</plugin>
```

6、项目中引入一个你熟悉的jar，但是项目中，未使用这个jar中的任何内容。使用maven命令检查出哪些是 Used undeclared 哪些是 Unused declared? 

```
// Used undeclared dependencies: 表示项目中使用到的，但是没有显示声明的依赖
// Unused declared dependencies: 表示项目中未使用的，但显示声明的依赖
mvn dependency:analyze
```

结果：

[WARNING] Unused declared dependencies found:
[WARNING]    com.ning:async-http-client:jar:1.6.0:compile
[WARNING]    com.alibaba:dubbo:jar:2.0.13:compile

