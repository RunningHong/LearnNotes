# Http的Get请求和Post请求的区别

1. get是从服务器获取数据，post是发送数据到服务器。

2. get参数通过URL传递，post参数放在Request body中。
   所以：get比post更不安全，因为参数直接暴露在URL上，所以不能用来传递敏感信息。
   所以：get的url可以存为书签，post的url不可以存为书签。

3. GET请求在URL中传送的参数是有长度限制的，而POST没有。

4. 对参数的数据类型，GET只接受ASCII字符，而POST没有限制。

5. GET请求参数会被完整保留在浏览器历史记录里，而POST中的参数不会被保留。

6. GET请求会被浏览器主动cache，而POST不会，除非手动设置。

7. GET在浏览器回退时是无害的，而POST会再次提交请求。

8. **GET产生一个TCP数据包；POST产生两个TCP数据包。**（在Firefox中post只发送一个）
   解释：对于GET方式的请求，浏览器会把http header和data一并发送出去，服务器响应200（返回数据）；

   对于POST，浏览器先发送header，服务器响应100 continue，浏览器再发送data，服务器响应200 ok（返回数据）。

<table>
	<tr>
        <td></td>
        <td>GET</td>
        <td>POST</td>
    </tr>
    <tr>
    	<td>数据传送方式</td>
        <td>从服务器获取数据</td>
        <td>发送数据到服务器</td>
    </tr>
    <tr>
        <td>参数传递方式</td>
        <td>通过URL传递</td>
        <td>放在Request body中</td>
    </tr>
    <tr>
        <td>可否存为书签</td>
        <td>可以</td>
        <td>不可以</td>
    </tr>
    <tr>
        <td>安全性</td>
        <td>不安全</td>
        <td>安全</td>
    </tr>
    <tr>
        <td>URL中参数长度</td>
        <td>有限制</td>
        <td>没限制</td>
    </tr>
    <tr>
        <td>对参数的数据类型</td>
        <td>只接受ASCII字符</td>
        <td>没有限制</td>
    </tr>
    <tr>
        <td>参数保存在浏览器历史记录？</td>
        <td>保留</td>
        <td>不保留</td>
    </tr>
    <tr>
        <td>浏览器主动cache</td>
        <td>会</td>
        <td>不会</td>
    </tr>
    <tr>
        <td>后退按钮/刷新</td>
        <td>无害</td>
        <td>数据会被重新提交（浏览器应该告知用户数据会被重新提交）。</td>
    </tr>
    <tr>
        <td>数据包个数</td>
        <td>1个</td>
        <td>2个（Firefox除外）</td>
    </tr>
</table>
