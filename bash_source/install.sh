#!/bin/bash

function source_alias {
	emit "alias ${1}=\"source '${VAR_HERE}/${1}.sh'\""
}

source_alias proxy
source_alias lx-box
