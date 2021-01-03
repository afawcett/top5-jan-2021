/**
 .----------------. 
| .--------------. |
| |     __       | |
| |    /  |      | |
| |    `| |      | |
| |     | |      | |
| |    _| |_     | |
| |   |_____|    | |
| |              | |
| '--------------' |
 '----------------' 
 */

/**
 * Improve Apex Testing with New SObject Error Methods
 * https://releasenotes.docs.salesforce.com/en-us/winter21/release-notes/rn_apex_trackErrors.htm
 * SObject Class
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_sobject.htm
 * Reducing Field Validation Boilerplate Code
 * https://andyinthecloud.com/2020/12/13/reducing-field-validation-boilerplate-code/
 */
public with sharing class One {

    public static void demo() {
        Opportunity opp = new Opportunity();
        opp.addError('Description', 'Error Message!'); 
        List<Database.Error> errors = opp.getErrors();
        System.assertEquals(1, errors.size());
        System.assertEquals('Error Message!', errors[0].getMessage());
        System.assertEquals('Description', errors[0].getFields()[0]);
    }

    public static void before(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        // Classic style validation
        switch on Trigger.operationType {
            when AFTER_UPDATE {
                // Prescan to bulkify querying for related Accounts
                Set<Id> accountIds = new Set<Id>();
                for (Opportunity opp : newMap.values()) {
                    Opportunity oldOpp = oldMap.get(opp.Id);
                    if(opp.AccountId != oldOpp.AccountId) { // AccountId changed?
                        accountIds.add(opp.AccountId);
                    }
                }                
                // Query related Account records?
                Map<Id, Account> associatedAccountsById = accountIds.size()==0 ? 
                    new Map<Id, Account>() : 
                    new Map<Id, Account>([select Id, NumberOfEmployees from Account where Id = :accountIds]);
                // Validate
                for (Opportunity opp : newMap.values()) {
                    Opportunity oldOpp = oldMap.get(opp.Id);
                    if(opp.StageName != oldOpp.StageName) { // Stage changed?
                        if(opp.StageName == 'Closed Won') { // Stage closed won?
                            if(opp.Description != oldOpp.Description) { // Description changed?               
                                if(opp.Description == null) { // Description null?
                                    opp.Description.addError('Description must be specified when Opportunity is closed');
                                }
                            }
                        }                                
                    }
                    if(opp.AccountId != oldOpp.AccountId) { // AccountId changed?
                        Account acct = associatedAccountsById.get(opp.AccountId);
                        if(acct!=null) { // Account queried?
                            if(acct.NumberOfEmployees==null) { // NumberOfEmployees null?
                                opp.AccountId.addError('Account does not have any employees');
                            }    
                        }
                    }
                }
            }
        }                       
    }

    public static void after(TriggerOperation operation, Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        SObjectFieldValidator.build()            
        .when(TriggerOperation.AFTER_UPDATE)
          .field(Opportunity.Description).hasChanged().isNull().addError('Description must be specified when Opportunity is closed')
            .when(Opportunity.StageName).hasChanged().equals('Closed Won')
          .field(Opportunity.AccountId).hasChanged().addError('Account does not have any employees')
            .when(Account.NumberOfEmployees).isNull()
        .validate(operation, oldMap, newMap);        
    }
}
