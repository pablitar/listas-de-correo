package listas

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors

class Usuario {
	
	@Accessors
	String emailPrincipal
	
	List<String> emails
	
	new(String mainEmail, String... extraEmails) {
		this.emailPrincipal = mainEmail
		this.emails = newArrayList(extraEmails)
		this.emails.add(this.emailPrincipal)
	}
	
	def tieneMail(String unMail) {
		this.emails.contains(unMail)
	}
	
}
	