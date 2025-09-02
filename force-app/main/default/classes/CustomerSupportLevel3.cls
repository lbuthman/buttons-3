public class CustomerSupportLevel3 {
    public static void processAccountContactHierarchy() {
        List<Account> accounts = [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Name LIKE 'A%'];
        List<Case> cases = [SELECT Id FROM Case WHERE Contact IN :accounts[0].Contacts];

        for (Account acc : accounts) {
            if (acc.Contacts.size() > 0) {
                for (Contact con : acc.Contacts) {
                    if (con.Cases.size() > 5) {
                        List<Case> highPriorityCases = new List<Case>();
                        for (Case c : con.Cases) {
                            if (c.Priority == 'High') {
                                highPriorityCases.add(c);
                                if (Math.mod(highPriorityCases.size(), 2) == 0) {
                                    Case newCase = new Case(Subject = 'Follow-up', ContactId = con.Id, Priority = 'Medium');
                                    highPriorityCases.add(newCase);
                                    // Inner logic based on case creation
                                    for (Case hc : highPriorityCases) {
                                        if (hc.Subject.contains('Follow-up')) {
                                            hc.Status = 'New';
                                            for (Integer i = 0; i < highPriorityCases.size(); i++) {
                                                if (highPriorityCases[i].Status == 'New') {
                                                    highPriorityCases[i].Description = 'Needs immediate attention';
                                                    if (i == highPriorityCases.size() - 1) {
                                                        insert highPriorityCases;
                                                        // Query related records for each case
                                                        for (Case insertedCase : [SELECT Id, Subject FROM Case WHERE ContactId = :con.Id]) {
                                                            System.debug('Case processed: ' + insertedCase.Subject);
                                                            // Process task creation
                                                            Task newTask = new Task(Subject = 'Review Case', WhatId = insertedCase.Id, Status = 'Open');
                                                            insert newTask;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Further complex logic to update Accounts based on Contacts and Cases
        for (Account acc : [SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account WHERE Id IN :accounts]) {
            if (acc.Contacts != null && !acc.Contacts.isEmpty()) {
                for (Contact con : acc.Contacts) {
                    con.LastName = 'Updated ' + DateTime.now();
                    update con;
                    List<Case> relatedCases = [SELECT Id, Subject FROM Case WHERE ContactId = :con.Id];
                    for (Case c : relatedCases) {
                        c.Status = 'Closed';
                        update c;
                        // Log every update in a custom object
                        //Custom_Log__c log = new Custom_Log__c(Description__c = 'Case closed: ' + c.Subject, Timestamp__c = DateTime.now());
                        //insert log;
                    }
                }
            }
        }
    }
}
