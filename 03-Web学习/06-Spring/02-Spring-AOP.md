[toc]

# Spring-AOP

## 1 Spring AOP理解（代理实现）

面向切面编程，在我们的应用中，经常需要做一些事情，但是这些事情与核心业务无关，比如，要记录所有update*方法的执行时间时间，操作人等等信息，记录到日志，

通过spring的AOP技术，就可以在不修改update*的代码的情况下完成该需求。

AOP即面向切面编程，面向切面编程的目标就是**分离关注点**。其中关注点就是你要做的事情。

比如你要去出国旅游，但在旅游之前，你还要办签证、计划路线、乘坐什么交通工具等等事情，这些都是我们不想关注的东西但还必须要做，怎样才能简化自己的工作呢，那就是把每件事情交给专门的人去做，即计划路线找一个旅游社帮你计划，乘坐什么样的交通工具也交个其他人来办，签证找专门的人去帮你办理，这样我们真正关心的就是旅游这件事了。

AOP的好处就是你只需要关心你的正事，其它的事情都是别人帮你干，如果某天你不想用原先的旅行社来帮你计划，那么直接不使用就好了，也许有一天你出门前想买点吃的，那么直接雇一个人在出门前把吃的买过来。**这就是AOP，每个人各司其职、灵活组合，达到一种可配置、可拔插的程序结构。**

从Spring角度来看，AOP最大的用途就是在于提供了事务管理能力。事务管理就是一个管理点，你的正事是访问数据库，而你不想管事务（太麻烦）,所以Spring在你访问数据库之前，自动帮你开启事务，当你访问数据库结束后自动帮你提交/回滚事务。

## 2 为什么使用AOP

我只想关注自己想做的**正事**，其他的事情我不想管，交给他人管，这样我的工作就少些。

还有就是为了更清晰的逻辑，可以让你的业务逻辑去**关注自己本身的业务**，而不去想一些其他的事情，这些其他的事情包括：安全，事物，日志等。

## 3 AOP术语

1. **通知**（Advice）：就是我们想要的功能，也就是我们说的事务、日志等，我们先把它定义好，让后在想用的地方直接使用它。
2. **连接点**（JoinPoint）：连接点就是Spring允许你使用通知的地方，接入点其实很多，比如：每个方法的前后（或单一的前或后），或者抛出异常时，Spring只支持方法连接点，其它如aspectJ还可以让你在构造器或属性注入时都可以。**重点就是：和方法相关的前前后后（或抛出异常）都是连接点**。
3. **切入点**（Pointcut）：上面说的连接点的基础上，来定义切入点，你的一个类里，有15个方法，那就有几十个连接点了对把，但是你并不想在所有方法附近都使用通知（使用叫织入，以后再说），你只想让其中的几个，在调用这几个方法之前，之后或者抛出异常时干点什么，那么就用切点来定义这几个方法，让**切点来筛选连接点，选中那几个你想要的方法**。
4. **切面**（Aspect）：切面是通知和切入点的结合。通知说明了干什么和什么时候干（什么时候通过方法名中的before，after，around等就能知道），而切入点说明了在哪干（指定到底是哪个方法），这就是一个完整的切面定义。
5. **引入**（introduction）：允许我们向现有的类添加新方法属性。就是把切面（也就是新方法属性：通知定义的）用到目标类中。
6. **目标**（target）：引入中所提到的目标类，也就是要被通知的对象，也就是真正的业务逻辑，他可以在毫不知情的情况下，被咱们织入切面。而自己专注于业务本身的逻辑。
7. **代理**（proxy）：实现AOP机制。
8. **织入**（weaving）：把切面应用到目标对象来创建新的代理对象的过程。有3种方式，Spring采用的是运行时。**关键就是：切点定义了哪些连接点会得到通知**。

## 4 他人理解

spring用代理类包裹切面，把他们织入到Spring管理的bean中。也就是说代理类伪装成目标类，它会截取对目标类中方法的调用，让调用者对目标类的调用都先变成调用伪装类，伪装类中就先执行了切面，再把调用转发给真正的目标bean。

现在可以自己想一想，怎么搞出来这个伪装类，才不会被调用者发现（通过JVM的检查，JAVA是强类型检查，哪里都要检查类型）。

1.实现和目标类相同的接口，我也实现和你一样的接口，反正上层都是接口级别的调用，这样我就伪装成了和目标类一样的类（实现了同一接口，咱是兄弟了），也就逃过了类型检查，到java运行期的时候，利用多态的后期绑定（所以spring采用运行时），伪装类（代理类）就变成了接口的真正实现，而他里面包裹了真实的那个目标类，最后实现具体功能的还是目标类，只不过伪装类在之前干了点事情（写日志，安全检查，事物等）。

这就好比，一个人让你办件事，每次这个时候，你弟弟就会先出来，当然这个人分不出来了，以为是你，你这个弟弟虽然办不了这事，但是他知道你能办，所以就答应下来了，并且收了点礼物（写日志），收完礼物了，给把事给人家办了啊，所以你弟弟又找你这个哥哥来了，最后把这是办了的还是你自己。但是你自己并不知道你弟弟已经收礼物了，你只是专心把这件事情做好。

顺着这个思路想，要是本身这个类就没实现一个接口呢，你怎么伪装我，我就压根没有机会让你搞出这个双胞胎的弟弟，那么就用第2种代理方式，创建一个目标类的子类，生个儿子，让儿子伪装我

2.生成子类调用，这次用子类来做为伪装类，当然这样也能逃过JVM的强类型检查，我继承的吗，当然查不出来了，子类重写了目标类的所有方法，当然在这些重写的方法中，不仅实现了目标类的功能，还在这些功能之前，实现了一些其他的（写日志，安全检查，事物等）。

这次的对比就是，儿子先从爸爸那把本事都学会了，所有人都找儿子办事情，但是儿子每次办和爸爸同样的事之前，都要收点小礼物（写日志），然后才去办真正的事。当然爸爸是不知道儿子这么干的了。这里就有件事情要说，某些本事是爸爸独有的(final的)，儿子学不了，学不了就办不了这件事，办不了这个事情，自然就不能收人家礼了。

前一种**兄弟模式**，spring会使用JDK的java.lang.reflect.Proxy类，它允许Spring动态生成一个新类来实现必要的接口，织入通知，并且把对这些接口的任何调用都转发到目标类。

后一种**父子模式**，spring使用CGLIB库生成目标类的一个子类，在创建这个子类的时候，spring织入通知，并且把对这个子类的调用委托到目标类。

相比之下，还是兄弟模式好些，他能更好的实现松耦合，尤其在今天都高喊着面向接口编程的情况下，父子模式只是在没有实现接口的时候，也能织入通知，应当做一种例外。
