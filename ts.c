#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMB_LEN 10

struct SimpleVar {
    int offset;
};

typedef struct SimpleVar* SimpleVar;

struct Element { // Sujeito a mudança
    char[MAX_SYMB_LEN] symbol;
    int lexLevel;
    int cat;
    union Cat{
        SimpleVar simpleVar;
        /*
        procedure;
        function;
        label;
        */
    } value;

};

typedef struct Element* Element;
typedef union Cat* Cat;

struct ST {
    int head;
    Element* symbs[100]
};


typedef struct ST* ST;

ST initST() {
    ST st = (ST) malloc(sizeof(struct ST));
    st->head = -1;
    return st;
}

void deleteST(ST st) {
    int i = 0;
    for(i = st->head; i >= 0; --i){
        free(st->symbs[i]);
    }
    free(st);
    return;
}

int insertST(char* symb, int lexlev, int cat, Cat value) { // Mudar pra push?
    Element elem = (Element) malloc(sizeof(struct Element));
    strncpy(elem->symbol, symb, MAX_SYMB_LEN);
    elem->lexLevel = lexlev;
    elem->cat = cat;
    elem->value = value;
    return st;
}

int searchST(ST st, char *symb) {
    int i;
    for(i=0; i<st->head; ++i) { // Talvez a condicao tem que ser <=, porque head começa em -1.
        if(strcmp( (*(st->symbs[i]))->symbol, symb ) == 0)
            return i;
    }
    return -1;
}

int main() {

}
