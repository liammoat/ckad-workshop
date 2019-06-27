# Lab 05 - Fireworks Exercise Part 2

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

# Exercise Part 2


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
