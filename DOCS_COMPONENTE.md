# Documentación de Componentes - PoC Tickets Bedrock

A continuación se detalla el funcionamiento de cada pieza del rompecabezas arquitectónico.

## 1. Backend (Python + RAG)

El backend reside en `backend/lambdas/support_agent`. Su núcleo es `lambda_function.py`.

- **Vectorización:** Utiliza el modelo multilingüe de **Cohere** para convertir la consulta del usuario en un vector numérico.
- **LanceDB (RAG):** Se conecta a una base de datos vectorial embebida almacenada en `/mnt/efs`. Esto permite persistencia de conocimiento sin necesidad de un servidor de base de datos dedicado (Managed Service).
- **Generación:** Envía el contexto recuperado y la pregunta al modelo **Claude Sonnet** en Bedrock.
- **Cero Hardcoding:** No hay una sola credencial o ID en el código. `os.environ` maneja todo, alimentado por Terraform.

## 2. Infraestructura (Terraform)

Organizada por recursos para facilitar el mantenimiento:

- **Cognito (`cognito.tf`):** Gestiona la autenticación de usuarios. Está configurado para integrarse directamente con la SPA de React.
- **API Gateway (`api_endpoints.tf`, `api-gateway.tf`):** Expone el endpoint `/ticket`. Utiliza un autorizador de Cognito para proteger la ruta y maneja CORS de forma nativa.
- **Lambda (`lambdas.tf`, `/modules`):** Definición modular. Implementa **Lambda Layers** para separar las librerías pesadas (`cohere`, `lancedb`) del código de negocio, acelerando los despliegues posteriores.
- **DynamoDB (`tables_dynamoDB.tf`):** Tabla `TicketsHistoryPoC` que registra cada interacción para auditoría y mejora del modelo.

## 3. Frontend (React)

- **Auth:** Utiliza `amazon-cognito-identity-js`. El flujo es 100% cliente; no requiere un servidor intermedio para el login.
- **Chat Interface:** Un componente reactivo que envía el JWT (Token de Identidad) en el header `Authorization`.
- **Diseño:** Basado en componentes funcionales modernos para una experiencia de usuario fluida.
