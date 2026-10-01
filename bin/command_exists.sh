#!/bin/bash
function find_command() {
	command -v "$@"
}
function command_exists() {
	find_command "$1" &> /dev/null
}
command_exists "$1"
