global class Fact_OpportunityLineItem
{
	public class OpportunityLineItemFactoryException extends Exception { }

    //component
    private static Fact_BaseComponent factoryBase = new Fact_BaseComponent('OpportunityLineItem');

    //define default constants
    public static final String SOBJECT_NAME = 'OpportunityLineItem';

    public static final String STANDARD_LINEITEM = 'Standard_Lineitem';
    public static final String TRAINING_LINEITEM = 'Training_Lineitem';



    public static final Set<String> DEFAULT_VARIANTS_SET = new Set<String> {STANDARD_LINEITEM, TRAINING_LINEITEM};

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

		//Product2 and ProductCode supplied as params
		//Discount set by Opp's Account (automatically?)

        Integer quantity = 1;
        Decimal unitPrice = 100.00;
        String description = 'Factory OpportunityLineItem description';

    	if (variant == STANDARD_LINEITEM)
    	{

        }
        else if (variant == TRAINING_LINEITEM)
        {
            Integer trainingDateOffsetInMonths = 5;  //training date is 5 month out from today
            Date trainingDate = Date.today().addMonths(trainingDateOffsetInMonths);
            requiredFieldsToValues.put('Training_Date__c', trainingDate);
        }
        else
        {
            throw new OpportunityLineItemFactoryException('Type not configured in OpportunityLineItem Factory');
        }

        requiredFieldsToValues.put('Quantity', quantity);
        requiredFieldsToValues.put('UnitPrice', unitPrice);
        requiredFieldsToValues.put('Description', description);

    	return requiredFieldsToValues;
    }


    /******** METHODS REGION ********/
    //Core 'create' method
	global static OpportunityLineItem createOpportunityLineItem(String variant)
	{	
		OpportunityLineItem oli = new OpportunityLineItem();

		/*** START param validation ***/
		if (!variantToRequiredFieldsToValuesNestedMap.containsKey(variant))
		{
			throw new OpportunityLineItemFactoryException('Fact_OpportunityLineItem does not support variant: ' + variant);       
		}
        /*** END param validation ***/

        //RecordType assignment: SObject has no record types

        /*** START Dynamic field assignment ***/
        factoryBase.assignValuesToFieldsFromMap(oli, variantToRequiredFieldsToValuesNestedMap.get(variant) );
        /*** END Dynamic field assignment ***/

		return oli;
	}

	//Core 'insert' method
    global static List<OpportunityLineItem> insertOpportunityLineItems(Opportunity opp, List<String> skus, List<String> variants)
    {
    	//guard conditions:
        if (opp == null || skus == null || variants == null  
            || skus.size() == 0 || variants.size() == 0)
        {
            throw new OpportunityLineItemFactoryException('Method cannot have null or empty list parameters');       
        }
        if (skus.size() != variants.size())
        {
            throw new OpportunityLineItemFactoryException('Method requires sku and variant parameter lists have equal size');       
        }

        //check that all paramater skus are available for use with Product Factory
        for (String sku : skus)
        {
            if (!Fact_Product.DEFAULT_SKUS_SET.contains(sku))
            {
                throw new OpportunityLineItemFactoryException('Fact_Product does not support sku: ' + sku);       
            }
        }

        //Factory records to generate and insert
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();

        //transform non-distinct parameter sku list to distinct sku list
        Set<String> distinctSkuSet = new Set<String>(skus);
        List<String> distinctSkuList = new List<String>(distinctSkuSet);

        //insert required sObjects for later oli insert
        List<Product2> distinctProducts = Fact_Product.insertProducts(distinctSkuList);

        //product-insert-result guard condition
        if (distinctProducts == null || distinctProducts.size() == 0 || distinctProducts.size() != distinctSkuList.size())
        {
            throw new OpportunityLineItemFactoryException('In OLI Factory, Product Factory failed to produce the expected amount of Product records');       
        }

        //build a list of Product2Ids and Pricebook2Ids for PBE Factory, 
        //and Map of Product2Id to Sku for later use in pbe assignment based on sku paramater
        List<ID> productIdsFromFactory = new List<ID>();
        List<ID> pricebook2IdsFromOpp = new List<ID>();
        Map<ID, String> product2IdToSkuMap = new Map<ID, String>();

        for (Product2 prod : distinctProducts) 
        {
            productIdsFromFactory.add(prod.ID);
            pricebook2IdsFromOpp.add(opp.Pricebook2Id);

            product2IdToSkuMap.put(prod.ID, prod.ProductCode);
        }

        //generate PricebookEntries from factory for assignment to OLI lookup
        List<PricebookEntry> distinctPbes = Fact_PricebookEntry.insertPricebookEntries(productIdsFromFactory, pricebook2IdsFromOpp);
        
        //pbe-insert-result guard condition
        if (distinctPbes == null || distinctPbes.size() == 0 || distinctPbes.size() != distinctSkuList.size())
        {
            throw new OpportunityLineItemFactoryException('In OLI Factory, Product Factory failed to produce the expected amount of Product records');       
        }

        ///map non-distinct sku to unique PBE for later sku-specific assignment to OLI
        Map<String, PricebookEntry> skuToPbeMap = new Map<String, PricebookEntry>();
        for (PricebookEntry pbe : distinctPbes) 
        {
            String skuFromProduct2Id = product2IdToSkuMap.get(pbe.Product2Id);

            skuToPbeMap.put(skuFromProduct2Id, pbe);
        }
        
        //for per-oli lookups:
        for (Integer i = 0; i < skus.size(); i++)
        {
            OpportunityLineItem oliToInsert = createOpportunityLineItem(variants[i]);

            //OpportunityId assignment
            factoryBase.assignLookupValue(oliToInsert, 'OpportunityId', opp.ID);

            //Opportunity's PricebookEntryId assignment
            factoryBase.assignLookupValue(oliToInsert, 'PricebookEntryId', skuToPbeMap.get(skus[i]).ID);

            olis.add(oliToInsert);
        }

        insert olis;

        return olis;
    }
}