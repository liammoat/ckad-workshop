# Explore ```kubectl```

* [Get Started](#get-started)
* [Generate yaml](#generate-yaml)
* [Export](#export)
* [Explain](#explain)
---

## Get Started

```kubectl```, said *Kube-Control*, is the  command line interface for running commands against a Kubernetes clusters. In this execise, you will explore some useful features of ```kubectl``` that you may find useful in the CKAD exam.  

1. Get Cluster information.

    ```bash
    kubectl cluster-info
    ```

2. Write Cluster information to a file name 'cluster.txt'.

    ```bash
    kubectl cluster-info > cluster.txt
    ```

3. Get a list of nodes in the cluster.

    ```bash
    kubectl get nodes
    ```
 
4. Get a list of all namespaces in the cluster.

    ```bash
    kubectl get namespaces
    ```

5. Get a list of **all** pods, including their IP addresses, running in the cluster.

    ```bash
    kubectl get pods --all-namespaces -o wide
    ```

    > **Note:** This instruction says "all" and "including their IP addresses". Watch out for key words like this in the CKAD exam questions. For example, ```kubectl get pods``` would be incorrect.

6. Find out CPU and memory limits for the first node in the cluster

    ```bash
    # get list of nodes
    kubectl get nodes

    # using the first one, describe the node
    kubectl describe node <node-name>
    ```

    **or**

    ```bash
    # once you become more familar with jsonpath, you could do the same like this
    kubectl get nodes -o jsonpath='{.items[0].metadata.name}' | kubectl describe node
    ```

## Generate yaml
Writing yaml files quickly is an essential skill in the CKAD exam. In a lot of cases you can use ```kubectl``` to generate yaml for you.

> Make sure you understand the constructs and syntax of yaml: www.json2yaml.com

1. Generate the yaml to create a namespace called 'new-namespace'.

    ```bash
    kubectl create namespace new-namespace --dry-run -o yaml
    ```

    > **Note:** the use of ```--dry-run -o yaml``` to generate the yaml. 
    >
    > * ```--dry-run``` - prints the object that would be sent, without sending it. 
    > * ```-o yaml``` - changes the output format to yaml

2. Write the yaml to create a namespace called 'new-namespace' to a file named 'namespace.yaml'.

    ```bash
    # write the generate yaml to disk
    kubectl create namespace new-namespace --dry-run -o yaml > namespace.yaml

    # check the contents of the file
    cat namespace.yaml
    ```

## Export
Exported resources are stripped of cluster-specific
information. This option is useful to obtain the yaml to recreate a particular object. 

1. Get a pod nginx in namespace demospace without any cluster specific information

    ```bash
    kubectl get pod nginx -n demospace --export -o yaml
    ```

## Explain
```kubectl explain``` will explain the given resource. For example, a top level API-object like Pod or a specific field like a Pod's container. 

1. Get the documentation of a Pod resource and its fields.

    ```bash
    kubectl explain pods
    ```

2. Get the documentation for a Pod's container specification.

    ```bash
    kubectl explain pods.spec.containers
    ```

    > **Note:** ```pods.spec.containers``` matches the yaml object structure:
    > ```yaml
    > apiVersion: v1
    > kind: Pod
    > metadata:
    > creationTimestamp: null
    > name: nginx
    > spec:
    >   containers:
    >   - image: nginx
    >     imagePullPolicy: IfNotPresent
    >     name: nginx
    >     resources: {}
    >   dnsPolicy: ClusterFirst
    >   restartPolicy: Never
    > ```