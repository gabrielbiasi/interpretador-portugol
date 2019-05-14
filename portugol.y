%{
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <string>
#include <vector>

using namespace std;

std::vector<char*> var_table;
extern int yylineno;
extern FILE* output;
extern int yylex();
extern void yyerror(std::string);
void AddVarTable(char*);
void CheckVarTable(char*);
void PrintVarTable();

int nivel = 0;
void Tab();
%}

%union {
    int     int_val;
    double  double_val;
    char* str_val;
}

%token <str_val> const_lit identificador num_inteiro num_real

%token <int_val> ponto virgula ponto_virgula dois_pontos abre_col fecha_col
%token <int_val> abre_par fecha_par
%token <int_val> op_arit_mult op_arit_div op_arit_adi op_arit_sub
%token <int_val> op_atrib op_rel_igual op_rel_naoigual op_rel_maior
%token <int_val> op_rel_maiorigual op_rel_menor op_rel_menorigual
%token <int_val> op_log_nao op_log_and op_log_or pr_algoritmo
%token <int_val> pr_inicio pr_fim_algo pr_logico pr_inteiro
%token <int_val> pr_real pr_caracter pr_registro pr_leia
%token <int_val> pr_escreva pr_se pr_entao pr_senao pr_fim_se pr_para pr_ate
%token <int_val> pr_passo pr_faca pr_fim_para pr_enqto pr_fim_enqto pr_repita
%token <int_val> pr_abs pr_trunca pr_resto pr_declare

%token <int_val> pr_entrada pr_fim_funcao pr_fim_procmto pr_funcao
%token <int_val> pr_procmto pr_saida

%type <str_val> EXP EXP_A TERM_A FAT_A ADISUB MULDIV VAR L_ESC L_ESCS EXP_L IND L_VAR L_VRS
%type <str_val> COND OP_LOG OP_REL REL FAT_R FUNC

%start INICIO

%%
INICIO:            ALGO { printf("Sucesso!\n"); };
ALGO:              pr_algoritmo identificador { free($2); } PROCS pr_inicio DECL CMDS pr_fim_algo;
DECL:              pr_declare L_IDS dois_pontos TIPO ponto_virgula DECL
                   | %empty;
L_IDS:             identificador { AddVarTable($1); } COMP LIDS;
LIDS:              virgula L_IDS
                   | %empty;
COMP:              abre_col DIM fecha_col
                   | %empty;
DIM:               num_inteiro ponto ponto num_inteiro DIMS;
DIMS:              virgula DIM
                   | %empty;
TIPO:              pr_logico
                   | pr_caracter
                   | pr_inteiro
                   | pr_real
                   | identificador { CheckVarTable($1); }
                   | REG;
REG:               pr_registro abre_par DECL fecha_par;

CMDS:              pr_leia VAR { Tab(); fprintf(output, "%s = input()\n", $2); free($2); } CMDS
                   | pr_escreva L_ESC { Tab(); fprintf(output, "print(%s)\n", $2); free($2);} CMDS
                   | identificador { CheckVarTable($1); } op_atrib EXP { Tab(); fprintf(output, "%s = %s\n", $1, $4); free($1); free($4); } CMDS
                   | pr_se COND pr_entao { Tab(); fprintf(output, "if %s:\n", $2); free($2); nivel++; } CMDS { nivel--; } SEN pr_fim_se CMDS
                   | pr_para identificador { CheckVarTable($2); } op_atrib EXP_A pr_ate EXP_A pr_passo EXP_A pr_faca { Tab(); fprintf(output, "for %s in range(%s, %s, %s):\n", $2, $5, $7, $9); free($2); free($5); free($7); free($9); nivel++; } CMDS pr_fim_para { nivel--; } CMDS
                   | pr_enqto COND pr_faca { Tab(); fprintf(output, "while %s:\n", $2); free($2); nivel++; } CMDS pr_fim_enqto { nivel--; } CMDS
                   | pr_repita { Tab(); fprintf(output, "while True:\n"); nivel++; } CMDS pr_ate COND { Tab(); fprintf(output, "if %s:\n", $5); nivel++; Tab(); fprintf(output, "break\n"); nivel-= 2; } CMDS
                   | identificador { CheckVarTable($1); } abre_par L_VAR fecha_par {Tab(); fprintf(output, "%s(%s)\n", $1, $4); free($1); free($4); } CMDS
                   | %empty;

L_VAR:             VAR L_VRS { asprintf(&$$, "%s%s", $1, $2); free($1); free($2); };
L_VRS:             virgula VAR { asprintf(&$$, ", %s", $2); free($2); }
                   | %empty { $$ = (char*) malloc(1); $$[0] = '\0'; };

VAR:               identificador { CheckVarTable($1); } IND {  asprintf(&$$, "%s%s", $1, $3); free($1); free($3);};
IND:               abre_col EXP_A fecha_col IND { asprintf(&$$, "[%s]%s", $2, $4); free($2); free($4);}
                   | ponto identificador { CheckVarTable($2); } IND { asprintf(&$$, ".%s%s", $2, $4); free($2); free($4);}
                   | %empty { $$ = (char*) malloc(1); $$[0] = '\0'; };

L_ESC:             const_lit L_ESCS { asprintf(&$$, "%s%s", $1, $2); free($1); free($2); }
                   | EXP L_ESCS { asprintf(&$$, "%s%s", $1, $2); free($1); free($2); };
L_ESCS:            virgula L_ESC { asprintf(&$$, ", %s", $2); free($2); }
                   | %empty { $$ = (char*) malloc(1); $$[0] = '\0'; };

SEN:               pr_senao { Tab(); fprintf(output, "else:\n"); nivel++; } CMDS { nivel--; }
                   | %empty;

PARAM:             identificador { AddVarTable($1); } dois_pontos TIPO;

L_PARAM:           PARAM L_PARAMS
L_PARAMS:          virgula L_PARAM
                   | %empty;

PROCS:             pr_funcao identificador { AddVarTable($2); } pr_entrada L_PARAM pr_saida PARAM DECL CMDS pr_fim_funcao PROCS
                   | pr_procmto identificador { AddVarTable($2); } pr_entrada L_PARAM DECL CMDS pr_fim_procmto PROCS
                   | %empty;


EXP:               EXP_L
                   | EXP_A {$$ = $1;};
EXP_A:             TERM_A MULDIV EXP_A {if($2[0] == '/') { asprintf(&$$, "%s %s float(%s)", $1, $2, $3); } else { asprintf(&$$, "%s %s %s", $1, $2, $3); } free($1); free($2); free($3);}
                   | TERM_A;
TERM_A:            FAT_A ADISUB TERM_A {asprintf(&$$, "%s %s %s", $1, $2, $3); free($1); free($2); free($3);}
                   | FAT_A;
FAT_A:             abre_par EXP_A fecha_par {asprintf(&$$, "(%s)", $2); free($2);}
                   | FUNC abre_par L_ESC fecha_par { asprintf(&$$, "%s(%s)", $1, $3); free($1); free($3); }
                   | VAR {$$ = $1;}
                   | num_inteiro {$$ = $1;}
                   | num_real {$$ = $1;};
MULDIV:            op_arit_mult {asprintf(&$$, "*");}
                   | op_arit_div {asprintf(&$$, "/");};
ADISUB:            op_arit_adi {asprintf(&$$, "+");}
                   | op_arit_sub {asprintf(&$$, "-");} ;
FUNC:              pr_abs { asprintf(&$$, "ABS"); }
                   | pr_trunca { asprintf(&$$, "TRUNCA"); }
                   | pr_resto { asprintf(&$$, "RESTO"); }
                   | identificador { CheckVarTable($1); };


EXP_L:             REL OP_LOG EXP_L { asprintf(&$$, "%s %s %s", $1, $2, $3); free($1); free($2); free($3); }
                   | op_log_nao abre_par EXP_L fecha_par { asprintf(&$$, "not (%s)", $3); free($3); }
                   | REL { $$ = $1; };
REL:               FAT_R OP_REL FAT_R { asprintf(&$$, "%s %s %s", $1, $2, $3); free($1); free($2); free($3); };
FAT_R:             FAT_A { $$ = $1; }
                   | const_lit { $$ = $1; };
OP_LOG:            op_log_and { asprintf(&$$, "and"); }
                   | op_log_or { asprintf(&$$, "or"); };
OP_REL:            op_rel_igual { asprintf(&$$, "=="); }
                   | op_rel_naoigual { asprintf(&$$, "!="); }
                   | op_rel_maior { asprintf(&$$, ">"); }
                   | op_rel_maiorigual { asprintf(&$$, ">="); }
                   | op_rel_menor { asprintf(&$$, "<"); }
                   | op_rel_menorigual { asprintf(&$$, "<="); };
COND:              abre_par EXP_L fecha_par { asprintf(&$$, "(%s)", $2); free($2); };

%%

void AddVarTable(char* var) {
    var_table.push_back(var);
}

void CheckVarTable(char* var) {
    auto it = var_table.begin();
    while(it != var_table.end()) {
        if(!strcmp(*it, var)) {
            return;
        }
        it++;
    }
    printf("Erro na linha [%d]: Variavel não declarada: \"%s\"\n\n", yylineno, var);
    PrintVarTable();
    free(var);
    exit(1);
}

void PrintVarTable() {
    printf("Lista de Variaveis\n");
    auto it = var_table.begin();
    while(it != var_table.end()) {
        printf("%s\n", *it);
        free(*it);
        it++;
    }
    printf("----\n");
}

void Tab() {
    int i;
    for(i = 0; i < nivel; i++) {
        fprintf(output, "    ");
    }
}
