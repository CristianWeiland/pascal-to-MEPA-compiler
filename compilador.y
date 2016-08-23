
// Testar se funciona corretamente o empilhamento de parâmetros
// passados por valor ou por referência.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "utils.h"

int deslocamento, lexLevel = 0;
SL symbolTable = initST();

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
// Adicionados por nois
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO OR DIV AND NOT
%token INTEGER

%%

programa    :{
             geraCodigo (NULL, "INPP");
             }
             PROGRAM IDENT
             ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA
             bloco PONTO {
             geraCodigo (NULL, "PARA");
             }
;

bloco       :
              parte_declara_vars
              {
              }

              comando_composto
              ;




parte_declara_vars:  var

var         : { deslocamento = 0; } VAR declara_vars {
                    char amem[10];
                    sprintf(amem, "AMEM %d", deslocamento);
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

tipo        : IDENT
;

lista_id_var: lista_id_var VIRGULA IDENT {
                //token ja está definido ?
                Cat cat = initSimpleVar(deslocamento);
                insertST(symbolTable, token, lexLevel, SIMPLEVAR, cat);
                ++deslocamento;
            }
            | IDENT {
                //token ja está definido ?
                Cat cat = initSimpleVar(deslocamento);
                insertST(symbolTable, token, lexLevel, SIMPLEVAR, cat);
                ++deslocamento;
            }
;

lista_idents: lista_idents VIRGULA IDENT
            | IDENT
;


comando_composto: T_BEGIN comandos T_END

comandos:
;


%%
/*
main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compilador <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compilador <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de Símbolos
 * ------------------------------------------------------------------- */
/*
   yyin=fp;
   yyparse();

   return 0;
}

*/
