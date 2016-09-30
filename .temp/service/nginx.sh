#!/usr/bin/env bash

conditional_start nginx -p 80:80 -p 443:443 -v /etc/nginx:/etc/nginx nginx:alpine
