#ifndef ST_H
#define ST_H
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define MAX_SYMB_LEN 10

struct SimpleVar {
    int offset;
};

typedef struct SimpleVar* SimpleVar;

union Cat{
    struct SimpleVar simpleVar;
    /*
    procedure;
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

enum CATEGORIES { SIMPLEVAR };

int searchST(ST st, const char *symb);
int insertST(ST st, const char* symb, int lexlev, int cat, Cat value);
void deleteST(ST st);
ST initST();
Cat initSimpleVar(int offset);

char* nextLabel();

Stack initStack();
void push(Stack stack, void *elem);
void* pop(Stack stack);
void deleteStack(Stack stack);

/* Error functions*/
void eSymbolNotFound(const char* token);
void eDuplicateSymbol(const char* token);

#endif

