## Pasos Para Usar el proyecto

###  Crear el entorno virtual (venv)
 
```bash
python3 -m venv venv
```
###  Instalar las dependencias
 
```bash
pip install -r requirements.txt
```

¿Por qué cada uno?
- `pandas` / `numpy` → el motor de toda la limpieza y transformación.
- `jupyterlab` + `ipykernel` → para trabajar y documentar en notebook.
- `sqlalchemy` + `psycopg2-binary` → para conectarse a PostgreSQL en el punto 2 del caso.
- `python-dotenv` → mantener credenciales de la BD fuera del código (buenas prácticas).
- `openpyxl` → por si el entregable final se necesita en Excel/CSV.
- `matplotlib` → validar hallazgos antes de pasarlos a Metabase.

Activar el entorno virtual
 
**Linux / Mac:**
```bash
source venv/bin/activate
```
 
**Windows (PowerShell):**
```powershell
venv\Scripts\Activate.ps1
```
Sabrás que está activo porque tu terminal mostrará `(venv)` al inicio del prompt.

### Instalar las dependencias
 
```bash
pip install -r requirements.txt
```


Para el punto 3 de power bi 
Este fue el lienzo que se hizo en figma
![alt text]({DBEBF59A-BAE0-4507-9181-DC6B546A4A4E}.png)