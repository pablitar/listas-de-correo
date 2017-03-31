package listas

import java.util.Arrays
import org.junit.Assert
import org.junit.Before
import org.junit.Test
import com.google.common.collect.Iterables

class ListaDeCorreoSuite {

	static val MEMBER_MAIL = "pablo@pablo.com"
	static val ADMIN_MAIL = "admin@pablo.com"
	static val LIST_MAIL = "lista@ciu.edu.ar"

	val testAdapterPair = TestMailSender.createAdapter()
	val usuario = crearUsuario(MEMBER_MAIL)
	val admin = crearUsuario(ADMIN_MAIL)
	val lista = new ListaDeCorreo(testAdapterPair.key, admin, LIST_MAIL)

	@Before
	def void setUp() {
		lista.agregarUsuario(usuario)
	}

	@Test
	def void unaListaAbiertaRecibeMailDeCualquierLado() {
		val mensaje = unMensaje("noenlista@ciu.edu.ar")
		lista.enviarMensaje(mensaje)
		assertMensajeEnviado(mensaje, usuario)
	}

	@Test(expected=MensajeRechazadoException)
	def void unaListaCerradaNoAceptaMailsDeCualquierLado() {
		lista.configurarCerrada()
		val mensaje = unMensaje("noenlista@ciu.edu.ar")
		lista.enviarMensaje(mensaje)
	}

	@Test
	def void unaListaCerradaAceptaMailsDeSusMiembros() {
		lista.configurarCerrada()
		val mensaje = unMensaje(MEMBER_MAIL)
		lista.enviarMensaje(mensaje)

		assertMensajeEnviado(mensaje, usuario)
	}

	@Test
	def void unaListaModeradaNoEnviaElEmailInmediatamente() {
		lista.configurarModerada()

		val mensaje = unMensaje(MEMBER_MAIL)
		lista.enviarMensaje(mensaje)

		assertMensajeEnviado(
			Mensaje.crear(LIST_MAIL, "Mensaje nuevo para revisar (1 pendientes)", "Un Titulo\nUn Cuerpo"), admin)
		assertMensajePendiente(mensaje)
	}

	@Test
	def void unaListaModeradaEnviaUnaVezAutorizado() {
		lista.configurarModerada()

		val mensaje = unMensaje(MEMBER_MAIL)
		lista.enviarMensaje(mensaje)
		lista.autorizarMensaje(mensaje)

		assertMensajeEnviado(mensaje, usuario)
		assertMensajeNoPendiente(mensaje)
	}

	@Test
	def void unaListaDeCorreoGuardaKeywords() {
		val observer = PalabrasClaveObserver.porDefecto()
		lista.agregarInteresado(observer)
		lista.enviarMensaje(unMensaje(MEMBER_MAIL))
		val msgBomba = unMensaje(MEMBER_MAIL, "bomba")
		lista.enviarMensaje(msgBomba)
		
		Assert.assertArrayEquals(#[msgBomba], observer.mensajesRegistrados)
	}
	
	@Test
	def void unaListaDeCorreoGuardaEstadisticas() {
		val observer = new ContadorMensajesObserver()
		lista.agregarInteresado(observer)
		
		(1..4).forEach [lista.enviarMensaje(unMensaje("masActivo1@gmail.com"))]
		(1..3).forEach [lista.enviarMensaje(unMensaje("masActivo2@gmail.com"))]
		(1..2).forEach [lista.enviarMensaje(unMensaje("masActivo3@gmail.com"))]
		
		lista.enviarMensaje(unMensaje(MEMBER_MAIL))
		
		Assert.assertArrayEquals(#["masActivo1@gmail.com", "masActivo2@gmail.com"], Iterables.toArray(observer.usuariosMasActivos(2), String))
	}

	def assertMensajePendiente(Mensaje mensaje) {
		Assert.assertTrue(this.lista.mensajesPendientes.contains(mensaje))
	}

	def assertMensajeNoPendiente(Mensaje mensaje) {
		Assert.assertFalse(this.lista.mensajesPendientes.contains(mensaje))
	}

	def assertMensajeEnviado(Mensaje mensaje, Usuario usuario) {
		Assert.assertTrue(testAdapterPair.value.sentMails.exists [
			it.tos.contains(usuario.emailPrincipal) && it.title == mensaje.titulo && it.body == mensaje.cuerpo &&
				Arrays.equals(it.attachments, mensaje.attachments)
		])
	}

	def unMensaje(String from) {
		unMensaje(from, "Un Titulo")
	}

	def unMensaje(String from, String titulo) {
		unMensaje(from, titulo, "Un Cuerpo")
	}

	def unMensaje(String from, String titulo, String cuerpo) {
		Mensaje.crear(from, titulo, cuerpo)
	}

	def crearUsuario(String direccion) {
		new Usuario(direccion)
	}

}
