# Demo 03 - State Persistence Configuration and jobs

* [State Persistance](#state-persistance)
* [Configuration](#Configuration)
* [Jobs](#Jobs)

---

## State Persistence

### List Storage Classes

```bash
kubectl get sc
```

### Persistant Volume Claim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: my-data-store
spec:
 accessModes:
 - ReadWriteOnce
 storageClassName: default
 resources:
  requests:
   storage: 1Gi
```

### After create show creation of PV and PVC

```bash
kubectl get pv,pvc
```

### Mount volume using PVC above

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: mypod1
spec:
 volumes:
  - name: my-volume
    persistentVolumeClaim:
     claimName: my-data-store
 containers:
 - image: nginx:1.15.5
   name: mypod
   volumeMounts:
   - name: my-volume
     mountPath: /mnt/data
```

## Configuration

### ConfigMaps from literal

```bash
kubectl create configmap special-config --from-literal=special.how=very --from-literal=special.type=charm
```

#### Use the ConfigMap as environment variable

```yaml
# Define container environment variables using ConfigMap data
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        # Define the environment variable
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              # The ConfigMap containing the value you want to assign to SPECIAL_LEVEL_KEY
              name: special-config
              # Specify the key associated with the value
              key: special.how
  restartPolicy: Never
```

### Secret using YAML

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4= #base64 of 'admin'
  password: MWYyZDFlMmU2N2Rm # '1f2d1e2e67df'
```

#### Now mount the secret as volume on pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: foo
      mountPath: "/etc/foo"
      readOnly: true
  volumes:
  - name: foo
    secret:
      secretName: mysecret
```

## Jobs

### Job using command line

```bash
kubectl create job sleepyjob --image busybox  -- sleep 5
```

### CronJob using command line

```bash
kubectl create cronjob sleepycron --image busybox --schedule "*/1 * * * *"  -- sleep 5 --dry-run -o yaml
```

#### Modified version that uses parallelism and completions properties

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: sleepycronjob
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      parallelism: 4
      completions: 8
      template:
        spec:
          containers:
          - name: busybox
            image: busybox
            command: ["sleep"]
            args: ["5"]
          restartPolicy: OnFailure
```
