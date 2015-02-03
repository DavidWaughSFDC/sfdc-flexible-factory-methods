global class Fact_User 
{
	public class UserFactoryException extends Exception { }

    public static final String DEFAULT_PROFILE = 'Standard User';
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';

    private static Map<String, Profile> profileNameToProfileMap = new Map<String, Profile>();
	
    //below static fields needed to insert unique username/emails for all new users within context
	private static String orgId = UserInfo.getOrganizationId();
	private static String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
	private static Integer userInsertCount = 0;
	private static Integer randomInt = Integer.valueOf(Math.rint(math.random() * 1000000));

	global static User insertUser()
	{	
		List<String> profileNames = new List<String> {DEFAULT_PROFILE};

		return insertUsers(profileNames)[0];
	}

	global static User insertUser(String profileName)
	{	
		List<String> profileNames = new List<String> {profileName};

		return insertUsers(profileNames)[0];
	}

	global static List<User> insertUsers(List<String> profileNames)
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

		List<User> usersToInsert = new List<User>();
		for (String profileName : profileNames)
		{
			User userToInsert = new User();

			String uniqueEmail = orgId + dateString + randomInt + String.valueOf(userInsertCount) + '@test' + orgId + '.org';

			userToInsert.Username = uniqueEmail;
			userToInsert.Email = uniqueEmail;
			userToInsert.LastName = 'LastName' + String.valueOf(userInsertCount);
			userToInsert.FirstName = 'FirstName' + String.valueOf(userInsertCount);
			userToInsert.Alias = 'use' + String.valueOf(userInsertCount);
			userToInsert.CommunityNickname ='use' + String.valueOf(userInsertCount);
			userToInsert.ProfileId = profileNameToProfileMap.get(profileName).ID;
			userToInsert.EmailEncodingKey='UTF-8';
			userToInsert.LanguageLocaleKey='en_US';
			userToInsert.LocaleSidKey='en_US';
			userToInsert.TimeZoneSidKey='America/Los_Angeles';
			userToInsert.Country = 'US';

			usersToInsert.add(userToInsert);
			userInsertCount++;
		}

		insert usersToInsert;

		return usersToInsert;
	}
}
