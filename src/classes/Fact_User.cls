global class Fact_User 
{
	public class UserFactoryException extends Exception { }

    public static final String DEFAULT_PROFILE = 'Standard User';
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';

    private static Map<String, Profile> profileNameToProfileMap = new Map<String, Profile>();
	
    //below static fields needed to insert unique username/emails for all new users within context
	private static String orgId = UserInfo.getOrganizationId();
	private static String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
	private static Integer userCreateCount = 0;
	private static Integer randomInt = Integer.valueOf(Math.rint(math.random() * 1000000));

	global static User createUser()
	{	
		List<String> profileNames = new List<String> {DEFAULT_PROFILE};

		return createUsers(profileNames)[0];
	}

	global static User createUser(String profileName)
	{	
		List<String> profileNames = new List<String> {profileName};

		return createUsers(profileNames)[0];
	}

	global static List<User> createUsers(List<String> profileNames)
	{
		//lazy map of profiles in profileNames elements to static member profileNameToProfileMap
		Set<String> unmappedProfileNames = new Set<String>();
		for (String profileName : profileNames)
		{
			if (!profileNameToProfileMap.containsKey(profileName))
			{
				unmappedProfileNames.add(profileName);
			}
		}

		if (unmappedProfileNames.size() > 0)
		{
			List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name = :unmappedProfileNames];

			if (profiles.size() != unmappedProfileNames.size())
			{
				throw new UserFactoryException('No Profile query result for specified profile name in User Factory');
			}

			for (Profile p : profiles)
			{
				profileNameToProfileMap.put(p.Name, p);
			}
		}

		List<User> usersToCreate = new List<User>();
		for (String profileName : profileNames)
		{
			User userToCreate = new User();

			String uniqueEmail = orgId + dateString + randomInt + String.valueOf(userCreateCount) + '@test' + orgId + '.org';

			userToCreate.Username = uniqueEmail;
			userToCreate.Email = uniqueEmail;
			userToCreate.LastName = 'LastName' + String.valueOf(userCreateCount);
			userToCreate.FirstName = 'FirstName' + String.valueOf(userCreateCount);
			userToCreate.Alias = 'use' + String.valueOf(userCreateCount);
			userToCreate.CommunityNickname ='use' + String.valueOf(userCreateCount);
			userToCreate.ProfileId = profileNameToProfileMap.get(profileName).ID;
			userToCreate.EmailEncodingKey='UTF-8';
			userToCreate.LanguageLocaleKey='en_US';
			userToCreate.LocaleSidKey='en_US';
			userToCreate.TimeZoneSidKey='America/Los_Angeles';
			userToCreate.Country = 'US';

			usersToCreate.add(userToCreate);
			userCreateCount++;
		}

        return usersToCreate;
	}
}
