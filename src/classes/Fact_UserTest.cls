@isTest
private class Fact_UserTest 
{
	/******** TEST METHODS REGION ********/

	static testmethod void runAsUser_succeeds()
	{
		try
		{
			User u = Fact_User.createUser();
            System.runAs(u)
            {
                //runAs block
            }
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void  runAsUserParameterProfile_succeeds()
	{
		try
		{
			User u = Fact_User.createUser(Fact_User.DEFAULT_PROFILE);
            System.runAs(u)
            {
                //runAs block
            }
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void runAsUsers_succeeds_differentProfiles()
	{
		try
		{	
			List<String> profileNames = new List<String>();
			profileNames.add(Fact_User.DEFAULT_PROFILE);
			profileNames.add(Fact_User.SYSTEM_ADMINISTRATOR);

			List<User> users = Fact_User.createUsers(profileNames);
            System.runAs(users[0])
            {
                //runAs block
            }
            System.runAs(users[1])
            {
                //runAs block
            }
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void createUsers_succeeds_with25Users()
	{
		try
		{
			List<String> profileNames = new List<String>();
			for (Integer i = 0; i < 25; i++)
			{
				profileNames.add(Fact_User.DEFAULT_PROFILE);
			}

			List<User> users = Fact_User.createUsers(profileNames);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void createUser_fails()
	{
		try
		{
			//force failure with bad profile name
			User u = Fact_User.createUser('Invalid_Profile_Name');
		}
		catch (Exception e)
		{
			System.assert(true);
		}
	}
}
