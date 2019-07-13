echo "Microsoft Ready - Setup Labs Script"

# setup variables

RANDOM=$$$(date +%s)

uniqueKey=$(date +%s | sha256sum | base64 | head -c 5 ; echo)
rg="ckad-rg-$uniqueKey" 
aksName="ckad-aks-$uniqueKey"
github="https://github.com/liammoat/ckad-workshop.git"

regions=(westus2 centralus eastus2)
selectedRegion=${regions[$RANDOM % ${#regions[@]} ]}

# clear existing

rm -rf ~/ckad

# create resource group

echo "Creating resource group: $rg"
echo "Selected region: $selectedRegion"

az group create -l $selectedRegion -n $rg -o table

# deploy aks cluster

echo "Creating AKS cluster: $aksName"
az aks create \
    --resource-group $rg \
    --name $aksName \
    --node-count 2 \
    --generate-ssh-keys \
    -o table

# obtain aks credentials

echo "Obtain AKS cluster credentials: $aksName"
az aks get-credentials --resource-group $rg --name $aksName

# setup aks for labs
echo "Setup $aksName for labs"
kubectl run faultywebserver --image=nnginx --restart=Never

kubectl create namespace fireworks

kubectl create namespace demospace
kubectl run nginx --image nginx --restart Never --namespace demospace

# clone github repository
echo "Clone GitHub repository: $github"
git clone $github ~/ckad
cd ~/ckad
code .