Autores: Miguel Arconada Manteca
	 Mario Garc�a Pascual

Consideraciones generales:

- El fichero p4a.com instala y desinstala el driver necesario para ejecutar el programa p4b.exe. Si no se instala antes de ejecutar, la interrupci�n no tiene c�digo asignado, por lo que para el funcionamiento.

- El fichero p4a2.com instala y desinstala los drivers necesarios para ejecutar el programa p4c.exe. Si no se instalan antes de ejecutar, las interrupciones no tienen c�digo asignado, por lo que para el funcionamiento.

Lo instaladores guardan el valor anterior del vector de interrupciones. Esto lo podemos comprobar f�cilmente, ya que si ejecutamos p4a.com instalando el driver, despu�s ejecutamos p4a2.com instalando, guarda el valor del vector de interrupci�n de p4a.com. Se ve ya que si ahora p4a2.com desinstala, queda instalado lo anterior (por p4a.com)