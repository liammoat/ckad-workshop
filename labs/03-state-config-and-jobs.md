# Lab 03 - State, config and jobs

* [Prerequisites](#prerequisites)
* [State Persistance](#state-persistance)
    * [Multicontainer using emptyDir](#mounting-emptydir)
    * [Persistant Volume using Storage Classes](#storage-classes)
* [Config - ConfigMaps and Secretes](#config)
* [Jobs](#jobs)
* [Fireworks scenario](#fireworks-scenario)
    * [Core Goal](#core-goal)
    * [Stretch Goal](#stretch-goal)
---

## Prerequisites

* You have completed [Lab 02 - Pods, Deployments and Services](./02-pods-deployments-and-services).

* All operations in this exercise should be performed in the ```default``` namespace.

    >**Top tip:** You can set 'default' as the default namespace.
    > ```bash
    > kubectl config set-context $(kubectl config current-context) --namespace=default
    > ```

### State Persistance

The Kubernetes Volume is simply a directory on disk mapped to the pod that allows you to store and share data usually beyond the lifetime of a pod.

#### Mounting emptyDir

1. Create busyboxvol pod with two containers (c1 and c2), each one will have the image busybox and will run the 'sleep 3600' command. Make both containers mount an emptyDir at '/etc/foo'.

    ```bash
    # Create Pod from the script file
    kubectl apply -f ~/ckad/labs/scripts/04-state-emptyDir.yaml
    ```

    > Open YAML File look how Volume and Volume mounts are performed

1. Connect to the first container ```c1```  , write current date time in the file ```/etc/foo//mydata.txt```

    ```bash
    kubectl exec -it busyboxvol -c c1 -- /bin/sh
    ls /etc/foo/ # confirm dir is empty
    echo $(date) > /etc/foo/mydata.txt
    cat /etc/foo/mydata.txt # confirm that stuff has been written successfully
    exit
    ```

    > Notice ```/etc/foo/``` directory has been mounted onto the container

1. Connect to the second container ```c2``` and read ```/etc/foo/mydata.txt``` file to standard output.

    ```bash
    kubectl exec -it busyboxvol -c c2 -- /bin/sh
    cat /etc/foo//mydata.txt
    exit
    ```

    > Notice that two containers within pod busyboxvol share the directory

#### Storage Classes

1. List all the storage class available on your cluster

    ```bash
    kubectl get sc
    ```

1. Create a PersistentVolumeClaim for azure storage class ```default```, called ```mypvc```, a request of 1Gi with an access mode of ReadWriteOnce.

    ```bash
    # Create PersistentVolumeClaim from the script file
    kubectl apply -f ~/ckad/labs/scripts/04-state-mypvc.yaml
    ```

    > Open YAML File look how PersistentVolumeClaim   is written.

1. Show the PersistentVolumes and PersistentVolumeClaims of the cluster

    ```bash
    # creation can take time, press ctrl+c to exit watch loop once pv and pvc are created
    kubectl get pv -w
    ```
    
    ```bash
    kubectl get pvc -w
    ```

1. Create a nginxvol pod running nginx image and Mount the PersistentVolumeClaim to '/etc/foo'.

    ```bash
    # Create Pod from the script file
    kubectl apply -f ~/ckad/labs/scripts/04-state-mount-pvc.yaml
    ```

   > Open YAML File look how Volume and Volume mounts are performed

1. Connect to the 'nginxvol' pod, and copy the '/etc/passwd' file to '/etc/foo'

    ```bash
    kubectl exec nginxvol -it -- cp /etc/passwd /etc/foo/passwd
    ```

1. Delete nginxvol pod

    ```bash
    kubectl delete po nginxvol
    ```

1. Recreate nginxvol pod running nginx image and Mount the PersistentVolumeClaim to '/etc/foo'.

    ```bash
    # Create Pod from the script file
    kubectl apply -f ~/ckad/labs/scripts/04-state-mount-pvc.yaml
    ```

1. Connect to the 'nginxvol' pod, and list all files in '/etc/foo'

    ```bash
    kubectl exec nginxvol ls /etc/foo/passwd
    ```

    > Notice files persisted, even after pod was deleted and recreated.

### Config

#### ConfigMaps and Secretes

1. Create a configmap named myconfig with values foo=lala,foo2=lolo

    ```bash
    kubectl create configmap myconfig --from-literal=foo=lala --from-literal=foo2=lolo
    ```

1. Create a secret called mysecret with the values password=mypass

    ```bash
    kubectl create secret generic mysecret --from-literal=password=mypass
    ```

1. Create a new nginx pod that loads the value from configmap ```myconfig``` ->  ```foo``` in an env variable called 'option'. Also load secret 'mysecret' as a volume inside an nginx pod on path ```/etc/secrets```.

    ```bash
    # Create Pod from the script file
    kubectl apply -f ~/ckad/labs/scripts/04-state-configs.yaml
    ```

1. Check environment variable ```option``` and ```/etc/secrets``` has expected values

    ```bash
    kubectl exec -it nginx -- env | grep option
    kubectl exec -it nginx -- ls /etc/secrets
    ```

### Jobs

1. Create CronJob called sleepycron that runs pod busy box with ```sleep 5``` command every minute

    ```bash
    kubectl create cronjob sleepycron --image busybox --schedule "*/1 * * * *" -- sleep 5
    ```

1. List all the CronJob, Jobs and Pods

    ```bash
    kubectl get cj,job,pod -w # observe every minute job and pods will be created
    ```
## Fireworks scenario

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

### Core goals

1. Configure Backplane for Fireworks App to use Azure SignalR ```ConnectionStringGoesHere```

    Fireworks app supports Signalr backplane allowing it to scale out and can be specified using envirnment variable.

    * ```SIGNALR_CS```: Connection string for Redis or Azure SignalR

    <details><p>
    here is a sample for Pod using environment variable

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
    name: sample-pod
    spec:
    containers:
    - name: mycontainer
        image: someImage
        env: #
        - name: SomeName #
          value: SomeValue #
    ```

    </p>
    </details>

1. Simulate shooting of 10's of multishot every 1 minute, take advantage of parallel and completions properties of Job  (tip: create CronJob)

    <details><summary>Hint</summary>
    <p>

    ```bash
    #1. Generate YAML for Cron Job to get started

    kubectl create cj firecron --image busybox --schedule "*/1 * * * *" --dry-run -o yaml -- /bin/sh -c "for i in 1 2 3 4 5;do wget fireservice:80/home/multiShot; sleep 1;done" > firecron.yaml

    ##2. modify file and add completion and parallel attribute
    code firecron.yaml

    # apply changes
    kubectl apply -f firecron.yaml
    ```

    Sample CronJob with parallelism and Completion attributes.

    ```YAML
    apiVersion: batch/v1beta1
    kind: CronJob
    metadata:
    name: sleepycronjob
    spec:
      parallelism: 2
      completions: 60
      template:
        metadata:
        spec:
          containers:
          - command:
            - /bin/sh
            - -c
            - for i in 1 2 3 4 5;do wget foo:80/home/multiShot; sleep 1;done
            image: busybox
            name: firecron
            resources: {}
          restartPolicy: OnFailure
        schedule: '*/1 * * * *'
    ```

    </p>
    </details>

### Stretch goals

1. Modify the deployment to populate ```SIGNALR_CS``` env variable from Secrets config

    <details><summary>Hint</summary>
    <p>

    ```bash
    #1. Create Secret 
    kubectl create secret generic mysecret --from-literal=<name>=<value>

    #2. Modify your deployment and add env variable from secret under  
    kubectl edit deploy 
    ```

    here is a sample for Pod using environment variable from secret

    ```yaml
    apiVersion: v1
    kind: Pod
    metadata:
    name: sample-cret-env-pod
    spec:
    containers:
    - name: mycontainer
        image: someImage
        env: #
        - name: SECRET_USERNAME #
            valueFrom: #
            secretKeyRef: #
                name: mysecret #
                key: username #
    ```

    </p>
    </details>
