package listas

import java.io.File
import org.eclipse.xtend.lib.annotations.Data

@Data
class Mensaje {
	String de
	String titulo
	String cuerpo
	File[] attachments
	
	static def crear(String de, String titulo, String cuerpo) {
		new Mensaje(de, titulo, cuerpo, #[])
	}
}