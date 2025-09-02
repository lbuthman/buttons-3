public class TA_Opportunity_StageInsertRules implements TriggerAction.BeforeInsert, TriggerAction.BeforeUpdate {

    public void beforeInsert(List<Opportunity> newList){
        enforceOpportunityStage('before Insert');
    }

    public void beforeUpdate(List<SObject> newList, List<SObject> oldList) {
        enforceOpportunityStage('before Update');
    }

    private static void enforceOpportunityStage(String context) {
        System.debug('context=' + context);
    }
}
