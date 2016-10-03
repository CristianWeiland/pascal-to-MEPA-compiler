#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils.h"
#include "compilador.h"

#define STACK_SIZE 100
#define LABEL_LENGTH 6

int label = -1;

ST initST() {
    ST st = (ST) malloc(sizeof(struct ST));
    st->head = -1;
    return st;
}

void deleteST(ST st) {
    int i = 0;
    for(i = st->head; i >= 0; --i){
        free(st->elems[i]);
    }
    free(st);
    return;
}

int pushST(ST st, Element elem) {
    ++(st->head);
    st->elems[st->head] = elem;
    return st->head;
}

int insertST(ST st, const char* symb, int lexlev, int cat, Cat value) { // Mudar pra push?
    Element elem = (Element) malloc(sizeof(struct Element));
    strncpy(elem->symbol, symb, MAX_SYMB_LEN);
    elem->symbol[MAX_SYMB_LEN] = '\0';
    elem->lexLevel = lexlev;
    elem->cat = cat;
    elem->value = value;
    ++(st->head);
    st->elems[st->head] = elem;
    return st->head;
}

int searchST(ST st, const char *symb) {
    int i;
    for(i = st->head; i >= 0; --i){ //Comparação é de traz para frente, primeiro compara o topo da pilha
        if(strcmp( (st->elems[i])->symbol, symb ) == 0)
            return i; // retorna i ou o elemento de i ?
    }
    return -1;
}

int removeLocalSymb(ST st, int lexLevel) {
    int removed = 0;
    int i = st->head;
    Element elem = st->elems[i];
    while( !(elem->lexLevel == lexLevel && (elem->cat == CAT_PROCEDURE || elem->cat == CAT_FUNCTION)) && i >= 0 ) {
        if(elem->cat == CAT_SIMPLEVAR) {
            ++removed;
        }
        free(elem);
        --i;
        if(i > -1) {
            elem = st->elems[i];
        }
    }
    // Elementos freeados e agora head movida.
    st->head = i;
    return removed;
}

void fixOffsetST(ST st) {
    //debug(st);
    // Enquanto o proximo elemento da ST nao for uma procedure/function, ignora.
    int i = st->head; // To acreditando que st->head aponta pro ultimo elemento existente.
    int offset = -4;
    Element elem = st->elems[i];
    while( elem->cat != CAT_PROCEDURE && elem->cat != CAT_FUNCTION ) {
        if(elem->cat != CAT_FORMALPARAM) {
            puts("Deveria ser formalParam.");
            --i;
            continue;
        }
        elem = st->elems[i];
        elem->value->formalParam->offset = offset;
        --offset;
        --i;
        elem = st->elems[i];
    }
/*    Element elem = st->elems[i];
    while( elem->cat != CAT_PROCEDURE && elem->cat != CAT_FUNCTION ) {
        --i;
        elem = st->elems[i];
    }
    // Se eu pegar st->elems[i] agora ele vai conter a procedure. Quero o proximo elemento.
    ++i;

    int offset = -4;

    printf("Achei i = %d e head = %d.\n", i, st->head);

    while( i <= st->head ) {
        if(elem->cat != CAT_FORMALPARAM) {
            puts("Deveria ser formalParam.");
            ++i;
            continue;
        }
        elem = st->elems[i];
        elem->value->formalParam->offset = offset;
        --offset;
        // Neste momento, elem contém o primeiro parametro (se contiver algum).

        ++i;
    }
*/
    //debug(st);
}

void debug(ST st) {
    int i;
    printf("Head: %d {\n", st->head);
    for(i = 0; i <= st->head; ++i){
        //printf("(%s, %d, %d), ", st->elems[i]->symbol, st->elems[i]->lexLevel, st->elems[i]->cat);
        printElement(st->elems[i]);
    }
    puts("}");
}

void printElement(Element e) {
    char cat[5];
    cat[0] = '\0';
    if(e->cat == CAT_SIMPLEVAR) sprintf(cat, "SVar");
    else if(e->cat == CAT_PROCEDURE) sprintf(cat, "Proc");
    else if(e->cat == CAT_FUNCTION) sprintf(cat, "Func");
    else if(e->cat == CAT_FORMALPARAM) sprintf(cat, "FPar");
    printf("    ( N: '%s', LL: %d, CAT: %s", e->symbol, e->lexLevel, cat);
    if(e->cat == CAT_SIMPLEVAR) {
        printf(", OFF: %d", e->value->simpleVar->offset);
    } else if(e->cat == CAT_PROCEDURE) {
        printf(", PAR: %d", e->value->procedure->n_params);
        // Se label tiver nulo, nao tenta imprimir, vai dar segFault.
        if(e->value->procedure->label) {
            printf(", LAB: '%s'", e->value->procedure->label);
        }
    } else if(e->cat == CAT_FORMALPARAM) {
        printf(", OFF: %d, REF: %d", e->value->formalParam->offset, e->value->formalParam->referencia);
    }

    printf(" ),\n");
}

Cat initSimpleVar(int offset) {
    Cat sv = (Cat) malloc(sizeof(union Cat));
    sv->simpleVar = malloc(sizeof(struct SimpleVar));
    sv->simpleVar->offset = offset;
    return sv;
}

Element createElement() {
    Element elem = (Element) malloc(sizeof(struct Element));
    elem->value = (Cat) malloc(sizeof(union Cat));
    return elem;
}

Cat createProcedure() {
    Cat proc = (Cat) malloc(sizeof(union Cat));
    proc->procedure = malloc(sizeof(struct Procedure));
    proc->procedure->label = (char *) malloc(sizeof(char) * MAX_SYMB_LEN);
    return proc;
}

Cat createFormalParam() {
    Cat fp = (Cat) malloc(sizeof(union Cat));
    fp->formalParam = malloc(sizeof(struct FormalParam));
    return fp;
}

char* nextLabel() {
    char* str;
    str = (char *) malloc(sizeof(char) * LABEL_LENGTH);
    sprintf(str, "r%03d", ++label);
    return str;
}

/* Stack */
struct Stack {
    int head;
    void **elems;
};

Stack initStack() {
    Stack st = (Stack) malloc(sizeof(struct Stack));
    st->elems = (void**) malloc(STACK_SIZE* sizeof(void*));
    st->head = -1;
    return st;
}

void push(Stack stack, void *elem) {
    ++(stack->head);
    if(stack->head == STACK_SIZE) {
        puts("Stack is full. Aborting...");
        exit(1);
    }
    stack->elems[stack->head] = elem;
    return ;
}

void* pop(Stack stack) {
    --(stack->head);
    return stack->elems[stack->head+1];
}

void deleteStack(Stack stack) {
    free(stack->elems);
}
/*
int main() {
    ST st = initST();
    union Cat c0, c1, c2, c3, c4;
    insertST(st, "a", 0, SIMPLEVAR, &c0);
    debug(st);
    insertST(st, "b", 0, SIMPLEVAR, &c1);
    debug(st);
    insertST(st, "c", 0, SIMPLEVAR, &c2);
    debug(st);
    insertST(st, "d", 0, SIMPLEVAR, &c3);
    debug(st);
    insertST(st, "mais de 9000 simbolos", 0, SIMPLEVAR, &c4);
    debug(st);
    return 0;
}
*/

/*Error Functions*/
void eSymbolNotFound(const char* token){
    char r[50];
    sprintf(r, "Simbolo %s não foi declarado", token);
    imprimeErro(r);
}

void eDuplicateSymbol(const char* token){
    char r[50];
    sprintf(r, "Simbolo %s já foi declarado anteriormente", token);
    imprimeErro(r);
}
