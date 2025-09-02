public class OpportunityManagementLevel2 {

    public static void complexAccountMerge(List<Id> sourceAccountIds, Id targetAccountId) {
        Account targetAccount = [SELECT Id, Name, NumberOfEmployees FROM Account WHERE Id = :targetAccountId LIMIT 1];
        List<Contact> contactsToReassign = new List<Contact>();
        List<Opportunity> opportunitiesToReassign = new List<Opportunity>();
        Decimal totalEmployees = targetAccount.NumberOfEmployees;

        for (Id accountId : sourceAccountIds) {
            List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId = :accountId];
            for (Contact c : contacts) {
                c.AccountId = targetAccountId;
                contactsToReassign.add(c);
            }

            List<Opportunity> opportunities = [SELECT Id, AccountId, Amount FROM Opportunity WHERE AccountId = :accountId];
            for (Opportunity o : opportunities) {
                o.AccountId = targetAccountId;
                opportunitiesToReassign.add(o);
            }

            Account sourceAccount = [SELECT Id, NumberOfEmployees FROM Account WHERE Id = :accountId LIMIT 1];
            if (sourceAccount.NumberOfEmployees != null) {
                totalEmployees += sourceAccount.NumberOfEmployees;
            }
        }

        update contactsToReassign;
        update opportunitiesToReassign;

        targetAccount.NumberOfEmployees = Integer.valueOf(totalEmployees);
        update targetAccount;

        // Performing redundant and potentially costly operations.
        for (Contact c : contactsToReassign) {
            if (c.LastName.startsWith('A')) {
                // Some complex logic here...
            }
        }

        for (Opportunity o : opportunitiesToReassign) {
            if (o.Amount > 10000) {
                // Additional unnecessary complex logic...
            }
        }

        // Delete source accounts without considering potential implications.
        List<Account> accountsToDelete = new List<Account>();
        for (Id accountId : sourceAccountIds) {
            accountsToDelete.add(new Account(Id = accountId));
        }
        delete accountsToDelete;
    }
}
