#!/bin/bash

tskill java* 2> /dev/null

cd ~

[[ -d ".m2" ]] && rm -r ".m2" && echo ".m2 apagado"
[[ -d ".tasy" ]] && rm -r ".tasy/" && echo ".tasy apagado"
[[ -d ".gradle/caches/" ]] && mv ".gradle/caches" ".gradle/bla" && rm -r ".gradle/bla" && echo "cache do gradle removido"



