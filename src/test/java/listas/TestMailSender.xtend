package listas

import external.MailSender
import java.io.File
import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.Accessors

class TestMailSender extends MailSender {
	
	@Accessors
	val sentMails = new ArrayList<SentMail>()
	
	override sendEmail(String to, String title, String body, File[] attachments) {
		sentMails.add(new SentMail(#[to], title, body, attachments))
	}
	
	override sendEmail(String[] tos, String title, String body, File[] attachments) {
		sentMails.add(new SentMail(tos, title, body, attachments))
	}
	
	def static createAdapter() {
		val testMailSender = new TestMailSender()
		new MailSenderAdapter(testMailSender) -> testMailSender
	}
	
}

@Data
class SentMail {
	String[] tos; String title; String body; File[] attachments 
}