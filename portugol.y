%{
#include <cstdio>
#include <cstdlib>
#include <string>
#include <map>

using namespace std;

map<std::string, double> vars;
extern int yylex();
extern void yyerror(char *);
void DivError(void);
void UnknownVarError(std::string s);
%}

%union {
    int     int_val;
    double  double_val;
    std::string* str_val;
}

%token <double_val> num_real

%token <str_val> const_lit identificador

%token <int_val> ponto virgula ponto_virgula dois_pontos abre_col fecha_col
%token <int_val> abre_par fecha_par aspas num_inteiro 
%token <int_val> op_arit_mult op_arit_div op_arit_adi op_ari_sub
%token <int_val> op_atrib op_rel_igual op_rel_naoigual op_rel_maior
%token <int_val> op_rel_maiorigual op_rel_menor op_rel_menorigual
%token <int_val> op_log_nao op_log_and op_log_or pr_algoritmo
%token <int_val> pr_inicio pr_fim_algo pr_logico pr_inteiro
%token <int_val> pr_real pr_caracter pr_registro pr_leia
%token <int_val> pr_escreva pr_se pr_entao pr_senao pr_fim_se pr_para pr_ate
%token <int_val> pr_passo pr_faca pr_fim_para pr_enqto pr_fim_enqto pr_repita
%token <int_val> pr_abs pr_trunca pr_resto pr_declare abra_par fechar_par

%token <int_val> op_arit_adicao op_arit_expo op_arit_rad op_logico_and
%token <int_val> op_logico_or op_rel_maiorque op_rel_menorque
%token <int_val> pr_entrada pr_fim_funcao pr_fim_procmto pr_funcao
%token <int_val> pr_procmto pr_saida op_arit_subtracao

%start ALGO

%%

ALGO:              pr_algoritmo identificador PROCS pr_inicio DECL CMDS pr_fim_algo;
DECL:              pr_declare L_IDS dois_pontos TIPO ponto_virgula DECL
                   | %empty;
L_IDS:             identificador COMP LIDS;
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
                   | identificador
                   | REG;
REG:               pr_registro abra_par DECL fecha_par;
CMDS:              pr_leia L_VAR
                   | pr_escreva L_ESC
                   | identificador op_atrib EXP
                   | pr_se COND pr_entao CMDS SEN pr_fim_se
                   | pr_para identificador op_atrib EXP_A pr_ate EXP_A pr_passo EXP_A pr_faca CMDS pr_fim_para
                   | pr_enqto COND CMDS pr_fim_enqto
                   | pr_repita CMDS pr_ate COND
                   | identificador abre_par L_VAR fecha_par;
L_VAR:             VAR L_VRS;
L_VRS:             virgula VAR
                   | %empty;
VAR:               identificador IND;
IND:               abre_col EXP_A fecha_col IND
                   | ponto identificador IND
                   | %empty;
L_ESC:             const_lit L_ESCS
                   | VAR L_ESCS;
L_ESCS:            virgula L_ESC
                   | %empty;
SEN:               pr_senao CMDS
                   | %empty;

PARAM:             VAR dois_pontos TIPO;

L_PARAM:           PARAM L_PARAMS
L_PARAMS:          virgula L_PARAM
                   | %empty;

PROCS:             pr_funcao identificador pr_entrada L_PARAM pr_saida PARAM DECL CMDS pr_fim_funcao PROCS
                   | pr_procmto identificador pr_entrada L_PARAM DECL CMDS pr_fim_procmto PROCS
                   | %empty;


EXP:               EXP_L
                   | EXP_A;
EXP_A:             TERM_A MULDIV EXP_A
                   | TERM_A;
TERM_A:            FAT_A ADISUB TERM_A
                   | FAT_A;
FAT_A:             EXP_A op_arit_expo EXP_A
                   | EXP_A op_arit_rad EXP_A
                   | abre_par EXP_A fecha_par
                   | FUNC abre_par L_VAR fecha_par
                   | VAR
                   | num_inteiro
                   | num_real;
MULDIV:            op_arit_mult
                   | op_arit_div;
ADISUB:            op_arit_adicao
                   | op_arit_subtracao;
FUNC:              pr_abs
                   | pr_trunca
                   | pr_resto
                   | identificador;


EXP_L:             REL OP_LOG EXP_L
                   | op_log_nao abre_par REL fechar_par
                   | REL;
REL:               FAT_R OP_REL FAT_R;
FAT_R:             FAT_A
                   | const_lit;
OP_LOG:            op_logico_and
                   | op_logico_or;
OP_REL:            op_rel_igual
                   | op_rel_naoigual
                   | op_rel_maiorque
                   | op_rel_maiorigual
                   | op_rel_menorque
                   | op_rel_menorigual;
COND:              abre_par EXP_L fecha_par;

%%

void DivError(void) {
    printf("DIVISÃO POR ZERO!\n");
    exit(0);
}

void UnknownVarError(std::string s) {
    printf("VARIÁVEL NÃO ESCRITA! = %s\n", s.c_str());
    exit(0);
}
