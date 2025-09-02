public with sharing class ExpenseController {

    @AuraEnabled
    public static Response fetchExpenseDataByDate(Date startDate, Date endDate) {
        Response response = new Response();

        for (Mock_Expense_Data__c expenseData: [
            SELECT Expense_Type__c, Amount__c
            FROM Mock_Expense_Data__c
            WHERE Expense_Date__c >= :startDate
            AND Expense_Date__c <= :endDate
        ]) {
            Integer amount = Integer.valueOf(expenseData.Amount__c);
            if (!response.expenseTotalsByType.containsKey(expenseData.Expense_Type__c)) {
                response.expenseTotalsByType.put(expenseData.Expense_Type__c, amount);
            }
            else {
                Integer currentTotal = response.expenseTotalsByType.get(expenseData.Expense_Type__c);
                currentTotal += amount;
                response.expenseTotalsByType.put(expenseData.Expense_Type__c, currentTotal);
            }
        }

        return response;
    }

    @AuraEnabled
    public static Boolean saveImageToFile(String title, String base64Image) {
        String sanitizeBase64 = base64Image.remove('data:image/png;base64,');
        System.debug(sanitizeBase64);
        ContentVersion reportImage = new ContentVersion();
        reportImage.Title = title;
        reportImage.VersionData = EncodingUtil.base64Decode(sanitizeBase64);
        reportImage.ContentLocation= 'S';
        reportImage.PathOnClient= title + '.png';
        insert reportImage;
        return true;
    }

    public class Response {
        @AuraEnabled
        public Boolean success = true;
        @AuraEnabled
        public Map<String, Integer> expenseTotalsByType = new Map<String, Integer>();
    }
}