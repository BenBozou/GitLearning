public class FlowGetOpportunityTypeValue {

   @InvocableMethod
   public static List <String> getValues ( List <String> names) {
       List<String> picklistValues = new List<String>();
       Schema.DescribeFieldResult fieldResult = User.Location__c.getDescribe();   
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple) {
           for(String str : names){
               if ( f.getLabel() == str) {
                   picklistValues.add(f.getValue());
               }
           }
       }
       return picklistValues;       
   }
    
}