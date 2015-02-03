global class Fact_Opportunity 
{
	public class OpportunityFactoryException extends Exception { }

    //component
    private static Fact_BaseComponent factoryBase = new Fact_BaseComponent('Opportunity');

    //define default constants
    public static final String DEFAULT_DIRECT_OPPORTUNITY_NAME = 'FactoryDirectOpportunity';
    public static final String DEFAULT_INDIRECT_OPPORTUNITY_NAME = 'FactoryIndirectOpportunity';

    public static final String ONE_TIME_RECORD_TYPE = 'One_Time_Opportunity';
    public static final String RENEWING_RECORD_TYPE = 'Renewing_Opportunity';

    public static final Set<String> VARIANTS_SET = new Set<String> {ONE_TIME_RECORD_TYPE, RENEWING_RECORD_TYPE};

    //members
    private static Map<String, ID> opportunityRecordTypes = new Map<String, ID>();
	
    private static Map<String, Map<String, Object>> variantToRequiredFieldsToValuesNestedMap = new Map<String, Map<String, Object>>();

    //Removed from Demo
    //private static Map<String, Pricebook2> pricebookNameToPricebookMap = new  Map<String, Pricebook2>();

    /******** STATIC INITIALIZATION REGION ********/

    static 
    {   
    	for (String variantName : VARIANTS_SET)
    	{
    		//this variant's required fields mapped to default values
    		Map<String, Object> variantNameToRequiredFieldsToValuesMap = populateRequiredFieldsToValuesMap(variantName);
			
			variantToRequiredFieldsToValuesNestedMap.put(variantName, variantNameToRequiredFieldsToValuesMap);
    	}

        //Note: Pricebook assignment has been simplified to Standard Pricebook for the demo, but see below for stub
        
        //Cache pricebooks by name
        //pricebookNameToPricebookMap = Util_DataMethods.PopulatePricebookMap();
    }

    /******** INIT HELPER REGION ********/

    private static Map<String, Object> populateRequiredFieldsToValuesMap(String recordTypeName)
    {
    	Map<String, Object> requiredFieldsToValues = new Map<String, Object>();

        String type = null;
        String shippingCountry = null;

        Date subscriptionStartDate = null;

        String stageName = 'Needs Analysis';  //assumes default sales processes associated with recordtypes
        String nextStep = 'Factory default next step';

        Integer closeDateOffsetInMonths = 1;  //minimum date is 1 month out from today
        Date closeDate = Date.today().addMonths(closeDateOffsetInMonths);

        Integer startDateOffsetInMonths = 1;  //start date 1 months out from close date

    	if (recordTypeName == ONE_TIME_RECORD_TYPE)
    	{
    		type = 'New Customer';  //Should be given better, non-default name
    	}
    	else if  (recordTypeName == RENEWING_RECORD_TYPE)
    	{
    		type = 'Existing Customer - Upgrade';  //Should be given better, non-default name

            subscriptionStartDate = Date.today().addMonths(closeDateOffsetInMonths + startDateOffsetInMonths);

            requiredFieldsToValues.put('Subscription_Start_Date__c', subscriptionStartDate);
    	}
        else
        {
            throw new OpportunityFactoryException('RecordType from Util_DataMethods.mapOfOpportunityRecordTypes() not configured in Opportunity Factory');
        }

        //dynamically assigned fields
        requiredFieldsToValues.put('Type', type);
    	requiredFieldsToValues.put('CloseDate', closeDate);

        //fixed-value fields
        requiredFieldsToValues.put('StageName', stageName);
        requiredFieldsToValues.put('NextStep', nextStep);

    	return requiredFieldsToValues;

    }

    /******** METHODS REGION ********/
    //Core 'create' method
	global static Opportunity createOpportunity(String name, String recordTypeName)
	{	
		Opportunity opp = new Opportunity();

		/*** START param validation ***/
		if (name != null && name != '')
		{
			opp.Name = name;
		}
		else
		{
			opp.Name = DEFAULT_DIRECT_OPPORTUNITY_NAME;
		}

		//if recordTypeName param's RecordType isn't available, throw config. error
        if (!factoryBase.recordTypesMap.containsKey(recordTypeName))
        {
            throw new OpportunityFactoryException(recordTypeName + ' RecordType inaccessible by user, inactive, or missing');       
        }
        //if the recordTypeName param isn't configured on the recordTypeName-to-required-fields/values map, throw config error
		if (!variantToRequiredFieldsToValuesNestedMap.containsKey(recordTypeName))
		{
	    	throw new OpportunityFactoryException(recordTypeName + ' is an invalid RecordType name for sObject: Opportunity');       
        }
        /*** END param validation ***/

        //RecordType assignment:
        opp.RecordTypeId = factoryBase.recordTypesMap.get(recordTypeName);

        /*** START Dynamic field assignment ***/
        factoryBase.assignValuesToFieldsFromMap(opp, variantToRequiredFieldsToValuesNestedMap.get(recordTypeName));
        /*** END Dynamic field assignment ***/

		return opp;
	}

	//Core 'insert' method
    global static List<Opportunity> insertOpportunities(List<String> names, List<String> recordTypeNames,
    													List<Account> accounts, List<Account> endUserAccounts)
    {
    	//guard conditions:
        if (names == null || recordTypeNames == null || accounts == null || recordTypeNames == null 
            || recordTypeNames.size() == 0 || recordTypeNames.size() == 0
        	|| accounts.size() == 0 || endUserAccounts.size() == 0)
        {
            throw new OpportunityFactoryException('Method cannot have null or empty list parameters');       
        }
        if (names.size() != recordTypeNames.size() || 
        	names.size() != accounts.size() ||
        	names.size() != endUserAccounts.size())
        {
            throw new OpportunityFactoryException('Method requires parameter lists have equal size');       
        }

        Integer recordCount = names.size();

        //Factory records to generate and insert
        List<Opportunity> opps = new List<Opportunity>();

        //for per-opp lookups: Accounts and EndUserAccounts passed in as parameters

        for (Integer i = 0; i < recordCount; i++)
        {
            Opportunity oppToInsert = createOpportunity(names[i], recordTypeNames[i]);

            //Account assignment
            factoryBase.assignLookupValue(oppToInsert, 'AccountId', accounts[i].ID);

            //NOTE: This template does not perscribe the method of pricebook assignment (could be at Account or Opp level),
            //but rather uses the standard pricebook as a shortcut in the demo. A better method would be 
            //to populate a map as below in commented line, and retreive pricebook from field maintained on account,
            //or set it above as a 'required' field, possibly based on some variant
            //oppToInsert.Pricebook2Id = pricebookNameToPricebookMap.get(accounts[i].Pricebook__r.ID);
            
            oppToInsert.Pricebook2Id = Util_DataMethods.getStandardPricebookId();

            //End User Account assignment
            factoryBase.assignLookupValue(oppToInsert, 'End_User_Account__c', endUserAccounts[i].ID);

            opps.add(oppToInsert);
        }

        insert opps;

        return opps;
    }

    global static Opportunity insertDirectOpportunity()
	{
		List<String> names = new List<String>();
        List<String> recordTypeNames = new List<String>();
        List<Account> accs = new List<Account>();
        List<Account> endUserAccs = new List<Account>();
        
        names.add(DEFAULT_DIRECT_OPPORTUNITY_NAME);
        recordTypeNames.add(ONE_TIME_RECORD_TYPE);

        Account endUserAcc = Fact_Account.insertDirectAccount();

        accs.add(endUserAcc);  //direct
        endUserAccs.add(endUserAcc);

        return insertOpportunities(names, recordTypeNames, accs, endUserAccs)[0];
    }

    global static Opportunity insertIndirectOpportunity()
    {
        List<String> names = new List<String>();
        List<String> recordTypeNames = new List<String>();
        List<Account> accs = new List<Account>();
        List<Account> endUserAccs = new List<Account>();
        
        names.add(DEFAULT_INDIRECT_OPPORTUNITY_NAME);
        recordTypeNames.add(ONE_TIME_RECORD_TYPE);

        Account endUserAcc = Fact_Account.insertIndirectAccount();

        //querty for newly inserted Channel Partner account associated with end user
        Account cpAccount = [SELECT ID FROM Account WHERE ID = :endUserAcc.ParentId];

        accs.add(cpAccount);
        endUserAccs.add(endUserAcc);  //indirect

        return insertOpportunities(names, recordTypeNames, accs, endUserAccs)[0];
    }

    //method can produce either direct or indirect opportunity
    global static Opportunity insertOpportunity(String recordTypeName, Boolean isDirect)
    {
        List<String> names = new List<String>();
        List<String> recordTypeNames = new List<String>();
        List<Account> accs = new List<Account>();
        List<Account> endUserAccs = new List<Account>();
        

        names.add( (isDirect ? DEFAULT_DIRECT_OPPORTUNITY_NAME : DEFAULT_INDIRECT_OPPORTUNITY_NAME) );
        recordTypeNames.add(recordTypeName);

        Account endUserAcc = null;
        if (isDirect)
        {
            endUserAcc = Fact_Account.insertDirectAccount();
            accs.add(endUserAcc);  //direct
        }
        else
        {
            endUserAcc = Fact_Account.insertIndirectAccount();
            
            //querty for newly inserted Channel Partner account associated with end user
            Account cpAccount = [SELECT ID FROM Account WHERE ID = :endUserAcc.ParentId];
            
            accs.add(cpAccount);  //indirect
        }

        endUserAccs.add(endUserAcc);

        return insertOpportunities(names, recordTypeNames, accs, endUserAccs)[0];
    }

    //direct bulk insert case with count
    global static List<Opportunity> insertDirectOpportunities(Integer count)
    {
        List<String> names = new List<String>();
        List<String> recordTypeNames = new List<String>();
        
        List<Account> accs = Fact_Account.insertChannelPartnerAccounts(count);
        List<Account> endUserAccs =  Fact_Account.insertDirectAccounts(count);

        for (Integer i = 0; i < count; i++)
        {
            names.add(DEFAULT_DIRECT_OPPORTUNITY_NAME + String.valueOf(i));
            recordTypeNames.add(ONE_TIME_RECORD_TYPE);
        }

        return insertOpportunities(names, recordTypeNames, accs, endUserAccs);
    }

    //indirect bulk insert case with count
    global static List<Opportunity> insertIndirectOpportunities(Integer count)
    {
        List<String> names = new List<String>();
        List<String> recordTypeNames = new List<String>();
        
        List<Account> accs = Fact_Account.insertChannelPartnerAccounts(count);
        List<Account> endUserAccs =  Fact_Account.insertDirectAccounts(count);

        for (Integer i = 0; i < count; i++)
        {
            names.add(DEFAULT_DIRECT_OPPORTUNITY_NAME + String.valueOf(i));
            recordTypeNames.add(ONE_TIME_RECORD_TYPE);
        }

        return insertOpportunities(names, recordTypeNames, accs, endUserAccs);
    }
}
