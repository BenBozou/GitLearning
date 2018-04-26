/**
* Class helper for creating and populating Json Header request for all callouts
* Gili Yehuda
* taskid PLR-137
* @class HeaderInterface
* @constructor
* @param {String} funcCode
* @module 360 
*/
public with sharing class HeaderInterface {
	
	private String source;
	private String target;	
	private String userName;	
	private String functionCode;	 
	
	public HeaderInterface(String funcCode){
		source='SF';
		target='OSB';
		functionCode=funcCode;	 
	/**	String userNameTmp=UserInfo.getUserName();
	    Integer index=userNameTmp.indexOf('@');
	    UserName=userNameTmp.substring(0,index);*/
	    userName='SKLEIN';
	}
	
	/**
	* Method that serialize this object, replace members names   
	* and returns the new deserialized Json as Map<String, Object>.
	* Gili Yehuda
	* taskid PLR-137
	* @method setMap
	* @return {Map} 
	*/
	public map<String, Object> setMap(){
		String tmp = Json.serialize(this);
		//tmp = tmp.replaceAll('(?i)\bFrom1\b','From');
		tmp=tmp.replace('source','From');
		tmp=tmp.replace('target','To');
		tmp=tmp.replace('userName','UserName');
		tmp=tmp.replace('functionCode','FunctionCode');
		
		return (Map<String, Object>)Json.deserializeUntyped(tmp);
	}
    
}