public class UrlLinksUtil {
    
    /**
    *   Get list of links for current environment.
    *   Will be used by javascript method to locate the prefix of url links 
    *   author Elad Iflah
    *   taskId POC
    *
    *   @method getUrlLinkByEnv
    *   @return {Map<String,String>}    ENV+serviceName, link Url
    */ 
    public static Map<String,String> getUrlLinkByEnv() {
            
        Map<String,String> linkMap = new Map<String,String>();
        
        try {
            
            String environmentType =  EnvironmentSettings__c.getInstance().CurrentEnvironment__c;
            if (string.isEmpty(environmentType)){
                System.debug(Logginglevel.ERROR,'UrlLinksUtil.getUrlLinkByEnv - No environment found, no service names will be returned');
                return null;
            }
            String likeEnvironmentType = '%_' + environmentType;
            Integer envStrLength = environmentType.length() + 1;                   
                        
            for(NamedCredential currNamedCred  : [SELECT DeveloperName,Endpoint FROM NamedCredential WHERE DeveloperName LIKE :likeEnvironmentType]) {
                String onlyServiceName = currNamedCred.DeveloperName.substring(0,currNamedCred.DeveloperName.length()-envStrLength);            
                if( onlyServiceName.length() > 0 )
                {
                    linkMap.put(onlyServiceName, currNamedCred.Endpoint);
                }            
            }
        
            String userId=UserInfo.getUserId();
            List<User> federationIdList=[SELECT FederationIdentifier 
                                 FROM User
                                 WHERE Id =: userId];
            system.debug('federationIdList : ' + federationIdList);                     
                                 
            linkMap.put('_federationId', federationIdList[0].FederationIdentifier);
            List<Report> reportIdList=[SELECT Id
                                 FROM Report
                                 WHERE DeveloperName = 'CreationRecomendation'];
            linkMap.put('_CreationRecommendation', reportIdList[0].Id);
            system.debug('_federationId : ' + linkMap.get('_federationId')); 
        }
        catch(Exception exc) {
            System.debug(Logginglevel.ERROR, 'UrlLinksUtil.getUrlLinkByEnv - ERROR! No service names will be returned, exception:'+ exc.getMessage());
        }
                        
        return linkMap;
    }

}