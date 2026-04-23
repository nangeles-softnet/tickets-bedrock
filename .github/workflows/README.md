# Workflows

- **Plan (Amazon)**: se ejecuta en cada PR a `main` y en cada push a ramas que no sean `main`.
- **Deploy (Amazon)**: se ejecuta en cada push a `main`.
- **Frontend Plan (Amazon)**: se ejecuta en cada PR a `main` y en cada push a ramas que no sean `main` cuando cambian archivos en `frontend/`. Sólo compila para validar.
- **Frontend Deploy (Amazon)**: se ejecuta en cada push a `main` cuando cambian archivos en `frontend/`. Compila, sube los estáticos a S3 e invalida la caché de CloudFront.

| Stack    | Directorio | Secrets necesarios |
|----------|------------|--------------------|
| Amazon   | `infra`    | `AWS_ROLE_ARN`, `AWS_REGION`, opcional `TF_VARS_FILE` |
| Frontend | `frontend` | `AWS_ROLE_ARN`, `AWS_REGION`, `S3_BUCKET`, `CLOUDFRONT_DISTRIBUTION_ID` |
