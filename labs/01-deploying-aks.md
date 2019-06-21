# Lab 01 - Deploying AKS

## Prerequisites
* Access to an Azure Subscription, with sufficient credit.

## Get setup
In this lab, you will get setup with Azure Cloud Shell and Azure Kubernetes Service.

### Steps

1. In your browser open Azure Cloud Shell by navigating to https://shell.azure.com.

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
    bash <(curl -Ls https://aka.ms/msready-ckad/setup-labs)
    ```

    > This [script](./assets/setup-labs.sh) does the following:
    > * Create a new resource group.
    > * Deploy an AKS cluster.
    > * Obtains the credentials, allowing you to use ```kubectl```.
    > * Clones this GitHub repository.

5. This will take approximately 10 minutes to complete. In the meantime, we'll explore some Kubernetes fundamentals and look at some CKAD exam tips and tricks. 