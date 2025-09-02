public class EmailServiceQueueable implements Queueable {

    private final String recipientEmail;
    private final String subject;
    private final String body;

    // Constructor to initialize email details
    public EmailServiceQueueable(String recipientEmail, String subject, String body) {
        this.recipientEmail = recipientEmail;
        this.subject = subject;
        this.body = body;
    }

    // The execute method contains the logic that's executed when this job runs
    public void execute(QueueableContext context) {
        EmailService.send(recipientEmail, subject, body);
    }

    // Static method to easily enqueue the email job
    public static void send(String recipientEmail, String subject, String body) {
        EmailServiceQueueable job = new EmailServiceQueueable(recipientEmail, subject, body);

        // Enqueue the job
        System.enqueueJob(job);
    }
}
