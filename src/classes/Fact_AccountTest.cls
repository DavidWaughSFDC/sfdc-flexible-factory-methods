@isTest
private class Fact_AccountTest 
{
    /******** TEST METHODS REGION ********/
    static testmethod void insertDirectAccount_succeeds()
	{
		try
		{
			Account acc = Fact_Account.insertDirectAccount();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertParameterizedAccount_succeeds()
	{
		try
		{
			Account acc = Fact_Account.insertAccount(Fact_Account.DEFAULT_DIRECT_NAME, Fact_Account.DEFAULT_ENTITY_ID_AND_DIRECT);
			Account anotherAcc = Fact_Account.insertAccount(Fact_Account.DEFAULT_INDIRECT_NAME, Fact_Account.DEFAULT_ENTITY_ID_AND_INDIRECT);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertChannelPartnerAccount_succeeds()
	{
		try
		{
			Account a = Fact_Account.insertChannelPartnerAccount();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	//Note: invalid name falls through to Factory default name.  Invalid EntityID throws AccountFactoryException.
	static testmethod void insertAccount_fails_withInvalidParam()
	{
		try
		{
			Account anotherAcc  = Fact_Account.insertAccount(null, 'Invalid_Enity_Key');
		}
		catch (Fact_Account.AccountFactoryException e)
		{
			System.assert(true);
		}
	}

	static testmethod void insertDirectAccounts_succeeds_with25Accounts()
	{
		try
		{
			Fact_Account.insertDirectAccounts(25);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertParameterizedAccounts_succeeds_with25Accounts()
	{
		List<String> names = new List<String>();
		List<String> entityIdAndIsDirectList = new List<String>();

		for (Integer i = 0; i < 25; i++)
		{
			names.add(Fact_Account.DEFAULT_DIRECT_NAME + String.valueOf(i));
			entityIdAndIsDirectList.add(Fact_Account.DEFAULT_ENTITY_ID_AND_DIRECT);
		}

		try
		{
			Fact_Account.insertAccounts(names, entityIdAndIsDirectList);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertDirectAndIndirectAccountForEachEntity_succeeds()
	{
		try
		{
			Fact_Account.insertDirectAndIndirectAccountForEachEntity();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}
}