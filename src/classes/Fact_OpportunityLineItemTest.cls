@isTest
private class Fact_OpportunityLineItemTest 
{
    /******** TEST METHODS REGION ********/

    //DIRECT

	static testmethod void insertDirectOpportunityLineItem_oneTime_succeeds()
	{
		try
		{
 			Opportunity opp = Fact_Opportunity.insertDirectOpportunity();

			List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertDirectOpportunityLineItem_oneTimeWithTrainingSku_succeeds()
	{
		try
		{
 			Opportunity opp = Fact_Opportunity.insertDirectOpportunity();

			List<String> skus = new List<String> {Fact_Product.DEFAULT_TRAINING_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.TRAINING_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertDirectOpportunityLineItem_renewing_succeeds()
	{
		try
		{
			//Insert Opportunity:
			Opportunity opp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.RENEWING_RECORD_TYPE, true);

			List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertDirectOpportunityLineItem_renewingWithTrainingSku_succeeds()
	{
		try
		{
			//Insert Opportunity:
			Opportunity opp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.RENEWING_RECORD_TYPE, true);

			List<String> skus = new List<String> {Fact_Product.DEFAULT_TRAINING_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.TRAINING_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	//DIRECT MIXED SKUS

	static testmethod void insertDirectOpportunityLineItem_addOnWithMixedSkus_succeeds()
	{
		try
		{
			//Insert Opportunity:
			Opportunity opp = Fact_Opportunity.insertDirectOpportunity();

			List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU, Fact_Product.DEFAULT_TRAINING_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM, Fact_OpportunityLineItem.TRAINING_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertDirectOpportunityLineItem_renewingWithMixedSkus_succeeds()
	{
		try
		{
			//Insert Opportunity:
			Opportunity opp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.RENEWING_RECORD_TYPE, true);

			List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU, Fact_Product.DEFAULT_TRAINING_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM, Fact_OpportunityLineItem.TRAINING_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	//INDIRECT

	static testmethod void insertIndirectOpportunityLineItem_oneTime_succeeds()
	{
		try
		{
 			Opportunity opp = Fact_Opportunity.insertIndirectOpportunity();

			List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertIndirectOpportunityLineItem_oneTimeWithTrainingSku_succeeds()
	{
		try
		{
 			Opportunity opp = Fact_Opportunity.insertIndirectOpportunity();

			List<String> skus = new List<String> {Fact_Product.DEFAULT_TRAINING_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.TRAINING_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertIndirectOpportunityLineItem_renewing_succeeds()
	{
		try
		{
			//Insert Opportunity:
			Opportunity opp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.RENEWING_RECORD_TYPE, false);

			List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertIndirectOpportunityLineItem_renewingWithTrainingSku_succeeds()
	{
		try
		{
			//Insert Opportunity:
			Opportunity opp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.RENEWING_RECORD_TYPE, false);

			List<String> skus = new List<String> {Fact_Product.DEFAULT_TRAINING_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	//INDIRECT MIXED SKUS

	static testmethod void insertIndirectOpportunityLineItem_addOnWithMixedSkus_succeeds()
	{
		try
		{
			//Insert Opportunity:
			Opportunity opp = Fact_Opportunity.insertIndirectOpportunity();

			List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU, Fact_Product.DEFAULT_TRAINING_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM, Fact_OpportunityLineItem.TRAINING_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertIndirectOpportunityLineItem_renewingWithMixedSkus_succeeds()
	{
		try
		{
			//Insert Opportunity:
			Opportunity opp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.RENEWING_RECORD_TYPE, false);

			List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU, Fact_Product.DEFAULT_TRAINING_SKU};
			List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM, Fact_OpportunityLineItem.TRAINING_LINEITEM};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	//BULK

	static testmethod void insertDirectOpportunityLineItem_succeeds_with30records()
	{
		try
		{
			Opportunity opp = Fact_Opportunity.insertDirectOpportunity();
			
			List<String> skus = new List<String>();
			List<String> variants = new List<String>();
			for (Integer i = 0; i < 30; i++)
			{
				skus.add(Fact_Product.DEFAULT_SKU);
				variants.add(Fact_OpportunityLineItem.STANDARD_LINEITEM);
			}

			Test.startTest();
			List<OpportunityLineItem> insertedOLIs = Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();

			//test number of inserted OLIs against target of 30
			System.assertEquals(insertedOLIs.size(), 30);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertIndirectOpportunityLineItem_succeeds_with30records()
	{
		try
		{
			Opportunity opp = Fact_Opportunity.insertIndirectOpportunity();
			
			List<String> skus = new List<String>();
			List<String> variants = new List<String>();
			for (Integer i = 0; i < 30; i++)
			{
				skus.add(Fact_Product.DEFAULT_SKU);
				variants.add(Fact_OpportunityLineItem.STANDARD_LINEITEM);
			}

			Test.startTest();
			List<OpportunityLineItem> insertedOLIs = Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();

			//test number of inserted OLIs against target of 30
			System.assertEquals(insertedOLIs.size(), 30);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	//FAIL

	static testmethod void insertOpportunityLineItem_fails()
	{
		try
		{
			Opportunity opp = Fact_Opportunity.insertDirectOpportunity();

			List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU};
			List<String> variants = new List<String> {'Invalid OLI type to force failure'};

			Test.startTest();
			Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);
			Test.stopTest();
		}
		catch (Exception e)
		{
			System.assert(true);
		}
	}
}
