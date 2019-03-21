Autores: Miguel Arconada Manteca
	 Mario García Pascual

A la hora de introducir los datos por teclado le decimos al usuario
que solo puede introducir numeros de dos digitos positivos o negativos,
debido a la restricción de que los numeros han de estar entre -16 y 15.
Por esto, el tamaño de buffer de input que hemos puesto es de 36 bytes,
esto es, 3*9 + 8, que son 9 numeros de 3 caracteres como maximo cuando
sean 9 numeros negativos de dos digitos, y 8 comas.