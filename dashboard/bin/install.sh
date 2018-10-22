#!/bin/bash

ETC=../etc/


cd ${ETC}


kubectl apply -f dashboard-rbac.yaml
kubectl create -f dashboard-controller.yaml
kubectl create -f dashboard-service.yaml
