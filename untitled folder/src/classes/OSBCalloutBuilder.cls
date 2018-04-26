/**
*   Comments examples for creating Class docs
*
*   @class OSBCalloutBuilder
*   author Eric Fishman
*   @module {OSBCalloutBuilder}
*   @constructor
*/
public with sharing class OSBCalloutBuilder {

	public enum cardStatus {ERROR, INFO, WARNING, SUCCESS}

	public static map < String, Object > prepareHeader(String funcCode) {
		User userData = [Select FederationIdentifier From User where Id=:userinfo.getuserId() limit 1];
		//string uName = UserInfo.getUserName().replaceAll('@.*$', '');
		string uName = userData.FederationIdentifier;

		map < String, Object > result = new map < String, Object > {
			'From' => 'SF',
			'To' => 'OSB',
			'UserName' => uName,
			//'UserName' => 'BOAZGE',
			'FunctionCode' => funcCode
		};

		//Added GUID for InterchangeID & ActivityID
		result.put('InterchangeID', generateGUID());
		result.put('ActivityID', generateGUID());

		return result;
	}

	public virtual class OSBRequest {
		public Map < String, Object > Header;
		public BodyBuilder Body;
		public Integer errorCode;
		public String errorCodeMessage;
		public Map < String, Object > outMap;
		private String Error;
		private String partError;
		private map<String, object> params;

		public OSBRequest(String funcCode) {
			Header = prepareHeader(funcCode);
			Body = new BodyBuilder();
		}

		public OSBRequest(String funcCode, Map < String, Object > outMap, String Error, String partError) {
			Header = prepareHeader(funcCode);
			Body = new BodyBuilder();
			this.outMap = outMap;
			this.error = Error;
			this.partError = partError;

		}

		public OSBRequest(String funcCode, Map < String, Object > outMap, String Error, String partError, map<String, object> params) {
			this(funcCode, outMap, Error, partError);
			this.params = params;
			if (this.outMap != null) this.outMap.put('_OSBRequestParam', params);
		}

		public OSBRequest(String funcCode, BodyBuilder bb) {
			this.Header = prepareHeader(funcCode);
			this.Body = (bb == null) ? new BodyBuilder() : bb;
		}

		public string serialize() {
			return JSON.serialize(this);
		}

		public OutboundCalloutService.RestResponse sendRequest(String endPointPrefix, String serviceName) {
			return sendRequest(endPointPrefix, serviceName, true);
		}

		public OutboundCalloutService.RestResponse sendRequest(String endPointPrefix, String serviceName, Boolean insertLogImmediate) {
			return outboundCalloutService.sendRestRequest(
				new map<String,object> {'timeout' => 25000, 'FunctionCode' => Header.get('FunctionCode')},
				null,
				endPointPrefix,
				serviceName,
				'POST',
				this.serialize(),
				insertLogImmediate
			);

		}

		public Map < String, Object > sendRequestWithErrorCheck(String endPointPrefix, String serviceName) {
			return sendRequestWithErrorCheck(endPointPrefix, serviceName, true);
		}

		public Map < String, Object > sendRequestWithErrorCheck(String endPointPrefix, String serviceName, Boolean insertLogImmediate) {
			this.errorCode = 0;
			String body = sendRequestWithErrorCheckReturnString(endPointPrefix, serviceName, insertLogImmediate);
			if (body == null) {
				this.errorCode = null;
				return null;
			}
			Map < String, Object > responseMap = (Map < String, Object > ) Json.deserializeUntyped(body);


			if ((responseMap.get('Header')) != null) {
				Map < String, Object > header = (Map < String, Object >) responseMap.get('Header');
				String errCode = (string) header.get('ReturnCode');
				this.errorCode = (errCode != null) ? integer.valueOf(errCode.replaceAll('[^0-9]','')) : null;
				this.errorCodeMessage = (String) header.get('ReturnCodeMessage');
				// if we run this method from card we need use this error handler;
				if (params == null || (params != null && params.get('withoutCheck'  ) == null)) {
					if (this.outMap != null) {
						this.outMap.put('originHeader', header);
						cardStatus Status = (this.errorCode == null || this.errorCode == 99)
							? cardStatus.ERROR
							: (this.errorCode > 0 && this.errorCode < 99)
								? cardStatus.WARNING
								: cardStatus.SUCCESS;
						if (Status != cardStatus.SUCCESS) returnError(Status, this.errorCodeMessage, serviceName);
					}
				}
			}

			return responseMap;
		}

		private void addValueToMap(String key, String value) {
			if (this.outMap == null) return;
			if (key == null) return;

			if (!this.outMap.containsKey(key)) this.outMap.put(key,'');
			String newVal = (this.outMap.get(key) =='') ? value : this.outMap.get(key) + ' : ' + value;

			this.outMap.put(key, newVal);
		}

		public void returnError(cardStatus status, String msg, String serviceName) {
			Boolean result = false;
			this.addValueToMap('lastServiceName', serviceName);
			this.addValueToMap('lastServiceMsg', msg);

			if ((params != null && params.get('warningAsError') == true)) {
				if (status == cardStatus.WARNING) {
					this.outMap.put('processError', 'true');
					this.addValueToMap('processErrorMsg', this.error);
					throw new applicationException(null, this.error,  applicationException.ExceptionType.OSB);
				}
			}

			if (status == cardStatus.ERROR) {
				this.outMap.put('processError', 'true');
				this.addValueToMap('processErrorMsg', this.error);
				throw new applicationException(null, this.error,  applicationException.ExceptionType.OSB);
			}

			String statusMsg = (status == cardStatus.ERROR)
				? 'processErrorMsg'
				: (status == cardStatus.INFO)
					? 'processInfoMsg'
					: (status == cardStatus.WARNING)
						? 'processWarningMsg'
						: (status == cardStatus.SUCCESS)
							? 'processSuccessMsg'
							: null;

			String message = (status == cardStatus.ERROR)
				? this.error
				: (status == cardStatus.WARNING)
					? this.partError
					: msg;

			this.addValueToMap(statusMsg, message);
		}


		/*
			USAGE : replace string to new value
		*/
		public Map < String, Object > sendRequestWithErrorCheck(String endPointPrefix, String serviceName, map<String, String> replaceMap) {
			String body = sendRequestWithErrorCheckReturnString(endPointPrefix, serviceName);
			if (replaceMap!=null) {
				for (String key : replaceMap.keyset()) {
					body = body.replaceAll(key, replaceMap.get(key));
				}
			}
			Map < String, Object > responseMap = (Map < String, Object > ) Json.deserializeUntyped(body);
			return responseMap;
		}

		private String sendRequestWithErrorCheckReturnString(String endPointPrefix, String serviceName) {
			return sendRequestWithErrorCheckReturnString(endPointPrefix, serviceName, true);
		}

		private String sendRequestWithErrorCheckReturnString(String endPointPrefix, String serviceName, Boolean insertLogImmediate) {
			//system.debug(Logginglevel.INFO, 'REQUEST: ' + this.serialize());
			OutboundCalloutService.RestResponse res = sendRequest(endPointPrefix, serviceName, insertLogImmediate);
			//system.debug(Logginglevel.INFO, 'RESPONSE: ' + (res!=null ? String.valueOf(res.StatusCode) : '') + ' : ' + (res!=null ? res.body: ''));
			return res != null ? res.body : null;
		}
	}

	public virtual class BodyBuilder {
		public RequestBuilder Request;
		public BodyBuilder() {
			Request = new RequestBuilder();
		}

		public void setRequestNode(RequestBuilder req) {
			Request = req;
		}
	}

	public virtual class RequestBuilder {}


	public static String generateGUID(){

		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);

		return guid;
	}
}