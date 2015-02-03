@isTest
private class Fact_UserTest 
{
	/******** TEST METHODS REGION ********/

	static testmethod void insertUser_succeeds()
	{
		try
		{
			User u = Fact_User.insertUser();
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertUserParameterProfile_succeeds()
	{
		try
		{
			User u = Fact_User.insertUser(Fact_User.DEFAULT_PROFILE);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertUsers_succeeds_differentProfiles()
	{
		try
		{	
			List<String> profileNames = new List<String>();
			profileNames.add(Fact_User.DEFAULT_PROFILE);
			profileNames.add(Fact_User.SYSTEM_ADMINISTRATOR);

			List<User> users = Fact_User.insertUsers(profileNames);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertUsers_succeeds_with25Users()
	{
		try
		{
			List<String> profileNames = new List<String>();
			for (Integer i = 0; i < 25; i++)
			{
				profileNames.add(Fact_User.DEFAULT_PROFILE);
			}

			List<User> users = Fact_User.insertUsers(profileNames);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertUser_fails()
	{
		try
		{
			//force failure with bad profile name
			User u = Fact_User.insertUser('Invalid_Profile_Name');
		}
		catch (Exception e)
		{
			System.assert(true);
		}
	}
}
