#ifndef ST_H
#define ST_H
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define MAX_SYMB_LEN 10

struct SimpleVar {
    int offset;
};

struct Procedure {
    int n_params;
    char *label;
};

struct FormalParam {
    int offset;
    int referencia; // 1 = ref, 0 = copia/valor
};

typedef struct SimpleVar* SimpleVar;
typedef struct Procedure* Procedure;
typedef struct FormalParam* FormalParam;

union Cat{
    struct SimpleVar simpleVar;
    Procedure procedure;
    struct FormalParam FormalParam;
    /*
    function;
    label;
    */
};

typedef union Cat* Cat;

struct Element { // Sujeito a mudança
    char symbol[MAX_SYMB_LEN + 1];
    int lexLevel;
    int cat;
    Cat value;
};

typedef struct Element* Element;

struct ST {
    int head;
    Element elems[100];
};

typedef struct ST* ST;
typedef struct Stack *Stack;

enum CATEGORIES { CAT_SIMPLEVAR, CAT_PROCEDURE, CAT_FORMALPARAM, CAT_FUNCTION, CAT_LABEL };

int searchST(ST st, const char *symb);
int pushST(ST st, Element elem);
int insertST(ST st, const char* symb, int lexlev, int cat, Cat value);
void deleteST(ST st);
ST initST();
Cat initSimpleVar(int offset);
Element createElement();
Procedure createProcedure();

char* nextLabel();

Stack initStack();
void push(Stack stack, void *elem);
void* pop(Stack stack);
void deleteStack(Stack stack);

/* Error functions*/
void eSymbolNotFound(const char* token);
void eDuplicateSymbol(const char* token);

#endif

