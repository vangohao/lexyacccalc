%code requires{
#include<stdio.h>
#include<stdlib.h>
#include<vector>
#include<string>
#include<unordered_map>
}

%union{
    var unit;
    char * name;
}

%code requires{ 
  typedef union
  {
      int d;
      double lf;
  } varvalue;
  enum valtype
  {
    INT=0,
    DOUBLE=1
  };
  struct var
  {
      varvalue value;
      valtype type;
  };
  extern "C"
  {
  int yyparse(void);
  int yylex(void);  
  int yyerror(const char *);
  int yywrap();
  }
}

%code{
  std::unordered_map<std::string,var>   idmp;

  var calc(var a,var b, int op)
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

  var negative(var x)
  {
    if(x.type==valtype::INT)
      {
        x.value.d = -x.value.d;
      }
      else x.value.lf = -x.value.lf;
      return x;
  }




int yyerror(const char *msg)
{
  printf("Error encountered: %s \n", msg);
  return 0;
}


}

%token ADD SUB MUL DIV EOL LEFTBRA RIGHTBRA ASSIGN ILLEGAL DOT

%token <unit> NUM
%token <unit> FLT
%token <name> ID
%type <unit> expr
%type <unit> assignexpr

%right ASSIGN
%left ADD SUB
%left MUL DIV
%right UMINUS

%%
stmts : stmts expr EOL {
            if($2.type == valtype::INT)  printf("%d\n",$2.value.d); 
            else if($2.type == valtype::DOUBLE) printf("%lf\n",$2.value.lf);
}
|stmts assignexpr EOL {
            if($2.type == valtype::INT)  printf("%d\n",$2.value.d); 
            else if($2.type == valtype::DOUBLE) printf("%lf\n",$2.value.lf);
}
        |stmts EOL 
        |error EOL {yyerrok;yyclearin;}
        |stmts illegal EOL {}
        |%empty
;
expr : expr ADD expr     { $$=calc($1,$3,ADD);}
       |expr SUB expr       { $$=calc($1,$3,SUB);}
       |expr MUL expr       { $$=calc($1,$3,MUL);}
       |expr DIV expr       { $$=calc($1,$3,DIV);}
       |SUB expr %prec UMINUS     {$$=negative($2);}
       | LEFTBRA expr RIGHTBRA    {$$=$2;}
       |NUM   
       |ID                    {
         auto it = idmp.find($1);
         if(it==idmp.end())
         {
           char ch[500];
           sprintf(ch,"identifier %s not defined!",$1);
           yyerror(ch);
           YYERROR;
         }
         else
         {
           $$=it->second;
         }
       }          
;
assignexpr : ID ASSIGN expr       { idmp[$1]=$3;$$=$3;}
          | ID ASSIGN assignexpr {idmp[$1]=$3;$$=$3;}
;
illegal : ILLEGAL {yyerror("Illegal Character!");}
       
%%

int main()
{
  yyparse();
  return 0;
}

