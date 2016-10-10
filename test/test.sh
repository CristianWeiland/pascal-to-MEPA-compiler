#! /bin/bash

basePath=$(echo $BASH_SOURCE | rev | cut -c 8- | rev)
cd $basePath

files=$(ls pas | cut -d. -f1)
out=""
r=0

for file in $files; do
    ../compilador pas/$file.pas &> test.out
    [[ $(cat test.out) == "" ]] && outputFile="MEPA" || outputFile="test.out"
    if [[ $(diff $outputFile mepa/$file.mepa) != "" ]]; then
        echo "Erro: Arquivo $file.pas falhou em teste"
        head -n1 pas/$file.pas
        if [[ $1 = '--diff' ]]; then
            echo ""
            diff $outputFile mepa/$file.mepa
            echo ""
        fi
        r=$(($r + 1))
    fi
done

rm test.out
rm MEPA


if [[ $r -ne 0 ]]; then
    echo ""
    echo "Falhou em $r testes"
fi
exit $r
