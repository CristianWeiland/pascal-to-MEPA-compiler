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

struct Function {
    int n_params;
    char *label;
    int offset;
};

struct FormalParam {
    int offset;
    int referencia; // 1 = ref, 0 = copia/valor
};

struct ExprRef {
    int fp_referencia; // 1 = ref, 0 = copia/valor
    int fp_index;
    int expr_referencia;
};

typedef struct Function* Function;
typedef struct SimpleVar* SimpleVar;
typedef struct Procedure* Procedure;
typedef struct FormalParam* FormalParam;
typedef struct ExprRef* ExprRef;

union Cat{
    SimpleVar simpleVar;
    Procedure procedure;
    FormalParam formalParam;
    Function function;
    /*
    label;
    */
};
// Funciona passar como parametro a > b?
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
int removeLocalSymb(ST st, int lexLevel);
int fixOffsetST(ST st); // Talvez precisa receber o lex level?
void deleteST(ST st);
ST initST();
void debug(ST st);
void printElement(Element e);

Element createElement();
Cat initSimpleVar(int offset);
Cat createProcedure();
Cat createFunction();
Cat createFormalParam();


ExprRef createExprRef(int r, int index);
void exprSetReference(Stack s, const int value);

char* nextLabel();

Stack initStack();
void push(Stack stack, void *elem);
void* pop(Stack stack);
void deleteStack(Stack stack);

/* Error functions*/
void eSymbolNotFound(const char* token);
void eDuplicateSymbol(const char* token);

#endif

