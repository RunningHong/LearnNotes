[toc]

# 通用Controller与前台交互的参数类型

## 1 WebResponse类

使用此结构不管成功还是失败那么传回前端的数据结构就是{code:'xxx', msg:'xxx', dataObj}。

```java
public class WebResponse<T> {
    // 0代表成功
    private static final Integer SUCCESS_CODE = 0;
    
    private Integer code;
    private String msg;
    private T data;
    
    public WebResponse() {}

    public static WebResponse<Void> success() {
        return new WebResponse<Void>().setCode(SUCCESS_CODE).setMsg("");
    }
    
    public static <T> WebResponse<T> success(T data) {
        Objects.requireNonNull(data);
        return new WebResponse<T>().setCode(SUCCESS_CODE).setMsg("").setData(data);
    }
    
    /**
     * 错误时可选错误编码以及错误信息
     */
    public static WebResponse<Void> fail(Integer code, String msg) {
        Objects.requireNonNull(code);
        Objects.requireNonNull(msg);
        return new WebResponse<Void>().setCode(code).setMsg(msg);
    }
    
    public Integer getCode() {
        return code;
    }

    public WebResponse<T> setCode(Integer code) {
        this.code = code;
        return this;
    }

    public String getMsg() {
        return msg;
    }

    public WebResponse<T> setMsg(String msg) {
        this.msg = msg;
        return this;
    }

    public T getData() {
        return data;
    }

    public WebResponse<T> setData(T data) {
        this.data = data;
        return this;
    }

}
```

## 2 使用示例

```java
@RestController
@RequestMapping("/user")
public class UserController {

    @Resource(name="userService")
    private UserService userService;
    
    public UserController() {}
    
    @RequestMapping(path = "/create", method = RequestMethod.POST)
    public WebResponse<Void> create(@ModelAttribute UserVo userVo) {
        User user = userVo.toUser();
        userService.addUser(user);
        return WebResponse.succees();
    }
    
    @RequestMapping(path = "/update", method = RequestMethod.POST)
    public WebResponse<Void> update(@ModelAttribute UserVo userVo) {
        User user = userVo.toUser();
        userService.updateUser(user);
        return WebResponse.succees();
    }
    
    @RequestMapping(path = "/delete", method = RequestMethod.DELETE)
    public WebResponse<Void> delete(@RequestParam Integer id) {
        User user = new User().setId(id);
        userService.logicalDeleteUser(user);
        return WebResponse.succees();
    }
    
    @RequestMapping(path = "/list")
    public WebResponse<PagedResult<UserVo>> query(@ModelAttribute PagedWebRequest pagedWebRequest) {
        Integer offset = pagedWebRequest.getOffset();
        Integer limit = pagedWebRequest.getLimit();
        List<User> users = userService.query(offset, limit);
        Integer total = userService.totalCount();
        List<UserVo> userVos = users.stream().map(UserVo::new).collect(Collectors.toList());
        PagedResult<UserVo> pagedResult = new PagedResult<>();
        pagedResult.setRows(userVos);
        pagedResult.setTotal(total);
        return WebResponse.succees(pagedResult);
    }

}
```

