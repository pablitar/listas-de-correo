package external

import java.io.File

abstract class MailSender {
	def static MailSender createInstance() {
		throw new UnsupportedOperationException()
	}
	
	def void sendEmail(String to, String title, String body, File[] attachments)
	def void sendEmail(String[] tos, String title, String body, File[] attachments)
}