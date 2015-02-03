public with sharing class Fact_BaseComponent 
{
	public class BaseFactoryException extends Exception { }

	/******** MEMBERS REGION ********/

	public Map<String, Schema.DisplayType> fieldNameToTypeMap = new Map<String, Schema.DisplayType>();
	public Map<String, ID> recordTypesMap = new Map<String, String>();

	/******** CONSTRUCTOR REGION ********/

	public Fact_BaseComponent(String objectName)
	{
		populateFieldNameToTypeMap(objectName);
		recordTypesMap = UtilityMethods_Data.mapOfSObjectRecordTypes(objectName);
	}


	/******** PRIVATE HELPER REGION ********/

	private void populateFieldNameToTypeMap(String objectName)
	{
		List<String> objNames = new List<String>();
		objNames.add(objectName);
		Schema.DescribeSobjectResult objDescribe = Schema.describeSObjects(objNames)[0];
		for (Schema.SObjectField objectFields : objDescribe.fields.getMap().values())
		{
			Schema.DescribeFieldResult fieldDescribe = objectFields.getDescribe();
			fieldNameToTypeMap.put(fieldDescribe.getName(), fieldDescribe.getType());
		}
	}

	//convert value to correct field-type based on oppFieldNameToTypeMap
	private void assignValueToField(SObject obj, String fieldName, Object value)
	{
		if (fieldNameToTypeMap.get(fieldName) != null)
		{
			Schema.DisplayType fieldType = fieldNameToTypeMap.get(fieldName);
			if (fieldType == Schema.DisplayType.Date)
			{
				obj.put(fieldName, (Date) value);
			}
			else if (fieldType == Schema.DisplayType.DateTime)
			{
				obj.put(fieldName, (DateTime) value);
			}
			else if (fieldType == Schema.DisplayType.Boolean)
			{
				obj.put(fieldName, (Boolean) value);
			}
			else if (fieldType == Schema.DisplayType.Integer)
			{
				obj.put(fieldName, (Integer) value);
			}
			else if (fieldType == Schema.DisplayType.Double)
			{
				obj.put(fieldName, (Decimal) value);
			}
			else //assume type is String
			{
				obj.put(fieldName, value);
			}
		}
		else
		{
			throw new BaseFactoryException('BaseFactory cannot determine field-type during field assignment');
		}
	}


	/******** METHODS REGION ********/

	//convert value to correct field-type based on oppFieldNameToTypeMap
	public void assignValuesToFieldsFromMap(SObject obj, Map<String, Object> requiredFieldsToValues)
	{
		if (requiredFieldsToValues != null)
		{
			for (String fieldName : requiredFieldsToValues.keySet())
			{
				if (requiredFieldsToValues.get(fieldName) != null)
				{
					//dynamic DML using value from map of fieldName to Object, cast based on fieldType 
					assignValueToField(obj, fieldName, requiredFieldsToValues.get(fieldName));
				}
			}
		}
		else
		{
			throw new BaseFactoryException('BaseFactory error: required fields map cannot be null');
		}

	}

	//attaches newly inserted, factory-produced lookup record
	public void assignLookupValue(SObject obj, String fieldName, ID lookupId)
	{
		obj.put(fieldName, lookupId);
	}
}
