#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "st.h"

#define STACK_SIZE 100
#define MAX_SYMB_LEN 10
#define LABEL_LENGTH 6

int label = -1;

struct SimpleVar {
    int offset;
};

union Cat{
    SimpleVar simpleVar;
    /*
    procedure;
    function;
    label;
    */
};

struct Element { // Sujeito a mudança
    char symbol[MAX_SYMB_LEN + 1];
    int lexLevel;
    int cat;
    Cat value;
};

struct ST {
    int head;
    Element elems[100];
};

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

void debug(ST st) {
    int i;
    printf("Head: %d { ", st->head);
    for(i = 0; i <= st->head; ++i){
        printf("(%s, %d, %d), ", st->elems[i]->symbol, st->elems[i]->lexLevel, st->elems[i]->cat);
    }
    puts("}");
}

Cat initSimpleVar(int offset) {
    Cat st = (Cat) malloc(sizeof(union Cat));
    st->simpleVar->offset = offset;
    return st;
}

char* nextLabel() {
    char* str;
    str = (char *) malloc(sizeof(char) * LABEL_LENGTH);
    sprintf(str, "r%04d", ++label);
    return str;
}

/* Stack */
struct Stack {
    int head;
    void **elems;
};

Stack initStack() {
    Stack st = (ST) malloc(sizeof(struct Stack));
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
