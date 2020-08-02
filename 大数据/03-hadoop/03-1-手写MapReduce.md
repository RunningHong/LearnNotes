[toc]

# 手写MapReudce

## 1 前提

```
现在拥有这样的数据需要对数据进行统计单词的个数
数据如：
hello this is jay
hello this is tom

最终输出：
hello 2
this 2
is 2
jay 1
tom 1
```

## 2 代码实现

```java
import org.apache.commons.lang.StringUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.MultipleInputs;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {
    // 运行该mapreduce的入口
    public statis void main(string[] args) throws IOException, ClassNotFoundException, InterruptedException{
        // 1、获取配置信息
        Configuration configuration = new Configuration();
        
        // 输入和输出路径
        String inputPath=args[0];
        String outputPath=args[1];

        System.out.println("args[0]  "+inputPath);
        System.out.println("args[1]  "+outputPath);

        // :首先删除输出路径的已有生成文件（如果输出路径存在则运行MR时会报错，所以这里手动删去）
        FileSystem fs = FileSystem.get(new URI(inputPath), configuration);
        Path outPath = new Path(outputPath);
        if (fs.exists(outPath)) {
            fs.delete(outPath, true);
        }
        
        
        // 2、Job得到实例（顺便设置jobname）
        Job job =  Job.getInstance(configuration, "wordCount");
        
        // 3、设置加载jar的位置路径,直接传入当前Class对象
        job.setJarByClass(WordCount.class);
        
        // 4.设置Map类
        job.setMapperClass(WordCountMapper.class);
        
        // 5.设置Map的输出类型
        job.setMapOutputKeyClass(Text.class);
        job.setMapOutputValueClass(IntWritable.class);
        
        // 6.设置Reduce类
        job.setReducerClass(WordCountReducer.class);
        
        // 7.设置最终的输出类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        
        // 8.设置输入和输出路径(如果输出路径存在则运行MR时会报错)
        FileInputFormat.setInputPaths(job, new Path(inputPath));
        FileOutputFormat.setOutputPath(job, new Path(outputPath));
        
        // 9.提交job&并且登台job计算完成
        job.waitForCompletion(true);
    }
    
    // 前两个参数类型（LongWritable，Text）代表Map的输入类型
    //     longWritable: map的key-行偏移量
    //     Text: map的value-行数据
    // 后两个参数类型（Text，IntWritable）代表Map输出
    //     Text: 输出类型的key
    //     IntWritable: 输出类型的value
    // 注意：如果是写的内部类的形式需要加static关键字
    public static class WordCountMapper extends Mapper<LongWritable, Text, Text, IntWritable> {
        
        // 参数1：LongWritable key代表行编译量-对应Mapper类的第一个参数类型
        // 参数2：Text value代表行数据-对应Mapper类的第二个参数类型
        // 参数3：Context context代表上下文-传递信息的容器
        @Override
        protected void map(LongWritable key, Text value, Context context) throws java.io.IOException, java.lang.InterruptedException {
            // 1 将行数据toString
            String line = value.toString();
            
            // 2 将行数据按照指定的分隔符分隔
            String words = line.split(" ");
            
            // 3 将每个单词都标1存入context
            for(String word : words) {
                // 单词进行trim
                String wordTrim=word.trim();
                // 排除为空的字符串
                if(!"". equlas(wordTrim)) { 
                    // 写入的类型需要和Mapper类里的第3和第4个参数类型对应
                    // 这里需要和main方法里的第5阶段类型对应
                    context.write(new Text(wordTrim), new IntWritable(1))
                }
            }
        }
    } 
    
    
    // 前两个参数类型Text, IntWritable代表Map阶段输出的参数类型（即map最后context.write的参数类型）需要和main方法里的第5阶段类型(设置Map的输出类型)对应
    // 后两个参数类型Text, IntWritable代表Reduce阶段输出的参数类型（即reduce最后context.write的参数类型）需要和main方法里的第7阶段类型(设置最终的输出类型)对应
    // 注意：如果是写的内部类的形式需要加static关键字
    public static class WordCountReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
        // 同一个key有且仅只执行一次reduce方法
        // 参数Text key代表进入reduce的key（对应一个单词）
        // 参数Iterable<IntWritable> iterable代表进入reduce的值的集合（对应出现的次数）
        // 参数Context context代表上下文
        @Override
        protected void reduce(Text key, Iterable<IntWritable> iterable, Context context) throws java.io.IOException, java.lang.InterruptedException {
            int sum=0;
            Interator<IntWritable> iter = iterable.iterator();
            while(iter.hasNext()) {
                sum+=iter.next().get();
            }
            // 对应Reduce后面的两个参数类型
            // 和main方法里的第7阶段类型(设置最终的输出类型)对应
            context.write(key, new IntWritable(sum));
    }
    
    
}
```