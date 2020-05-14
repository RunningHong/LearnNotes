# Java中在liunx调用shell

```java
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class ShellRun {
        public static void main(String[] args) {
        Process process;
        try {
            process = Runtime.getRuntime().exec("sh /home/q/data/hongzh_tmp/tmp/echo_sh.sh");//查看我的 .bash_history里面的grep 命令使用历史记录
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
            int exitValue = process.waitFor();
            while((line = reader.readLine())!= null){
                System.out.println(line);
            }
            if (exitValue == 0){
                System.out.println( "successfully executed the linux command");
            }
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
	
        }



} 
```

