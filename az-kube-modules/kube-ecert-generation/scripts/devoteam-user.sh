#!/bin/sh

echo "test  a new kube user"

cat <<EOF | kubectl apply -f - 
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: tsp
  name: pod-reader
rules:
- apiGroups: ["devoteam-apps"] # "" indicates the core API group
  resources: ["services","endpoints","pods"]
  verbs: ["get", "watch", "list","create","update"]
---
kind: RoleBinding  # This role binding allows "jane" to read pods in the "default" namespace.
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: devoteam # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role #this must be Role or ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
EOF
