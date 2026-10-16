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

## Parte C – Separar los ambientes

Estructura:

```
modules/network/          main, variables, outputs, versions.tf
environments/
├── development/          main, variables, outputs, backend.tf, backend.hcl, terraform.tfvars
└── production/           igual, con key y red propias
```

El módulo de `development` usa `source = "../../modules/network"` y conserva la key ya migrada (`orders-development.tfstate`), así que no se creó una segunda copia de la infraestructura.

Puntos de control (`terraform init -backend-config=backend.hcl`, `state list`, `plan`):

| | development | production |
|---|---|---|
| Key | `orders-development.tfstate` | `orders-production.tfstate` |
| Red | `10.10.0.0/16` | `10.20.0.0/16` |
| `state list` | Las mismas 4 direcciones de antes de reorganizar | Vacío (state nuevo) |
| `plan` | `No changes.` | `4 to add, 0 to change, 0 to destroy` (RG, VNet y 2 subnets) |

`production` todavía no se ha aplicado.
