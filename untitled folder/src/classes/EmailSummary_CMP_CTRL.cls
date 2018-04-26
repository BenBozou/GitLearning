/**
 * Class for getting tassk for Event email template.
 * Eric Fishman
 * taskid PLR - 976
 * @class EmailSummary_CMP_CTRL 
 * @module Lead 
 */
public with sharing class EmailSummary_CMP_CTRL
{
    public Id eventId {get; set;}

    public List<Task> getRetrieveRelatedTaskListVF()
    {
        list<Task> taskList = [SELECT Id, ActivityDate, Description, Subject, Ownerid, Status, Priority, Whoid, Whatid, Who.LastName, Who.FirstName
                                FROM Task 
                                WHERE eventID__c = :eventId and RecordType.DeveloperName = 'MeetingSummery' ORDER 
                                BY CreatedDate DESC];
                                
        return taskList;
    }
}