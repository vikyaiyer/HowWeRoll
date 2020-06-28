public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> updatedCases, Map<Id,Case> oldCaseMap) {
        // TODO: Complete the method to update workorders
        Set<Id> validCaseIds = new Set<Id>();
        for(Case obj: updatedCases){
            if(oldCaseMap.get(obj.Id).Status != 'Closed' || obj.Status == 'Closed'){
                if(obj.Type == 'Repair' || obj.Type == 'Routine Maintenance'){
                    validCaseIds.add(obj.Id);
                }
            }
        }
        if(!validCaseIds.isEmpty()){
            List<Case> lstNewCases = new List<Case>();
            Map<Id,Case> closedCaseMap = new Map<Id,Case>([SELECT Id, Vehicle__c, Equipment__c, Equipment__r.Maintenance_Cycle__c, 
                                                                  (SELECT Id, Equipment__c, Quantity__c FROM Work_Parts__r) 
                                                           FROM Case 
                                                           WHERE Id IN :validCaseIds]);
            Map<Id, Decimal> maintCycleMap = new Map<Id, Decimal>();
            AggregateResult [] results = [SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c)cycle
                                        FROM Work_Part__c
                                        WHERE Maintenance_Request__c IN :validCaseIds
                                        GROUP BY Maintenance_Request__c];
            for(AggregateResult ar: results){
                maintCycleMap.put((Id) ar.get('Maintenance_Request__c'),(Decimal) ar.get('cycle') );
            }
            for(Case cc: closedCaseMap.values()){
                Case newCase = new Case(ParentId = cc.Id,
                                        Status = 'New',
                                        Subject = 'Routine Maintenance',
                                        Type = 'Routine Maintenance',
                                        Vehicle__c = cc.Vehicle__c,
                                        Equipment__c = cc.Equipment__c,
                                        Origin = 'Web',
                                        Date_Reported__c = Date.Today());
                if(maintCycleMap.containsKey(cc.Id)){
                    newCase.Date_Due__c = Date.Today().addDays((Integer) maintCycleMap.get(cc.Id));
                }
                else {
                    newCase.Date_Due__c = Date.Today().addDays((Integer) cc.Equipment__r.Maintenance_Cycle__c);    
                }
				lstNewCases.add(newCase);                
            }           
            insert lstNewCases;
        }
        
    }
}