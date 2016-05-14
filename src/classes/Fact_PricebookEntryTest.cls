@isTest
private class Fact_PricebookEntryTest 
{
    /******** TEST METHODS REGION ********/

	static testmethod void insertPricebookEntry_succeeds()
	{
		try
		{
        	//construct Product (with ID) from Factory
        	Product2 product = Fact_Product.insertProduct();
        	ID productId = product.ID;

        	//construct Opp (with ID) from Factory and get auto-assigned PricebookId from Account
        	Opportunity opp = Fact_Opportunity.insertDirectOpportunity();
        	ID pricebook2Id = opp.Pricebook2Id;

			Test.startTest();
			PricebookEntry pbe = Fact_PricebookEntry.insertPricebookEntry(productId, pricebook2Id);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertPricebookEntries_succeeds()
	{
		try
		{
			List<Id> prodIds = new List<Id>();
        	Product2 product1 = Fact_Product.insertProduct(Fact_Product.DEFAULT_SKU);
        	prodIds.add(product1.ID);
        	Product2 product2 = Fact_Product.insertProduct(Fact_Product.DEFAULT_SERVICE_SKU);
        	prodIds.add(product2.ID);

        	//use the same default-opp-account's pricebook for both products for multi-insert test
        	List<Id> pricebook2Ids = new List<Id>();
        	Opportunity opp = Fact_Opportunity.insertDirectOpportunity();
        	pricebook2Ids.add(opp.Pricebook2Id);
        	pricebook2Ids.add(opp.Pricebook2Id);


			Test.startTest();
			List<PricebookEntry> pbes = Fact_PricebookEntry.insertPricebookEntries(prodIds, pricebook2Ids);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertPricebookEntry_fails()
	{
		try
		{
			//construct Product (with ID) from Factory
        	Product2 product = Fact_Product.insertProduct();
        	ID productId = product.ID;

        	//Cause of failure: use Standard PricebookId and force double-insert of pbe for product to 
        	//Standard Pricebook, which throws exception
        	ID standardPricebook2Id = Util_DataMethods.getStandardPricebookId();

			Test.startTest();
			PricebookEntry pbe = Fact_PricebookEntry.insertPricebookEntry(productId, standardPricebook2Id);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(true);
		}
	}
}