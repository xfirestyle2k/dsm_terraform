VIADMINAUTHHDR=$(curl -k \
    -d '{"username":"'administrator@vsphere.local'", "password":"'SecretPassword1!'"}' \
    -H "Content-Type: application/json" -X POST \
    -i -s \
    https://<DSM-Provider>/provider/plugin/session-using-vc-credentials | grep "Authorization: Bearer ")

curl -k -s \
 -H "$VIADMINAUTHHDR" \
 -H 'Accept: application/vnd.vmware.dms-v1+octet-stream' \
 https://<DSM-Provider>/provider/gateway-kubeconfig > dsm-viadmin.kubeconfig

export KUBECONFIG=dsm-viadmin.kubeconfig