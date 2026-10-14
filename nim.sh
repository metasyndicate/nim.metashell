#!/usr/bin/env bash

NIM_TAG="metashell"
export NIM_HOME="$(dirname ${BASH_SOURCE[0]:-${0}}})"
export NIM_CELL="$(dirname ${NIM_HOME})/nim.${NIM_TAG}"

export NIM_LIBPATH="${NIM_CELL}/lib"

[[ -e "${NIM_CELL}" ]] || { 
   printf "NIM.%s: invalid installation (%s)\n\n" "${NIM_TAG^^}" "${NIM_CELL}" ; exit 1; }

 # [10.11.26]@bradley: TODO >> need to establish known fs structure/naming/conventions, standardize/centralize all path resolution, implement static/known location(s). this project has long suffered from environment inferrence and variable/config sprawl, and divergence/fragmentation in path/file structural and naming comventions. objective: codify schema and core principles in developer and agent documents to establish, persist, and converge all path resolution and initialization to centralize, simplify, and persist a singular procedural flow.

#printf "loading %s ... " "${NIM_CELL}/lib/core/core.sh"

source ${NIM_CELL}/lib/core/core.sh ### printf "OK\n\n" || printf "FAIL\n\n"

echo ${NIM_LIBPATH}

