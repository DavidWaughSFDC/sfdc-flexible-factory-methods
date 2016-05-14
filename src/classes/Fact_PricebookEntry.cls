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

    global static List<PricebookEntry> insertPricebookEntries(List<ID> productIds, ID paramPricebook2Id)
    {
        //guard conditions:
        if (productIds == null || productIds.size() == 0 || paramPricebook2Id == null)
        {
            throw new PricebookEntryFactoryException('Method cannot have null or empty parameters');       
        }

        List<PricebookEntry> allPbesForInsert = new List<PricebookEntry>();
        List<PricebookEntry> paramPbes = new List<PricebookEntry>();

        ID standardPricebook2Id = Util_DataMethods.getStandardPricebookId();

        // query to determine if pbe is already added for either the standard or paramater pricebooks
        // (necessary because of seeAllData = true in tests)
        List<PricebookEntry> alreadyInsertedPbes = [SELECT Id,
                                                        UnitPrice,
                                                        Product2Id,
                                                        UseStandardPrice,
                                                        IsActive,
                                                        Pricebook2Id
                                                    FROM PricebookEntry 
                                                    WHERE Product2Id IN :productIds
                                                    AND (Pricebook2Id = :standardPricebook2Id
                                                        OR Pricebook2Id = :paramPricebook2Id)];



        Map<Id, PricebookEntry> alreadyInsertedProductIdsInParamPricebookToPbeMap = new Map<Id, PricebookEntry>();
        Map<Id, PricebookEntry> alreadyInsertedProductIdsInStandardPricebookToPbeMap = new Map<Id, PricebookEntry>();

        // parse above query result into 2 (named) data structures for use below
        for (PricebookEntry alreadyInsertedPbe : alreadyInsertedPbes)
        {
            if (alreadyInsertedPbe.Pricebook2Id == paramPricebook2Id)
            {
                alreadyInsertedProductIdsInParamPricebookToPbeMap.put(alreadyInsertedPbe.Product2Id, alreadyInsertedPbe);
            }

            else if (alreadyInsertedPbe.Pricebook2Id == standardPricebook2Id)
            {
                alreadyInsertedProductIdsInStandardPricebookToPbeMap.put(alreadyInsertedPbe.Product2Id, alreadyInsertedPbe);
            }
        }

        // use 2 filled data structures to determine which products need
        // standard- and param-pricebook entries
        for (Id productId : productIds)
        {
            PricebookEntry pbeToInsert = createPricebookEntry();

            if (!alreadyInsertedProductIdsInParamPricebookToPbeMap.containsKey(productId))
            {
                if (!alreadyInsertedProductIdsInStandardPricebookToPbeMap.containsKey(productId))
                {
                    PricebookEntry standardPbeToInsert = createPricebookEntry();

                    factoryBase.assignLookupValue(standardPbeToInsert, 'Pricebook2Id', standardPricebook2Id);
                    factoryBase.assignLookupValue(standardPbeToInsert, 'Product2Id', productId);
                
                    allPbesForInsert.add(standardPbeToInsert);

                }


                factoryBase.assignLookupValue(pbeToInsert, 'Pricebook2Id', paramPricebook2Id);
                factoryBase.assignLookupValue(pbeToInsert, 'Product2Id', productId);

                // below line commented out because basic use-case only needs standard pricebook
                //allPbesForInsert.add(pbeToInsert);
            }
            else
            {
                pbeToInsert = alreadyInsertedProductIdsInParamPricebookToPbeMap.get(productId);
            }

            // below line commented out because basic use-case only needs standard pricebook
            //paramPbes.add(pbeToInsert);
        }

        insert allPbesForInsert;
        
        // toggle below lines to enable non-standard pricebook (see comments throughout this class)
        return allPbesForInsert;
        //return paramPbes;
    }

    global static PricebookEntry insertPricebookEntry(ID productId, ID pricebook2Id)
    {
        List<ID> productIds = new List<ID>();
        productIds.add(productId);

        return insertPricebookEntries(productIds, pricebook2Id)[0];
    }
}