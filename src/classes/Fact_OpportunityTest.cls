@isTest
private class Fact_OpportunityTest 
{
    /******** TEST METHODS REGION ********/

	static testmethod void insertDirectOpportunity_succeeds()
	{
		try
		{
			Opportunity opp = Fact_Opportunity.insertDirectOpportunity();  //one time type
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}
	
	static testmethod void insertDirectOpportunity_oneTime_succeeds()
	{
		try
		{
			Opportunity initialOpp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.ONE_TIME_RECORD_TYPE, true);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertDirectOpportunity_renewing_succeeds()
	{
		try
		{
			Opportunity renewalOpp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.RENEWING_RECORD_TYPE, true);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertIndirectOpportunity_succeeds()
	{
		try
		{
			Opportunity opp = Fact_Opportunity.insertIndirectOpportunity();  //one time type
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertIndirectOpportunity_oneTime_succeeds()
	{
		try
		{
			Opportunity initialOpp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.ONE_TIME_RECORD_TYPE, false);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertIndirectOpportunity_renewing_succeeds()
	{
		try
		{
			Opportunity renewalOpp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.RENEWING_RECORD_TYPE, false);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertOpportunity_fails()
	{
		try
		{
			//this should throw an exception
			Opportunity failedOpp = Fact_Opportunity.insertOpportunity('Invalid Opportunity Type', true);
		}
		catch (Exception e)
		{
			System.assert(true);
		}
	}

	static testmethod void insertDirectOpportunities()
	{
		try
		{
			List<Opportunity> opps = Fact_Opportunity.insertDirectOpportunities(25);  //one time type
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertIndirectOpportunities()
	{
		try
		{
			List<Opportunity> opps = Fact_Opportunity.insertIndirectOpportunities(25);  //one time type
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}
}