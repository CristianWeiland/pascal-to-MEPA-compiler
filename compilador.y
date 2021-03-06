
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compilador.h"
#include "utils.h"

int offset, lexLevel, n_params_reais = 0, is_function, main_local_vars;
// Obs: Nao da pra inicializar coisas aqui!
ST symbolTable;
Stack labels;
Stack ExprE, ExprT, ExprF;
Stack ExprR;
Element atribuido;
char Operacao[5];

const char* type_integer = "int";
const char* type_boolean = "bool";
const char* type_undefined = "";

/* Coisas de procedures */
Element procedure, function;
Procedure proc;
Function func;
Stack procSt;

Cat category;

%}

%token PROGRAM ABRE_PARENTESES FECHA_PARENTESES
%token VIRGULA PONTO_E_VIRGULA DOIS_PONTOS PONTO
%token T_BEGIN T_END VAR IDENT ATRIBUICAO
// Adicionados por nois
%token LABEL TYPE ARRAY OF PROCEDURE FUNCTION
%token GOTO IF THEN ELSE WHILE DO OR DIV AND NOT
%token INTEGER MAIS MENOS ASTERISCO BARRA
%token IGUAL NUMERO MAIOR MENOR DESIGUAL
%token MAIOR_IGUAL MENOR_IGUAL WRITE READ

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

programa: {
    symbolTable = initST();
    labels = initStack();
    ExprE = initStack();
    ExprT = initStack();
    ExprF = initStack();
    procSt = initStack();
    ExprR = initStack();
    atribuido = NULL;
    geraCodigo (NULL, "INPP");
} PROGRAM IDENT ABRE_PARENTESES lista_idents FECHA_PARENTESES PONTO_E_VIRGULA bloco PONTO {
    geraCodigo (NULL, "PARA");
    deleteST(symbolTable);
    deleteStack(labels);
    deleteStack(ExprE);
    deleteStack(ExprT);
    deleteStack(ExprF);
    deleteStack(procSt);
    deleteStack(ExprR);
};

bloco: parte_declaracao parte_declara_subrotina comando_composto {
    int i = removeLocalSymb(symbolTable, lexLevel);
    if(i > 0) {
        char dmem[10];
        sprintf(dmem, "DMEM %d", i);
        geraCodigo(NULL, dmem);
    }
};

parte_declaracao: {
    offset = 0;
} parte_declara {
    char amem[10];
    sprintf(amem, "AMEM %d", offset);
    if(offset > 0) // Jogando sujeira embaixo do tapete. Porque ele chega aqui com 0?
        geraCodigo(NULL, amem);
    if(lexLevel == 0) {
        // Estamos no main. Guarda em main_local_vars o numero de variaveis locais.
        // Isso vai ser util SOMENTE pra gerar ENRT.
        main_local_vars = offset;
    } else {
        // Estamos em alguma funcao. Pega ela e seta o numero de variaveis locais.
        Element e = (Element) pop(procSt);
        if(e->cat == CAT_FUNCTION) {
            e->value->function->n_local_vars = offset;
        } else if(e->cat == CAT_PROCEDURE) {
            e->value->procedure->n_local_vars = offset;
        }
        // Restaura a pilha.
        push(procSt, e);
    }
};

parte_declara: parte_declara_label parte_declara_vars;

parte_declara_vars: VAR declara_vars | ;

declara_vars: declara_vars declara_var | declara_var;

declara_var: lista_id_var DOIS_PONTOS tipo PONTO_E_VIRGULA;

tipo: INTEGER;

lista_id_var: lista_id_var VIRGULA IDENT {
    Cat cat = initSimpleVar(offset);
    insertST(symbolTable, token, lexLevel, CAT_SIMPLEVAR, cat);
    ++offset;
} | IDENT {
    Cat cat = initSimpleVar(offset);
    insertST(symbolTable, token, lexLevel, CAT_SIMPLEVAR, cat);
    ++offset;
};

lista_idents: lista_idents VIRGULA IDENT | IDENT;

parte_declara_label: LABEL declara_labels PONTO_E_VIRGULA | ;

// Perigo: Variavel cat->label existe, mas eh uma Struct Label. O char* eh cat->label->label!!!
declara_labels: declara_labels VIRGULA NUMERO {
    Cat cat = createLabel();
    cat->label->label = nextLabel();
    insertST(symbolTable, token, lexLevel, CAT_LABEL, cat);
} | NUMERO {
    Cat cat = createLabel();
    cat->label->label = nextLabel();
    insertST(symbolTable, token, lexLevel, CAT_LABEL, cat);
};

parte_declara_subrotina: parte_declara_subrotina parte_declara_procedimento | parte_declara_subrotina parte_declara_funcao | ;

parte_declara_procedimento: PROCEDURE IDENT {
    // ENPR lex_level do procedimento.
    char dsvs[10];
    // Gera rotulo de saida.
    char *label_in = nextLabel();
    sprintf(dsvs, "DSVS %s", label_in);
    push(labels, label_in); // Guarda pra poder declarar o rotulo depois (r000: NADA).
    geraCodigo(NULL, dsvs);

    char enpr[8];
    char *label_proc = nextLabel();
    ++lexLevel;
    sprintf(enpr, "ENPR %d", lexLevel);
    // r01: ENPR 1 --> Isso ja gera o rotulo pra entrar no procedimento!
    geraCodigo(label_proc, enpr);

    procedure = createElement();
    procedure->cat = CAT_PROCEDURE;
    procedure->lexLevel = lexLevel;
    category = createProcedure();
    proc = category->procedure;
    proc->n_params = 0;
    procedure->value->procedure = proc;

    // Insere o label de entrada do proc na Tabela de Simbolos.
    strncpy(proc->label, label_proc, MAX_SYMB_LEN);
    // Insere o procedimento na tabela de simbolos.
    pushST(symbolTable, procedure);
    push(procSt, procedure);
    // Adiciona o nome do proc na Tabela de Simbolos.
    strncpy(procedure->symbol, token, MAX_SYMB_LEN);

    is_function = 0;
} parte_params_formais PONTO_E_VIRGULA bloco PONTO_E_VIRGULA {
    char rtpr[12];
    procedure = (Element) pop(procSt);
    sprintf(rtpr, "RTPR %d,%d", procedure->lexLevel, procedure->value->procedure->n_params);
    geraCodigo(NULL, rtpr);
    --lexLevel;
    // Cria rotulo de saida.
    geraCodigo(pop(labels), "NADA");
};

parte_declara_funcao: FUNCTION IDENT {
    // ENPR lex_level da funcao.
    char dsvs[10];
    // Gera rotulo de saida.
    char *label_in = nextLabel();
    sprintf(dsvs, "DSVS %s", label_in);
    push(labels, label_in); // Guarda pra poder declarar o rotulo depois (r000: NADA).
    geraCodigo(NULL, dsvs);

    char enpr[8];
    char *label_func = nextLabel();
    ++lexLevel;
    sprintf(enpr, "ENPR %d", lexLevel);
    // r01: ENPR 1 --> Isso ja gera o rotulo pra entrar no procedimento!
    geraCodigo(label_func, enpr);

    function = createElement();
    function->cat = CAT_FUNCTION;
    function->lexLevel = lexLevel;
    category = createFunction();
    func = category->function;
    func->n_params = 0;
    function->value->function = func;

    // Insere o label de entrada do proc na Tabela de Simbolos.
    strncpy(func->label, label_func, MAX_SYMB_LEN);
    // Insere o procedimento na tabela de simbolos.
    pushST(symbolTable, function);
    push(procSt, function);
    // Adiciona o nome do proc na Tabela de Simbolos.
    strncpy(function->symbol, token, MAX_SYMB_LEN);

    is_function = 1;
} parte_params_formais {
    function->value->function->offset = offset;
} DOIS_PONTOS tipo PONTO_E_VIRGULA bloco PONTO_E_VIRGULA {
    char rtpr[12];
    function = (Element) pop(procSt);
    sprintf(rtpr, "RTPR %d,%d", function->lexLevel, function->value->function->n_params);
    geraCodigo(NULL, rtpr);
    --lexLevel;
    // Cria rotulo de saida.
    geraCodigo(pop(labels), "NADA");
};

parte_params_formais: ABRE_PARENTESES params_formais FECHA_PARENTESES {
    offset = fixOffsetST(symbolTable);
} | ;

params_formais: params_formais PONTO_E_VIRGULA param | param;

param: lista_args_copia DOIS_PONTOS tipo {
    // Atualiza o tipo na TS.
} | VAR lista_args_ref DOIS_PONTOS {
    // Atualiza o tipo na TS.
} tipo;

lista_args_copia: lista_args_copia VIRGULA IDENT {
    // Obs: Lista_args ainda nao aceita passagem por referencia, s� por c�pia.
    // Achei algo tipo "a, b: integer", aqui eu to tratando o 'b', por exemplo.
    // Token == 'b'.
    if(is_function) {
        func->params[func->n_params] = createFPReference(type_undefined, 0);
        func->n_params++;
    }
    else {
        proc->params[proc->n_params] = createFPReference(type_undefined, 0);
        proc->n_params++;
    }
    cria_arg(symbolTable, token, lexLevel, 0);
} | IDENT {
    if(is_function) {
        func->params[func->n_params] = createFPReference(type_undefined, 0);
        func->n_params++;
    }
    else {
        proc->params[proc->n_params] = createFPReference(type_undefined, 0);
        proc->n_params++;
    }
    cria_arg(symbolTable, token, lexLevel, 0);
};

lista_args_ref: lista_args_ref VIRGULA IDENT {
    if(is_function) {
        func->params[func->n_params] = createFPReference(type_undefined, 1);
        func->n_params++;
    }
    else {
        proc->params[proc->n_params] = createFPReference(type_undefined, 1);
        proc->n_params++;
    }
    cria_arg(symbolTable, token, lexLevel, 1);
} | IDENT {
    if(is_function) {
        func->params[func->n_params] = createFPReference(type_undefined, 1);
        func->n_params++;
    }
    else {
        proc->params[proc->n_params] = createFPReference(type_undefined, 1);
        proc->n_params++;
    }
    cria_arg(symbolTable, token, lexLevel, 1);
};

comando_composto: T_BEGIN comandos T_END;

comandos: comandos PONTO_E_VIRGULA comando | comando;

comando: rotulo comando_sem_rotulo;

/* Ou 'numero DOIS_PONTOS' ou nada. Suponho que, se nao tem nada, eu deixo em branco soh. */
rotulo: NUMERO {
    /* Aqui entrou um label. Insere ENRT lex_level_atual, n_var_locais. Acredito que tambem tenho que inserir o r003:. */
    char enrt[20];
    /* Pega dados do Rotulo. */
    int i;
    if((i = searchST(symbolTable, token)) < 0) {
        printf("(rotulo - %s)\n", token);
        eSymbolNotFound(token);
    }
    Element lab = symbolTable->elems[i];
    if(lab->cat != CAT_LABEL) {
        printf("Varaivel que nao eh rotulo sendo usada como rotulo.\n");
        exit(-1);
    }
    if(lab->lexLevel != lexLevel) {
        printf("Tentou inserir label em nivel lexico diferente do que ela foi declarada.\n");
        exit(-2);
    }

    int n_local_var = 0;
    int j = getSubroutineLexLevel(symbolTable, lab->lexLevel);
    if(j == -1) {
        // We jumped into main.
        n_local_var = main_local_vars;
    } else {
        Element subroutine = symbolTable->elems[j];
        if(subroutine->cat == CAT_FUNCTION) {
            n_local_var = subroutine->value->function->n_local_vars;
        } else if(subroutine->cat == CAT_PROCEDURE) {
            n_local_var = subroutine->value->procedure->n_local_vars;
        }
    }

    sprintf(enrt, "ENRT %d,%d", lexLevel, n_local_var);
    // Gera r003: ENRT 1,1
    geraCodigo(lab->value->label->label, enrt);
} DOIS_PONTOS | ;

comando_sem_rotulo: atrib_ou_csr | comando_repetitivo | comando_condicional | impressao | leitura | desvio_incondicional;

impressao: WRITE ABRE_PARENTESES lista_impressao FECHA_PARENTESES;

lista_impressao: lista_impressao VIRGULA imprime | imprime;

imprime: IDENT {
    int i;
    if((i = searchST(symbolTable, token)) < 0) {
        eSymbolNotFound(token);
    }
    Element elem = symbolTable->elems[i];
    char cr[15];
    if(elem->cat == CAT_SIMPLEVAR)
        sprintf(cr, "CRVL %d,%d", elem->lexLevel, elem->value->simpleVar->offset);
    else if(elem->cat == CAT_FORMALPARAM && elem->value->formalParam->referencia == 0) // Passado por valor
        sprintf(cr, "CRVL %d,%d", elem->lexLevel, elem->value->formalParam->offset);
    else if(elem->cat == CAT_FORMALPARAM && elem->value->formalParam->referencia == 1) // Passado por referencia
        sprintf(cr, "CRVI %d,%d", elem->lexLevel, elem->value->formalParam->offset);
    else
        puts("Tentando imprimir algo que nao eh FormalParam nem SimpleVar...");
    // Gera CRVL
    geraCodigo(NULL, cr);
    geraCodigo(NULL, "IMPR");
};

leitura: READ ABRE_PARENTESES lista_leitura FECHA_PARENTESES;

lista_leitura: lista_leitura VIRGULA le | le;

le: IDENT {
    int i;
    if((i = searchST(symbolTable, token)) < 0) {
        eSymbolNotFound(token);
    }
    Element elem = symbolTable->elems[i];
    geraCodigo(NULL, "LEIT");
    char ar[15];
    if(elem->cat == CAT_SIMPLEVAR)
        sprintf(ar, "ARMZ %d,%d", elem->lexLevel, elem->value->simpleVar->offset);
    else if(elem->cat == CAT_FORMALPARAM && elem->value->formalParam->referencia == 0) // Passado por valor
        sprintf(ar, "ARMZ %d,%d", elem->lexLevel, elem->value->formalParam->offset);
    else if(elem->cat == CAT_FORMALPARAM && elem->value->formalParam->referencia == 1) // Passado por referencia
        sprintf(ar, "ARMI %d,%d", elem->lexLevel, elem->value->formalParam->offset);
    else
        puts("Tentando ler algo que nao eh FormalParam nem SimpleVar...");
    // Gera CRVL
    geraCodigo(NULL, ar);
};

desvio_incondicional: GOTO NUMERO {
    int i;
    if((i = searchST(symbolTable, token)) < 0) {
        eSymbolNotFound(token);
    }
    Element elem = symbolTable->elems[i];
    char dsvr[20];
    if(elem->cat != CAT_LABEL) {
        puts("Tentando dar goto para algo que nao eh uma label.");
    } else {
        //                             Rotulo Dest                LexLevel Dest,  LexLevel Atual
        sprintf(dsvr, "DSVR %s,%d,%d", elem->value->label->label, elem->lexLevel, lexLevel);
        if(elem->lexLevel != lexLevel) {
            // To pulando pra fora da funcao (mudando de lexlevel). Preciso limpar a SymbolTable.
            gotoCleanSymbolTable(symbolTable, elem->lexLevel, lexLevel);
        }
    }
    geraCodigo(NULL, dsvr);
};

atrib_ou_csr: IDENT {
    int i;
    if((i = searchST(symbolTable, token)) < 0) {
        eSymbolNotFound(token);
    }
    atribuido = symbolTable->elems[i];
    ExprRef e = createExprRef(0, i, atribuido);
    push(ExprR, e);
} atrib_ou_csr2 {
    pop(ExprR);
};

atrib_ou_csr2: atribuicao | chamada_subrotina;

atribuicao: ATRIBUICAO expressao {
    pop(ExprE);
    char armz[13]; // Da ateh 3 digitos de inteiros
    if(atribuido->cat == CAT_SIMPLEVAR)
        sprintf(armz, "ARMZ %d,%d", atribuido->lexLevel, atribuido->value->simpleVar->offset);
    else if(atribuido->cat == CAT_FORMALPARAM && atribuido->value->formalParam->referencia == 0) // Passado por valor
        sprintf(armz, "ARMZ %d,%d", atribuido->lexLevel, atribuido->value->formalParam->offset);
    else if(atribuido->cat == CAT_FORMALPARAM && atribuido->value->formalParam->referencia == 1) // Passado por referencia
        sprintf(armz, "ARMI %d,%d", atribuido->lexLevel, atribuido->value->formalParam->offset);
    else if(atribuido->cat == CAT_FUNCTION)
        sprintf(armz, "ARMZ %d,%d", atribuido->lexLevel, atribuido->value->function->offset);
    else
        puts("Tentando atribuir pra algo que nao eh FormalParam nem SimpleVar...");
    geraCodigo(NULL, armz);
};

chamada_subrotina: {
    ExprRef e = pop(ExprR);
    Element procedure = (Element) e->function;
    if(procedure->cat != CAT_PROCEDURE && procedure->cat != CAT_FUNCTION) {
        yyerror("Chamada de subrotina para um identificador que nao eh funcao nem procedimento.");
        exit(1);
    }
    if(procedure->cat == CAT_FUNCTION) {
        geraCodigo(NULL, "AMEM 1");
    }
    push(ExprR, e);
} params_reais {
    // Checa se o numero de parametros confere.
    ExprRef e = pop(ExprR);
    Element procedure = (Element) e->function;
    int n_params = -1;
    char *label;
    if(procedure->cat == CAT_PROCEDURE) {
        n_params = procedure->value->procedure->n_params;
        label = procedure->value->procedure->label;
    } else { // Function
        n_params = procedure->value->function->n_params;
        label = procedure->value->function->label;
    }
    if(e->n_params_reais != n_params) {
        char err[100];
        sprintf(err, "Chamada de subrotina com numero errado de parametros: %d usados, %d esperados.", n_params_reais, n_params);
        yyerror(err);
    }

    // Parametros corretos e empilhados, chama funcao.
    char chpr[13];
    sprintf(chpr, "CHPR %s,%d", label, lexLevel);
    geraCodigo(NULL, chpr);
    push(ExprR, e);
};

params_reais: ABRE_PARENTESES lista_params_reais FECHA_PARENTESES | ;

lista_params_reais: lista_params_reais VIRGULA param_real | param_real;

param_real: {

    ExprRef e = (ExprRef) pop(ExprR);
    ++(e->fp_index);
    ++(e->n_params_reais);
    ++n_params_reais;
    struct FPReference *fp;
    if(e->function->cat == CAT_PROCEDURE) {
        fp = &(e->function->value->procedure->params[e->fp_index]);
    }
    else {
        fp = &(e->function->value->function->params[e->fp_index]);
    }
    e->fp_referencia = fp->referencia;
    push(ExprR, e);

} expressao {
    pop(ExprE);
    ExprRef e = (ExprRef) pop(ExprR);
    //se fp_referencia = false qualquer valor serve (n�o da erro)
    //ser for 1 ent�o expr_referencia tamb�m tem que ser
    if((e->expr_referencia != e->fp_referencia) && e->fp_referencia) {
        imprimeErro("Erro na verificacao de tipos. Passagem por referencia precisa ter variavel como parametro");
    }
    push(ExprR, e);
};

expressao: expr relacao expr {
    checa_tipo(ExprE, ExprE, type_integer);
    geraCodigo(NULL, Operacao);
    push(ExprE, (void*)type_boolean);
    exprSetReference(ExprR, 0);
} | expr { // Isso aceita caso exista uma var a = boolean e tenha algo tipo "if(a)".
};

expressao_booleana: expressao {
    // Tambem aceita if(a and b). O pop deve estar certo.
    if(strcmp(type_boolean, (char *) pop(ExprE)) != 0) {
        imprimeErro("Erro na verificacao de tipos.");
    }
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
    checa_tipo(ExprT, ExprE, type_integer);

    push(ExprE, (void*)type_integer);
    exprSetReference(ExprR, 0);
} | expr OR t {
    geraCodigo(NULL, "DISJ");
    checa_tipo(ExprT, ExprE, type_boolean);

    push(ExprE, (void*)type_boolean);
    exprSetReference(ExprR, 0);
} | expr MENOS t {
    geraCodigo(NULL, "SUBT");
    checa_tipo(ExprT, ExprE, type_integer);

    push(ExprE, (void*)type_integer);
    exprSetReference(ExprR, 0);
} | t {
    push(ExprE, pop(ExprT));
};

t: t ASTERISCO f {
    geraCodigo(NULL, "MULT");
    checa_tipo(ExprF, ExprT, type_integer);
    push(ExprT, (void*)type_integer);
    exprSetReference(ExprR, 0);
} | t AND f {
    geraCodigo(NULL, "CONJ");
    checa_tipo(ExprF, ExprT, type_boolean);
    push(ExprT, (void*)type_boolean);
    exprSetReference(ExprR, 0);
} | t BARRA f {
    geraCodigo(NULL, "DIVI");
    checa_tipo(ExprF, ExprT, type_integer);
    push(ExprT, (void*)type_integer);
    exprSetReference(ExprR, 0);
} | f {
    // Joga o tipo pra cima.
    push(ExprT, pop(ExprF));
};

f: NUMERO {
    char crct[13];
    sprintf(crct, "CRCT %s", token);
    geraCodigo(NULL, crct);

    push(ExprF, (void*)type_integer);
    exprSetReference(ExprR, 0);
} | IDENT {
    int i = searchST(symbolTable, token);
    if(i < 0){
        eSymbolNotFound(token);
    }

    ExprRef e = createExprRef(0, i, symbolTable->elems[i]);
    push(ExprR, e);

    if(e->function->cat == CAT_FUNCTION) {
        geraCodigo(NULL, "AMEM 1");
    }

} params_reais {

    char cr[13], mod[5];
    ExprRef e = pop(ExprR);
    Element elem = e->function; // � o elemento inserido na pilha (pode ser uma variavel)

    if(elem->cat == CAT_FUNCTION) {
        char *label;
        int n_params = elem->value->function->n_params;
        label = elem->value->function->label;
        if(e->n_params_reais != n_params) {
            char err[100];
            sprintf(err, "Chamada de subrotina com numero errado de parametros: %d usados, %d esperados.", e->n_params_reais, n_params);
            yyerror(err);
        }

        char chpr[13];
        sprintf(chpr, "CHPR %s,%d", label, lexLevel);
        geraCodigo(NULL, chpr);

        push(ExprF, (void*)type_integer);
    }

    else if (elem->cat == CAT_PROCEDURE) {
        imprimeErro("Procedimentos n�o retornam valor, e n�o podem ser utilizados em express�es");
    }

    else {
        if(e->n_params_reais > 0){
            imprimeErro("Utilizou parametros para algo que n�o � uma fun��o");
        }
        e = pop(ExprR);
        if(e != NULL && e->fp_referencia) { // Passagem por referencia.
            if(elem->cat == CAT_FORMALPARAM && elem->value->formalParam->referencia) {
                sprintf(mod, "CRVL");
            } else {
                sprintf(mod, "CREN");
            }
        } else { // Passagem por valor.
            if(elem->cat == CAT_FORMALPARAM && elem->value->formalParam->referencia) {
                sprintf(mod, "CRVI");
            } else {
                sprintf(mod, "CRVL");
            }
        }

        sprintf(cr, "%s %d,%d", mod, elem->lexLevel, elem->value->simpleVar->offset);
        geraCodigo(NULL, cr);

        if(e != NULL) {
            push(ExprR, e);
        }
        push(ExprF, (void*)type_integer);
        exprSetReference(ExprR, 1);
    }


} | ABRE_PARENTESES expressao FECHA_PARENTESES {
    push(ExprF, pop(ExprE));
};

cmd_simples_ou_composto: comando_composto | comando_sem_rotulo;

/* Implementa while */
comando_repetitivo: WHILE {
    char *label_in = nextLabel();
    push(labels, label_in);
    geraCodigo(label_in, "NADA");
} ABRE_PARENTESES expressao_booleana FECHA_PARENTESES DO {
    char *label_out = nextLabel();
    push(labels, label_out);
    char aux[15]; // Precisa 10 soh acho.
    strcpy(aux, "DSVF ");
    strcat(aux, label_out);
    geraCodigo(NULL, aux);
} cmd_simples_ou_composto {
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

comando_condicional: if_then cmd_composto_else {
    // Gera o ultimo rotulo, que vai ser destino do DSVF (depois do fim do if then else).
    char *label_out = (char *) pop(labels);
    geraCodigo(label_out, "NADA");
    free(label_out);
};

if_then: IF ABRE_PARENTESES expressao_booleana FECHA_PARENTESES {
    // Gera DSVF
    char *label_out = nextLabel();
    push(labels, label_out);
    char aux[15]; // Precisa 10 soh acho.
    strcpy(aux, "DSVF ");
    strcat(aux, label_out);
    geraCodigo(NULL, aux);
} THEN cmd_simples_ou_composto;

cmd_composto_else: {
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
} ELSE cmd_simples_ou_composto | %prec LOWER_THAN_ELSE;

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

void cria_arg(ST st, char *token, int lexLevel, int ref) {
    Cat cat = createFormalParam();
    FormalParam fp = cat->formalParam;
    fp->offset = 1000000; // Aqui ainda nao sei offset. Tenho que arrumar na TS depois.
                         // To setando em 1000000 porque se eu ver isso impresso, sei que deu ruim.
    fp->referencia = ref; // Por enquanto referencia eh sempre 0, portanto, eh sempre valor.
    insertST(st, token, lexLevel, CAT_FORMALPARAM, cat);
}
