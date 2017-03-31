package listas

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

class ListaDeCorreo {
	
	
	val MailSenderAdapter mailAdapter
	
	val List<Usuario> miembros = newArrayList()
	@Accessors
	val List<Mensaje> mensajesPendientes = newArrayList()
	
	val List<MensajeEnviadoObserver> interesados = newArrayList()
	
	val Usuario administrador 
	
	ModoEnvio modoEnvio = ModoEnvio.ABIERTA
	ModoModeracion modoModeracion = ModoModeracion.NO_MODERADA
	
	val String direccion
	
	new(MailSenderAdapter mailAdapter, Usuario administrador, String direccion) {
		this.mailAdapter = mailAdapter
		this.administrador = administrador
		this.direccion = direccion
	}
	
	def agregarUsuario(Usuario usuario) {
		this.miembros.add(usuario)
	}
	
	def enviarMensaje(Mensaje mensaje) {
		modoEnvio.validaMensaje(mensaje, this)
		this.modoModeracion.enviarMensaje(mensaje, this)
	}
	
	def configurarCerrada() {
		this.modoEnvio = ModoEnvio.CERRADA
	}
	
	def esMiembro(String mail) {
		miembros.exists[it.tieneMail(mail)]
	}
	
	def agregarMensajePendiente(Mensaje mensaje) {
		this.mensajesPendientes.add(mensaje)
		this.mailAdapter.enviarMensaje(newArrayList(administrador), notificacionMensajeNuevo(mensaje))
	}
	
	def notificacionMensajeNuevo(Mensaje mensaje) {
		new Mensaje(direccion, '''Mensaje nuevo para revisar («mensajesPendientes.size» pendientes)''',
			mensaje.titulo + "\n" + mensaje.cuerpo, mensaje.attachments 
		)
	}
	
	def doEnviarMensaje(Mensaje mensaje) {
		this.mailAdapter.enviarMensaje(miembros, mensaje);
		this.interesados.forEach[it.onMensajeEnviado(mensaje)]
	}
	
	def configurarModerada() {
		this.modoModeracion = ModoModeracion.MODERADA
	}
	
	def autorizarMensaje(Mensaje mensaje) {	 
		if(!this.mensajesPendientes.remove(mensaje)) throw new MensajeNoPendienteException(mensaje)
		this.doEnviarMensaje(mensaje)
	}
	
	def agregarInteresado(MensajeEnviadoObserver observer) {
		this.interesados.add(observer)
	}
	
	def quitarInteresado(MensajeEnviadoObserver observer) {
		this.interesados.remove(observer)
	}
	
}

abstract class ModoEnvio {
	
	def validaMensaje(Mensaje mensaje, ListaDeCorreo lista) {
		if(!aceptaMensaje(mensaje, lista)) {
			throw new MensajeRechazadoException(mensaje)
		}
	}
	def boolean aceptaMensaje(Mensaje mensaje, ListaDeCorreo lista)
	
	static public val ABIERTA = new ModoAbierta
	static public val CERRADA = new ModoCerrada
}

class ModoAbierta extends ModoEnvio {
	override aceptaMensaje(Mensaje mensaje, ListaDeCorreo lista) {
		true
	}
}

class ModoCerrada extends ModoEnvio {
	override aceptaMensaje(Mensaje mensaje, ListaDeCorreo lista) {
		lista.esMiembro(mensaje.de)
	}
}

abstract class ModoModeracion {
	def void enviarMensaje(Mensaje mensaje, ListaDeCorreo lista)
	
	static public val NO_MODERADA = new ModoNoModearada
	static public val MODERADA = new ModoModerada
}

class ModoNoModearada extends ModoModeracion {
	override enviarMensaje(Mensaje mensaje, ListaDeCorreo lista) {
		lista.doEnviarMensaje(mensaje)
	}
}

class ModoModerada extends ModoModeracion {
	override enviarMensaje(Mensaje mensaje, ListaDeCorreo lista) {
		lista.agregarMensajePendiente(mensaje)
	}
}