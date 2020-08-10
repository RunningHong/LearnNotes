[TOC]

# UDF

在Hive中，用户可以自定义一些函数，用于扩展HiveQL的功能，而这类函数叫做UDF（用户自定义函数） 。

UDF函数其实就是一个简单的函数，执行过程就是在Hive转换成MapReduce程序后，执行java方法，类似于像MapReduce执行过程中加入一个插件，方便扩展。UDF只能实现一进一出的操作，如果需要实现多进一出，则需要实现UDAF。 

## 1 UDF类型

Hive中有3种UDF：

1. UDF：操作单个数据行，产生单个数据行；
2. UDAF：操作多个数据行，产生一个数据行；
3. UDTF：操作一个数据行，产生多个数据行一个表作为输出；

## 2 如何构建UDF

1. 继承UDF或者UDAF或者UDTF，实现特定的方法；
2. 将写好的类打包为jar，如LowerUDF.jar；
3. 进入到Hive shell环境中，输入命令add jar /home/hadoop/LowerUDF.jar注册该jar文件；
    或者把LowerUDF.jar上传到hdfs，hadoop fs -put LowerUDF.jar /home/hadoop/LowerUDF.jar，再输入命令add jar hdfs://hadoop01:8020/user/home/LowerUDF.jar；
4. 为该UDF取个别名，create temporary function lower_udf as 'com.hong.hive.udf.LowerUDF'；
    注意，这里UDF只是为这个Hive会话临时定义的；
5. 在select中使用lower_udf()；

## 3 相关依赖

```
		<dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>2.5.0</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hive</groupId>
            <artifactId>hive-exec</artifactId>
            <version>2.2.0</version>
        </dependency>
```

## 4 UDF

编写Hive UDF有两种方式：

1. extends UDF ， 重写evaluate方法
    org.apache.hadoop.hive.ql. exec.UDF 基础UDF的函数读取和返回基本类型，即Hadoop和Hive的基本类型。如，Text、IntWritable、LongWritable、DoubleWritable等。（通过反射调用evaluate方法）
2. extends GenericUDF，重写initialize、getDisplayString、evaluate方法
    org.apache.hadoop.hive.ql.udf.generic.GenericUDF 复杂的GenericUDF可以处理Map、List、Set类型。（ 继承GenericUDF更加有效率，因为UDF class 需要HIve使用反射的方式去实现 ）

### 4.1 方式1：extends UDF 

可以在类中进行evaluate方法重载，

这种方式需要实现evaluate方法，最终是通过反射调用该方法的

```java
package com.hong.hive.udf;

import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.io.Text;

/**
 * UDF
 * 1、打成jar
 * 2、上传至hdfs: hdfs dfs -put hive_udf_project.jar /udf/
 * 3、hive中：add jar hdfs:/udf/hive_udf_project.jar;
 * 4、create temporary function lower_udf as 'com.hong.hive.udf.LowerUDF';
 * 5、在hive中使用： select lower_udf('AAbb')
 */
public class LowerUDF extends UDF {

    /**
     * 需要实现evaluate方法，该方法最终是通过反射调用的
     */
    public Text evaluate(Text text) {
        if (text == null) {
            return null;
        }
        return new Text(text.toString().toLowerCase());
    }

}
```

### 4.2 方式2：extends GenericUDF 

#### 4.2.1 GenericUDF抽象类

```java
//这个方法只调用一次，并且在evaluate()方法之前调用。
//该方法接受的参数是一个ObjectInspectors数组。该方法检查接受正确的参数类型和参数个数。  
abstract ObjectInspector initialize(ObjectInspector[] arguments);  
  
//这个方法类似UDF的evaluate()方法。它处理真实的参数，并返回最终结果。  
abstract Object evaluate(GenericUDF.DeferredObject[] arguments);  
  
//这个方法用于当实现的GenericUDF出错的时候，打印出提示信息。没啥作用
abstract String getDisplayString(String[] children);
```

#### 4.2.2 代码实现 

```java
package com.hong.hive.udf;

import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDF;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.objectinspector.PrimitiveObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;

import java.util.ArrayList;

/**
 * 将逗号分隔的字符串(传入一个参数)转换为List并返回
 */
public class StringToArrayGenericUDF extends GenericUDF {

    private ArrayList aryayList = new ArrayList();
    
    /**
     * 这个方法只调用一次，并且在evaluate()方法之前调用。
     * 该方法接受的参数是一个ObjectInspectors数组。
     * 该方法可以检查接受正确的参数类型和参数个数。
     * This will be called once and only once per GenericUDF instance.
     */
    @Override
    public ObjectInspector initialize(ObjectInspector[] objectInspectors) throws UDFArgumentException {
        // 初始化文件系统，可以在这里初始化读取文件等
        System.out.println("################这个方法只调用一次， hello################");

        //定义函数的返回类型为java的List
        ObjectInspector returnOI = PrimitiveObjectInspectorFactory
                .getPrimitiveJavaObjectInspector(PrimitiveObjectInspector.PrimitiveCategory.STRING);
        return ObjectInspectorFactory.getStandardListObjectInspector(returnOI);
    }

    @Override
    public Object evaluate(DeferredObject[] args) throws HiveException {
        aryayList.clear();
        if (args.length<1) {
            return aryayList;
        }

        // 获取第一个参数
        String content=args[0].get().toString();
        String[] words=content.split(",");
        for (String word : words) {
            aryayList.add(word);
        }
        return aryayList;
    }

    /**
     * 这个方法用于当实现的GenericUDF出错的时候，打印出提示信息。
     * 没有太多作用
     */
    @Override
    public String getDisplayString(String[] strings) {
        return "提示信息：一个参数(String)，以逗号分隔,最终返回List";
    }

    /**
     * 关闭操作，关闭流等
     * 注意：This is only called in runtime of MapRedTask.
     */
    @Override
    public void close() {
        System.out.println("################关闭了################");
    }
}

```

## 5 UDAF-多变一

UDAF是聚合函数，相当于reduce，将表中多行数据聚合成一行结果 

UDAF是需要在hive的sql语句和group by联合使用，hive的group by 对于每个分组，只能返回一条记录 

开发通用UDAF有两个步骤：

1. resolver负责类型检查，操作符重载，里面创建evaluator类对象；
2. evaluator真正实现UDAF的逻辑；

```java
package com.hong.hive.udaf;


import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.exec.UDFArgumentLengthException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.parse.SemanticException;
import org.apache.hadoop.hive.ql.udf.generic.AbstractGenericUDAFResolver;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDAFEvaluator;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDAFParameterInfo;
import org.apache.hadoop.hive.ql.util.JavaDataModel;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.LongObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.typeinfo.TypeInfo;
import org.apache.hadoop.io.LongWritable;
/**
 * 开发通用UDAF有两个步骤：
 * 第一个是编写resolver类，第二个是编写evaluator类
 * resolver负责类型检查，操作符重载
 * evaluator真正实现UDAF的逻辑。
 * 通常来说，顶层UDAF类继承{@link org.apache.hadoop.hive.ql.udf.generic.GenericUDAFResolver2}
 * 里面编写嵌套类evaluator实现UDAF的逻辑
 *
 * resolver通常继承org.apache.hadoop.hive.ql.udf.GenericUDAFResolver2，但是更建议继承AbstractGenericUDAFResolver，隔离将来hive接口的变化
 * GenericUDAFResolver和GenericUDAFResolver2接口的区别是:  后面的允许evaluator实现利用GenericUDAFParameterInfo可以访问更多的信息，例如DISTINCT限定符，通配符(*)。
 */
public class CountUDAF extends AbstractGenericUDAFResolver {

    /**
     * 构建方法，传入的是函数指定的列
     * @param params
     * @return
     */
    @Override
    public GenericUDAFEvaluator getEvaluator(TypeInfo[] params) throws SemanticException {
        if (params.length > 1){
            throw new UDFArgumentLengthException("Exactly one argument is expected");
        }
        return new CountUDAFEvaluator();
    }

    /**
     * 这个构建方法可以判输入的参数是*号或者distinct
     * @param info
     * @return
     * @throws SemanticException
     */
    @Override
    public GenericUDAFEvaluator getEvaluator(GenericUDAFParameterInfo info) throws SemanticException {

        ObjectInspector[] parameters = info.getParameterObjectInspectors();
        boolean isAllColumns = false;
        if (parameters.length == 0){
            if (!info.isAllColumns()){
                throw new UDFArgumentException("Argument expected");
            }

            if (info.isDistinct()){
                throw new UDFArgumentException("DISTINCT not supported with");
            }
            isAllColumns = true;
        }else if (parameters.length != 1){
            throw new UDFArgumentLengthException("Exactly one argument is expected.");
        }
        return new CountUDAFEvaluator(isAllColumns);
    }

    /**
     * GenericUDAFEvaluator类实现UDAF的逻辑
     *
     * enum Mode运行阶段枚举类
     * PARTIAL1；
     * 这个是mapreduce的map阶段：从原始数据到部分数据聚合
     * 将会调用iterate()和terminatePartial()
     *
     * PARTIAL2:
     * 这个是mapreduce的map端的Combiner阶段，负责在map端合并map的数据：部分数据聚合
     * 将会调用merge()和terminatePartial()
     *
     * FINAL:
     * mapreduce的reduce阶段：从部分数据的聚合到完全聚合
     * 将会调用merge()和terminate()
     *
     * COMPLETE:
     * 如果出现了这个阶段，表示mapreduce只有map，没有reduce，所以map端就直接出结果了；从原始数据直接到完全聚合
     * 将会调用iterate()和terminate()
     */
    public static class CountUDAFEvaluator extends GenericUDAFEvaluator{

        private boolean isAllColumns = false;

        /**
         * 合并结果的类型
         */
        private LongObjectInspector aggOI;

        private LongWritable result;

        public CountUDAFEvaluator() {
        }

        public CountUDAFEvaluator(boolean isAllColumns) {
            this.isAllColumns = isAllColumns;
        }

        /**
         * 负责初始化计算函数并设置它的内部状态，result是存放最终结果的
         * @param m 代表此时在map-reduce哪个阶段，因为不同的阶段可能在不同的机器上执行，需要重新创建对象partial1，partial2，final，complete
         * @param parameters partial1或complete阶段传入的parameters类型是原始输入数据的类型
         *                   partial2和final阶段（执行合并）的parameters类型是partial-aggregations（既合并返回结果的类型），此时parameters长度肯定只有1了
         * @return ObjectInspector
         *  在partial1和partial2阶段返回局部合并结果的类型，既terminatePartial的类型
         *  在complete或final阶段返回总结果的类型，既terminate的类型
         * @throws HiveException
         */
        @Override
        public ObjectInspector init(Mode m, ObjectInspector[] parameters) throws HiveException {
            super.init(m, parameters);
            //当是combiner和reduce阶段时，获取合并结果的类型，因为需要执行merge方法
            //merge方法需要部分合并的结果类型来取得值
            if (m == Mode.PARTIAL2 || m == Mode.FINAL){
                aggOI = (LongObjectInspector) parameters[0];
            }

            //保存总结果
            result = new LongWritable(0);
            //局部合并结果的类型和总合并结果的类型都是long
            return PrimitiveObjectInspectorFactory.writableLongObjectInspector;
        }

        /**
         * 定义一个AbstractAggregationBuffer类来缓存合并值
         */
        static class CountAgg extends AbstractAggregationBuffer{
            long value;

            /**
             * 返回类型占的字节数，long为8
             * @return
             */
            @Override
            public int estimate() {
                return JavaDataModel.PRIMITIVES2;
            }
        }

        /**
         * 创建缓存合并值的buffer
         * @return
         * @throws HiveException
         */
        @Override
        public AggregationBuffer getNewAggregationBuffer() throws HiveException {
            CountAgg countAgg = new CountAgg();
            reset(countAgg);
            return countAgg;
        }

        /**
         * 重置合并值
         * @param agg
         * @throws HiveException
         */
        @Override
        public void reset(AggregationBuffer agg) throws HiveException {
            ((CountAgg) agg).value = 0;
        }

        /**
         * map时执行，迭代数据
         * @param agg
         * @param parameters
         * @throws HiveException
         */
        @Override
        public void iterate(AggregationBuffer agg, Object[] parameters) throws HiveException {
            //parameters为输入数据
            //parameters == null means the input table/split is empty
            if (parameters == null){
                return;
            }
            if (isAllColumns){
                ((CountAgg) agg).value ++;
            }else {
                boolean countThisRow = true;
                for (Object nextParam: parameters){
                    if (nextParam == null){
                        countThisRow = false;
                        break;
                    }
                }
                if (countThisRow){
                    ((CountAgg) agg).value++;
                }
            }
        }

        /**
         * 返回buffer中部分聚合结果，map结束和combiner结束执行
         * @param agg
         * @return
         * @throws HiveException
         */
        @Override
        public Object terminatePartial(AggregationBuffer agg) throws HiveException {
            return terminate(agg);
        }

        /**
         * 合并结果，combiner或reduce时执行
         * @param agg
         * @param partial
         * @throws HiveException
         */
        @Override
        public void merge(AggregationBuffer agg, Object partial) throws HiveException {
            if (partial != null){
                //累加部分聚合的结果
                ((CountAgg) agg).value += aggOI.get(partial);
            }
        }

        /**
         * 返回buffer中总结果，reduce结束执行或者没有reduce时map结束执行
         * @param agg
         * @return
         * @throws HiveException
         */
        @Override
        public Object terminate(AggregationBuffer agg) throws HiveException {
            //每一组执行一次（group by）
            result.set(((CountAgg) agg).value);
            //返回writable类型
            return result;
        }
    }
}

```

## 6 UDTF-一变多

UDTF用来解决输入一行输出多行的需求。

限制：

1. No other expressions are allowed in SELECT不能和其他字段一起使用：SELECT pageid,explode(adid_list) AS myCol... is not supported
2. UDTF's can't be nested 不能嵌套：SELECT explode(explode(adid_list)) AS myCol..... is not supported
3. GROUP BY/ CLUSTER BY/ DISTRIBUTE BY/ SORT BY is not supported：SELECT explode(adid_list) AS myCol.....GROUP BY myCol is not supported

继承org.apache.hadoop.hive.ql.udf.generic.GenericUDTF，实现**initialize，process，close**三个方法。

执行过程：

1. UDTF首先会调用initialize方法，此方法返回UDTF的输出行的信息（输出列个数与类型）；
2. 初始化完成后，会调用process方法，真正的处理过程在process函数中：
    在process中，每一次forward()调用产生一行；
    如果产生多列可以将多个列的值放在一个数组中，然后将该数组传入到forward()函数。
3. 最后close()方法调用，对需要清理的方法进行清理。

```java
package com.hong.hive.udtf;

import org.apache.hadoop.hive.ql.exec.UDFArgumentException;
import org.apache.hadoop.hive.ql.metadata.HiveException;
import org.apache.hadoop.hive.ql.udf.generic.GenericUDTF;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.ObjectInspectorFactory;
import org.apache.hadoop.hive.serde2.objectinspector.StructObjectInspector;
import org.apache.hadoop.hive.serde2.objectinspector.primitive.PrimitiveObjectInspectorFactory;

import java.util.ArrayList;
import java.util.List;

/**
 *  对输入的字符串进行扩展，对逗号进行分隔，第一列为分隔出来的值，第二列为col_2_第一列值
 * 输入AA,BB
 * 返回：
 * AA col_2_AA
 * BB col_2_BB
 */
public class GenericUDTFExplodeV2 extends GenericUDTF {

    @Override
    public StructObjectInspector initialize(StructObjectInspector argOIs) throws UDFArgumentException {
        // 生成表的字段名数组，多个列对应多个值
        ArrayList<String> fieldNames = new ArrayList<>();

        // 生成表的字段对象监控器（object inspector）数组，即生成表的行对象每个字段的类型
        ArrayList<ObjectInspector> fieldOIs = new ArrayList<>();

        fieldNames.add("col_1"); // 第一个字段名：col_1
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector); // 第一个字段类型是PRIMITIVE

        fieldNames.add("col_2"); // 第二个字段名：col_2
        fieldOIs.add(PrimitiveObjectInspectorFactory.javaStringObjectInspector); // 第二个字段类型是PRIMITIVE

        return ObjectInspectorFactory.getStandardStructObjectInspector(fieldNames, fieldOIs); //返回对象监控器
    }

    @Override
    public void process(Object[] args) throws HiveException {
        String str=args[0].toString(); // 得到当前行的数据,真实类型为Text

        String[] values=str.split(","); // 进行分割

        List<String[]> result=null; // 最终输出的结果

        for (int i = 0; i < values.length; i++) {
            String col_1_value=values[i];
            String col_2_value="col_2_"+values[i];

            result.add(new String[]{col_1_value, col_2_value});

            // 转发结果。注意：每转发一次生成一行
            forward(result);
        }
    }

    @Override
    public void close() throws HiveException {
        System.out.println("关闭啦");
    }
}

```

