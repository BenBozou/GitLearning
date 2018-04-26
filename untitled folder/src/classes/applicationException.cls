/**
*	General Exeption class. Must provide a methods for debug, log and send information about exeption
*	
*	@class applicationException
*	author Dmitry Rivlin
*	@module Exception
*	@constructor
*/
public class applicationException extends Exception {

	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId PLR-627
	*
	*	@method	ExceptionType
	*	@return	enum
	*
	*/
	public enum ExceptionType { INBOUND, OUTBOUND, OSB }

	public ExceptionType eType;
	
	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	applicationException
	*	@param	{Exception} e
	*	@param	{String} ExLogTxt
	*	@param	{ExceptionType} exType
	*	@return	
	*
	*/
	public applicationException(Exception e, String ExLogTxt, ExceptionType exType) {
		
		this (e, ExLogTxt, exType, true);
	}
	
	
	/**
	*	method description
	*	author Dmitry Rivlin
	*	taskId
	*
	*	@method	applicationException
	*	@param	{Exception} e
	*	@param	{String} ExLogTxt
	*	@param	{ExceptionType} exType
	*	@param	{Boolean} logException
	*	@return	
	*
	*/
	public applicationException(Exception e, String ExLogTxt, ExceptionType exType, Boolean logException) {
		String Msg = (E!=null) ? E.getMessage() + ' Line: ' + E.getLineNumber() + ' Stack: ' + E.getStackTraceString() + ExLogTxt : ExLogTxt; 
		//coreDebugLog exLog = coreDebugLog.getInstance();
		//exLog.setException(e,ExLogTxt);
		this.eType = exType;
		this.setMessage(Msg);
		
		if (logException){
			//LoggerService.writeErrorMessage('ERROR', new LoggerService.ErrorMessage(e));
		}
	}

}