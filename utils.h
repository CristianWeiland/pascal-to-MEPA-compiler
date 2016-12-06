#ifndef ST_H
#define ST_H
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define MAX_SYMB_LEN 10
#define MAX_PARAMS_LEN 10

struct SimpleVar {
    int offset;
};


struct FormalParam {
    int offset;
    int referencia; // 1 = ref, 0 = copia/valor
};

struct Label {
    char *label;
};

struct FPReference {
    int referencia;
    const char* type;
};

struct Procedure {
    int n_params, n_local_vars;
    char *label;
    struct FPReference params[MAX_PARAMS_LEN];
};

struct Function {
    int n_params, n_local_vars;
    char *label;
    struct FPReference params[MAX_PARAMS_LEN];
    int offset;
};

typedef struct Function* Function;
typedef struct SimpleVar* SimpleVar;
typedef struct Procedure* Procedure;
typedef struct FormalParam* FormalParam;
typedef struct Label* Label;
typedef struct ExprRef* ExprRef;

union Cat{
    SimpleVar simpleVar;
    Procedure procedure;
    FormalParam formalParam;
    Function function;
    Label label;
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

struct ExprRef {
    int fp_referencia; // 1 = ref, 0 = copia/valor
    int fp_index;
    int expr_referencia;
    int n_params_reais;
    Element function;
};

struct ST {
    int head;
    Element elems[100];
};

typedef struct ST* ST;
typedef struct Stack *Stack;

enum CATEGORIES { CAT_SIMPLEVAR, CAT_PROCEDURE, CAT_FORMALPARAM, CAT_FUNCTION, CAT_LABEL };

int searchST(ST st, const char *symb);
int getLastSubroutineST(ST st);
int getSubroutineLexLevel(ST st, int lexLevel);
int pushST(ST st, Element elem);
int insertST(ST st, const char* symb, int lexlev, int cat, Cat value);
int removeLocalSymb(ST st, int lexLevel);
int fixOffsetST(ST st);
int gotoCleanSymbolTable(ST st, int destll, int curll);
void deleteST(ST st);
ST initST();
void debug(ST st);
void printElement(Element e);

Element createElement();
Cat initSimpleVar(int offset);
Cat createProcedure();
Cat createFunction();
Cat createFormalParam();
Cat createLabel();
struct FPReference createFPReference(const char* type, int reference);


ExprRef createExprRef(int r, int index, Element f);
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

