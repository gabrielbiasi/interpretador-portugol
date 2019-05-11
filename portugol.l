%{
#include <cstdio>
#include <cstdlib>
#include <string>
#include "portugol.tab.h"

using namespace std;

void yyparser(void);
void yyerror(std::string);
void yywarning(std::string);

FILE *output;

%}

%option yylineno

delim               [ \t\n]+
identificador       [a-zA-Z][a-zA-Z0-9]{0,31}
num_inteiro         [0-9]+
num_real            [0-9]+,[0-9]+
const_lit           \"(\\.|[^"])*\"
comment             \/\/[^\n]*

%%

{delim}             { /* sem ação para delimitadores. */ }
{comment}           { /* sem ação para comentários simples. */ }

"algoritmo"                              return pr_algoritmo;
"inicio"                                 return pr_inicio;
"fim_algoritmo"                          return pr_fim_algo;
"LOGICO"                                 return pr_logico;
"INTEIRO"                                return pr_inteiro;
"REAL"                                   return pr_real;
"CARACTER"                               return pr_caracter;
"REGISTRO"                               return pr_registro;
"leia"                                   return pr_leia;
"escreva"                                return pr_escreva;
"se"                                     return pr_se;
"entao"                                  return pr_entao;
"senao"                                  return pr_senao;
"fim_se"                                 return pr_fim_se;
"para"                                   return pr_para;
"ate"                                    return pr_ate;
"passo"                                  return pr_passo;
"faca"                                   return pr_faca;
"fim_para"                               return pr_fim_para;
"enquanto"                               return pr_enqto;
"fim_enquanto"                           return pr_fim_enqto;
"repita"                                 return pr_repita;
"ABS"                                    return pr_abs;
"TRUNCA"                                 return pr_trunca;
"RESTO"                                  return pr_resto;
"declare"                                return pr_declare;
"entrada"                                return pr_entrada;
"saida"                                  return pr_saida;
"funcao"                                 return pr_funcao;
"fim_funcao"                             return pr_fim_funcao;
"procedimento"                           return pr_procmto;
"fim_procedimento"                       return pr_fim_procmto;

{identificador}                          {yylval.str_val = strdup(yytext); return identificador;};
{num_inteiro}                            {yylval.str_val = strdup(yytext); return num_inteiro;};
{num_real}                               {yylval.str_val = strdup(yytext); return num_real;};
{const_lit}                              return const_lit;
"."                                      return ponto;
","                                      return virgula;
";"                                      return ponto_virgula;
":"                                      return dois_pontos;
"["                                      return abre_col;
"]"                                      return fecha_col;
"("                                      return abre_par;
")"                                      return fecha_par;
"*"                                      return op_arit_mult;
"/"                                      return op_arit_div;
"+"                                      return op_arit_adi;
"-"                                      return op_arit_sub;
"="                                      return op_atrib;
"=="                                     return op_rel_igual;
"!="                                     return op_rel_naoigual;
">"                                      return op_rel_maior;
">="                                     return op_rel_maiorigual;
"<"                                      return op_rel_menor;
"<="                                     return op_rel_menorigual;
"!"                                      return op_log_nao;
"&&"                                     return op_log_and;
"||"                                     return op_log_or;
.                                        { printf("Erro lexico! Token nao reconhecido! \"%s\"\n", yytext); }

%%

void yyerror(std::string str) {
    printf("Error! Na linha %d!\n", yylineno);
}

void yywarning(std::string str) {
    printf("Warning! Na linha %d!\n", yylineno);
}

int yywrap(void) { return 1; }

int main (int num_args, char **args) {
    if (num_args != 2) exit(0);
    FILE *file = fopen(args[1], "r");
    output = fopen("output.py", "w");
    if (file == NULL) exit(0);
    yyin = file;
    yyparse();
    fclose(file);
    fclose(output);
}
