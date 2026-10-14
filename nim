#/usr/bin/env bash

NIM_TAG="nim"
NIM_HOME=$(dirname ${BASH_SOURCE[0]:-${0}})
#NIM_CELL="$(dirname ${NIM_HOME})/${NIM_TAG}.sh"
NIM_CELL="${NIM_HOME}/${NIM_TAG}.sh"


echo ${NIM_HOME}
echo ${NIM_CELL}
echo ${NIM_LIBPATH}

source ${NIM_CELL}

echo ${NIM_HOME}
echo ${NIM_CELL}
echo ${NIM_LIBPATH}

export NIM_LIBPATH="${NIM_CELL}/lib"



