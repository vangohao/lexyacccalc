%{
    
#include<stdlib.h>
#include "y.tab.h"

%}
quit quit
alpha [A-Za-z_][A-Za-z_0-9]*
blank [ \t]+
flt ([0-9]+\.[0-9]+)|(\.[0-9]+)|([0-9]+\.)
num [0-9]+
add \+
sub -
mul \*
div \/
eol [\n;]
leftbra "("
rightbra ")"
assign "="
ident {alpha}+
%%
{blank}    {}
{flt}    {yylval.unit.value.lf = atof(yytext);     //浮点数
yylval.unit.type = valtype::DOUBLE;
return FLT;
}
{num}    {yylval.unit.value.d = atoi(yytext);     //整数
yylval.unit.type = valtype::INT;
return NUM;
}
{add}    {return ADD;}
{sub}    {return SUB;}
{mul}    {return MUL;}
{div}    {return DIV;}
{eol}    {return EOL;}
{leftbra}    {return LEFTBRA;}
{rightbra}    {return RIGHTBRA;}
{assign}        {return ASSIGN;}
{quit}          {return QUIT;}
{ident}         {yylval.name = strdup(yytext);return ID;}   //标识符

[^\n;]*[^A-Za-z_0-9.\-+*/= \t\n;]+[^\n;]* {return ILLEGAL;}  //含有非法字符的语句
\. {return DOT;}                                              //独立的.号
%%

int yywrap()
{
    return 1;
}
