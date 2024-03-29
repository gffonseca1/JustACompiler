%define parse.error verbose
%{

#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

extern void *arvore;

int yylex(void);
void yyerror (char const *s);
extern int get_line_number();

%}

%union{
	ASTNODE *no;
	VALOR_T *valor_lexico;
}

%type<no> programa;
%type<no> lista_de_elementos;
%type<no> tipo;
%type<no> declaracao_funcao;
%type<no> lista_parametros;
%type<no> parametros_entrada;
%type<no> parametro;
%type<no> comando;
%type<no> literal;
%type<no> lista_comandos;
%type<no> declaracao_var_local;
%type<no> identificador_local;
%type<no> declaracao_var_global;
%type<no> lista_de_identificadores_local;
%type<no> atribuicao;
%type<no> corpo;
%type<no> lista_argumentos;
%type<no> argumentos_entrada;
%type<no> argumento;
%type<no> controle_fluxo;
%type<no> controle_fluxo_while;
%type<no> retorno;
%type<no> chamada_funcao;
%type<no> expressao;
%type<no> bloco_comandos;
%type<no> E;
%type<no> T;
%type<no> F;
%type<no> G;
%type<no> H;
%type<no> I;
%type<no> J;
%type<no> K;
%type<no> L;
%type<no> operando;
%type<no> identificador_expressao;
%type<no> lista_expressoes;
%type<no> identificador;


%token <valor_lexico>TK_PR_INT
%token <valor_lexico>TK_PR_FLOAT
%token <valor_lexico>TK_PR_BOOL
%token <valor_lexico>TK_PR_CHAR
%token <valor_lexico>TK_PR_IF
%token <valor_lexico>TK_PR_THEN
%token <valor_lexico>TK_PR_ELSE
%token <valor_lexico>TK_PR_WHILE
%token <valor_lexico>TK_PR_INPUT
%token <valor_lexico>TK_PR_OUTPUT
%token <valor_lexico>TK_PR_RETURN
%token <valor_lexico>TK_PR_FOR
%token <valor_lexico>TK_OC_LE
%token <valor_lexico>TK_OC_GE
%token <valor_lexico>TK_OC_EQ
%token <valor_lexico>TK_OC_NE
%token <valor_lexico>TK_OC_AND
%token <valor_lexico>TK_OC_OR
%token <valor_lexico> TK_LIT_INT
%token <valor_lexico> TK_LIT_FLOAT
%token <valor_lexico> TK_LIT_FALSE
%token <valor_lexico> TK_LIT_TRUE
%token <valor_lexico> TK_LIT_CHAR
%token <valor_lexico> TK_IDENTIFICADOR
%token <valor_lexico> '='
%token <valor_lexico> '<'
%token <valor_lexico> '>'
%token <valor_lexico> '+'
%token <valor_lexico> '-'
%token <valor_lexico> '*'
%token <valor_lexico> '/'
%token <valor_lexico> '%'
%token <valor_lexico> '!'
%token <valor_lexico> '['
%token <valor_lexico> ']'
%token <valor_lexico> '^'
%type <valor_lexico> cabecalho;
%token TK_ERRO



%%

/* -----------------------------------------------------------------------
	
	3 A Linguagem

-------------------------------------------------------------------------
*/

programa: lista_de_elementos { arvore = $$;  }; // REVISAR
programa: { $$ = 0; };

lista_de_elementos: lista_de_elementos declaracao_funcao { if($1 == 0){ $$ = $2;} else {$$ = $1; add_child(&$$, &$2);} };
lista_de_elementos: lista_de_elementos declaracao_var_global { $$ = $1; };
lista_de_elementos: declaracao_funcao { $$ = $1; };
lista_de_elementos: declaracao_var_global { }; //Nao vai na AST //REVISAR

/* -----------------------------------------------------------------------
	
	3.1 Declarações de Variáveis Globais

-------------------------------------------------------------------------
*/

// void create_node(filho1, filho2, filho3, nome_do_node);
// create_leaf(valor, nome_da_folha)


tipo: TK_PR_INT   { $$ = 0; }|  //REVISAR PERGUNTAR PARA O SOR
      TK_PR_FLOAT { $$ = 0; }| 
      TK_PR_BOOL  { $$ = 0; }| 
      TK_PR_CHAR  { $$ = 0; };

identificador : TK_IDENTIFICADOR { $$ = create_leaf($1,IDENTIFICADOR); }; //REVISAR  FOLHA - VALUE

lista_dimensional_inteiro: TK_LIT_INT;
lista_dimensional: lista_dimensional_inteiro ;
lista_dimensional: lista_dimensional '^' lista_dimensional_inteiro ;
var_multidimensional: TK_IDENTIFICADOR '[' lista_dimensional ']' { deleteValue($1); };

declaracao_var_global: tipo lista_de_identificadores ';' { $$ = 0;};//{ $$ = $2; };//{ $$ = create_node($2, 0, 0, DEC_VAR_GLOBAL);};
lista_de_identificadores: TK_IDENTIFICADOR { deleteValue($1); };
lista_de_identificadores: var_multidimensional;
lista_de_identificadores: lista_de_identificadores ',' TK_IDENTIFICADOR {deleteValue($3);};
lista_de_identificadores: lista_de_identificadores ',' var_multidimensional;

/* -----------------------------------------------------------------------
	
	3.2 Definição de Funções  3.3 Bloco de Comandos

-------------------------------------------------------------------------
*/

//AST:  id -> ( nome , primeiro comando )
declaracao_funcao: cabecalho corpo  { $$ = create_node($1, IDENTIFICADOR); add_child(&$$, &$2); };
cabecalho: tipo TK_IDENTIFICADOR '(' lista_parametros ')' { $$ = $2; };
lista_parametros: parametros_entrada { $$ = 0; } | { $$ = 0;};
parametros_entrada: parametros_entrada ',' parametro { $$ = 0; } | parametro { $$ = 0; };
parametro: tipo TK_IDENTIFICADOR { $$ = 0; deleteValue($2);};

corpo : bloco_comandos { $$ = $1; }; 
bloco_comandos : '{' lista_comandos '}'  { $$ = $2; } | '{' '}' {  $$ = 0; };
lista_comandos: lista_comandos comando ';'  { if($1 == 0){ $$ = $2;} else {$$ = $1; add_child(&$$, &$2);} } | comando ';'  { $$ = $1; };


//FOLHA : LITERAIS, IDENTIFICADORES
//NODE : COMANDOS e FUNCOES
//CHILD : > 1 Funcão , > 1 comando, > 1 expressao  ; COMANDO; 


/* -----------------------------------------------------------------------
	
	3.4 Comandos Simples

-------------------------------------------------------------------------
*/

comando: declaracao_var_local { $$ = $1;}| 
         atribuicao { $$ = $1;}| 
         retorno { $$ = $1;}| 
         bloco_comandos { $$ = $1;}| 
         chamada_funcao { $$ = $1;}| 
         controle_fluxo { $$ = $1;}| 
         controle_fluxo_while { $$ = $1;};

literal: TK_LIT_INT   { $$ = create_leaf($1, VAL_LIT_INT); }| //REVISAR
         TK_LIT_CHAR  { $$ = create_leaf($1, VAL_LIT_CHAR); }| 
         TK_LIT_FALSE { $$ = create_leaf($1, VAL_LIT_BOOL); }| 
         TK_LIT_TRUE  { $$ = create_leaf($1, VAL_LIT_BOOL); }| 
         TK_LIT_FLOAT { $$ = create_leaf($1, VAL_LIT_FLOAT); };


// int a, b <= 2, c, d <= 3;

declaracao_var_local: tipo lista_de_identificadores_local { $$ = $2; };

identificador_local: TK_IDENTIFICADOR { $$=0; deleteValue($1); } | identificador TK_OC_LE literal { $$ = create_node($2, INIC_VAR); add_child(&$$,&$1); add_child(&$$,&$3); };

lista_de_identificadores_local: lista_de_identificadores_local ',' identificador_local { if($3 != 0){$$ = $3; add_child(&$$, &$1);} } | identificador_local { $$ = $1; };

atribuicao: identificador_expressao '=' expressao { $$ = create_node($2, ATRIBUICAO); add_child(&$$, &$1); add_child(&$$,&$3); } ;

lista_argumentos: argumentos_entrada { $$ = $1; } | { $$ = 0; };
argumentos_entrada: argumentos_entrada ',' argumento { $$ = $1; add_child(&$$, &$3); } | argumento { $$ = $1; };
argumento: expressao { $$ = $1; };

controle_fluxo: TK_PR_IF '(' expressao ')' TK_PR_THEN bloco_comandos  { $$ = create_node($1, IF); add_child(&$$,&$3); add_child(&$$,&$6);  } | 
                TK_PR_IF '(' expressao ')' TK_PR_THEN bloco_comandos TK_PR_ELSE bloco_comandos { $$ = create_node($1, IF_ELSE); add_child(&$$,&$3); add_child(&$$,&$6); add_child(&$$,&$8); }; // REVISAR

controle_fluxo_while: TK_PR_WHILE '(' expressao ')' bloco_comandos { $$ = create_node($1, WHILE); add_child(&$$, &$3); add_child(&$$, &$5); } ;

retorno: TK_PR_RETURN expressao { $$ = create_node( $1, RETURN); add_child(&$$,&$2); } ;

chamada_funcao: TK_IDENTIFICADOR '(' lista_argumentos ')' { $$ = create_node($1, CHAMADA_FUNC); add_child(&$$, &$3); } ;

/* -----------------------------------------------------------------------
	
	3.5 Expressões

-------------------------------------------------------------------------
*/

expressao: E { $$ = $1;};
E: E TK_OC_OR T { $$ = create_node($2, EXP_OR); add_child(&$$, &$1); add_child(&$$, &$3); }  | T { $$ = $1; };

T: T TK_OC_AND F { $$ = create_node($2, EXP_AND); add_child(&$$, &$1); add_child(&$$, &$3); } | F { $$ = $1; };

F: F TK_OC_EQ G { $$ = create_node($2, EXP_EQ); add_child(&$$, &$1); add_child(&$$, &$3); } | F TK_OC_NE G  { $$ = create_node($2, EXP_NE); add_child(&$$, &$1); add_child(&$$, &$3); } | G { $$ = $1; };

G: G TK_OC_GE H { $$ = create_node($2, EXP_GE); add_child(&$$, &$1); add_child(&$$,&$3); } | 
   G TK_OC_LE H { $$ = create_node($2, EXP_LE); add_child(&$$, &$1); add_child(&$$, &$3); } |
   G '<' H { $$ = create_node($2, EXP_LT); add_child(&$$, &$1); add_child(&$$, &$3); }  |
   G '>' H { $$ = create_node($2, EXP_GT); add_child(&$$, &$1); add_child(&$$, &$3); } |
   H { $$ = $1; };

H: H '+' I { $$ = create_node($2, BIN_PLUS); add_child(&$$, &$1); add_child(&$$, &$3); } | H '-' I { $$ = create_node($2, BIN_MINUS); add_child(&$$, &$1); add_child(&$$, &$3); } | I { $$ = $1; };

I: I '%' J { $$ = create_node($2, BIN_PERCENT); add_child(& $$, & $1); add_child(& $$, & $3); }| I '/' J { $$ = create_node($2, BIN_DIV); add_child(& $$, & $1); add_child(& $$, & $3); } | I '*' J { $$ = create_node($2, BIN_MULT); add_child(& $$, & $1); add_child(& $$, & $3); }| J { $$ = $1; };

J: '-' K { $$ = create_node($1, UN_MINUS); add_child(&$$, &$2); } | '!' K { $$ = create_node($1, UN_NEG); add_child(&$$, &$2); } | L { $$ = $1; };

K: '-' K { $$ = create_node($1, UN_MINUS); add_child(&$$, &$2); } | '!' K { $$ = create_node($1, UN_NEG); add_child(&$$, &$2); } | L { $$ = $1; };

L: '(' E ')' { $$ = $2; } | operando { $$ = $1; };

operando: literal { $$ = $1; } | chamada_funcao { $$ = $1; } | identificador_expressao { $$ = $1; };

identificador_expressao: TK_IDENTIFICADOR { $$ = create_leaf($1, IDENTIFICADOR); } | TK_IDENTIFICADOR '[' lista_expressoes ']' 
{ $$ = create_node($2, IDENT_EXP); ASTNODE * identLeaf = create_leaf($1,IDENTIFICADOR);  add_child(&$$,&identLeaf); add_child(&$$,&$3); deleteValue($4); } ; //REVISAR - Passando o primeiro '[' , constroi o [] no ast.c



//lista_de_elementos: lista_de_elementos declaracao_funcao { if($1 == 0){ $$ = $2;} else {$$ = $1; add_child(&$$, &$2);} };
lista_expressoes: lista_expressoes '^' expressao { $$=create_node($2,LISTA_EXP); add_child(&$$,&$1); add_child(&$$, &$3); } | expressao { $$ = $1; };

%%


void yyerror(char const *s){
	printf("%s na linha: %d\n", s,get_line_number());
	
}

