public class EmailService {

    @Future
    public static void sendEmailAsync(String recipientEmail, String subject, String body) {
        // Create a new email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // Set the recipient's email address
        String[] toAddresses = new String[]{recipientEmail};
        mail.setToAddresses(toAddresses);

        // Set the email subject and body
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }

    // Call this method to send an email asynchronously
    public static void send(String recipientEmail, String subject, String body) {
        // Call the asynchronous method
        sendEmailAsync(recipientEmail, subject, body);
    }
}
