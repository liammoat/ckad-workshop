# Lab 03 - Fireworks Exercise Part 1

## About Fireworks App

SignalR based application that allows website users to light fireworks and display on all the connected site users. You can light single or multi shot using the app. There is also a button that can stimulate a crash /home/admin. Pressing the button again will make the application run again.

### Port Exposed
* 80

### Images [on Docker Hub](https://cloud.docker.com/u/kunalbabre/repository/docker/kunalbabre/fireworks)

* Green: kunalbabre/fireworks:green
* Blue: kunalbabre/fireworks:blue
* Red: kunalbabre/fireworks:red
* Yellow: kunalbabre/fireworks:yellow

### Trigger fireworks manually

* Trigger Single - ```/home/singleshot```
* Trigger Multishot - ```/home/multishot```


### Environment  variables 
* ```SIGNALR_CS```  : (optional) if you wish to scale-out you can provide connection string for Redis or Azure SignalR
* ```APP_COLOR```:  (works with latest tag): you can specify theme color for the app (red,green, blue, yellow)

### Health Monitoring

* Liveness - ```/home/isRunning```
    * returns HTTP 200 if the application is alive
    * returns HTTP 400 if the application has crashed

* Readiness  - ```/home/isRunning```
    * returns HTTP 200 if the application is alive
    * returns HTTP 400 if the application has crashed

# Exercise Part 1

1. All operations in this exercise should be performed in the ```fireworks``` namespace (already been created for you). 

    <details><summary>show</summary>
    <p>

    ```bash
    kubectl config set-context $(kubectl config current-context) --namespace=fireworks
    ```
    </p>
    </details>

1. Create Deployment called 'fireworks' using the image ```kunalbabre/fireworks:red``` in the namespace 'fireworks'.

    <details><summary>hint</summary>
    <p>

    ```bash
    # You can use create deployment command
    kubectl create deployment <name> --image <image name>
    ```

    </p>
    </details>

1. Expose the deployment ```firework``` ```externally``` on port 80 and name the service ```fireservice```.

    <details><summary>hint</summary>
    <p>

    ```bash
    # You can use expose deployment command
    kubectl expose deployment <Deployment Name> --name <Service Name> --port=80 --type <Service Type> 
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

1. Scale the deployment ```fireworks``` to 5 replicas. Observe the Pods being created.

   <details><summary>hint</summary>
    <p>

    ```bash
    # There are few ways you can scale deployment in exam

    # 1. Using edit command to update replica count
    kubectl edit deployment <deployment name>

    # 2.Using Scale command
    kubectl scale deployment <deployment name> --replicas=5

    # Finally you can watch pods being created using -w
    kubectl get po -w
    ```

    </p>
    </details>

1. Update the deployment ```fireworks``` to use image ```kunalbabre/fireworks:latest```.

   <details><summary>hint</summary>
    <p>

    ```bash
    # There are couple of ways to update deployment image

    # 1. Using edit command to update container image
    kubectl edit deployment <deployment name>

    # 2.Using set iamge command
    kubectl set image deploy <deployment name> fireworks=<New Image Name>
    ```

    </p>
    </details>

## Streach Goal

1. Configure the ```fireworks``` app deployed to only accept traffic when ready and auto restart if crashed.

   <details><summary>hint</summary>
    <p>
    
    look for http probes examples
    [Kubernetes docs here ](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probe)

    </p>
    </details>
