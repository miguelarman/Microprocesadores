Autores: Miguel Arconada Manteca
	 Mario Garc�a Pascual

A la hora de introducir los datos por teclado le decimos al usuario
que s�lo puede introducir n�meros de dos d�gitos positivos o negativos,
debido a la restricci�n de que los n�meros han de estar entre -16 y 15.
Por esto, el tama�o de buffer de input que hemos puesto es de 36 bytes,
esto es, 3*9 + 8 + 1, que son 9 n�meros de 3 caracteres como m�ximo cuando
sean 9 n�meros negativos de dos d�gitos, 8 comas y el retorno de carro. Por
como est� hecha la funci�n de tomar input del usuario, si se introducen los
36 caracteres ya no detecta m�s, ni siquiera el retorno de carro, por tanto
el �ltimo (si se ha llegado a 35 caracteres) siempre ha de reservarse
para el retorno de carro.
Si se introducen m�s de 9 datos correctos el programa
tomar� los 9 primeros para su ejecuci�n.