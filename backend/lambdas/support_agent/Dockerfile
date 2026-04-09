# Usamos Python 3.12 que se basa en Amazon Linux 2023 (incluye GCC moderno)
FROM public.ecr.aws/lambda/python:3.12

# En Python 3.12 (AL2023) dnf sustituye a yum
RUN dnf install -y gcc gcc-c++ && dnf clean all

# Copiar el archivo de requerimientos
COPY requirements.txt ${LAMBDA_TASK_ROOT}

# Actualizar pip e instalar dependencias
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copiar el código de la función
COPY lambda_function.py ${LAMBDA_TASK_ROOT}

# Comando por defecto para el handler
CMD [ "lambda_function.lambda_handler" ]
