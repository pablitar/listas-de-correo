package listas

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Map

interface MensajeEnviadoObserver {
	def void onMensajeEnviado(Mensaje mensaje)
}

class PalabrasClaveObserver implements MensajeEnviadoObserver {
	val List<String> palabras
	@Accessors
	val List<Mensaje> mensajesRegistrados = newArrayList()

	new(String... palabras) {
		this.palabras = newArrayList(palabras)
	}

	static def porDefecto() {
		new PalabrasClaveObserver("bomba", "nos estan escuchando", "fafafa", "terrorismo")
	}
	
	override onMensajeEnviado(Mensaje mensaje) {
		if(palabras.exists[
			mensaje.cuerpo.contains(it) || mensaje.titulo.contains(it)
		]) {
			this.mensajesRegistrados.add(mensaje)
		}
	}
	
}

class ContadorMensajesObserver implements MensajeEnviadoObserver {
	
	val Map<String, Integer> cuenta = newHashMap()
	override onMensajeEnviado(Mensaje mensaje) {
	
		if(!cuenta.containsKey(mensaje.de)) {
			cuenta.put(mensaje.de, 1)
		} else {
			cuenta.put(mensaje.de, cuenta.get(mensaje.de) + 1)
		}
	}
	
	def usuariosMasActivos(Integer cantidad) {
		cuenta.entrySet.sortBy[-it.value].map[it.key].take(cantidad)
	}
	
}
