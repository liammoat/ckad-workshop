# Lab 01 - Deploying AKS

* [Prerequisites](#prerequisites)
* [Get setup](#get-setup)
---

## Prerequisites
* You have access to an Azure Subscription, with sufficient credit.

## Get setup
Before you get started, you will setup Azure Cloud Shell and Azure Kubernetes Service.

### Steps

1. In your browser open Azure Cloud Shell by navigating to https://shell.azure.com.

    > You will use Azure Cloud Shell for all labs in this workshop. See [here](https://docs.microsoft.com/en-us/azure/cloud-shell/using-the-shell-window){:target="_blank"} for some tips and tricks (like how to *copy* and *paste*).

2. Check which subscription you have connected to:

    ```bash
    az account show
    ```

3. If you prefer, you can switch to a different subscription:

    ```bash
    az account set --subscription <subscription-name>
    ```

4. Within Cloud Shell, run the following command to download and execute the setup script:

    ```bash
    bash <(curl -Ls https://aka.ms/ckad-workshop/setup-labs)
    ```

    > This [script](../assets/setup-labs.sh) does the following:
    > * Create a new resource group.
    > * Deploy an AKS cluster.
    > * Obtains the credentials, allowing you to use ```kubectl```.
    > * Clones this GitHub repository.

5. This will take approximately 10 minutes to complete. In the meantime, we'll explore some Kubernetes fundamentals and look at some CKAD exam tips and tricks. 