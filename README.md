# 编译实习小作业
罗昊 1700010686
# 基于lex和yacc创建的简易计算器
该计算器基于Gnu Flex 和 Gnu Bison创建,支持基本四则运算和赋值运算.
四则运算支持括号和优先级,支持整数运算和浮点数运算,除法运算规则与C语言相同.
支持通过赋初值的方式创建变量,变量名与c语言标识符风格相同.
支持多语句串联,可用;或回车作为分隔符.
遇到非法字符,使用未定义的变量,语法错误时会给出相应的错误提示,可继续输入新语句.
