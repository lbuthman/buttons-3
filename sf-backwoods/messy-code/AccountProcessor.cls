public class AccountProcessor {

    // Method to execute the process
    public static void processAccounts() {
        List<Account> accounts = [SELECT Id, Name, BillingCity, BillingState,
        (SELECT Id, Name, Quantity__c, Product__r.Name, Product__r.Weight__c
        FROM AccountProducts__r)
        FROM Account];

        for(Account acc : accounts) {
            if(acc.BillingCity != null && acc.BillingState != null) {
                // Apply discounts and modify quantities based on product types
                for(AccountProduct__c accProduct : acc.AccountProducts__r) {
                    if(accProduct.Product__r.Name == 'Widget') {
                        accProduct.Quantity__c *= 2; // Double the quantity for Widgets
                    }
                    else if(accProduct.Product__r.Name == 'Gadget') {
                        accProduct.Quantity__c *= 3; // Triple the quantity for Gadgets
                    }
                    else if(accProduct.Product__r.Name == 'Tool') {
                        accProduct.Quantity__c *= 1.5; // Increase quantity by 50% for Tools
                    }
                }

                // Update shipping details
                String formattedAddress = acc.BillingCity + ', ' + acc.BillingState;
                acc.ShippingCity = acc.BillingCity;
                acc.ShippingState = acc.BillingState;
                acc.ShippingStreet = 'Same as Billing: ' + formattedAddress;

                // Apply shipping fees
                Decimal baseShippingFee = 0;

                // Base shipping fee based on state
                if(acc.ShippingStreet == 'CA') {
                    baseShippingFee = 10;
                } else if(acc.ShippingStreet == 'NY') {
                    baseShippingFee = 15;
                } else {
                    baseShippingFee = 20;
                }

                // Additional fee based on the number of products
                Decimal additionalFee = acc.AccountProducts__r.size() * 2;
                acc.ShippingFee__c = baseShippingFee + additionalFee;

                // Apply special discount for high-value accounts
                if(acc.Total_Revenue__c > 10000) {
                    acc.ShippingFee__c *= 0.9; // Apply 10% discount
                }

                if(acc.ShippingState == 'CA') {
                    acc.ShippingFee__c -= 5;
                } else if(acc.ShippingState == 'NY') {
                    acc.ShippingFee__c -= 3;
                }

                // Apply additional fees for oversized shipments
                Decimal totalWeight = 0;
                for(AccountProduct__c accProduct : acc.AccountProducts__r) {
                    if(accProduct.Product__r.Weight__c != null) {
                        totalWeight += accProduct.Quantity__c * accProduct.Product__r.Weight__c;
                    }
                }
                if(totalWeight > 100) {
                    acc.ShippingFee__c += 20; // Apply $20 fee for orders over 100 lbs
                }

                update acc;
            } else {
                System.debug('Skipping account with missing billing information: ' + acc.Name);
            }
        }
    }
}
