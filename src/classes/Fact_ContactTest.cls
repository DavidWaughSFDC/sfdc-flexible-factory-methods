@isTest
private class Fact_ContactTest 
{
    /******** TEST METHODS REGION ********/

	static testmethod void insertContact_succeeds()
	{
		try
		{
			Contact con = Fact_Contact.insertContact();
			Contact con2 = Fact_Contact.insertContact(Fact_Contact.DEFAULT_FIRST_NAME, Fact_Contact.DEFAULT_LAST_NAME);
			Contact con3 = Fact_Contact.insertContact(null, null);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertContacts_succeeds_with25Contacts()
	{
		try
		{
			Fact_Contact.insertContacts(25);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}
}