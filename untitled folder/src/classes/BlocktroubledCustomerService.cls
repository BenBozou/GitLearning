/**
* Service class to send sms 
* Eliran Shalom
* Taskid PLR-1313
* @class BlocktroubledCustomerService
* @module Leads
*/

public with sharing class BlocktroubledCustomerService{
    
    public String templateName;
    public String phone;
    public String text; 
    
    public BlocktroubledCustomerService(String templateName, String phone, String text) {
       // this.templateName = templateName;
       // this.phone = phone;
       // this.text = text;
       // BlockCustomer(templateName,phone,text);
    }
   
    /**
    * Method send invoke OutboundCalloutService to BlockCustomer
    * Eliran Shalom
    * Taskid PLR-1313
    * @class BlockCustomer
    * @module Leads
    */
    public static GetResult BlockCustomer(String templateName, String phone, String text) {
        try {
            messageImpl[] msg = new messageImpl[] {
                new messageImpl(templateName, phone, text, 'false')
            };
 			GetResult resultData = new GetResult();
          
             
            // build Body JSON
            CourierRequest request = new CourierRequest(msg);
            OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00729');
            ctrlRequest.body.setRequestNode(request);
            system.debug('#### REQUEST: ' + request);

            // Append Body tp Request JSON
            ctrlRequest.body.setRequestNode(request);
            String requestJSON = ctrlRequest.serialize();
            system.debug(Logginglevel.INFO, 'REQUEST: ' + requestJSON);
            Map<String,Object> response = ctrlRequest.sendRequestWithErrorCheck('OSB', 'api/services/rest/00729_osb_botheredcustomerblock_bp');
           
            map<String,Object> bodyMap = (map<String,Object>)response.get('Body');
            map<String,Object> ResponseMap = (map<String,Object>)bodyMap.get('Response');
            
            
            map<String,Object> headerMap = (map<String,Object>)response.get('Header');
            resultdata.ReturnCode = (String)headerMap.get('ReturnCode'); 
            resultdata.blockType = (String)ResponseMap.get('action'); 
            
            if((String)headerMap.get('ReturnCode') != '00'){
           		 System.debug(Logginglevel.ERROR, 'Service error: ' + (String)headerMap.get('ReturnCode'));
       		 }
		    system.debug(Logginglevel.INFO, 'Response ' + resultdata);
            return resultData;
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, '>>>> 10 sendSMS Exception: ' + e + ' from: ' + e.getStackTraceString());
      		 return null;
        }
        
    }
    
    public class CourierRequest extends OSBCalloutBuilder.RequestBuilder {
        public SmsImpl sms;
        public CourierRequest(messageImpl[] msg) {
            sms = new SmsImpl();
            sms.message = msg;
        }
    }
    
    public class SmsImpl {
        public messageImpl[] message;
    }
    
    public class messageImpl {
        public String template_name ;
        public String to;
        public String text;
        public String is_immediate;
        public messageImpl(String template_name, String messageTo, String text, String is_immediate) {
            this.template_name = template_name;
            this.to = messageTo;
            this.text = text;
            this.is_immediate = is_immediate;
        }
    }
    /**
    * Class helper to get Lead data as a structure
    * Eliran Shalom    
    * taskid PLR-805
    * @class GetResult
    * @module Lead 
*/
  public class GetResult{
        public String blockType;
        public String ReturnCode;
    }
}