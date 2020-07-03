#!/bin/sh

helm delete flux -n flux
sleep 20
kubectl delete ns flux