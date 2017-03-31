package listas

class MensajeNoPendienteException extends RuntimeException {
	
	Mensaje mensaje
	
	new(Mensaje m) {
		super("El mensaje no está pendiente. No puede ser autorizado")
		this.mensaje = m
	}
}