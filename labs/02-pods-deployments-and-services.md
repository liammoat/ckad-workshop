# Lab 02 - Pods, Deployments and Services

* [Prerequisites](#prerequisites)
* [```kubectl```](#kubectl)
    * [Explore ```kubectl```](#explore-kubectl)
    * [Generate yaml](#generate-yaml)
    * [Export](#export)
    * [Explain](#explain)
* [Initial concepts](#initial-concepts)
    * [Pods](#pods)
        * [Create a pod using ```kubectl```](#create-a-pod-using-kubectl)
        * [Create a pod using yaml](#create-a-pod-using-yaml)
        * [Labels and annotations](#labels-and-annotations)
        * [Logs and Exec](#logs-and-exec)
    * [Deployments](#deployments)
    * [Services](#services)
* [Fireworks scenario](#fireworks-scenario)
    * [Core goals](#core-goals)
    * [Stretch goals](#core-goals)
---

## Prerequisites
* You have completed [Lab 01 - Deploying AKS](./01-deploying-aks.md).

## ```kubectl```
```kubectl```, said *Kube-Control*, is the  command line interface for running commands against a Kubernetes clusters. In this execise, you will explore some useful features of ```kubectl``` that you may find useful in the CKAD exam.  

kubernetes.io > Documentation > Reference > kubectl CLI > [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### Explore ```kubectl```
...

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

### Generate yaml
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

### Export
Exported resources are stripped of cluster-specific
information. This option is useful to obtain the yaml to recreate a particular object. 

1. 

2.

### Explain
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

## Initial concepts

### Pods
A Pod represents a set of running containers on your cluster - it's the smallest and simplest Kubernetes object. 

#### Create a pod using ```kubectl```

1. Create a new Pod called 'webserver' running ```nginx``` image.

    ```bash
    kubectl run webserver --image=nginx --restart=Never
    ```

2. Get the status and IP of 'webserver'.

    ```bash
    kubectl get pod webserver -o wide 
    ```

3. Get a detailed description of the pod, including related resources such as events or controllers.

    ```bash
    kubectl describe pod webserver
    ```

4. Delete 'webserver'.

    ```bash
    kubectl delete pod webserver
    ```

5. Create a new Pod called 'faultywebserver' running ```nnginx``` image.

    ```kubernetes
    kubectl run faultywebserver --image=nnginx --restart=Never 
    ```

6. Get the status and IP of 'faultywebserver'.

    ```
    kubectl get pod faultywebserver -o wide 
    ```

    > Notice that the Pod status is "ImagePullBackOff". Something is wrong.

7. Identify, and resolve, the issue with 'faultywebserver'.
    
    ```
    kubectl describe pod faultywebserver 
    kubectl set image pod faultywebserver faultywebserver=nginx
    kubectl get pod faultywebserver -o wide
    ```

8. Delete all Pods in current namespace 

    ``` 
    kubectl delete pod --all
    ```

#### Create a pod using yaml

1. Create new Namespace called 'mynamespace'.
    
    ```
    kubectl create namespace mynamespace
    ```

2. Using YAML, create a new Pod called 'webserver' running ```nginx``` image in 'mynamespace'.

    ```
    # use kubectl to generate nginx-pod.yaml
    kubectl run webserver --image=nginx --restart=Never --dry-run -o yaml > nginx-pod.yaml

    # view nginx-pod.yaml
    code nginx-pod.yaml
    
    # apply the YAML file
    kubectl apply -f nginx-pod.yaml -n mynamespace
    ```
    
    > Notice the use of ```--dry-run -o yaml``` to generate the yaml, which is then piped into nginx-pod.yaml. 

3. Get the status and IP of the pod 'webserver' 

    ```
    kubectl get pod webserver -o wide -n mynamespace 
    ```

#### Labels and annotations

1. Create 3 pods with names 'nginx1', 'nginx2' and 'nginx3'. All of them should have the label 'app=v1'

    ```bash
    kubectl run nginx1 --image=nginx --restart=Never --labels=app=v1
    kubectl run nginx2 --image=nginx --restart=Never --labels=app=v1
    kubectl run nginx3 --image=nginx --restart=Never --labels=app=v1
    ```

2. Show all Pods in the default namespace, including the Pods' labels.

    ```bash
    kubectl get po --show-labels
    ```
3. Change the labels of pod 'nginx2' to be 'app=v2'

    ```bash
    kubectl label po nginx2 app=v2 --overwrite
    ```

4. Show all Pods and the label 'app' for each Pod

    ```bash
    kubectl get po -L app
    ```

5. Get all Pods with the label 'app=v2'.

    ```bash
    kubectl get po -l app=v2

    # or
    kubectl get po -l 'app in (v2)'
    ```

6. Remove the 'app' label from the three Pods you created before.

    ```bash
    kubectl label po nginx1 nginx2 nginx3 app-
    
    # or
    kubectl label po nginx{1..3} app-
    
    # or
    kubectl label po -l app app-
    ``` 

7. Annotate Pods 'nginx1', 'nginx2' and 'ngingx3' with "description='my description'".

    ```bash
    kubectl annotate po nginx1 nginx2 nginx3 description='my description'
    ```

8. Check the annotations for pod 'nginx1'.

    ```bash
    kubectl describe po nginx1 | grep -i 'annotations'
    ```

9. Delete Pods 'nginx1', 'nginx2' and 'ngingx3'

    ```bash
    kubectl delete po nginx{1..3}
    ```

#### Logs and Exec 

1. Get logs from 'webserver'.

    ```
    kubectl logs webserver -n mynamespace 
    ```

2. Retrieve a list of all the files within the ```nginx``` container running on 'webserver' pod.

    ```
    kubectl exec webserver -n mynamespace -- ls
    ```

4. Delete the namespace 'mynamespace'

    ```bash
    kubectl delete namespace mynamespace
    ```

### Deployments
A deployment is an API object that manages a replicated application. A *Deployment controller* provides declarative updates for Pods and ReplicaSets.

1. Create a yaml file for a Deployment running a ```nginx``` container, with five replicas, and save it as mydeploy.yaml.

    ```bash
    kubectl run mydeploy --image=nginx --replicas=5 --dry-run -o yaml > mydeploy.yaml 
    ```

    > This is another great example where you can use ```--dry-run -o yaml``` to generate the required yaml.

2. Create a Deployment using mydeploy.yaml.

    ```bash
    kubectl apply -f .\mydeploy.yaml
    ```

3. View the Deployment 'mydeploy', the associated Replica Set and Pods.

    ```bash
    kubectl get deploy,rs,po
    ```

4. Modify the image used by 'mydeploy' to use image ```nginx:1.16.0``` and observe the update as it's applied.

    ```bash
    # edit image in mydeploy.yaml
    code mydeploy.yaml

    # apply the updated file
    kubectl apply -f .\mydeploy.yaml

    # observe how rollowing update gets applied 
    kubectl get rs -w
    ```

    **or**

    ```bash
    # set the deployment image
    kubectl set image deployment mydeploy mydeploy=nginx:1.16.0

    # observe how rollowing update gets applied 
    kubectl get rs -w
    ```

5. View the rollout history for 'mydeploy' and roll back to the previous revision.

    ```bash
    # view previous rollout revisions and configurations.
    kubectl rollout history deploy mydeploy
    
    # rollback to the previous rollout.
    kubectl rollout undo deploy mydeploy
    
    # observe how rollowing update gets applied 
    kubectl get rs -w
    ```

6. Scale 'mydeploy' to 1 instance. 

    ```
    kubectl scale deploy mydeploy --replicas=1
    ```

7. Delete all resources in the 'default' namespace 

    ```bash
    kubectl delete all
    ```

### Services
A Service is an abstract way to expose an application running on a set of Pods.

1. Create a Pod with image ```nginx``` called 'nginx' and expose its port **80**. Observe that a Pod as well as a Service are created

    ```bash
    kubectl run nginx --image=nginx --restart=Never --port=80 --expose
    
    kubectl get pod,svc -l run=nginx
    kubectl get svc nginx
    ```

2. Confirm that a ClusterIP has been created. Also, view the cluster's endpoints.

    ```bash
    # cluster IP
    kubectl get svc nginx -o jsonpath='{.spec.clusterIP}'

    # endpoints
    kubectl get ep
    ```

3. Using the Pod's ClusterIP, create a new temporary Pod using ```busybox``` and 'hit' the IP with ```wget```:

    ```bash
    # get the Pod's IP
    kubectl get svc nginx -o jsonpath='{.spec.clusterIP}'

    # run busybox
    kubectl run busybox --rm --image=busybox -it --restart=Never -- sh

    # from inside the container
    wget -O- <cluster-id>:80
    exit
    ```

4. Convert the ClusterIP to NodePort and find the NodePort port.

    ```bash
    # edit the service
    kubectl edit svc nginx

    # change "type: ClusterIP" to "type: NodePort"

    # get the service
    kubectl get svc 
    ```

5. Change to service type from the NodePort to LoadBalancer. Find the Public IP and browse to the application.

    ```bash
    # edit the service
    kubectl edit svc nginx

    # change "type: ClusterIP" to "type: LoadBalancer"

    # get the assigned external IP
    kubectl get svc -w
    ```

6. Delete all resources in the current namespace.

    ```bash
    kubectl delete all
    ```
