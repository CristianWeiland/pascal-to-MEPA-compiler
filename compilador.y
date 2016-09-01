
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

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
// Adicionados por nois
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO OR DIV AND NOT
%token INTEGER MAIS MENOS ASTERISCO BARRA
%token IGUAL NUMERO

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

comando_sem_rotulo: atribuicao | comando_repetitivo;

atribuicao: variavel ATRIBUICAO expr {
        char armz[13]; // Da ateh 3 digitos de inteiros
        sprintf(armz, "ARMZ %d,%d", atribuido->lexLevel, atribuido->value->simpleVar.offset);
        geraCodigo(NULL, armz);
        // Verifica se os tipos sao iguais. NAO FOI FEITO AINDA.
    }

variavel: IDENT {
            int i;
            if((i = searchST(symbolTable, token)) < 0) {
                eSymbolNotFound(token);
            }
            atribuido = symbolTable->elems[i];
        }

expr: expr MAIS t {
    geraCodigo(NULL, "SOMA");
    checa_tipo(ExprT, ExprE, "integer");
} | expr OR t {
    geraCodigo(NULL, "CONJ");
    checa_tipo(ExprT, ExprE, "boolean");
} | expr MENOS t {
    geraCodigo(NULL, "SUBT");
    checa_tipo(ExprT, ExprE, "integer");
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

/* Implementa while */
comando_repetitivo: WHILE {
        char *label_in = nextLabel();
        push(labels, label_in);
        geraCodigo(label_in, "NADA");
    } expr DO {
        char *label_out = nextLabel();
        push(labels, label_out);
        geraCodigo(NULL, strcat("DSVF ", label_out));
    }
    comando_sem_rotulo {
        char *label_out = (char *) pop(labels);
        char *label_in = (char *) pop(labels);
        geraCodigo(NULL, strcat("DSVS ", label_in));
        geraCodigo(label_out, "NADA");
        free(label_out);
        free(label_in);
    };

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
