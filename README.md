# PoC Portal de Soporte Técnico con IA (Bedrock + RAG)

Este proyecto es una Prueba de Concepto (PoC) para un portal de soporte que utiliza **Amazon Bedrock** junto con una base de datos vectorial **LanceDB** montada en **Amazon EFS** para proporcionar respuestas precisas basadas en conocimiento técnico previo (RAG).

## 🚀 Estructura del Proyecto

- **`/backend`**: Funciones Lambda en Python 3.11 que realizan la lógica de búsqueda vectorial e invocación a Bedrock.
- **`/infra`**: Código de infraestructura como código (Terraform) para desplegar todos los recursos en AWS.
- **`/frontend`**: Aplicación Single Page Application (SPA) en React con integración a AWS Cognito.
- **`Makefile`**: Orquestador de tareas para compilación y despliegue.

## 🛠️ Requisitos Previos

- AWS CLI configurado con el perfil `softnet`.
- Terraform >= 1.5.0.
- Python 3.11 y `pip`.
- Node.js y `npm`.
- Acceso habilitado a los modelos de Anthropic (Claude Sonnet) en Amazon Bedrock (región `us-east-1`).

## 📖 Documentación Detallada

- [Documentación de Componentes](./DOCS_COMPONENTE.md)
- [Guía de Despliegue y Ejecución](./GUIA_DESPLIEGUE.md)

## ⚡ Comandos Rápidos

```bash
# Compilar todo (incluyendo capas pesadas)
make build_layer
make build_lambda

# Desplegar infraestructura
make apply_aws
```
