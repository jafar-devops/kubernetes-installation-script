#!/bin/bash
# Kubernetes Single-Node Cluster Setup for Ubuntu 22.04
# ------------------------------------------------
# Usage: sudo bash setup-kubernetes-ubuntu.sh

set -e  # Exit on error

echo "=== Step 1: Install Kubernetes Components ==="
# Remove old repo if exists
rm -f /etc/apt/sources.list.d/kubernetes.list

# Add Kubernetes repo
apt-get update -qq
apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

# Install packages
apt-get update -qq
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "=== Step 2: Initialize Control Plane ==="
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all

echo "=== Step 3: Configure kubectl ==="
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "=== Step 4: Install Flannel Network ==="
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "=== Step 5: Remove Master Taint (Single-Node) ==="
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "=== Verification ==="
echo "Cluster Nodes:"
kubectl get nodes
echo "Pods:"
kubectl get pods -A

echo "=== Setup Complete! ==="
echo "Run 'kubectl get nodes' to verify cluster status."