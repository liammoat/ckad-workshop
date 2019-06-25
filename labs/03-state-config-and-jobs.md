# Lab 03 - State, config and jobs

## Prerequisites
...

## Initial concepts
...

### State (Volumes)

The Kubernetes Volume is simply a directory on disk mapped to the pod that allows you to store and share data usually beyond the lifetime of a pod.

#### Multi-container Pods with emptyDir

1. Create busyboxvol pod with two containers (c1 and c2), each one will have the image busybox and will run the 'sleep 3600' command. Make both containers mount an emptyDir at '/etc/foo'.

    ```bash
    # Create Pod from the script file
    kubectl apply -f ~/ckad/labs/scripts/03-state-emptyDir.yaml
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

#### Persistant Volume using Storage Classes

1. List all the storage class available on your cluster

```bash
kubectl get sc
```

1. Create a PersistentVolumeClaim for azure storage class ```default```, called ```mypvc```, a request of 1Gi with an access mode of ReadWriteOnce.

    ```bash
    # Create PersistentVolumeClaim from the script file
    kubectl apply -f ~/ckad/labs/scripts/03-state-mypvc.yaml
    ```

    > Open YAML File look how PersistentVolumeClaim   is written.

1. Show the PersistentVolumes and PersistentVolumeClaims of the cluster

    ```bash
    # creation can take time, press ctrl+c to exit watch loop once pv and pvc are created 
    kubectl get pv,pvc -w 
    ```

1. Create a nginxvol pod running nginx image and Mount the PersistentVolumeClaim to '/etc/foo'. 

    ```bash
    # Create Pod from the script file
    kubectl apply -f ~/ckad/labs/scripts/03-state-mount-pvc.yaml
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
    kubectl apply -f ~/ckad/labs/scripts/03-state-mount-pvc.yaml
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
    kubectl apply -f ~/ckad/labs/scripts/03-state-configs.yaml
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



### Core goals

1. Configure Backplane for Fireworks App to use Azure SignalR ```ConnectionStringGoesHere```

    Fireworks app supports Signalr backplane allowing it to scale out and can be specified using envirnment variable.

    * ```SIGNALR_CS```: Connection string for Redis or Azure SignalR

1. Simulate shooting of 5 multishot every minute, take advantage of parallel and completions properties of Job  (tip: create CronJob)

    ```bash
    kubectl create cj firecron --image busybox --schedule "*/1 * * * *" --dry-run -o yaml -- /bin/sh -c "do wget foo:80/home/multiShot;sleep 1"

    ## modify file and add completion attribte to 60

    ```

### Stretch goals

1. Modify the deployment hard-coded to populate ```SIGNALR_CS``` env variable from Secrets config

1. Deploy Redis service in your cluster and configure env variable ```SIGNALR_CS``` to use it as connection string instead