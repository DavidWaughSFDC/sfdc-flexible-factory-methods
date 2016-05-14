@isTest
private class Fact_PricebookEntryTest 
{
    /******** TEST METHODS REGION ********/

	static testmethod void insertPricebookEntries_succeeds()
	{
        Test.startTest();
		List<Id> prodIds = new List<Id>();
    	Product2 product1 = Fact_Product.insertProduct(Fact_Product.DEFAULT_SKU);
    	prodIds.add(product1.ID);
    	Product2 product2 = Fact_Product.insertProduct(Fact_Product.DEFAULT_SERVICE_SKU);
    	prodIds.add(product2.ID);

    	//use the same default-opp-account's pricebook for both products for multi-insert test
    	List<Id> pricebook2Ids = new List<Id>();
    	Opportunity opp = Fact_Opportunity.insertDirectOpportunity();

		List<PricebookEntry> pbes = Fact_PricebookEntry.insertPricebookEntries(prodIds, opp.Pricebook2Id);
		Test.stopTest();
	
	}

	static testmethod void insertPricebookEntry_fails()
	{
		try
		{
            Test.startTest();
			//construct Product (with ID) from Factory
        	Product2 product = Fact_Product.insertProduct();
        	ID productId = product.ID;

        	//Cause of failure: use null pricebook, which throws exception
        	ID standardPricebook2Id = Util_DataMethods.getStandardPricebookId();

			PricebookEntry pbe = Fact_PricebookEntry.insertPricebookEntry(productId, null);
			Test.stopTest();
            
            System.assert(false);
		}
		catch (Exception e)
		{
			System.assert(true);
		}
	}
}