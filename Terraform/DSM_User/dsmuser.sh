export DSMADMINAUTHDR=$(curl -k \
  -d '{"email":"thomas@broadcom.com", "password":"SecretPassword"}' \
  -H "Content-Type: application/json" -X POST \
  -i -s \
  https://10.77.10.10/provider/session | grep "Authorization: Bearer ")

curl -k -s \
 -H "$DSMADMINAUTHDR" \
 -H 'Accept: application/vnd.vmware.dms-v1+octet-stream' \
 https://<DSM-Provider>/provider/gateway-kubeconfig > dsm-admin.kubeconfig

export KUBECONFIG=dsm-admin.kubeconfig