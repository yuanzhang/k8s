#!/bin/bash

kubectl delete deployment kube-dns -n kube-system
kubectl delete svc kube-dns -n kube-system
kubectl delete deployment coredns -n kube-system
