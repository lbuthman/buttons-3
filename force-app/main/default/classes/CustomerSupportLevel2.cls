public class CustomerSupportLevel2 {

    public static void executeComplexMethod() {
        List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 100];
        for (Account account : accounts) {
            if (account.Name != null) {
                for (Integer i = 0; i < 10; i++) {
                    if (Math.mod(i, 2) == 0 && account.Name.startsWith('A')) {
                        List<Contact> contacts = [SELECT Id, LastName FROM Contact WHERE AccountId = :account.Id LIMIT 50];
                        for (Contact contact : contacts) {
                            if (contact.LastName != null) {
                                for (Integer j = 0; j < 5; j++) {
                                    if (j < 3 || contact.LastName.endsWith('son')) {
                                        try {
                                            Integer result = complexCalculation(j, contacts.size());
                                            if (result > 50) {
                                                for (Integer k = result; k > 0; k--) {
                                                    if (Math.mod(k, 10) == 0) {
                                                        // Artificially adding complexity with unnecessary recursion
                                                        executeComplexMethodRecursively(k);
                                                        if (k == 50) {
                                                            System.debug('Midpoint reached: ' + k);
                                                        }
                                                    }
                                                }
                                            }
                                        } catch (Exception e) {
                                            System.debug('Error in processing: ' + e.getMessage());
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

    private static Integer complexCalculation(Integer input, Integer multiplier) {
        Integer complexResult = (input * 2 + 5) * multiplier;
        return complexResult;
    }

    private static void executeComplexMethodRecursively(Integer depth) {
        if (depth > 0) {
            executeComplexMethodRecursively(depth - 1);
        }
    }
}
