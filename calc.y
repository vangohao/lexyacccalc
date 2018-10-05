%code requires{         //该部分代码会被同时添加到y.tab.h和y.tab.c中
#include<stdio.h>
#include<stdlib.h>
#include<vector>
#include<string>
#include<unordered_map>

  typedef union
  {
      int d;
      double lf;
  } varvalue;             //储存变量和直接数的数据值
  enum valtype            //表示类型
  {
    INT=0,
    DOUBLE=1
  };
  struct var              //变量,包括类型和值
  {
      varvalue value;
      valtype type;
  };
  extern "C"              //yy系列函数声明
  {
  int yyparse(void);
  int yylex(void);  
  int yyerror(const char *);
  int yywrap();
  }
}

%union{                   //YYSTYPE类型定义,也即yylval的类型
    var unit;
    char * name;
}

%code{                  //全局变量定义及函数定义
  std::unordered_map<std::string,var>   idmp;           //符号表,用unorded_map实现

  var calc(var a,var b, int op)                       //用于计算的函数,支持加减乘除,支持整数和浮点数
  {
      if(a.type == valtype::INT && b.type == valtype::INT)
      {
        switch(op)
        {
          case ADD: a.value.d += b.value.d;  return a;
          case SUB: a.value.d -= b.value.d;  return a;
          case MUL: a.value.d *= b.value.d;  return a;
          case DIV: a.value.d /= b.value.d;  return a;
          default:  return a;
        }
      } 
      else if(a.type == valtype::DOUBLE && b.type == valtype::DOUBLE)
      {
        switch(op)
        {
          case ADD: a.value.lf += b.value.lf;  return a;
          case SUB: a.value.lf -= b.value.lf;  return a;
          case MUL: a.value.lf *= b.value.lf;  return a;
          case DIV: a.value.lf /= b.value.lf;  return a;
          default:  return a;
        }
      }
      else if(a.type == valtype::DOUBLE && b.type == valtype::INT)
      {
        switch(op)
        {
          case ADD: a.value.lf += b.value.d;  return a;
          case SUB: a.value.lf -= b.value.d;  return a;
          case MUL: a.value.lf *= b.value.d;  return a;
          case DIV: a.value.lf /= b.value.d;  return a;
          default:  return a;
        }
      }
      else
      {
        return calc(b,a,op);
      }
  }

  var negative(var x)               //计算相反数的函数
  {
    if(x.type==valtype::INT)
      {
        x.value.d = -x.value.d;
      }
      else x.value.lf = -x.value.lf;
      return x;
  }




int yyerror(const char *msg)            //输出错误信息的yyerror()函数
{
  printf("Error encountered: %s \n", msg);
  return 0;
}


}

%token ADD SUB MUL DIV EOL LEFTBRA RIGHTBRA ASSIGN ILLEGAL QUIT DOT     //token声明

%token <unit> NUM             //<unit>指明 NUM 对应值实际引用%union中的unit属性,在后面$1,$2处用到
%token <unit> FLT
%token <name> ID
%type <unit> expr               //指明expr的对应值实际引用%union中的unit属性
%type <unit> assignexpr

%right ASSIGN                 //指明赋值号右结合,加减乘除左结合,优先级越往下越高.即*/ 高于 +- 高于 = 
%left ADD SUB
%left MUL DIV
%right NEGA                   //形式标记,使负号的有限级最高

%%
stmts : stmts expr EOL {     //输出结果
            if($2.type == valtype::INT)  printf("%d\n",$2.value.d); 
            else if($2.type == valtype::DOUBLE) printf("%lf\n",$2.value.lf);
}
|stmts assignexpr EOL {     //输出结果
            if($2.type == valtype::INT)  printf("%d\n",$2.value.d); 
            else if($2.type == valtype::DOUBLE) printf("%lf\n",$2.value.lf);
}
        |stmts EOL          
        |error EOL {yyerrok;yyclearin;//接受错误处理,继续语法分析.
        }
        |stmts ILLEGAL EOL {yyerror("Illegal Character!");//报告非法字符
        }
        |stmts QUIT EOL {exit(0);//退出
        }
        |%empty          { //%empty表示空
        }
;
expr : expr ADD expr     { $$=calc($1,$3,ADD);}
       |expr SUB expr       { $$=calc($1,$3,SUB);}
       |expr MUL expr       { $$=calc($1,$3,MUL);}
       |expr DIV expr       { $$=calc($1,$3,DIV);}
       |SUB expr %prec NEGA     {$$=negative($2);//%prec指明词条的优先级依照NEGA的优先级,即优先级高于*/
       }
       | LEFTBRA expr RIGHTBRA    {$$=$2; //括号
       }
       |NUM   
       |FLT 
       |ID                    {//处理标识符
         auto it = idmp.find($1);//在符号表中查找标识符
         if(it==idmp.end())
         {
           char ch[500];
           sprintf(ch,"identifier %s not defined!",$1);//报告标识符不存在
           yyerror(ch);
           YYERROR;//进入错误处理状态
         }
         else       //读取变量并提交
         {
           $$=it->second;
         }
       }          
;
assignexpr : ID ASSIGN expr       { idmp[$1]=$3;$$=$3;//赋值语句,如果标识符未被创建,则会自动创建
}
          | ID ASSIGN assignexpr {idmp[$1]=$3;$$=$3;//连续赋值语句
          }
       
%%

int main()   //主程序
{
  yyparse();
  return 0;
}