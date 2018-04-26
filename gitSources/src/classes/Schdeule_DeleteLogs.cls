public class Schdeule_DeleteLogs implements Schedulable {
   /*Schdeule_DeleteLogs   sch = new Schdeule_DeleteLogs();
System.schedule('Schdeule_DeleteLogs Batch Schedule job hourly', '0 0 * * * ?', sch);*/
    
    public void execute(SchedulableContext sc) {
      Batch_DeleteLog b = new Batch_DeleteLog(-6); 
      database.executebatch(b);
   }
}