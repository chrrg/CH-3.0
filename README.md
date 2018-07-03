# CH语言3.0

ch3/  已编译好的windows下的CH语言3.0  有很多小例子



最初的windows平台的软件开发用VB源码制作。


已移植到PHP源码，即开即用，还有小bug：
php实验地址：https://www.gutdx.club/ch/?test&debug
修复最后几个小bug后开源。


支持：
if
for
do
while
switch
等基本语法
所有代码都可以写作一行。
灵活的eval函数，实现自举。
基本语法：


定义变量很多人说不喜欢$符号，ok：
<pre>
<code>
deflim(true);
a=123;
a=a+456;
print(a);
//这样就没问题，不过建议变量加$符号，否则变量名和函数名可能出现重复
</code>
</pre>

if：
<pre>
<code>
if(true,//条件
  print('条件成立'),   //条件成立时执行
  print('条件不成立')   //条件不成立时执行
);//逗号为分隔符
</code>
</pre>

关于小括号形式而不是大括号形式的好处：
$a=if(2==2,'345','678');
这样是可以实现返回值。




for:
<pre>
<code>
for($a=1,$a<=10,$a++,

);
</code>
</pre>

do:
<pre>
<code>
$i=0;
do(//进入do无论如何都会执行一次
$i++;
//这里是do循环体
,$i>=10);//直到$i>=10后退出循环
</code>
</pre>


while:
<pre>
<code>
$i=0;
while($i<=10,//首先判断是否成立，成立即循环，不成立退出循环
$i++;

//这里是while循环体
);
</code>
</pre>



switch判断语句:
<pre>
<code>

$a=123;//初始化变量


//switch判断的不一定是常量
switch($a,
	123,msgbox('switch123');exit,
	456,msgbox('456');exit,
	123,msgbox('also123');exit,
	
	msgbox('switch执行到最后');
  ,void//void是一个空函数(仅为了保持switch代码语法)
);//switch每一个都判断，可用exit()提前推出。


</code>
</pre>

case判断语句:
<pre>
<code>

$a=123;//初始化变量

case($a,
	123,msgbox('case123'),
	456,msgbox('456'),
	123,msgbox('also123'),
	msgbox('case全部不成立执行');
);//case匹配到一个后不会再进行后续的判断，会直接跳出case语句体。



$res = case($a,
	123,456,
	456,789,
	789,123,
	'都不是'
);//任何语句体都可以有返回值。



</code>
</pre>


re循环语句:最简单的循环语句
<pre>
<code>
re(3,line("输出"););
line("循环3次完成");
//最简单3的循环，3即代表固定循环3次
</code>
</pre>


字符串合并的方法
<pre>
<code>

$a='abc';
$a=$a.'123';

print($a);
</code>
</pre>







另增加了丰富的函数库


试试？

——CH  2018-07-03
