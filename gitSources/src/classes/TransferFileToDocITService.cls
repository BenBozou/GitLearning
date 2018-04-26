global with sharing class TransferFileToDocITService implements vlocity_cmt.VlocityOpenInterface{
    global TransferFileToDocITService() {}

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try{
            if (methodName.equals('GetCaseData')){
                GetCaseData(inputMap,outMap);
            }
            else {
                result = false;
            }
        }
        catch(Exception e){
            System.debug('TransferFileToDocITService:invokeMethod -> exception: '+e);
            result = false;
        }

        return result;
    }

void GetCaseData(Map<String, Object> inputMap, Map<String, Object> outMap){

        String inputFile = (String)inputMap.get('Type');
        System.debug('inputFile: ' + inputFile);
		outMap.put('options', inputMap.get('Type'));
    }
}