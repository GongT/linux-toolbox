#!/bin/bash

PTS=$(ps $$ | tail -n1 | awk '{print $2}')

echo "Using pseudo-terminal:"
ls -l "/dev/$PTS"
