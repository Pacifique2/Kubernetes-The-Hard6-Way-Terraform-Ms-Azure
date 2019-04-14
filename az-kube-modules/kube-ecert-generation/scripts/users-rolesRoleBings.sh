#!/bin/sh

set -e

echo "creating the devoteam user role and roleBing"
cat <<EOF | kubectl apply -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: devoteam-apps
  name: devoteam-deployment-manager
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # You can also use ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: devo-deployment-manager-binding
  namespace: devoteam-apps
subjects:
- kind: User
  name: devoteam-pacy
  apiGroup: ""
roleRef:
  kind: Role
  name: devoteam-deployment-manager
  apiGroup: ""
EOF

echo "done granting permissions to the devoteam-pacy user"

echo "creating the telecom sud paris user role and roleBinding"
cat <<EOF | kubectl apply -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: telecom-sud-paris-apps
  name: stp-deployment-manager
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch","create","update"] # You can also use ["*"]
---
# This role binding allows "tsp-pacy" to have the admin rights in the "telecom-sud-paris" namespace.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tsp-rights
  namespace: telecom-sud-paris-apps # This only grants permissions within the "telecom-sud-paris" namespace.
subjects:
- kind: User
  name: tsp-pacy # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: stp-deployment-manager
  apiGroup: rbac.authorization.k8s.io
EOF

echo "done granting permissions to the tsp-pacy user"
