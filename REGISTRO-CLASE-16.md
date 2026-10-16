# Registro – Clase 16: estado remoto y ambientes

Continuación de la clase 15 (módulo `network`). Región: `northcentralus`.

## Parte A – Preparar el backend

| Recurso | Valor |
|---|---|
| Resource Group | `rg-tfstate-dev` |
| Storage Account | `sttfstate20235722` (Standard_LRS, StorageV2, sin acceso público a blobs) |
| Container | `tfstate` |
| Rol | `Storage Blob Data Contributor` sobre el Storage Account, asignado al usuario |

```bash
az group create --name rg-tfstate-dev --location northcentralus
az storage account create --name sttfstate20235722 --resource-group rg-tfstate-dev \
  --location northcentralus --sku Standard_LRS --kind StorageV2 --allow-blob-public-access false
az role assignment create --assignee-object-id "$USER_OBJECT_ID" --assignee-principal-type User \
  --role "Storage Blob Data Contributor" --scope "$STORAGE_ACCOUNT_ID"
az storage container create --name tfstate --account-name sttfstate20235722 --auth-mode login
```

Verificación de permisos: `az storage blob list --account-name sttfstate20235722 -c tfstate --auth-mode login` devuelve los blobs.

## Parte B – Migrar el state de desarrollo

Antes de migrar, `terraform plan` → `No changes.`

`terraform state list` (antes y después de la migración, idéntico):

```
azurerm_resource_group.main
module.network.azurerm_subnet.main["application"]
module.network.azurerm_subnet.main["data"]
module.network.azurerm_virtual_network.main
```

```hcl
# backend.tf
terraform {
  backend "azurerm" {
    use_azuread_auth = true
    use_cli          = true
  }
}
```

```hcl
# backend.hcl
storage_account_name = "sttfstate20235722"
container_name       = "tfstate"
key                  = "orders-development.tfstate"
```

Comando: `terraform init -migrate-state -force-copy -backend-config=backend.hcl`
(`-force-copy` porque la sesión no era interactiva; evita la pregunta de confirmación).

Después de migrar, `terraform plan` → `No changes.`

**Ubicación del blob:** `sttfstate20235722` / `tfstate` / `orders-development.tfstate` (Resource Group `rg-tfstate-dev`).
