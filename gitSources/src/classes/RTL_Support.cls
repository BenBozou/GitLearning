/**
* RTL_Support
* @module Framework
* @class RTL_Support
*/

global with sharing class RTL_Support {

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	RTL_Support
	*	@param	{StandardController} stdController
	*	@return	
	*
	*/
	global RTL_Support(ApexPages.StandardController stdController) {
		//don't do anything for now
	}

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	RTL_Support
	*	@param	{Object} stdController
	*	@return	
	*
	*/
	global RTL_Support(Object stdController) {
		//don't do anything for now
	}

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	RTL_Support
	*	@return	
	*
	*/
	global RTL_Support() {

	}

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	isLanguageRTL
	*	@return	Boolean
	*
	*/
	global Boolean isLanguageRTL {
		get {
			Set < String > rtlLang = new Set < String > {
				'iw',
				'ar',
				'ur'
			};
			String language = UserInfo.getLanguage();
			return rtlLang.contains(language);
		}
		set;
	}

	global String currentLang {
		get {
			return UserInfo.getLanguage();
		}
		set;
	}
}