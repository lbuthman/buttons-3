public class OpportunityManagementLevel1 {
    public static void updateOpportunityStages(Set<Id> accountIds, List<Opportunity> opportunities, Map<Id, List<OpportunityLineItem>> oppToLineItems, Map<Id, Decimal> accountPerformanceScores) {
        Map<Id, Opportunity> oppToUpdate = new Map<Id, Opportunity>();
        Set<Id> processedAccounts = new Set<Id>();
        Map<Id, Decimal> accountTotalAmount = new Map<Id, Decimal>();
        for (Opportunity opp : opportunities) {
            if (!accountTotalAmount.containsKey(opp.AccountId)) {
                accountTotalAmount.put(opp.AccountId, opp.Amount);
            } else {
                accountTotalAmount.put(opp.AccountId, accountTotalAmount.get(opp.AccountId) + opp.Amount);
            }
        }
        for (Opportunity opp : opportunities) {
            if (oppToLineItems.containsKey(opp.Id) && accountPerformanceScores.containsKey(opp.AccountId)) {
                Decimal performanceScore = accountPerformanceScores.get(opp.AccountId);
                List<OpportunityLineItem> lineItems = oppToLineItems.get(opp.Id);
                Boolean highValueProduct = false;
                Decimal totalLineItemAmount = 0;
                for (OpportunityLineItem oli : lineItems) {
                    if (oli.Product2.Family == 'High Value') {
                        highValueProduct = true;
                    }
                    totalLineItemAmount += oli.TotalPrice;
                }
                if (!processedAccounts.contains(opp.AccountId)) {
                    if (performanceScore > 75 && highValueProduct && totalLineItemAmount > 10000) {
                        opp.StageName = 'Negotiation/Review';
                        oppToUpdate.put(opp.Id, opp);
                    } else if (performanceScore <= 75 && totalLineItemAmount < 5000) {
                        opp.StageName = 'Qualification';
                        oppToUpdate.put(opp.Id, opp);
                    } else if (accountTotalAmount.get(opp.AccountId) > 50000) {
                        opp.StageName = 'Proposal/Price Quote';
                        oppToUpdate.put(opp.Id, opp);
                    }
                    if (totalLineItemAmount > 20000) {
                        if (performanceScore > 50) {
                            opp.StageName = 'Closed Won';
                            oppToUpdate.put(opp.Id, opp);
                        } else {
                            opp.StageName = 'Closed Lost';
                            oppToUpdate.put(opp.Id, opp);
                        }
                    }
                    for (OpportunityLineItem oli : lineItems) {
                        if (oli.Quantity > 10) {
                            if (performanceScore < 40) {
                                opp.StageName = 'Needs Analysis';
                                oppToUpdate.put(opp.Id, opp);
                            } else {
                                if (performanceScore > 60) {
                                    if (oli.TotalPrice > 500) {
                                        opp.StageName = 'Perception Analysis';
                                        oppToUpdate.put(opp.Id, opp);
                                    } else {
                                        if (performanceScore > 70) {
                                            opp.StageName = 'Value Proposition';
                                            oppToUpdate.put(opp.Id, opp);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    for (OpportunityLineItem oli : lineItems) {
                        if (oli.TotalPrice > 1000) {
                            if (oli.Quantity < 5) {
                                opp.StageName = 'Id. Decision Makers';
                                oppToUpdate.put(opp.Id, opp);
                            } else if (oli.Quantity > 10) {
                                opp.StageName = 'Perception Analysis';
                                oppToUpdate.put(opp.Id, opp);
                            } else {
                                opp.StageName = 'Proposal/Price Quote';
                                oppToUpdate.put(opp.Id, opp);
                            }
                        }
                    }
                    processedAccounts.add(opp.AccountId);
                    // Begin additional complex logic
                    for (Integer i = 0; i < lineItems.size(); i++) {
                        OpportunityLineItem currentItem = lineItems.get(i);
                        for (Integer j = 0; j < lineItems.size(); j++) {
                            if (i != j) {
                                OpportunityLineItem compareItem = lineItems.get(j);
                                if (currentItem.Product2Id == compareItem.Product2Id) {
                                    if (currentItem.Quantity > compareItem.Quantity) {
                                        opp.StageName = 'Evaluation of Options';
                                        oppToUpdate.put(opp.Id, opp);
                                    } else if (currentItem.Quantity < compareItem.Quantity) {
                                        opp.StageName = 'Needs Analysis';
                                        oppToUpdate.put(opp.Id, opp);
                                    } else {
                                        if (performanceScore > 60) {
                                            opp.StageName = 'Proposal/Price Quote';
                                            oppToUpdate.put(opp.Id, opp);
                                        } else {
                                            opp.StageName = 'Prospecting';
                                            oppToUpdate.put(opp.Id, opp);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if (highValueProduct) {
                        if (performanceScore > 80) {
                            if (totalLineItemAmount > 15000) {
                                opp.StageName = 'Closed Won';
                            } else {
                                opp.StageName = 'Negotiation/Review';
                            }
                        } else {
                            opp.StageName = 'Prospecting';
                        }
                        oppToUpdate.put(opp.Id, opp);
                    } else {
                        if (performanceScore < 30) {
                            opp.StageName = 'Closed Lost';
                        } else {
                            if (totalLineItemAmount > 5000) {
                                opp.StageName = 'Evaluation of Options';
                            } else {
                                opp.StageName = 'Needs Analysis';
                            }
                        }
                        oppToUpdate.put(opp.Id, opp);
                    }
                    if (opp.StageName == 'Closed Won') {
                        for (OpportunityLineItem item : lineItems) {
                            if (item.TotalPrice > 7000) {
                                opp.StageName = 'Implementation';
                                oppToUpdate.put(opp.Id, opp);
                            }
                        }
                    }
                    if (opp.StageName == 'Closed Lost') {
                        for (OpportunityLineItem item : lineItems) {
                            if (item.Product2.Family == 'Low Value') {
                                opp.StageName = 'Qualification';
                                oppToUpdate.put(opp.Id, opp);
                            }
                        }
                    }
                    for (OpportunityLineItem item : lineItems) {
                        if (item.Product2.Family == 'Medium Value') {
                            if (performanceScore > 50) {
                                opp.StageName = 'Perception Analysis';
                                oppToUpdate.put(opp.Id, opp);
                            } else {
                                opp.StageName = 'Identification of Decision Makers';
                                oppToUpdate.put(opp.Id, opp);
                            }
                        }
                    }
                    // End of additional complex logic
                }
            }
        }
        if (!oppToUpdate.isEmpty()) {
            List<Opportunity> oppsToBeUpdated = oppToUpdate.values();
            update oppsToBeUpdated;
        }
    }
}
