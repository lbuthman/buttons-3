List<CronTrigger> scheduledJobs = [
    SELECT Id
    FROM CronTrigger
    WHERE CronJobDetail.Name IN (
        'Experience Credits'
    )];
for (CronTrigger job : scheduledJobs) {
    System.abortJob(job.Id);
}