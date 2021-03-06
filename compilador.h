/* -------------------------------------------------------------------
 *            Arquivo: compilador.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [15/03/2012, 08h:22m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, prot�tipos e vai�veis globais do compilador
 *
 * ------------------------------------------------------------------- */

#include "utils.h"

#define TAM_TOKEN 16

typedef enum simbolos { 
  simb_program, simb_var, simb_begin, simb_end, 
  simb_identificador, simb_numero,
  simb_ponto, simb_virgula, simb_ponto_e_virgula, simb_dois_pontos,
  simb_atribuicao, simb_abre_parenteses, simb_fecha_parenteses,
// A partir daqui s�o os nossos
  simb_label, simb_type, simb_array, simb_of, simb_procedure,
  simb_function, simb_goto, simb_if, simb_then, simb_else,
  simb_while, simb_do, simb_or, simb_div, simb_and, simb_not,
  simb_integer, simb_mais, simb_menos, simb_asterisco, simb_barra,
  simb_igual, simb_maior, simb_menor, simb_maior_igual,
  simb_menor_igual, simb_desigual, simb_write, simb_read

} simbolos;

void yyerror (char* msg);
void checa_tipo(Stack F, Stack T, const char* expected);
void cria_arg(ST st, char *token, int lexLevel, int ref);

/* -------------------------------------------------------------------
 * vari�veis globais
 * ------------------------------------------------------------------- */

extern simbolos simbolo, relacao;
extern char token[TAM_TOKEN];
extern int nivel_lexico;
extern int desloc;
extern int nl;

simbolos simbolo, relacao;
char token[TAM_TOKEN];
