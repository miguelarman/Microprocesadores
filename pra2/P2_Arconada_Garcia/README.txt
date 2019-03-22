Autores: Miguel Arconada Manteca
	 Mario García Pascual

A la hora de introducir los datos por teclado le decimos al usuario
que sólo puede introducir números de dos dígitos positivos o negativos,
debido a la restricción de que los números han de estar entre -16 y 15.
Por esto, el tamaño de buffer de input que hemos puesto es de 36 bytes,
esto es, 3*9 + 8 + 1, que son 9 números de 3 caracteres como máximo cuando
sean 9 números negativos de dos dígitos, 8 comas y el retorno de carro. Por
como está hecha la función de tomar input del usuario, si se introducen los
36 caracteres ya no detecta más, ni siquiera el retorno de carro, por tanto
el último (si se ha llegado a 35 caracteres) siempre ha de reservarse
para el retorno de carro.
Si se introducen más de 9 datos correctos el programa
tomará los 9 primeros para su ejecución.