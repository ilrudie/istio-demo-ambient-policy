#!/usr/bin/env bash

istioctl x waypoint apply --name productpage-waypoint --wait

kubectl label service productpage istio.io/use-waypoint=productpage-waypoint
