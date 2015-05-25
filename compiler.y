%{
#include <stdio.h>
#include <string.h>
#include "stack.h"
#include "vmCompiler.h"
#include "y.tab.h"


void yyerror(char *s);
extern ccLine;

static int total;
static Stack s;
// falta a variavel
// duvida na lista/conjunto de instruções
// alterações:
// Decla -> juntei ponto e virgula
// O Lista de Instruções está estranho (tem nested instructions)
// talvez deviamos distinguir entre as variaveis escalares e vetoriais
// no conjunto de instruções, é possivel identificar funções logo ao abrir usem duas chavetas
// juntar &no SCANI ?
// contar com os \n?
// rever as Exp
// pode dar erro quando se faz uma Atrib fora de FOR pq falta ;
// e quando se faz uma atribuiçao ao mesmo tempo que uma declaraçao? -> acrescentei produção (resolve tambem problema anterior)
// é necessario rever todos os sitios onde se deve inserir ou nao ;

%}

%union{
	char* var_name;
	int value;
	Type type;
	struct sVarAtr
	{
		char* var_name;
		int value;
		int size;
	} varAtr;	
}

%token INT WHILE FOR IF ELSE RETURN VOID PRINTI SCANI TRUE FALSE DO END
%token var nomefuncao num

%type <var_name> var
%type <value> num
%type <varAtr> VarAtr
%type <varAtr> Atrib
%type <type> Tipo

%left '+' '-'
%left '*' '/' '%'
%left '&' '|'

%start Prog

%% 
Prog:		ListaDecla									{printf("START\n");}
			ListInstI									{printf("STOP\n");}
			;

ListInstI:	Inst ListInstI								
			| 
			;

ConjInst:	Inst										
			| '{' ListInst '}'						
			;

ListInst:	Inst ListInst								
			| Inst										
			;

Inst:		If											
			| While										
			| For										
			| Atrib	';'									
			| Printi';'									
			| Scani	';'									
			| RETURN Exp ';'
			| DoWhile									
			;

VarAtr:		var											{$$.var_name=strdup($1); $$.size=1;}
			;

Atrib: 		VarAtr '=' Exp								{Addr a = getAddr($1.var_name);
														printf("STORE%c %d\n",a.scope,a.addr);}
			| VarAtr '+''+'								{Addr a = getAddr($1.var_name);
														printf("PUSHI 1\nPUSH%c %d\nADD\nSTORE%c %d\n",a.scope,a.addr,a.scope,a.addr);}
			| VarAtr 									{Addr a = getAddr($1.var_name); 
														printf("PUSHI %d\n",a.addr);}
			 '[' Exp ']' '=' Exp 						{printf("STOREN\n");}
			;

ListaDecla: Decla ListaDecla 										
            | Funcao ListaDecla
            |
            ;

Decla:		INT var ';' 								{printf("PUSHI 0\n"); decVar($2, 1);}
			| INT var '[' num ']' ';'					{printf("PUSHN %d\n",$4); decVar($2, $4);}
			;

Printi:		PRINTI '(' Exp ')'							{printf("WRITEI\n");}
			;

Scani:		SCANI '(' VarAtr ')'						{Addr a = getAddr($3.var_name);
														printf("READ\nATOI\nSTORE%c %d\n",a.scope,a.addr);}
			;

If: 		IF TestExpL									{total++; push(s,total); printf("JZ endCond%d\n", get(s));}
			ConjInst									{printf("endCond%d\n", pop(s));}
			Else
			;

Else:
			| ELSE ConjInst
			;

While:		WHILE 										{total++; push(s,total); printf("Cond%d: NOP\n", get(s));}
			TestExpL									{printf("JZ endCond%d\n", get(s));}
			ConjInst									{printf("JUMP Cond%d\nendCond%d\n", get(s), get(s)); pop(s);}
			;

DoWhile:	DO 											{total++; push(s,total); printf("Cond%d: NOP\n", get(s));}
			ConjInst WHILE TestExpL						{printf("JZ endCond%d\nJUMP Cond%d\nendCond%d: NOP\n",get(s) ,get(s) ,get(s)); pop(s);}
			;
	
For:		FOR ForHeader ConjInst 						{printf("JUMP Cond%dA\nendCond%d\n", get(s), get(s)); pop(s);}
			;

ForHeader:	'(' ForAtrib ';'							{total++; push(s,total); printf("Cond%d: NOP\n", get(s));}
			ExpL ';'									{printf("JZ endCond%d\nJUMP Cond%dB\nCond%dA: NOP\n", get(s), get(s), get(s));}
			ForAtrib ')'								{printf("JUMP Cond%d\nciclo%dB: NOP\n", get(s), get(s));}
			;

ForAtrib: 	Atrib										
			| 											
			;

Funcao:		'#'Tipo var 						{decFun($2.type,$3);}
			'(' ListaArg ')'					{}
			ConjInst							{}
			;

Tipo:		VOID								{$$ = _VOID;}
			| INT								{$$ = _INT;}
			;

ListaArg: 	
			| ListaArg2 
			;

ListaArg2:	Tipo var 							{dec}
			| ListaArg2  ','  Tipo var 
			;

Exp:		 Exp '+' Exp								{printf("ADD\n");}
			| Exp '-' Exp								{printf("SUB\n");}
			| Exp '%' Exp   							{printf("MOD\n");}
			| Exp '*' Exp								{printf("MUL\n");}
			| Exp '/' Exp								{printf("DIV\n");}
			| '(' Exp ')'								
			| num										{printf("PUSHI %d\n", $1);}
			| VarAtr									{Addr a = getAddr($1.var_name); printf("PUSH%c %d\n",a.scope,a.addr); }
			| VarAtr '[' Exp ']'						{Addr a = getAddr($1.var_name); printf("PUSH%cP\nADD\nPUSHI %d\nLOADN\n",a.scope,a.addr);}
			| var '(' FunArgs')'						
			;
FunArgs: 	
			| FunArgs2
			;

FunArgs2: 	 Exp 
			| FunArgs2 ',' Exp

TestExpL:	'(' ExpL ')'										
			;

ExpL:		  Exp '=''=' Exp							{printf("EQUAL\n");}
     		| Exp '!''=' Exp							{printf("EQUAL\nPUSHI 0\nEQUAL\n");}
			| Exp '>''=' Exp  							{printf("SUPEQ\n");}
			| Exp '<''=' Exp							{printf("INFEQ\n");}
			| Exp '<' Exp 								{printf("INF\n");}
			| Exp '>' Exp								{printf("SUP\n");}
			| ExpL '&''&' ExpL
			| ExpL '|''|' ExpL
			;
%%

void yyerror(char *s){
    printf("Erro sintatico line %d: %s\n",ccLine,s);
}

void init()
{
	s = initStack();
	total = 0;
}

