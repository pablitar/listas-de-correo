package listas

class MensajeRechazadoException extends RuntimeException {
	
	Mensaje mensaje
	
	new(Mensaje m) {
		super("No se puede enviar el mensaje a los destinatarios")
		this.mensaje = m
	}
}