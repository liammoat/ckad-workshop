# Microsoft Ready - CKAD

## Setup Labs

1. In your browser open Azure Cloud Shell. Navigate to https://shell.azure.com.

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

## Quick links

* **GitHub:** https://aka.ms/msready-ckad
* **Setup Labs:** https://aka.ms/msready-ckad/setup-labs
* **Setup Demos:** https://aka.ms/msready-ckad/setup-demos