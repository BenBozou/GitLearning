/**
* Service class to send sms 
* Eliran Shalom
* Taskid PLR-1313
* @class SMSService
* @module Leads
*/
public with sharing class SMSService {
	
	public String templateName;
	public String phone;
	public String text;
	
    public SMSService(String templateName, String phone, String text) {
    	this.templateName = templateName;
    	this.phone = phone;
    	this.text = text;
    	sendSMS();
    }
    
    /**
	* Method send invoke OutboundCalloutService to send sms
	* Eliran Shalom
	* Taskid PLR-1313
	* @class sendSMS
	* @module Leads
	*/
    public void sendSMS() {
        try {
            messageImpl[] msg = new messageImpl[] {
                new messageImpl(this.templateName, this.phone, this.text, 'false')
            };

            // build Body JSON
            CourierRequest request = new CourierRequest(msg);
            OSBCalloutBuilder.OSBRequest ctrlRequest = new OSBCalloutBuilder.OSBRequest('00499');
            ctrlRequest.body.setRequestNode(request);
            system.debug('#### REQUEST: ' + request);

            // Append Body tp Request JSON
            ctrlRequest.body.setRequestNode(request);
            String requestJSON = ctrlRequest.serialize();
            system.debug(Logginglevel.INFO, 'REQUEST: ' + requestJSON);
            OutboundCalloutService.RestResponse res = ctrlRequest.sendRequest('OSB', 'api/services/rest/osb_sendsms_cellcomcourier');
            system.debug(Logginglevel.INFO, 'Response ' + res);
            if (res == null || res.statusCode == 90) {
                system.debug(Logginglevel.INFO, 'Invoke SMS faled: ' + res);
            }
            
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, '>>>> 10 sendSMS Exception: ' + e + ' from: ' + e.getStackTraceString());
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
        public String messageTo;
        public String text;
        public String is_immediate;
        public messageImpl(String template_name, String messageTo, String text, String is_immediate) {
            this.template_name = template_name;
            this.messageTo = messageTo;
            this.text = text;
            this.is_immediate = is_immediate;
        }
    }
}