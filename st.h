#ifndef ST_H
#define ST_H
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

typedef struct SimpleVar* SimpleVar;
typedef union Cat* Cat;
typedef struct ST* ST;
typedef struct Element* Element;

enum CATEGORIES { SIMPLEVAR };

int searchST(ST st, const char *symb);
int insertST(ST st, const char* symb, int lexlev, int cat, Cat value);
void deleteST(ST st);
ST initST();
#endif

