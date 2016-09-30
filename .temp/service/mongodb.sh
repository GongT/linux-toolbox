#!/usr/bin/env bash

conditional_start mongodb -e AUTH=no -e MONGODB_PASS="920223" -v /data/database/mongodb:/data/db -p 27017:27017 -p 28017:28017 tutum/mongodb
