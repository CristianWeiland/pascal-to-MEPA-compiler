#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAGIC_LENGTH 6

int rotulo = -1;

char* proximo_rotulo() {
    char* str;
    str = (char *) malloc(sizeof(char) * MAGIC_LENGTH);
    sprintf(str, "r%04d", ++rotulo);
    return str;
}

int main() {
    char *str;
    int i;
    for(i=0; i<10; ++i) {
        puts(proximo_rotulo());
    }
}
