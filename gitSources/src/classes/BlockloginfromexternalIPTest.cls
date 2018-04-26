@isTest
public class BlockloginfromexternalIPTest {

    public static testMethod void testIsOutOfRange() {
        

        /* Create a map for the event we’re going to build. */
        Map<String, String> eventData = new Map<String, String>();
        
        TxnSecurity.Event e = new TxnSecurity.Event(
            '00Dxxx123123123', /* organizationId */
            '005xxx123123123', /* userId */
            'AuthSession', /* entityName */
            'Login', /* action */
            'LoginHistory', /* resourceType */
            '01pR00000009D2H', /* entityId */
            Datetime.newInstance(2016, 2, 15), /* timeStamp */
            eventData );
            
            BlockloginfromexternalIPPolicyCondition condition =
            new BlockloginfromexternalIPPolicyCondition();
        
        System.assertEquals(true, condition.evaluate(e));
    }
    
    
}