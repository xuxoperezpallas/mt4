Para utilizar el programa basado en inteligencia artificial:

1. Instalar prophet desde su pagina de github:

https://facebook.github.io/prophet/
 
2. Descargar en mt4 desde la pestaña  herramientas->centro de historiales. los datos históricos diarios de la divisa en cuestión y exportar a csv

3. Seleccionar los últimos ocho años (aproximadamente).

4. Eliminar la columna de horas, y la ultima columna también.

5. Y  aplicarle el formato de la primara fila del archivo de ejemplo, de modo que el csv quede con el formato del archivo de ejemplo.

6. Cambiar el nombre del archivo de ejemplo, y renombrar el archivo creado a "datos.csv"

7. Ejecutar desde cmd (consola de Windows)  python3 main.py

7. Es posible que tambien haya que instalar matplotlib y pyplot. Para ello ejecutamos desde na terminal o desde la consola de windows:

   7.1 python3 -m pip install matplotlib
   7.2 python3 -m pip install pyplot
