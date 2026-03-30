# Guía de Despliegue y Ejecución - PoC Tickets Bedrock

Sigue estos pasos para poner en marcha la PoC.

## 📡 Despliegue de Infraestructura (AWS)

1.  **Configuración de Variables:**
    Edita `infra/envs_poc.tfvars` y asegúrate de poner tu `cohere_api_key`. Si tienes una VPC y EFS ya creados, rellena los IDs correspondientes. Si no, deja las listas vacías (la Lambda fallará en el paso RAG pero funcionará el resto).

2.  **Compilación de la Capa (Solo la primera vez):**
    Las dependencias de Python son pesadas. Créalas una sola vez con:
    ```bash
    make build_layer
    ```

3.  **Despliegue con Terraform:**
    ```bash
    make apply_aws
    ```
    *Nota: Esto también compilará el código de la Lambda automáticamente.*

4.  **Obtener Salidas:**
    Toma nota de los valores de `api_gateway_url`, `cognito_user_pool_id` y `cognito_client_id` que aparecerán en la terminal al finalizar.

---

## 💻 Ejecución del Frontend (Local)

1.  **Instalar dependencias:**
    ```bash
    cd frontend
    npm install
    ```

2.  **Configurar conexión:**
    Abre `frontend/src/App.js` y localiza el objeto `CONFIG`. Reemplaza los valores con los que obtuviste en el paso anterior.

3.  **Lanzar aplicación:**
    ```bash
    npm start
    ```
    La aplicación se abrirá en `http://localhost:3000`.

---

## 📦 Compilación para Producción (S3/CloudFront)

Si deseas subir el frontend a un bucket S3 para que sea público:

1.  **Generar el Build:**
    ```bash
    cd frontend
    npm run build
    ```

2.  **Subir a S3 (Manual):**
    Desde la consola de AWS o CLI, sube el contenido de la carpeta `frontend/build/` a tu bucket S3 configurado para Static Website Hosting.
    ```bash
    aws s3 sync frontend/build/ s3://tu-nombre-de-bucket-frontend --profile softnet
    ```
