#!/bin/bash

function source_alias {
	emit "alias ${1}=\"source '${VAR_HERE}/${1}'\""
}

source_alias switch
source_alias proxy
source_alias path-var
source_alias set-window-title
source_alias set-prompt
source_alias set-window-title-callback
source_alias lx-box

emit_source set-prompt ""
emit_source set-window-title-callback-auto
emit_source set-window-title-callback "set-window-title-callback-auto"
