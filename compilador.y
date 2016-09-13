
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "utils.h"

int offset, lexLevel = 0;
// Obs: Nao da pra inicializar coisas aqui!
ST symbolTable;
Stack labels;
Stack ExprE, ExprT, ExprF;
Element atribuido;
char Operacao[5];

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
// Adicionados por nois
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO OR DIV AND NOT
%token INTEGER MAIS MENOS ASTERISCO BARRA
%token IGUAL NUMERO MAIOR MENOR DESIGUAL
%token MAIOR_IGUAL MENOR_IGUAL

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

programa    :{
             symbolTable = initST();
             labels = initStack();
             ExprE = initStack();
             ExprT = initStack();
             ExprF = initStack();
             atribuido = NULL;
             geraCodigo (NULL, "INPP");
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO {
             char dmem[10];
             sprintf(dmem, "DMEM %d", offset);
             geraCodigo(NULL, dmem);
             geraCodigo (NULL, "PARA");
             deleteST(symbolTable);
             deleteStack(labels);
             deleteStack(ExprE);
             deleteStack(ExprT);
             deleteStack(ExprF);
             }
;

bloco       :
              parte_declara_vars
              {
              }

              comando_composto
              ;




parte_declara_vars:  var

var         : { offset = 0; } VAR declara_vars {
                    char amem[10];
                    sprintf(amem, "AMEM %d", offset);
                    geraCodigo(NULL, amem);
                }
            |
;

declara_vars: declara_vars declara_var
            | declara_var
;

declara_var : { }
              lista_id_var DOIS_PONTOS
              tipo
              { /* AMEM */
              }
              PONTO_E_VIRGULA
;

tipo        : INTEGER
;

lista_id_var: lista_id_var VIRGULA IDENT {
                //token ja está definido ?
                Cat cat = initSimpleVar(offset);
                insertST(symbolTable, token, lexLevel, SIMPLEVAR, cat);
                ++offset;
            }
            | IDENT {
                //token ja está definido ?
                Cat cat = initSimpleVar(offset);
                insertST(symbolTable, token, lexLevel, SIMPLEVAR, cat);
                ++offset;
            }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;

comando_composto: T_BEGIN comandos T_END;

comandos: comandos PONTO_E_VIRGULA comando | comando;

comando: rotulo comando_sem_rotulo;

/* Ou 'numero DOIS_PONTOS' ou nada. Suponho que, se nao tem nada, eu deixo em branco soh. */
rotulo: NUMERO DOIS_PONTOS | ;

comando_sem_rotulo: atribuicao | comando_repetitivo | comando_condicional;

atribuicao: variavel ATRIBUICAO expr {
        char armz[13]; // Da ateh 3 digitos de inteiros
        sprintf(armz, "ARMZ %d,%d", atribuido->lexLevel, atribuido->value->simpleVar.offset);
        geraCodigo(NULL, armz);
        // Verifica se os tipos sao iguais. NAO FOI FEITO AINDA.
    }
;

variavel: IDENT {
            int i;
            if((i = searchST(symbolTable, token)) < 0) {
                eSymbolNotFound(token);
            }
            atribuido = symbolTable->elems[i];
        }
;

expressao: expr relacao expr {
    /*
    checa_tipo(ExprE, ExprE, "boolean");
    */
    geraCodigo(NULL, Operacao);
} | expr {
    /* if(strcmp("boolean", (char *) pop(ExprE)) != 0) {
        imprimeErro("Erro na verificacao de tipos.");
    }*/
};

relacao: MAIOR {
    strcpy(Operacao, "CMMA");
} | MENOR {
    strcpy(Operacao, "CMME");
} | MAIOR_IGUAL {
    strcpy(Operacao, "CMAG");
} | MENOR_IGUAL {
    strcpy(Operacao, "CMEG");
} | IGUAL {
    strcpy(Operacao, "CMIG");
} | DESIGUAL {
    strcpy(Operacao, "CMDG");
};

expr: expr MAIS t {
    geraCodigo(NULL, "SOMA");
    checa_tipo(ExprT, ExprE, "integer");

    char type[] = "integer";
    push(ExprE, (void*)type);
} | expr OR t {
    geraCodigo(NULL, "CONJ");
    checa_tipo(ExprT, ExprE, "boolean");

    char type[] = "boolean";
    push(ExprE, (void*)type);
} | expr MENOS t {
    geraCodigo(NULL, "SUBT");
    checa_tipo(ExprT, ExprE, "integer");

    char type[] = "integer";
    push(ExprE, (void*)type);
} | t {
    push(ExprE, pop(ExprT));
}

t: t ASTERISCO f {
    geraCodigo(NULL, "MULT");
    checa_tipo(ExprF, ExprT, "integer");
    char type[] = "integer";
    push(ExprT, (void*)type);
} | t AND f {
    geraCodigo(NULL, "DISJ");
    checa_tipo(ExprF, ExprT, "boolean");
    char type[] = "boolean";
    push(ExprT, (void*)type);
} | t BARRA f {
    geraCodigo(NULL, "DIVI");
    checa_tipo(ExprF, ExprT, "integer");
    char type[] = "integer";
    push(ExprT, (void*)type);
} | f {
    // Joga o tipo pra cima.
    push(ExprT, pop(ExprF));
}

f: NUMERO {
    char crct[13];
    sprintf(crct, "CRCT %s", token);
    geraCodigo(NULL, crct);

    char type[] = "integer";
    push(ExprF, (void*)type);
} | IDENT {
    int i = searchST(symbolTable, token);
    if(i < 0){
        eSymbolNotFound(token);
    }
    Element elem = symbolTable->elems[i];
    char crvl[13]; // Da ateh 3 digitos de inteiros
    sprintf(crvl, "CRVL %d,%d", elem->lexLevel, elem->value->simpleVar.offset);
    geraCodigo(NULL, crvl);

    char type[] = "integer";
    push(ExprF, (void*)type);
}

cmd_simples_ou_composto: comando_composto | comando_sem_rotulo;

/* Implementa while */
comando_repetitivo: WHILE {
        char *label_in = nextLabel();
        push(labels, label_in);
        geraCodigo(label_in, "NADA");
    } ABRE_PARENTESES expressao FECHA_PARENTESES DO {
        char *label_out = nextLabel();
        push(labels, label_out);
        char aux[15]; // Precisa 10 soh acho.
        strcpy(aux, "DSVF ");
        strcat(aux, label_out);
        geraCodigo(NULL, aux);
    }
    cmd_simples_ou_composto {
        char *label_out = (char *) pop(labels);
        char *label_in = (char *) pop(labels);

        char aux[15]; // Precisa 10 soh acho.
        strcpy(aux, "DSVS ");
        strcat(aux, label_in);

        geraCodigo(NULL, aux);
        geraCodigo(label_out, "NADA");
        free(label_out);
        free(label_in);
    };

/*
Estrutura do IF THEN ELSE:
IF (expressao) THEN
    cmd_simples_ou_composto
ELSE
    cmd_simples_ou_composto

Que equivale a:

computa_expressao
dsvf r00
computa_cmd_then
dsvs r01
r00: NADA
computa_cmd_else
r01: NADA

cond_if = comando_condicional
if_then = if_then
cond_else = cmd_composto_else
*/

comando_condicional : if_then cmd_composto_else {
    // Gera o ultimo rotulo, que vai ser destino do DSVF (depois do fim do if then else).
    char *label_out = (char *) pop(labels);
    geraCodigo(label_out, "NADA");
    free(label_out);
};

if_then : IF ABRE_PARENTESES expressao FECHA_PARENTESES {
    // Gera DSVF
    char *label_out = nextLabel();
    push(labels, label_out);
    char aux[15]; // Precisa 10 soh acho.
    strcpy(aux, "DSVF ");
    strcat(aux, label_out);
    geraCodigo(NULL, aux);
} THEN cmd_simples_ou_composto;

cmd_composto_else : {
    // Insere DSVS e rotulo do else. Obs: O pop deve ser feito ANTES do push!!
    char *label_in = nextLabel();
    char aux[15];
    strcpy(aux, "DSVS ");
    strcat(aux, label_in);
    geraCodigo(NULL, aux);

    char *label_out = (char *) pop(labels);
    geraCodigo(label_out, "NADA");
    free(label_out);

    push(labels, label_in);
} ELSE cmd_simples_ou_composto
| %prec LOWER_THAN_ELSE;

/*
comando_condicional: IF ABRE_PARENTESES expressao FECHA_PARENTESES THEN {
                      char *label_out = nextLabel();
                      push(labels, label_out);
                      char aux[15]; // Precisa 10 soh acho.
                      strcpy(aux, "DSVF ");
                      strcat(aux, label_out);
                      geraCodigo(NULL, aux);
                  } cmd_composto_else;

cmd_composto_else:
                   cmd_simples_ou_composto {
                      // Insere DSVS e rotulo do else. Obs: O pop deve ser feito ANTES do push!!
                      char *label_in = nextLabel();
                      char aux[15];
                      strcpy(aux, "DSVS ");
                      strcat(aux, label_in);
                      geraCodigo(NULL, aux);

                      char *label_out = (char *) pop(labels);
                      geraCodigo(label_out, "NADA");
                      free(label_out);

                      push(labels, label_in);
                  } ELSE cmd_simples_ou_composto {
                      // Insere o rotulo do fim do if (pra pular o else caso a expressao tenha sido true)
                      char *label_out = (char *) pop(labels);
                      geraCodigo(label_out, "NADA");
                      free(label_out);
                  }
                  | %prec LOWER_THAN_ELSE
                   cmd_simples_ou_composto {
                      char *label_out = (char *) pop(labels);
                      geraCodigo(label_out, "NADA");
                      free(label_out);
                  }
*/
/*
cmd_composto_else: cmd_simples_ou_composto {
                      char *label_out = (char *) pop(labels);
                      geraCodigo(label_out, "NADA");
                      free(label_out);
                  } %prec LOWER_THAN_ELSE
                  | cmd_simples_ou_composto {
                      // Insere DSVS e rotulo do else. Obs: O pop deve ser feito ANTES do push!!
                      char *label_in = nextLabel();
                      char aux[15];
                      strcpy(aux, "DSVS ");
                      strcat(aux, label_in);
                      geraCodigo(NULL, aux);

                      char *label_out = (char *) pop(labels);
                      geraCodigo(label_out, "NADA");
                      free(label_out);

                      push(labels, label_in);
                  } ELSE cmd_simples_ou_composto {
                      // Insere o rotulo do fim do if (pra pular o else caso a expressao tenha sido true)
                      char *label_out = (char *) pop(labels);
                      geraCodigo(label_out, "NADA");
                      free(label_out);
                  }
*/
/*
comando_condicional: IF ABRE_PARENTESES expressao FECHA_PARENTESES THEN {
                      char *label_out = nextLabel();
                      push(labels, label_out);
                      char aux[15]; // Precisa 10 soh acho.
                      strcpy(aux, "DSVF ");
                      strcat(aux, label_out);
                      geraCodigo(NULL, aux);
                  } cmd_simples_ou_composto {
                      char *label_out = (char *) pop(labels);
                      geraCodigo(label_out, "NADA");
                      free(label_out);
                  } LOWER_THAN_ELSE
                  | IF ABRE_PARENTESES expressao FECHA_PARENTESES THEN {
                      char *label_out = nextLabel();
                      push(labels, label_out);
                      char aux[15]; // Precisa 10 soh acho.
                      strcpy(aux, "DSVF ");
                      strcat(aux, label_out);
                      geraCodigo(NULL, aux);
                  } cmd_simples_ou_composto {
                      // Insere DSVS e rotulo do else. Obs: O pop deve ser feito ANTES do push!!
                      char *label_in = nextLabel();
                      char aux[15];
                      strcpy(aux, "DSVS ");
                      strcat(aux, label_in);
                      geraCodigo(NULL, aux);

                      char *label_out = (char *) pop(labels);
                      geraCodigo(label_out, "NADA");
                      free(label_out);

                      push(labels, label_in);
                  } ELSE cmd_simples_ou_composto {
                      // Insere o rotulo do fim do if (pra pular o else caso a expressao tenha sido true)
                      char *label_out = (char *) pop(labels);
                      geraCodigo(label_out, "NADA");
                      free(label_out);
                  }
*/
%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc != 2) {
       printf("usage compilador <arq>a %d\n", argc);
       return(-1);
   }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }

   yyin=fp;
   yyparse();

   return 0;
}

void yyerror (char* msg){
    imprimeErro(msg);
}

void checa_tipo(Stack F, Stack T, const char* expected) {
    char *x = (char *) pop(F);
    char *y = (char *) pop(T);
    if(strcmp(x, expected) != 0 || strcmp(y, expected) != 0) {
        imprimeErro("Erro na verificacao de tipos.");
    }
}
