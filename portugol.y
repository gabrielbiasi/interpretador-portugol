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

%type <str_val> EXP EXP_A TERM_A FAT_A ADISUB MULDIV VAR


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
CMDS:              pr_leia L_VAR CMDS
                   | pr_escreva L_ESC CMDS
                   | identificador { CheckVarTable($1); } op_atrib EXP { fprintf(output, "%s = %s\n", $1, $4); free($1); free($4); } CMDS
                   | pr_se COND pr_entao CMDS SEN pr_fim_se CMDS
                   | pr_para identificador { CheckVarTable($2); } op_atrib EXP_A pr_ate EXP_A pr_passo EXP_A pr_faca CMDS pr_fim_para CMDS
                   | pr_enqto COND pr_faca CMDS pr_fim_enqto CMDS
                   | pr_repita CMDS pr_ate COND CMDS
                   | identificador { CheckVarTable($1); } abre_par L_VAR fecha_par CMDS
                   | %empty;
L_VAR:             VAR L_VRS;
L_VRS:             virgula VAR
                   | %empty;
VAR:               identificador { CheckVarTable($1); } IND;
IND:               abre_col EXP_A fecha_col IND
                   | ponto identificador { CheckVarTable($2); } IND
                   | %empty;
L_ESC:             const_lit L_ESCS
                   | EXP_A L_ESCS;
L_ESCS:            virgula L_ESC
                   | %empty;
SEN:               pr_senao CMDS
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
EXP_A:             TERM_A MULDIV EXP_A {asprintf(&$$, "%s %s %s", $1, $2, $3); free($1); free($2); free($3);}
                   | TERM_A;
TERM_A:            FAT_A ADISUB TERM_A {asprintf(&$$, "%s %s %s", $1, $2, $3); free($1); free($2); free($3);}
                   | FAT_A;
FAT_A:             abre_par EXP_A fecha_par {asprintf(&$$, "(%s)", $2); free($2);}
                   | FUNC abre_par L_ESC fecha_par
                   | VAR {$$ = $1;}
                   | num_inteiro {$$ = $1;}
                   | num_real {$$ = $1;};
MULDIV:            op_arit_mult {asprintf(&$$, "*");}
                   | op_arit_div {asprintf(&$$, "/");};
ADISUB:            op_arit_adi {asprintf(&$$, "+");}
                   | op_arit_sub {asprintf(&$$, "-");} ;
FUNC:              pr_abs
                   | pr_trunca
                   | pr_resto
                   | identificador { CheckVarTable($1); };


EXP_L:             REL OP_LOG EXP_L
                   | op_log_nao abre_par EXP_L fecha_par
                   | REL;
REL:               FAT_R OP_REL FAT_R;
FAT_R:             FAT_A
                   | const_lit;
OP_LOG:            op_log_and
                   | op_log_or;
OP_REL:            op_rel_igual
                   | op_rel_naoigual
                   | op_rel_maior
                   | op_rel_maiorigual
                   | op_rel_menor
                   | op_rel_menorigual;
COND:              abre_par EXP_L fecha_par;

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
