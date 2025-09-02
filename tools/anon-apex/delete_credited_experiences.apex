Adventurer__c adventurer = UtilityService.getCurrentAdventurer();

List<Experience__c> experiences = [
    SELECT Id
    FROM Experience__c
    WHERE Adventurer__c = :adventurer.Id
    AND Credited__c = TRUE
];
System.debug('experiences.size()=' + experiences.size());

delete experiences;
Database.emptyRecycleBin(experiences);