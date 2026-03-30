import json
import os
import boto3
import cohere
import lancedb
from datetime import datetime
import uuid

# ==========================================
# Carga de variables de entorno (CERO HARDCODING)
# ==========================================
MODEL_ID = os.environ.get('MODEL_ID', 'us.anthropic.claude-sonnet-4-20250514-v1:0')
AWS_REGION = os.environ.get('AWS_REGION', 'us-east-1')
DYNAMODB_TABLE = os.environ.get('DYNAMODB_TABLE', 'TicketsHistory')
EFS_MOUNT_PATH = os.environ.get('EFS_MOUNT_PATH', '/mnt/efs')
COHERE_API_KEY = os.environ.get('COHERE_API_KEY')

# ==========================================
# Inicialización global (para reuso en lambdas)
# ==========================================
bedrock_runtime = boto3.client('bedrock-runtime', region_name=AWS_REGION)
dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)

# Conexión a LanceDB embebido en el EFS
try:
    db = lancedb.connect(f"{EFS_MOUNT_PATH}/lancedb")
except Exception as e:
    print(f"Error al conectar con LanceDB en EFS: {e}")
    db = None

# Cliente Cohere
co = cohere.Client(api_key=COHERE_API_KEY) if COHERE_API_KEY else None

def get_context(query_text):
    """
    Vectoriza la pregunta usando Cohere y busca similitudes en LanceDB.
    """
    if not db or not co:
        print("Atención: BD o Cliente Cohere no inicializados. Se omite RAG.")
        return ""
    
    try:
        # Generar embeddings multilingüe 
        response = co.embed(
            texts=[query_text], 
            model='embed-multilingual-v3.0', 
            input_type="search_query"
        )
        query_vector = response.embeddings[0]
        
        # Buscar en LanceDB (asumiendo tabla 'knowledge_base' precreada)
        if "knowledge_base" in db.table_names():
            tbl = db.open_table("knowledge_base")
            results = tbl.search(query_vector).limit(3).to_list()
            
            # Concatenar el texto recuperado
            context = "\n".join([res.get("text", "") for res in results])
            return context
        else:
            print("Tabla 'knowledge_base' no existe en LanceDB aún.")
            return ""
            
    except Exception as e:
        print(f"Error en recuperación RAG: {e}")
        return ""

def generate_response(query, context):
    """
    Genera la respuesta invocando el modelo fundacional en Bedrock.
    """
    prompt = f"System: Eres un asistente técnico experto en resolver problemas. Usa este contexto (si aplica) para responder: {context}\n\nHuman: {query}\n\nAssistant:"
    
    body = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 1000,
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": prompt
                    }
                ]
            }
        ]
    }
    
    # Invocación a Amazon Bedrock
    response = bedrock_runtime.invoke_model(
        modelId=MODEL_ID,
        body=json.dumps(body)
    )
    
    # Parseo de la respuesta
    response_body = json.loads(response.get('body').read())
    return response_body['content'][0]['text']

def lambda_handler(event, context_lambda):
    """
    Punto de entrada para la petición HTTP desde API Gateway.
    """
    try:
        # Parseo del body original
        body = json.loads(event.get('body', '{}'))
        query = body.get('query', '')
        
        # Extraer ID del usuario desde Authorizer (JWT)
        user_id = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('sub', 'anonymous')
        
        if not query:
            return {
                'statusCode': 400,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Credentials': True
                },
                'body': json.dumps({'error': 'La petición debe incluir el parámetro "query".'})
            }
        
        # 1. Recuperar contexto vectorial (RAG)
        kb_context = get_context(query)
        
        # 2. Generar respuesta (Bedrock)
        llm_response = generate_response(query, kb_context)
        
        # 3. Guardar persistencia en DynamoDB
        ticket_id = str(uuid.uuid4())
        timestamp = datetime.utcnow().isoformat()
        
        table.put_item(
            Item={
                'ticket_id': ticket_id,
                'user_id': user_id,
                'query': query,
                'response': llm_response,
                'timestamp': timestamp
            }
        )
        
        # Respuesta JSON exitosa
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'ticket_id': ticket_id,
                'timestamp': timestamp,
                'response': llm_response
            })
        }
        
    except Exception as e:
        print(f"Error procesando el ticket: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'Error interno procesando la solicitud', 'details': str(e)})
        }
