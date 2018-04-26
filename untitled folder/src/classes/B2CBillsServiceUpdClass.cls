public class B2CBillsServiceUpdClass{

	public cls_FinData FinData;
	public String ShareDataInd;	//RP
	public String Contact;	//RP
	public String Consumer;	//OB1488151
    public cls_TotalByCompanyCode TotalByCompanyCode;
    public cls_Total Total;

	public class cls_FinData {
		public cls_billing_account[] billing_account;
	}
	public class cls_billing_account {
		public String invoice_no;	//RP
		public String bill_url;	//RP
		public String bill_url_type;	//RP
		public String bill_method_desc;	//RP
		public String dep_charges_amt;	//RP
		public String bill_due_date;	//RP
		public String collection_ind;	//N
		public String debt_amount;	//RP
		public String bill_cycle;	//RP
		public String prd_cvrg_end_date;	//RP
		public String prd_cvrg_strt_date;	//RP
		public String total_due_amt;	//RP
		public String ar_balance;	//RP
		public String psid;	//RP
		public String nvid;	//RP
		public String ban;	//239662027
		public String company_id;	//RP
		public String source;
		public String payment_terms_desc;
		public String currency_code_desc;
		public String company_code_desc;
        public String billing_address;
        public String payment_type;
        public String payment_type_desc;
        public String email_bill_dest;
        public String sms_bill_dest;
        public String account_type_desc;
        public String account_mid_type_desc;
        public String account_sub_type_desc;
        public String acc_password;
        public String credit_card_type_desc;
        public String credit_card_no;
        public String bnk_acct_number;
        public String bank_code;
        public String bank_name;
        public String branch_code;
        public String action_security_level;
        public String action_security_level_desc;
        public String recordTypeId;
        public String name;
        public String status;
        public string numberOfBillingAccount;
        public String Consumertype;
        public String PaidByName;
        public String Id;
	}

    public class cls_TotalByCompanyCode {
		public cls_company_code[] company_code;
	}
	public class cls_company_code {
		public String company_code;	//string
		public String company_name;	//string
		public String total_debt_amount;	//string
		public String total_ar_balance;	//string
	}
	public class cls_Total {
		public String total_deposits_amount;	//string
		public String total_debt_amount;	//string
		public String total_ar_balance;	//string
	}

	/*public static B2CBillsServiceUpdClass parse(String json){
		return (B2CBillsServiceUpdClass) System.JSON.deserialize(json, B2CBillsServiceUpdClass.class);
	}*/

}