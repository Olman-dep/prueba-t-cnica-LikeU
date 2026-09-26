# 📊 Caso Técnico: Analista de Datos — Operación Campaña WhatsApp

## 📝 Contexto del Negocio

El equipo de operaciones de nuestro BPO lanzó una campaña vía WhatsApp para motivar a los clientes a realizar pedidos. Sin embargo, se percibe fricción en la campaña: asesores saturados y falta de visibilidad sobre el éxito de las entregas.

Este proyecto procesa los datos crudos transaccionales usando herramientas **Open Source y de bajo costo**, generando insights operativos estructurados, consultas SQL optimizadas y un dashboard para la toma de decisiones.

---

## 📂 Estructura del repositorio

```
├── data/
│   └── prueba.txt                  # Extracto crudo del sistema transaccional
├── notebooks/
│   └── Caso_Tecnico_Punto1.ipynb   # Limpieza, parsing de JSON, clasificación y carga a MySQL
├── sql/
│   └── consultas_punto2.sql        # Funnel, SLA y curva de calor horaria
├── dashboard/
│   └── caso_tecnico.pbix           # Tablero en Power BI
├── requirements.txt
└── README.md
```

---

## ⚙️ Pasos para usar el proyecto

### 1. Crear el entorno virtual

```bash
python3 -m venv venv
```

### 2. Activar el entorno virtual

**Linux / Mac:**
```bash
source venv/bin/activate
```

**Windows (PowerShell):**
```powershell
venv\Scripts\Activate.ps1
```
> Si PowerShell bloquea el script por política de ejecución, corre una vez `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` antes de activar.

Sabrás que está activo porque tu terminal mostrará `(venv)` al inicio del prompt.

### 3. Instalar las dependencias

```bash
pip install -r requirements.txt
```

**¿Por qué usamos cada librería?**

| Librería | Uso |
|---|---|
| `pandas` / `numpy` | Motor de la limpieza, procesamiento y transformación de datos |
| `jupyterlab` + `ipykernel` | Trabajar y documentar la exploración en notebooks |
| `sqlalchemy` + `pymysql` | Conectarse y volcar los datos a la base de datos **MySQL** |
| `cryptography` | Requerido por `pymysql` para el método de autenticación `caching_sha2_password` de MySQL 8 |
| `python-dotenv` | Mantener credenciales de la BD fuera del código (buenas prácticas) |
| `openpyxl` | Exportar/leer resultados auxiliares en Excel |
| `matplotlib` | Validar hallazgos rápidamente antes de pasarlos al dashboard |

### 4. Base de datos

Crea una base MySQL 8.0+ local llamada `pruebatecnica` y un archivo `.env` en la raíz del proyecto:

```
DB_USER=root
DB_PASSWORD=tu_password
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=pruebatecnica
```

Corre el notebook de punto 1 de principio a fin: limpia el archivo crudo, extrae los errores/plantillas desde JSON, clasifica los mensajes entrantes y carga el resultado en la tabla `mensajes`.

---

## 🔍 Desarrollo del Caso Técnico

### Punto 1: Limpieza Estructural y Procesamiento (Python)

El notebook toma `prueba.txt` crudo y realiza:

- **Limpieza Estructural:** manejo del delimitador correcto y eliminación de espacios residuales o columnas nulas generadas en los extremos.
- **Parsing de JSON:** extracción estructurada de errores (`external_error`) y nombres de plantilla desde las columnas `content` / `content_attributes` para los mensajes en estado `failed`.
- **Clasificación básica (NLP ligero):** categorización de los mensajes `incoming` en *Soporte*, *Queja* o *Pedido* buscando palabras clave en el texto.
- **Carga a MySQL:** el DataFrame resultante se sube a la tabla `mensajes` de la base `pruebatecnica` vía SQLAlchemy.

### Punto 2: Extracción de Insights (SQL)

Consultas optimizadas en `sql/consultas_punto2.sql`, usando CTEs y Window Functions y evitando subconsultas pesadas:

- **Funnel de Entrega:** porcentaje de mensajes salientes (`outgoing`) por estado (`read`, `delivered`, `sent`, `failed`), calculado con `SUM(COUNT(*)) OVER ()` en vez de un `SELECT` anidado.
- **SLA de Respuesta Operativa:** tiempo promedio (en minutos) entre un mensaje `incoming` y la siguiente acción del asesor (`activity` u `outgoing`) dentro del mismo `conversation_id`, usando `LEAD()` sobre la ventana particionada por conversación.
- **Curva de Calor Horaria:** volumen de mensajes `incoming` agrupado por hora (`HOUR(created_at)`), para dimensionar turnos de Workforce Management.

### Punto 3: Dashboard y Visualización (Power BI)

Tablero interactivo que consolida los tres insights del punto 2, con filtros de **fecha** y **estado** aplicables sin tocar el código subyacente (segmentadores de datos nativos de Power BI sobre la tabla `mensajes`).

**Diseño inicial de la interfaz (Figma):**
<img width="1115" height="824" alt="{DBEBF59A-BAE0-4507-9181-DC6B546A4A4E}" src="https://github.com/user-attachments/assets/1d234884-72e6-47c8-b725-f83fee106603" />

**Resultado final del tablero (Power BI):**
<img width="964" height="544" alt="image" src="https://github.com/user-attachments/assets/1d67f799-b75c-4cad-acea-cf1bbdc1b68a" />


> ⚠️ Reemplaza la URL de arriba: al subir la imagen a un issue o PR de GitHub, copia el link `https://github.com/user-attachments/assets/...` que se genera automáticamente — el nombre de archivo entre llaves (`{456CB612-...}`) no es una URL válida y no va a renderizar.

---

## 🧠 Visión de Negocio y Escalabilidad (Mindset FinOps)

### Diagnóstico de la campaña y acciones sugeridas

**1. Fricción por errores técnicos**

Un porcentaje significativo de mensajes salientes cae en estado `failed` (más de la mitad del total en la muestra analizada), con causas identificables en los JSON parseados (`external_error`, plantillas específicas).

> **Acción inmediata:** pausar temporalmente el envío de las plantillas con mayor tasa de error, auditar la integración con la API de WhatsApp, y depurar la base de números de clientes inválidos antes de reanudar la campaña.

**2. Saturación operativa (SLA superado)**

La curva de calor horaria muestra picos donde los mensajes clasificados como *Queja* o *Soporte* concentran el volumen entrante, presionando el tiempo de respuesta del equipo.

> **Acción inmediata:** redistribuir turnos (Workforce Management) hacia las horas pico identificadas, y configurar respuestas automáticas básicas para contener *Soporte* de primer nivel, liberando a los asesores para atender *Pedidos* (que generan revenue directo).

### Respuesta arquitectónica de escalabilidad (FinOps)

Si el reporte se despliega y 50 usuarios lo abren simultáneamente refrescando cada 5 minutos, consultar la base transaccional en vivo colapsaría el servidor. Estrategia para mantener bajo costo sin perder rendimiento:

- **Vistas materializadas / data marts (pre-cálculo):** en vez de que el dashboard ejecute las CTEs y Window Functions contra la tabla cruda en cada refresco, un job programado (cron o *scheduled task*) calcula Funnel, SLA y Curva de Calor cada cierto intervalo (ej. 30 min) y guarda el resultado en tablas agregadas ligeras. El dashboard consume solo esas tablas.
- **Modo Import en vez de DirectQuery:** Power BI en modo *Import* ya cachea los datos en su propio motor (VertiPaq) tras cada actualización programada, así que los 50 usuarios consultan la caché de Power BI, no la base MySQL en vivo — esto por sí solo evita gran parte del problema.
- **Indexación estratégica:** índices sobre `created_at`, `status`, `message_type` y `conversation_id` en MySQL, que son las columnas más usadas en filtros y joins, reduciendo *full table scans* en el job de pre-cálculo.
- **Costo de licenciamiento de Power BI (punto que el enunciado de FinOps exige no pasar por alto):** compartir un reporte publicado con 50 usuarios simultáneos requiere licencias Power BI Pro por usuario o capacidad Premium — ninguna de las dos es gratis a esa escala. Alternativas de costo real cero para mantener la solución 100% open source: auto-hospedar **Metabase** (que además soporta filtros SQL nativos y cache de consultas) o distribuir el `.pbix` con actualización programada solo para un grupo reducido de supervisores, en vez de acceso masivo vía Power BI Service.

---

## 📦 Entregables

- [x] Notebook de Python documentado (limpieza, parsing JSON, clasificación, carga a MySQL)
- [x] Archivo `.sql` con las tres consultas del punto 2
- [ ] Video breve (máx. 5 min) presentando el dashboard, hallazgos de negocio y respuesta de escalabilidad

## 👤 Autor

_Completa con tu nombre y contacto._