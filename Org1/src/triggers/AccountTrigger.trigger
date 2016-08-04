trigger AccountTrigger on Account (after insert, 
                                   after update) {
    if(!AccountTriggerHandler2.inFutureContext){
        if(Trigger.isAfter){
            if(Trigger.isUpdate){
                //AccountTriggerHandler.onAfterupdate(Trigger.old); 
                AccountTriggerHandler2.onAfterupdate(Trigger.oldMap);   
            }else if(Trigger.isInsert){
                //AccountTriggerHandler.onAfterInsert(Trigger.new);
                AccountTriggerHandler2.onAfterInsert(Trigger.newMap);
            }
        }
    }
}