# Lab 02 - Pods, Deployments and Services

## Prerequisites
* You have completed [Lab 01 - Deploying AKS](./01-deploying-aks.md).

## ```kubectl```
```kubectl```, said *Kube-Control*, is the  command line interface for running commands against a Kubernetes clusters. In this execise, you will explore some useful features of ```kubectl``` that you may find useful in the CKAD exam.  

### Generate yaml
Writing yaml files quickly is an essential skill in the CKAD exam. In a lot of cases you can use ```kubectl``` to generate yaml for you.

1. 

2. 

### Modify output
...

1. 

2. 

### Explain
...

1. 

2. 

## Initial concepts
...

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

1. 
2. 

### Services

1. 
2. 

## Fireworks scenario
...

### Core goals

1. 
2. 

### Stretch goals

1. 
2. 