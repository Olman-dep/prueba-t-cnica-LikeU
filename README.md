Aquí tienes el código completo en formato Markdown (MD), listo para que lo copies y lo pegues en tu archivo README.md.

Simplemente haz clic en el botón de "Copiar código" en la esquina superior derecha del bloque y pégalo en tu repositorio:

Markdown
# 📊 Caso Técnico: Analista de Datos - Operación Campaña WhatsApp

## 📝 Contexto del Negocio
El equipo de operaciones de nuestro BPO lanzó una campaña vía WhatsApp para motivar a los clientes a realizar pedidos. Sin embargo, se percibe fricción en la campaña: asesores saturados y falta de visibilidad sobre el éxito de las entregas. 

Este proyecto busca procesar los datos crudos transaccionales mediante herramientas **Open Source**, generando insights operativos estructurados, consultas SQL optimizadas y un dashboard para la toma de decisiones.
⚙️ Pasos para usar el proyecto
1. Crear el entorno virtual (venv)
Bash
python3 -m venv venv
2. Activar el entorno virtual
Linux / Mac:

Bash
source venv/bin/activate
Windows (PowerShell):

PowerShell
venv\Scripts\Activate.ps1
(Sabrás que está activo porque tu terminal mostrará (venv) al inicio del prompt).

3. Instalar las dependencias
Bash
pip install -r requirements.txt
¿Por qué usamos cada librería?

pandas / numpy → Motor de toda la limpieza, procesamiento y transformación de datos.

jupyterlab + ipykernel → Para trabajar y documentar la exploración en notebooks.

sqlalchemy + psycopg2-binary → Para conectarse y volcar los datos a la base de datos PostgreSQL.

python-dotenv → Mantener credenciales de la BD seguras y fuera del código (buenas prácticas).

openpyxl → Por si el entregable final se necesita exportar en Excel/CSV.

matplotlib → Validar hallazgos de manera rápida antes de pasarlos al dashboard.

📂 Desarrollo del Caso Técnico
Punto 1: Limpieza Estructural y Procesamiento (Python)
Se construyó un script/notebook en Python que toma el archivo prueba.txt crudo y realiza:

Limpieza Estructural: Manejo de delimitadores y eliminación de espacios residuales o columnas nulas generadas en los extremos.

Parsing de JSON: Extracción estructurada de errores (ej. external_error) y nombres de plantillas desde las columnas content o content_attributes para los mensajes en estado failed.

Clasificación Básica (NLP ligero): Categorización de los mensajes incoming en Soporte, Queja o Pedido buscando palabras clave dentro de los textos.

Punto 2: Extracción de Insights (SQL)
Los datos procesados se cargaron en una base de datos relacional. En los entregables se encuentran las consultas optimizadas (haciendo uso de CTEs y Window Functions, evadiendo subconsultas pesadas) para calcular:

Funnel de Entrega: Tasa de éxito de la campaña mostrando el porcentaje de mensajes salientes (outgoing) que quedaron en estado read, delivered y failed.

SLA de Respuesta Operativa: Tiempo promedio (en minutos) de reacción de los asesores ante un mensaje entrante (incoming), midiendo el intervalo hasta la siguiente acción del asesor (activity u outgoing) dentro del mismo conversation_id.

Curva de Calor Horaria: Volumen de mensajes entrantes agrupados por hora (extrayendo la hora de created_at) para apoyar el dimensionamiento de turnos (Workforce Management).

Punto 3: Dashboard y Visualización (Power BI)
Para generar acción en la operación, se diseñó un tablero interactivo consolidando los resultados, incluyendo filtros de fecha y estado sin modificar el código subyacente.

Diseño inicial de la interfaz (Figma):<img width="1115" height="824" alt="{DBEBF59A-BAE0-4507-9181-DC6B546A4A4E}" src="https://github.com/user-attachments/assets/1d234884-72e6-47c8-b725-f83fee106603" />


Resultado Final del Tablero (Power BI):<img width="964" height="544" alt="image" src="https://github.com/user-attachments/assets/1d67f799-b75c-4cad-acea-cf1bbdc1b68a" />



🧠 Visión de Negocio y Escalabilidad (Mindset FinOps)
Diagnóstico de la Campaña y Acciones Sugeridas
Analizando los resultados de los scripts, el diagnóstico para el gerente de la cuenta se centra en dos frentes principales:

Fricción por Errores Técnicos: Un porcentaje significativo de mensajes salientes cae en estado failed debido a errores capturados en los JSON (ej. external_error o plantillas rotas).

Acción Inmediata: Pausar temporalmente los envíos masivos de las plantillas con mayor tasa de error, auditar la integración con la API de WhatsApp y depurar la base de datos de números de clientes inválidos.

Saturación Operativa (SLA superado): La curva de calor muestra picos horarios donde los mensajes clasificados como Quejas o Soporte superan la capacidad operativa, disparando el SLA de respuesta del equipo.

Acción Inmediata: Redistribuir los turnos del equipo (Workforce Management) para hacer "staffing" inteligente en las horas pico identificadas y configurar un flujo de respuestas automáticas (bot básico) para contener los mensajes de la categoría Soporte, liberando a los asesores para gestionar los Pedidos que traen revenue.

Respuesta Arquitectónica de Escalabilidad (FinOps)
Si este reporte se despliega mañana y 50 usuarios lo abren simultáneamente dando clic en "Actualizar" cada cinco minutos, el servidor colapsará si consulta la base transaccional. Para mantener la solución a bajo costo sin perder rendimiento aplicaremos las siguientes estrategias técnicas:

Vistas Materializadas / Data Marts (Pre-cálculo): En lugar de que el tablero ejecute consultas pesadas (CTEs y Window Functions) contra millones de filas en vivo, orquestaremos un script programado que calcule el Funnel, SLA y la Curva de Calor en intervalos definidos (ej. cada 30 minutos) y guarde los resultados en tablas agregadas. El dashboard consumirá únicamente estas tablas ligeras.

Caché en el Motor de Visualización: Configuraremos la plataforma del dashboard para que habilite la caché de consultas. Así, las recargas simultáneas consumirán la memoria de la herramienta de visualización y no golpearán la base de datos.

Indexación Estratégica: Asegurar la creación de índices (ej. B-Tree) en la base de datos sobre las columnas más usadas para filtros y cruces (created_at, status, message_type, conversation_id), reduciendo los escaneos de tabla completa (Full Table Scans).
