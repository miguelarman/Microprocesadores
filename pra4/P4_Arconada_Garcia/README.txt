Autores: Miguel Arconada Manteca
	 Mario García Pascual

Consideraciones generales:

- El fichero p4a.com instala y desinstala el driver necesario para ejecutar el programa p4b.exe. Si no se instala antes de ejecutar, la interrupción no tiene código asignado, por lo que para el funcionamiento.

- El fichero p4a2.com instala y desinstala los drivers necesarios para ejecutar el programa p4c.exe. Si no se instalan antes de ejecutar, las interrupciones no tienen código asignado, por lo que para el funcionamiento.

Lo instaladores guardan el valor anterior del vector de interrupciones. Esto lo podemos comprobar fácilmente, ya que si ejecutamos p4a.com instalando el driver, después ejecutamos p4a2.com instalando, guarda el valor del vector de interrupción de p4a.com. Se ve ya que si ahora p4a2.com desinstala, queda instalado lo anterior (por p4a.com)