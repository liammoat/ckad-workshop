# Lab 02 - Pods, Deployments and Services

* [Prerequisites](#prerequisites)
* [Initial concepts](#initial-concepts)
    * [Pods](#pods)
        * [Creating and updating Pods](#creating-and-updating-pods)
        * [Labels and annotations](#labels-and-annotations)
        * [Logs and Exec](#logs-and-exec)
    * [Deployments](#deployments)
    * [Services](#services)
* [Fireworks scenario](#fireworks-scenario)
    * [Core Goal](#core-goal)
    * [Stretch Goal](#stretch-goal)
---

## Prerequisites

* You have completed [Lab 01 - Deploying AKS](./01-deploying-aks.md).

* If you're not familar with ```kubectl```, please take a look at [Explore ```kubectl```](../reference/explore-kubectl.md).

## Initial concepts

### Pods
A Pod represents a set of running containers on your cluster - it's the smallest and simplest Kubernetes object. 

#### Creating and updating Pods

1. Using ```kubectl```, create a new Pod called 'webserver' running ```nginx``` image.

    ```bash
    kubectl run webserver --image=nginx --restart=Never
    ```

1. Get the status and IP of Pod 'webserver'.

    ```bash
    kubectl get pod webserver -o wide 
    ```

1. Get a detailed description of the pod, including related resources such as events or controllers.

    ```bash
    kubectl describe pod webserver
    ```

1. Get the status of 'faultywebserver'.

    ```
    kubectl get pod faultywebserver -o wide 
    ```

    > Notice that the Pod status is "ImagePullBackOff". Something is wrong.

1. Identify, and resolve, the issue with 'faultywebserver'.
    
    ```
    kubectl describe pod faultywebserver 
    kubectl set image pod faultywebserver faultywebserver=nginx
    kubectl get pod faultywebserver -o wide
    ```

1. Using YAML, create a new Pod called 'web' running ```nginx``` image.

    ```
    # use kubectl to generate web-pod.yaml
    kubectl run webserver --image=nginx --restart=Never --dry-run -o yaml > web-pod.yaml

    # view nginx-pod.yaml
    cat web-pod.yaml
    
    # apply the YAML file
    kubectl apply -f web-pod.yaml
    ```
    
    > Notice the use of ```--dry-run -o yaml``` to generate the yaml, which is then piped into web-pod.yaml. 

#### Labels and annotations

1. Using ```kubectl```, create a new Pod called 'nginx' running ```nginx``` image. Label the Pod with 'app=v1'.

    ```bash
    kubectl run nginx --image=nginx --restart=Never --labels=app=v1
    
    # or

    kubectl run nginx --image=nginx --restart=Never
    kubectl label pod nginx app=v1
    ```

1. Show all Pods in the default namespace, including the Pods' labels.

    ```bash
    kubectl get pod --show-labels
    ```

1. Change the label of pod 'nginx' to be 'app=v2'

    ```bash
    kubectl label pod nginx2 app=v2 --overwrite
    ```

1. Get all Pods with the label 'app=v2'.

    ```bash
    kubectl get pod -l app=v2
    ```

1. Remove the 'app' label from Pod 'nginx'.

    ```bash
    kubectl label pod nginx app-
    ``` 

1. Annotate Pod 'nginx' with "description='my description'".

    ```bash
    kubectl annotate pod nginx description='my description'
    ```

#### Logs and Exec 

1. Get logs from 'webserver'.

    ```
    kubectl logs webserver -n mynamespace 
    ```

1. Retrieve a list of all the files within the ```nginx``` container running on 'webserver' pod.

    ```
    kubectl exec webserver -n mynamespace -- ls
    ```

### Deployments
A deployment is an API object that manages a replicated application. A *Deployment controller* provides declarative updates for Pods and ReplicaSets.

1. Create a yaml file for a Deployment running a ```nginx``` container, with five replicas, and save it as mydeploy.yaml.

    ```bash
    kubectl run mydeploy --image=nginx --replicas=5 --dry-run -o yaml > mydeploy.yaml 
    ```

    > This is another great example where you can use ```--dry-run -o yaml``` to generate the required yaml.

1. Create a Deployment using mydeploy.yaml.

    ```bash
    kubectl apply -f mydeploy.yaml
    ```

1. View the Deployment 'mydeploy', the associated ReplicaSet and Pods.

    ```bash
    kubectl get deployment,rs,pod
    ```

1. Modify the image used by 'mydeploy' to use image ```nginx:1.16.0``` and observe the update as it's applied.

    ```bash
    # set the deployment image
    kubectl set image deployment mydeploy mydeploy=nginx:1.16.0

    # observe how the update gets applied 
    kubectl get rs -w
    ```

1. View the rollout history for 'mydeploy' and roll back to the previous revision.

    ```bash
    # view previous rollout revisions and configurations.
    kubectl rollout history deploy mydeploy
    
    # rollback to the previous rollout.
    kubectl rollout undo deploy mydeploy
    
    # observe how rollowing update gets applied 
    kubectl get rs -w
    ```

1. Scale 'mydeploy' to 2 instance. 

    ```
    kubectl scale deploy mydeploy --replicas=2
    ```

### Services
A Service is an abstract way to expose an application running on a set of Pods.

1. Expose the deployment 'mydeploy' on port **80**. Observe that a service is created.

    ```bash
    kubectl expose deployment mydeploy --port 80
    kubectl get svc mydeploy
    ```

1. Confirm that a Cluster IP has been created.

    ```bash
    kubectl get svc mydeploy -o jsonpath='{.spec.clusterIP}'
    ```

1. Using the Pod's Cluster IP, create a new temporary Pod using ```busybox``` and 'hit' the IP with ```wget```:

    ```bash
    # get the service's Cluster IP
    kubectl get svc mydeploy -o jsonpath='{.spec.clusterIP}'

    # run busybox
    kubectl run busybox --rm --image=busybox -it --restart=Never -- sh

    # from inside the container
    wget -O- <cluster-id>:80
    exit
    ```

1. Change to service type of 'mydeploy' from the ClusterIP to LoadBalancer. Find the Public IP address and browse to the application.

    ```bash
    # edit the service
    kubectl edit svc nginx

    # change "type: ClusterIP" to "type: LoadBalancer"

    # get the assigned external IP
    kubectl get svc -w
    ```

    > **Note:** This may take a few minutes to complete.

## Fireworks scenario
SignalR based application that allows website users to light fireworks and display on all the connected site users. You can light single or multi shot using the app. There is also a button that can stimulate a crash /home/admin. Pressing the button again will make the application run again.

**Port Exposed:**
* 80

**Images [on Docker Hub](https://cloud.docker.com/u/kunalbabre/repository/docker/kunalbabre/fireworks):**

* **Green:** kunalbabre/fireworks:green
* **Blue:** kunalbabre/fireworks:blue
* **Red:** kunalbabre/fireworks:red
* **Yellow:** kunalbabre/fireworks:yellow

**Trigger fireworks manually:**

* **Trigger Single:** /home/singleshot
* **Trigger Multishot:** /home/multishot

**Environment  variables:**

* ```SIGNALR_CS```: (optional) if you wish to scale-out you can provide connection string for Redis or Azure SignalR
* ```APP_COLOR```:  (works with latest tag) you can specify theme color for the app (red,green, blue, yellow)

**Health Monitoring:**

* **Liveness:** /home/isRunning
    * returns HTTP 200 if the application is alive
    * returns HTTP 400 if the application has crashed

* **Readiness:** /home/isRunning
    * returns HTTP 200 if the application is alive
    * returns HTTP 400 if the application has crashed

### Core Goal

1. All operations in this exercise should be performed in the ```fireworks``` namespace (already been created for you). 

    <details><summary>hint</summary>
    <p>

    ```bash
    kubectl config set-context $(kubectl config current-context) --namespace=<namespace>
    ```
    </p>
    </details>

1. Create Deployment called 'fireworks' using the image ```kunalbabre/fireworks:red``` in the namespace 'fireworks'.

    <details><summary>hint</summary>
    <p>

    ```bash
    kubectl create deployment <name> --image <image name>
    ```

    </p>
    </details>

1. Expose the deployment ```firework``` on port **80**. Use a ```LoadBalancer``` service called 'fireservice'.

    <details><summary>hint</summary>
    <p>

    ```bash
    kubectl expose deployment <deployment-name> --name <service-name> --port=80 --type <service-type> 
    ```

    </p>
    </details>

1. Wait for the external IP to be allocated. Once available, navigate to the IP address in the web browser.

   <details><summary>hint</summary>
    <p>

    ```bash
    kubectl get svc -w
    ```

    </p>
    </details>

1. Scale the deployment 'fireworks' to **5** replicas. Observe the Pods being created.

   <details><summary>hint</summary>
    <p>

    ```bash
    # using edit command to update replica count
    kubectl edit deployment <deployment name>

    # or, using the scale command
    kubectl scale deployment <deployment name> --replicas=5

    # finally, you can watch pods being created
    kubectl get po -w
    ```

    </p>
    </details>

1. Update the deployment 'fireworks' to use image ```kunalbabre/fireworks:latest```.

   <details><summary>hint</summary>
    <p>

    ```bash
    # using edit command to update container image
    kubectl edit deployment <deployment name>

    # or, using set image command
    kubectl set image deploy <deployment name> fireworks=<New Image Name>
    ```

    </p>
    </details>

## Stretch Goal

1. Configure the 'fireworks' pods to only accept traffic when ready and auto restart if crashed.

   <details><summary>hint</summary>
    <p>
    
    Look for examples in the
    [Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes).

    </p>
    </details>
