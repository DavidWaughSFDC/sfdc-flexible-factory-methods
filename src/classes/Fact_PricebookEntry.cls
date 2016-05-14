global class Fact_PricebookEntry
{
	public class PricebookEntryFactoryException extends Exception { }

	//define default constants
	public static final String SOBJECT_NAME = 'PricebookEntry';

	public static final String DEFAULT_VARIANT = 'STANDARD';
    public static final Set<String> DEFAULT_VARIANTS_SET = new Set<String> {DEFAULT_VARIANT};

	//component
	private static Fact_BaseComponent factoryBase = new Fact_BaseComponent('PricebookEntry');

	//members
    private static Map<String, Map<String, Object>> variantToRequiredFieldsToValuesNestedMap = new Map<String, Map<String, Object>>();

    /******** STATIC INITIALIZATION REGION ********/

    static 
    {
        for (String variant : DEFAULT_VARIANTS_SET)
    	{
        	variantToRequiredFieldsToValuesNestedMap.put(variant, populateRequiredFieldsToValuesMap(variant));
        }
    }

	/******** INIT HELPER REGION ********/
    
    private static Map<String, Object> populateRequiredFieldsToValuesMap(String variant)
    {
		Map<String, Object> requiredFieldsToValues = new Map<String, Object>();

        Double unitPrice = 100.00;
        Boolean useStandardPrice = false;
        Boolean isActive = true;

    	if (variant == DEFAULT_VARIANT)
    	{
            //variant-specific field assignment
        }
        else
        {
            throw new PricebookEntryFactoryException('Variant ' + variant + ' not configured in PricebookEntry Factory');
        }

        requiredFieldsToValues.put('UnitPrice', unitPrice);
        requiredFieldsToValues.put('UseStandardPrice', useStandardPrice);
        requiredFieldsToValues.put('IsActive', isActive);

    	return requiredFieldsToValues;
    }

    /******** METHODS REGION ********/

    //Core 'create' method
	global static PricebookEntry createPricebookEntry()
	{	
		PricebookEntry pbe = new PricebookEntry();

		/*** START param validation ***/
		
		//if recordTypeName param's RecordType isn't available, throw config. error
        if (!variantToRequiredFieldsToValuesNestedMap.containsKey(DEFAULT_VARIANT))
        {
            throw new PricebookEntryFactoryException('Variant ' + DEFAULT_VARIANT + ' not configured in PricebookEntry Factory');       
        }
        /*** END param validation ***/

        //RecordType assignment: SObject has no record types

        /*** START Dynamic field assignment ***/
		Map<String, Object> requiredFieldsToValues = variantToRequiredFieldsToValuesNestedMap.get(DEFAULT_VARIANT);

		for (String fieldName : requiredFieldsToValues.keySet())
		{
			if (requiredFieldsToValues.get(fieldName) != null)
			{
				//dynamic DML using value from map of fieldName to Object, cast based on fieldType 
				factoryBase.assignValuesToFieldsFromMap(pbe, variantToRequiredFieldsToValuesNestedMap.get(DEFAULT_VARIANT));
			}
		}
        /*** END Dynamic field assignment ***/

		return pbe;
	}

	//Core 'insert' method
    global static List<PricebookEntry> insertPricebookEntries(List<ID> productIds, List<ID> pricebook2Ids)
    {
        //guard conditions:
        if (productIds == null || productIds.size() == 0
        	|| pricebook2Ids == null || pricebook2Ids.size() == 0)
        {
            throw new PricebookEntryFactoryException('Method cannot have null or empty list parameters');       
        }
        if (productIds.size() != pricebook2Ids.size())
        {
            throw new PricebookEntryFactoryException('Method requires parameter lists have equal size');       
        }

        Integer recordCount = productIds.size();

        //Factory records to generate and insert
        List<PricebookEntry> standardPbes = new List<PricebookEntry>();
        List<PricebookEntry> pbes = new List<PricebookEntry>();

        ID standardPricebook2Id = Util_DataMethods.getStandardPricebookId();

	    //for per-pbe lookups: Product2Id from parameter and Pricebook2Id from UltilityMethod_Data
        for (Integer i = 0; i < recordCount; i++)
        {
        	//note: each pricebookEntry tied to a Pricebook2Id needs a standard entry first, so this
        	//loop adds the standard pbe and then the Pricebook2-specific entry
        	//Only the non-standard pbe need be returned

            //DEMO Note: because the demo relies exclusively on the StandardPricebook for simplicity's sake,
            //the second, parameter-based pricebook entry is commented out on line 121, 125, 129, and 132. Restore 
            //and remove shortcut return once you have the factory opportunities being correctly assigned pricebooks 

        	PricebookEntry standardPbeToInsert = createPricebookEntry();
            //PricebookEntry pbeToInsert = createPricebookEntry();

            //Pricebook2Id assignments
            factoryBase.assignLookupValue(standardPbeToInsert, 'Pricebook2Id', standardPricebook2Id);
            //factoryBase.assignLookupValue(pbeToInsert, 'Pricebook2Id', pricebook2Ids[i]);

            //Product2Id assignment
            factoryBase.assignLookupValue(standardPbeToInsert, 'Product2Id', productIds[i]);
            //factoryBase.assignLookupValue(pbeToInsert, 'Product2Id', productIds[i]);

            pbes.add(standardPbeToInsert);
            //pbes.add(pbeToInsert);
        }

        insert pbes;  
        //Demo shortcut return
        return pbes;
        //insert pbes;

        //return only second, non-standard pbe for each insert above
        List<PricebookEntry> nonStandardPbes = new List<PricebookEntry>();
        for (Integer i = 1; i < pbes.size(); i = i + 2)
       	{
       		nonStandardPbes.add(pbes[i]);
       	}

        return nonStandardPbes;
    }

    global static PricebookEntry insertPricebookEntry(ID productId, ID pricebook2Id)
	{
		List<ID> productIds = new List<ID>();
		List<ID> pricebook2Ids = new List<ID>();
        productIds.add(productId);
        pricebook2Ids.add(pricebook2Id);

        return insertPricebookEntries(productIds, pricebook2Ids)[0];
    }
}