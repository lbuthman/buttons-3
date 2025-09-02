Boolean now = true;
if (now) { Database.executeBatch(new ExperienceCreditBatcher(), 5);
    System.debug('processing experiences now');
} else { System.schedule('Experience Credits', '0 1 0 * * ?', new ExperienceCreditScheduler());
    System.debug('experiences processor scheduled');
}