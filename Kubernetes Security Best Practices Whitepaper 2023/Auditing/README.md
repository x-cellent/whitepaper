# Audit Configuration 
In this scenario we are creating a kind-cluster to test out auditing.

This audit configuration is just for demonstration purposes. The settings depend *a lot* on who you and the users on your cluster are.

# Example: Creation of a replica set
First we need to setup the cluster using the provided kind configuration:

`kind create cluster --config kind-config.yaml`

Then we can deploy our test repicaset:

`kubectl apply -f test-rs.yaml`

If we look at the audit log now via:

`docker exec kind-control-plane cat /var/log/kubernetes/kube-apiserver-audit.log`

we can see the following four requests:

```json
{
  "kind": "Event",
  "apiVersion": "audit.k8s.io/v1",
  "level": "RequestResponse",
  "auditID": "24c8ae67-8a33-4247-8ffa-5f42124b8355",
  "stage": "RequestReceived",
  "requestURI": "/apis/apps/v1/namespaces/default/replicasets/nginx-rs",
  "verb": "get",
  "user":
    {
      "username": "kubernetes-admin",
      "groups": ["system:masters", "system:authenticated"],
    },
  "sourceIPs": ["172.18.0.1"],
  "userAgent": "kubectl/v1.27.4 (linux/amd64) kubernetes/fa3d799",
  "objectRef":
    {
      "resource": "replicasets",
      "namespace": "default",
      "name": "nginx-rs",
      "apiGroup": "apps",
      "apiVersion": "v1",
    },
}
```
This shows us:
- who we are: `kubernetes-admin` using `kubectl/v1.27.4 (linux/amd64) kubernetes/fa3d799` since we used the kubeconfig kind provided us with
- what we did: `get` info on `/apis/apps/v1/namespaces/default/replicasets/nginx-rs`

And the response from the API Server was:
```json
{
    "kind": "Event",
    "apiVersion": "audit.k8s.io/v1",
    "level": "RequestResponse",
    "auditID": "24c8ae67-8a33-4247-8ffa-5f42124b8355",
    "stage": "ResponseComplete",
    "requestURI": "/apis/apps/v1/namespaces/default/replicasets/nginx-rs",
    "verb": "get",
    "user": {
        "username": "kubernetes-admin",
        "groups": [
            "system:masters",
            "system:authenticated"
        ]
    },
    "sourceIPs": [
        "172.18.0.1"
    ],
    "userAgent": "kubectl/v1.27.4 (linux/amd64) kubernetes/fa3d799",
    "objectRef": {
        "resource": "replicasets",
        "namespace": "default",
        "name": "nginx-rs",
        "apiGroup": "apps",
        "apiVersion": "v1"
    },
    "responseStatus": {
        "metadata": {},
        "status": "Failure",
        "message": "replicasets.apps \"nginx-rs\" not found",
        "reason": "NotFound",
        "details": {
            "name": "nginx-rs",
            "group": "apps",
            "kind": "replicasets"
        },
        "code": 404
    },
    "responseObject": {
        "kind": "Status",
        "apiVersion": "v1",
        "metadata": {},
        "status": "Failure",
        "message": "replicasets.apps \"nginx-rs\" not found",
        "reason": "NotFound",
        "details": {
            "name": "nginx-rs",
            "group": "apps",
            "kind": "replicasets"
        },
        "code": 404
    },
    "annotations": {
        "authorization.k8s.io/decision": "allow",
        "authorization.k8s.io/reason": ""
    }
}
```
But unfortunately the resource we requested does not exist, hence the `404` status code and the `replicasets.apps \"nginx-rs\" not found` message.

Now the `kube-controller-manager` jumps in and creates the replicaset for us:
```json
{
    "kind": "Event",
    "apiVersion": "audit.k8s.io/v1",
    "level": "RequestResponse",
    "auditID": "a424ec44-1e54-4d92-a662-b1318c8592d3",
    "stage": "RequestReceived",
    "requestURI": "/apis/apps/v1/namespaces/default/replicasets/nginx-rs",
    "verb": "get",
    "user": {
        "username": "system:serviceaccount:kube-system:replicaset-controller",
        "uid": "8691e56d-8022-4dcc-897f-0293330c1d32",
        "groups": [
            "system:serviceaccounts",
            "system:serviceaccounts:kube-system",
            "system:authenticated"
        ]
    },
    "sourceIPs": [
        "172.18.0.2"
    ],
    "userAgent": "kube-controller-manager/v1.25.11 (linux/amd64) kubernetes/8cfcba0/system:serviceaccount:kube-system:replicaset-controller",
    "objectRef": {
        "resource": "replicasets",
        "namespace": "default",
        "name": "nginx-rs",
        "apiGroup": "apps",
        "apiVersion": "v1"
    },
}
```

And the API server responds with our requested object:
```json
{
    "kind": "Event",
    "apiVersion": "audit.k8s.io/v1",
    "level": "RequestResponse",
    "auditID": "a424ec44-1e54-4d92-a662-b1318c8592d3",
    "stage": "ResponseComplete",
    "requestURI": "/apis/apps/v1/namespaces/default/replicasets/nginx-rs",
    "verb": "get",
    "user": {
        "username": "system:serviceaccount:kube-system:replicaset-controller",
        "uid": "8691e56d-8022-4dcc-897f-0293330c1d32",
        "groups": [
            "system:serviceaccounts",
            "system:serviceaccounts:kube-system",
            "system:authenticated"
        ]
    },
    "sourceIPs": [
        "172.18.0.2"
    ],
    "userAgent": "kube-controller-manager/v1.25.11 (linux/amd64) kubernetes/8cfcba0/system:serviceaccount:kube-system:replicaset-controller",
    "objectRef": {
        "resource": "replicasets",
        "namespace": "default",
        "name": "nginx-rs",
        "apiGroup": "apps",
        "apiVersion": "v1"
    },
    "responseStatus": {
        "metadata": {},
        "code": 200
    },
    "responseObject": {
        "kind": "ReplicaSet",
        "apiVersion": "apps/v1",
        "metadata": {
            "name": "nginx-rs",
            "namespace": "default",
            "uid": "97aa3a2c-3afc-44ee-9cfe-830aa4bbac40",
            "resourceVersion": "525",
            "generation": 1,
            "creationTimestamp": "2023-07-27T14:11:15Z",
            "annotations": {
                "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"apps/v1\",\"kind\":\"ReplicaSet\",\"metadata\":{\"annotations\":{},\"name\":\"nginx-rs\",\"namespace\":\"default\"},\"spec\":{\"replicas\":3,\"selector\":{\"matchLabels\":{\"app\":\"nginx\"}},\"template\":{\"metadata\":{\"labels\":{\"app\":\"nginx\"}},\"spec\":{\"containers\":[{\"image\":\"nginx:latest\",\"name\":\"nginx\",\"ports\":[{\"containerPort\":80}]}]}}}}\n"
            },
            "managedFields": [
                {
                    "manager": "kube-controller-manager",
                    "operation": "Update",
                    "apiVersion": "apps/v1",
                    "time": "2023-07-27T14:11:15Z",
                    "fieldsType": "FieldsV1",
                    "fieldsV1": {
                        "f:status": {
                            "f:observedGeneration": {}
                        }
                    },
                    "subresource": "status"
                },
                {
                    "manager": "kubectl-client-side-apply",
                    "operation": "Update",
                    "apiVersion": "apps/v1",
                    "time": "2023-07-27T14:11:15Z",
                    "fieldsType": "FieldsV1",
                    "fieldsV1": {
                        "f:metadata": {
                            "f:annotations": {
                                ".": {},
                                "f:kubectl.kubernetes.io/last-applied-configuration": {}
                            }
                        },
                        "f:spec": {
                            "f:replicas": {},
                            "f:selector": {},
                            "f:template": {
                                "f:metadata": {
                                    "f:labels": {
                                        ".": {},
                                        "f:app": {}
                                    }
                                },
                                "f:spec": {
                                    "f:containers": {
                                        "k:{\"name\":\"nginx\"}": {
                                            ".": {},
                                            "f:image": {},
                                            "f:imagePullPolicy": {},
                                            "f:name": {},
                                            "f:ports": {
                                                ".": {},
                                                "k:{\"containerPort\":80,\"protocol\":\"TCP\"}": {
                                                    ".": {},
                                                    "f:containerPort": {},
                                                    "f:protocol": {}
                                                }
                                            },
                                            "f:resources": {},
                                            "f:terminationMessagePath": {},
                                            "f:terminationMessagePolicy": {}
                                        }
                                    },
                                    "f:dnsPolicy": {},
                                    "f:restartPolicy": {},
                                    "f:schedulerName": {},
                                    "f:securityContext": {},
                                    "f:terminationGracePeriodSeconds": {}
                                }
                            }
                        }
                    }
                }
            ]
        },
        "spec": {
            "replicas": 3,
            "selector": {
                "matchLabels": {
                    "app": "nginx"
                }
            },
            "template": {
                "metadata": {
                    "creationTimestamp": null,
                    "labels": {
                        "app": "nginx"
                    }
                },
                "spec": {
                    "containers": [
                        {
                            "name": "nginx",
                            "image": "nginx:latest",
                            "ports": [
                                {
                                    "containerPort": 80,
                                    "protocol": "TCP"
                                }
                            ],
                            "resources": {},
                            "terminationMessagePath": "/dev/termination-log",
                            "terminationMessagePolicy": "File",
                            "imagePullPolicy": "Always"
                        }
                    ],
                    "restartPolicy": "Always",
                    "terminationGracePeriodSeconds": 30,
                    "dnsPolicy": "ClusterFirst",
                    "securityContext": {},
                    "schedulerName": "default-scheduler"
                }
            }
        },
        "status": {
            "replicas": 0,
            "observedGeneration": 1
        }
    },
    "annotations": {
        "authorization.k8s.io/decision": "allow",
        "authorization.k8s.io/reason": "RBAC: allowed by ClusterRoleBinding \"system:controller:replicaset-controller\" of ClusterRole \"system:controller:replicaset-controller\" to ServiceAccount \"replicaset-controller/kube-system\""
    }
}
```

# References
- https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/
- https://kind.sigs.k8s.io/docs/user/auditing/
- https://cloud.google.com/kubernetes-engine/docs/concepts/audit-policy
- https://signoz.io/blog/kubernetes-audit-logs/
