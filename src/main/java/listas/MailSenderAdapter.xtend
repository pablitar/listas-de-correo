package listas

import external.MailSender
import java.util.Collection
import com.google.common.collect.Iterables
import org.eclipse.xtend.lib.annotations.Accessors

class MailSenderAdapter {
	
	@Accessors
	MailSender mailSender
	
	new(MailSender mailSender) {
		this.mailSender = mailSender
	}
	
	def enviarMensaje(Collection<Usuario> destinatarios, Mensaje m) {
		val mails = destinatarios.map[it.emailPrincipal]
		if(destinatarios.size() == 1) {
			this.mailSender.sendEmail(mails.iterator.next, m.titulo, m.cuerpo, m.attachments)
		} else {
			this.mailSender.sendEmail(Iterables.toArray(mails, String), m.titulo, m.cuerpo, m.attachments)
		}
		
	}
	
}