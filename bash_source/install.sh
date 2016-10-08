#!/bin/bash

function source_alias {
	emit "alias ${1}=\"source '${_INSTALLING_}/${1}'\""
}

source_alias switch
source_alias proxy
source_alias path-var
source_alias set-window-title
source_alias set-prompt
source_alias set-window-title-callback
source_alias lx-box
