#!/usr/bin/env bash

hx "$1"

kubectl apply -f "$1"
