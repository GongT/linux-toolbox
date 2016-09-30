#!/usr/bin/env bash

conditional_start memcached  -p 11211:11211 memcached:alpine
conditional_start memcached2 -p 11212:11211 memcached:alpine
conditional_start memcached3 -p 11213:11211 memcached:alpine
