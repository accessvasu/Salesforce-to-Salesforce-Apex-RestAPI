public class AccountTriggerHandler2 {
	public static void onAfterInsert(Map<Id, Account> records){
        addObjectToQueue(records);
	}
	public static void onAfterupdate(Map<Id, Account> records){
	    addObjectToQueue(records);
	}
    public static void addObjectToQueue(Map<Id, Account> newList){
        if(!Test.isRunningTest())
   			  System.enqueueJob(new QueueServiceBroker(newList));
   	}
    public static Boolean inFutureContext = false;
}