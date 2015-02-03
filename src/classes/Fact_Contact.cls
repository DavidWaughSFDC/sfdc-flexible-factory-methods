global class Fact_Contact
{
	public class ContactFactoryException extends Exception { }

	//define default constants
	public static final String SOBJECT_NAME = 'Contact';
    public static final String DEFAULT_RECORD_TYPE_DEVELOPER_NAME = 'Standard_Contact';

    public static final String DEFAULT_FIRST_NAME = 'Linus';  //random first name
    public static final String DEFAULT_LAST_NAME = 'FactoryContact';

    public static final String DEFAULT_VARIANT = 'STANDARD';
	public static final Set<String> DEFAULT_VARIANTS_SET = new Set<String> {DEFAULT_VARIANT};

	//component
	private static Fact_BaseComponent factoryBase = new Fact_BaseComponent(SOBJECT_NAME);

	//members
    private static Map<String, Map<String, Object>> variantToRequiredFieldsToValuesNestedMap = new Map<String, Map<String, Object>>();


    /******** STATIC INITIALIZATION REGION ********/

    static 
    {
    	for (String variant : DEFAULT_VARIANTS_SET)
    	{
        	variantToRequiredFieldsToValuesNestedMap.put(variant, populateRequiredFieldsToValuesMap(variant));
        } 	
    }

    /******** INIT HELPER REGION ********/

    private static  Map<String, String> populateRequiredFieldsToValuesMap(String variant)
    {
    	Map<String, String> requiredFieldsToValues = new Map<String, String>();

        requiredFieldsToValues.put('MailingCountry', 'United States');

    	return requiredFieldsToValues;
    }

    /******** METHODS REGION ********/

	global static Contact createContact()
	{
		return createContact(DEFAULT_FIRST_NAME, DEFAULT_LAST_NAME);
	}

	global static Contact createContact(String firstName, String lastName)
	{	
		Contact con = new Contact();

		/*** START param validation ***/
		if (firstName != null && firstName != '' && lastName != null && lastName != '')
		{
			con.FirstName = firstName;
			con.LastName = lastName;
		}
		else
		{
			con.FirstName = DEFAULT_FIRST_NAME;
			con.LastName = DEFAULT_LAST_NAME;
		}
        /*** END param validation ***/

        //RecordType assignment:
        if (!factoryBase.recordTypesMap.containsKey(DEFAULT_RECORD_TYPE_DEVELOPER_NAME))
        {
            throw new ContactFactoryException(DEFAULT_RECORD_TYPE_DEVELOPER_NAME + ' RecordType inaccessible by user, inactive, or missing');       
        }

        con.RecordTypeId = factoryBase.recordTypesMap.get(DEFAULT_RECORD_TYPE_DEVELOPER_NAME);
        
		/*** START Dynamic field assignment ***/
        factoryBase.assignValuesToFieldsFromMap(con, variantToRequiredFieldsToValuesNestedMap.get(DEFAULT_VARIANT));
        /*** END Dynamic field assignment ***/

		return con;
	}

	global static Contact insertContact()
	{
		Contact contactToInsert = createContact();

		insert contactToInsert;

		return contactToInsert;
    }

    //single insert case
    global static Contact insertContact(String firstName, String lastName)
	{
		Contact contactToInsert = createContact(firstName, lastName);

		insert contactToInsert;

		return contactToInsert;
    }

    //bulk insert case
    global static List<Contact> insertContacts(Integer count)
	{
		//Factory records to generate and insert
		List<Contact> cons = new List<Contact>();
		for (Integer i = 0; i < count; i++)
		{
			cons.add(createContact(DEFAULT_FIRST_NAME, DEFAULT_LAST_NAME + String.valueOf(i)));
		}

		insert cons;

		return cons;
    }
}
