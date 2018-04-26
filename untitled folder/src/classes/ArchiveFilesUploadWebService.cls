/**
* Service class Archive Files.
* Tal Sabati
* taskid PLR-501
* @class ArchiveFilesUploadWebService
* @module Leads
*/
public with sharing class ArchiveFilesUploadWebService {
    private static String boundary;
    /**
    * The method prepares data and invoke the HTTP call to DocIt
    * Tal Sabati
    * taskid PLR-501
    * @method ArchiveFilesUpload
    * @return {HTTPResponse} res
    */
    public static Boolean ArchiveFilesUpload(Blob filebody, map<string,string> inputHeaderMap, map<string,string> inputBodyMap, ExternalAttachment__c externalAttachment,string parentRelationName, string parentId){
        String GUID = createGUID();
        externalAttachment = populateExternalAttachmentRecord(GUID, parentRelationName, parentId, externalAttachment);       
        string xmlBody = buildXmlBody(inputHeaderMap, inputBodyMap, externalAttachment);
        Blob bodyBlob = buildBlob(filebody,externalAttachment.Name__c,xmlBody);
        
        string res = invoke(bodyBlob);
        if(res != null && res.containsIgnoreCase('<std:ReturnCode>00</std:ReturnCode>')){
            insert externalAttachment;
            return true;
        }
        return false;
    }
    
    /**
    * The method create GUID using crypto algorithm
    * Tal Sabati
    * taskid PLR-501
    * @method createGUID
    * @return {String} GUID
    */
    private static string createGUID(){
        String result = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(DateTime.now().getTime().format())));
        string GUID = result.substring(0,8) + '-' + result.substring(8,12) + '-' + result.substring(12,16) + '-' + result.substring(16,20)+ '-' + result.substring(20);
        system.debug('GUID: ' + GUID);
        return GUID;
    }
    /**
    * The method insert new external attachment Record
    * Tal Sabati
    * taskid PLR-501
    * @method createExternalAttachmentRecord
    * @param {String} GUID 
    * @param {String} parentRelationName 
    * @param {String parentId}, 
    * @param {ExternalAttachment__c} externalAttachment
    * @return {ExternalAttachment__c}
    */
    private static ExternalAttachment__c populateExternalAttachmentRecord(String GUID, String parentRelationName, String parentId, ExternalAttachment__c externalAttachment){
        string name = externalAttachment.Name__c;
        externalAttachment.FileExtension__c = name.substringAfterLast('.');
        externalAttachment.ArchiveSystem__c = 'DOCIT';
        externalAttachment.GUID__c = GUID;
        externalAttachment.put(parentRelationName, parentId);
        OutboundCalloutService.setNamedCredintialFound('DOCIT');
        if(OutboundCalloutService.namedCredintialFound != null){
            externalAttachment.DocitEndpoint__c = OutboundCalloutService.namedCredintialFound.Endpoint;
        }
        return externalAttachment;
    }
    /**
    * The method create string in the form of XML, with the parameters of the file.
    * Tal Sabati
    * taskid PLR-501
    * @method buildXmlBody
    * @return {string} xmlBody
     */
    private static string buildXmlBody(map<string,string> inputHeaderMap, map<string,string> inputBodyMap, ExternalAttachment__c externalAttachment){
        inputBodyMap.put('FILE_GUID', externalAttachment.GUID__c);
        inputBodyMap.put('FORM_FILE_NAME', 'crm_' + externalAttachment.GUID__c + '.' + externalAttachment.FileExtension__c);
        
        String xmlBody = '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:req="http://cellcom.co.il/2016/OSB_GenericFileUpload_FileSystem_00672/Request" xmlns:std="http://www.cellcom.co.il/2004/01/std-headers" xmlns:res="http://cellcom.co.il/2016/OSB_GenericFileUpload_FileSystem_00672/Response">';
        xmlBody += '<soap:Header>';
        xmlBody += '<req:FileBinary>cid:268041132574</req:FileBinary>';
        xmlBody += '</soap:Header>';
        xmlBody += '<soap:Body>';
        xmlBody += '<std:Envelope>';
        xmlBody += '<std:Header>';
        for (string key : inputHeaderMap.keySet()) {
            xmlBody += '<std:' + key + '>';
            xmlBody += inputHeaderMap.get(key);
            xmlBody += '</std:' + key + '>';
        }                
        xmlBody += '</std:Header>';
        xmlBody += '<std:Body>';
        xmlBody += '<req:Request>';
        xmlBody += '<File AppName="docit" Name="' + 'crm_' + externalAttachment.GUID__c + '.' + externalAttachment.FileExtension__c + '">';
        xmlBody += '<MetaDataFields>';  
        for (string key : inputBodyMap.keySet()) {
            xmlBody += '<Field Name="' + key + '">';
            xmlBody += inputBodyMap.get(key);
            xmlBody += '</Field>';
        }          
        xmlBody += '</MetaDataFields>';
        xmlBody += '</File>';
        xmlBody += '</req:Request>';
        xmlBody += '</std:Body>';
        xmlBody += '</std:Envelope>';         
        xmlBody += '</soap:Body>';
        xmlBody += '</soap:Envelope>';      
        system.debug('the xmlBody: ' + xmlBody);
        return xmlBody;
    }
    /**
    * The Method merges the XML file and the blob of the file.
    * Tal Sabati
    * taskid PLR-501
    * @method buildBlob
    * @param {Blob} filebody
    * @param {String} fileName
    * @param {string} xmlBody
    * @return {string} response from the call
    */
    private static Blob buildBlob(Blob filebody, String fileName, string xmlBody){
        system.debug('the xmlBody: ' + xmlBody);
        fileName = fileName.replace(' ', '_');
        boundary = '----------------------------741e90d31eff';
        String headerXML = '--'+boundary+'\nContent-Type: text/xml; charset=UTF-8\nContent-Transfer-Encoding: 8bit\nContent-ID: <rootpart@soapui.org>\r\n\r\n'+xmlBody;
        String header = headerXML + '\r\n--'+boundary+'\nContent-Type: application/octet-stream; name=' + fileName + '\nContent-Transfer-Encoding: binary\nContent-ID: <digitalDocIt>\nContent-Disposition: attachment; name="' + fileName + '"; filename="' + fileName + '"';

        String footer = '--'+boundary+'--';
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('=')){
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(filebody);

        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());

        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        }
        return bodyBlob;
    }
    /**
    * The method call http request to docId sysytem and return the response.
    * Tal Sabati
    * taskid PLR-501
    * @method invoke
    * @return {HTTPResponse} res
     */
    private static string invoke(Blob bodyBlob){
        map<String, String> headerMap = new map<String, String>();
		headerMap.put('Content-Type', 'multipart/related; boundary='+boundary);

		map<String, object> paramsMap = new map<String, object>();
		paramsMap.put('bodyBlob', bodyBlob);
		
		String endPointPrefix = 'OSB';
		String serviceName = 'api/services/soap/osb_genericfileupload_filesystem_00672';
		String methodName = 'POST';
		
		OutboundCalloutService.RestResponse res = OutboundCalloutService.sendRestRequest(paramsMap, headerMap, endPointPrefix, serviceName, methodName, null);
		if (res == null || res.statusCode == 90) {
			return null;
		}
		return res.body;
    }
}