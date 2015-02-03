global class Fact_Account 
{
    public class AccountFactoryException extends Exception { }

    //component
    private static Fact_BaseComponent factoryBase = new Fact_BaseComponent('Account');

    //define default constants
    public static final String DEFAULT_DIRECT_NAME = 'FactoryDirectAccount';
    public static final String DEFAULT_INDIRECT_NAME = 'FactoryIndirectAccount';
    public static final String DEFAULT_CP_NAME = 'FactoryCPAccount';
    
    public static final String DEFAULT_ENTITY_ID_AND_DIRECT = 'FooCorp_USA_Direct';  //composite variant with _Direct/_Indirect marking the SECOND variant
    public static final String DEFAULT_ENTITY_ID_AND_INDIRECT = 'FooCorp_USA_Indirect';

    private static Map<String, ID> recordTypes = new Map<String, ID>();

    private static Map<String, Map<String, Object>> entityIdAndIsDirectToRequiredFieldsToValuesNestedMap = new Map<String, Map<String, Object>>();


    /******** STATIC INITIALIZATION REGION ********/

    static 
    {
        recordTypes = Util_DataMethods.mapOfAccountRecordTypes();
    	
        List<string> entityIds = Util_DataMethods.EntityIDsList();
    	for (String entityId : entityIds)
    	{
    		//this entity's required fields mapped to default values
    		//Note: per entity, two variants exist: one for 'Direct' and one for 'Indirecct'
    		Map<String, Object> requiredFieldsToValuesForDirectAccount = populateRequiredFieldsToValuesMap(entityId, true);
            Map<String, Object> requiredFieldsToValuesForIndirectAccount = populateRequiredFieldsToValuesMap(entityId, false);
			
			entityIdAndIsDirectToRequiredFieldsToValuesNestedMap.put(entityId + '_Direct', requiredFieldsToValuesForDirectAccount);
            entityIdAndIsDirectToRequiredFieldsToValuesNestedMap.put(entityId + '_Indirect', requiredFieldsToValuesForIndirectAccount);
    	}
    }

    /******** INIT HELPER REGION ********/

    private static Map<String, Object> populateRequiredFieldsToValuesMap(String entityId, Boolean isDirect)
    {
    	Map<String, Object> requiredFieldsToValues = new Map<String, Object>();

        String billingCountry = null;
        String shippingCountry = null;

        String region = null;

    	if (entityId == 'FooCorp_USA')
    	{
            //only require State fields where country = USA or Canada
    		requiredFieldsToValues.put('BillingState', 'CA');
            requiredFieldsToValues.put('ShippingState', 'CA');
    		
            billingCountry = 'United States';

            if (isDirect)
            {
                region = 'USA Direct';
            }
            else
            {
                region = 'USA Indirect';
            }
    	}
    	else if (entityId == 'FooCorp_Euro')
    	{
            billingCountry = 'France';

            if (isDirect)
            {
                region = 'Euro Direct';
            }
            else
            {
                region = 'Euro Indirect';
            }
    	}
    	else if (entityId == 'FooCorp_Asia')
    	{
    		//nested variants (entity + isDirect) may have different assignment flow
    		//within the top-level variant, as is demonstrated here by assigning distinct
    		//countries based on isDirect's value
            if (isDirect)
            {
                billingCountry = 'Singapore';  //Direct only in Singapore

                region = 'Asia Direct';
            }
            else
            {
                billingCountry = 'Vietnam';  //Indirect only in Vietnam

                region = 'Asia Indirect';
            }
    	}
        else
        {
            throw new AccountFactoryException('Entity on Util_DataMethods.EntityIDsList() not configured in Account Factory');
        }

        //shipping country always equals billing country
        shippingCountry = billingCountry;

        requiredFieldsToValues.put('BillingCountry', billingCountry);
        requiredFieldsToValues.put('ShippingCountry', shippingCountry);

        requiredFieldsToValues.put('Region__c', region);  //required custom field

    	return requiredFieldsToValues;
    }

    /******** METHODS REGION ********/
    //Core 'create' method
	global static Account createAccount(String name, String entityIdAndIsDirect, Boolean isChannelPartner)
	{	
		Account acc = new Account();

		/*** START param validation ***/
		if (name != null && name != '')
		{
			acc.Name = name;
		}
		else
		{
			acc.Name = DEFAULT_DIRECT_NAME;
		}
        
        //if the entityId specified in the param isn't configured on the entity-to-required-fields/values map, throw config error
		if (!entityIdAndIsDirectToRequiredFieldsToValuesNestedMap.containsKey(entityIdAndIsDirect))
		{
	    	throw new AccountFactoryException('Entity\'s required fields not configured in Account Factory');		
		}
        /*** END param validation ***/

        //check that default Account RecordType is available
        if (!recordTypes.containsKey('Standard_Account'))
        {
            throw new AccountFactoryException('Standard_Account RecordType inaccessible by user, inactive, or missing');       
        }
        //check that Channel Partner Account RecordType is available
        if (!recordTypes.containsKey('Channel_Partner'))
        {
            throw new AccountFactoryException('Channel_Partner RecordType inaccessible by user, inactive, or missing');       
        }

        //Account RecordType assignment (and Channel Partner-specific field assignent)
        if (isChannelPartner)
        {
            acc.RecordTypeId = recordTypes.get('Channel_Partner');
            //additional dependant-account field assignment here as needed,
            //or refactor into variant and use assignValuesToFieldsFromMap
        }
        else 
        {
            acc.RecordTypeId = recordTypes.get('Standard_Account');
        }

        /*** START Dynamic field assignment ***/
        factoryBase.assignValuesToFieldsFromMap(acc, entityIdAndIsDirectToRequiredFieldsToValuesNestedMap.get(entityIdAndIsDirect) );
        /*** END Dynamic field assignment ***/

		return acc;
	}

    //Core 'insert' method
    global static List<Account> insertAccounts(List<String> names, List<String> entityIdsAndIsDirect)
    {
        //guard conditions:
        if (names == null || entityIdsAndIsDirect == null 
            || names.size() == 0 || entityIdsAndIsDirect.size() == 0)
        {
            throw new AccountFactoryException('Method cannot have null or empty list parameters');       
        }
        if (names.size() != entityIdsAndIsDirect.size())
        {
            throw new AccountFactoryException('Method requires parameter lists have equal size');       
        }

        Integer recordCount = names.size();

        //Factory records to generate and insert
        List<Account> accs = new List<Account>();

        //for per-account lookup: Billing Contact generation for assignment in FOR loop
        List<Contact> billingContacts = Fact_Contact.insertContacts(recordCount);

        //Special Case indices list: Channel Partner Parent
        List<Integer> cpParentAssignmentCaseIndices = new List<Integer>();

        //per-account creation and lookup assignment; per-special-case-lookup indexing
        for (Integer i = 0; i < recordCount; i++)
        {
            Account accountToInsert = createAccount(names[i], entityIdsAndIsDirect[i], false);

            //Billing Contact assignment
            factoryBase.assignLookupValue(accountToInsert, 'Billing_Contact__c', billingContacts[i].ID);

            //special case test and associated indexing for later use
            if (entityIdsAndIsDirect[i].endsWith('_Indirect'))
            {
                cpParentAssignmentCaseIndices.add(i);
            }

            accs.add(accountToInsert);
        }

        //now that accounts are created and per-account lookups are assigned, generate all
        //special case lookup records and loop through indices lists to assign

        //Generate Channel Partner Parents:
        List<Account> cpAccounts = insertChannelPartnerAccounts(cpParentAssignmentCaseIndices.size());

        //Assignment loop for special case: Channel Partner Parent
        for (Integer i = 0; i < cpParentAssignmentCaseIndices.size(); i++)
        {
            Integer indexOfAccountToAssignCpTo = cpParentAssignmentCaseIndices[i];

            factoryBase.assignLookupValue(accs[indexOfAccountToAssignCpTo], 'ParentId', cpAccounts[i].ID);
        }

        insert accs;

        //In the real org, query for trigger-assigned fields that may be needed by other factories 
        /*List<Account> refreshedAccs = [SELECT ID, ...
                                            FROM Account WHERE ID in :accs];*/
        //return refreshedAccs;

        return accs;
    }

	global static Account insertDirectAccount()
	{
		List<String> names = new List<String>();
        List<String> entityIdsAndIsDirect = new List<String>();
        
        names.add(DEFAULT_DIRECT_NAME);
        entityIdsAndIsDirect.add(DEFAULT_ENTITY_ID_AND_DIRECT);

        return insertAccounts(names, entityIdsAndIsDirect)[0];
    }

    global static Account insertIndirectAccount()
    {
        List<String> names = new List<String>();
        List<String> entityIdsAndIsDirect = new List<String>();
        
        names.add(DEFAULT_INDIRECT_NAME);
        entityIdsAndIsDirect.add(DEFAULT_ENTITY_ID_AND_INDIRECT);

        return insertAccounts(names, entityIdsAndIsDirect)[0];
    }

    global static Account insertAccount(String name, String entityIdAndIsDirect)
    {
        List<String> names = new List<String>();
        List<String> entityIdsAndIsDirect = new List<String>();
        
        names.add(name);
        entityIdsAndIsDirect.add(entityIdAndIsDirect);

        return insertAccounts(names, entityIdsAndIsDirect)[0];
    }

    //bulk insert case with count
    global static List<Account> insertDirectAccounts(Integer count)
    {
        List<String> names = new List<String>();
        List<String> entityIdsAndIsDirect = new List<String>();
        for (Integer i = 0; i < count; i++)
        {
            names.add(DEFAULT_DIRECT_NAME + String.valueOf(i));
            entityIdsAndIsDirect.add(DEFAULT_ENTITY_ID_AND_DIRECT);
        }

        return insertAccounts(names, entityIdsAndIsDirect);
    }

    //each entity bulk case
    global static List<Account> insertDirectAndIndirectAccountForEachEntity()
	{
		List<String> entityIdAndIsDirectList = new List<String>(entityIdAndIsDirectToRequiredFieldsToValuesNestedMap.keySet());

        List<String> names = new List<String>();
        List<String> entityIdsAndIsDirect = new List<String>();

		List<Account> accs = new List<Account>();
		for (Integer i = 0; i < entityIdAndIsDirectList.size(); i++)
		{
            names.add(DEFAULT_DIRECT_NAME + String.valueOf(i));
            entityIdsAndIsDirect.add(entityIdAndIsDirectList[i]);		
        }

        return insertAccounts(names, entityIdsAndIsDirect);
    }

    //bulk CP case
    global static List<Account> insertChannelPartnerAccounts(Integer count)
    {
        List<Account> cpAccountsToInsert = new List<Account>();

        for (Integer i = 0; i < count; i++)
        {
            cpAccountsToInsert.add(createAccount(DEFAULT_CP_NAME + String.valueOf(i), DEFAULT_ENTITY_ID_AND_DIRECT, true));
        }

        insert cpAccountsToInsert;

        //In a real org, query for trigger-assigned fields that may be needed by other factories 
        /*List<Account> refreshedCpAccs = [SELECT ID, ... FROM Account WHERE ID in :cpAccountsToInsert];*/
        
        //return refreshedAccs;

        return cpAccountsToInsert;
    }

    //single CP case
    global static Account insertChannelPartnerAccount()
    {
        return insertChannelPartnerAccounts(1)[0];
    }

}
