public with sharing class Util_DataMethods
{
    private static Map<String, Map<String, Id>> allRecordTypesCache;
    
    static 
    {
        allRecordTypesCache = null;
    }


    public static ID getStandardPricebookId()
    {
        ID standardPbeId = null;

        //separate execution paths for test/prod to isolate tests with SeeAllData=false
        if (Test.isRunningtest())
        {
            standardPbeId = Test.getStandardPricebookId();
        }
        else
        {
            Pricebook2 standardPricebook = [SELECT ID
                                            FROM Pricebook2
                                            WHERE isStandard = true];
                                            
            standardPbeId = standardPricebook.ID;
        }

        return standardPbeId;
    }

    /*EntityIDsList is used by Fact_Account, but was purposefully put here to demonstrate that it may be desirable to have
    dependencies outside of the Factory Methods class, like using a business entities list (used by other parts of the
    instance) to determine logical variants without duplicating the list*/
    public static List<string> EntityIDsList()
    {
        List<string> entityIds = new List<string>();
        
        entityIds.add('FooCorp_USA');
        entityIds.add('FooCorp_Euro');
        entityIds.add('FooCorp_Asia');

        return entityIds;
    }

    //Pricebook assignment has been simplified for the demo, so not needed
    /*public static Map<ID, Pricebook2> PopulatePricebookMap()
    {
        //stub
    }*/


    /*******************************RECORD TYPE QUERIES***************************/

    //lazy load all sObject recordtype ids and developer names into static nested map
    public static void populateAllRecordTypesCache() 
    {
        allRecordTypesCache = new Map<String, Map<String, Id>>();

        List<RecordType> queryResults;
        try 
        {
            queryResults = [SELECT ID,
                               SObjectType,
                               Name,
                               DeveloperName
                        FROM RecordType
                        WHERE IsActive = TRUE];
        } 
        catch (Exception e) 
        {
            queryResults = new List<SObject>();
        }

        //group recordTypes (Name, Id pair) by sObject:
        for (RecordType rt : queryResults)
        {
            Map<String, Id> sObjectNameToRecordTypeId = null;

            if (allRecordTypesCache.containsKey(rt.SObjectType))
            {
                sObjectNameToRecordTypeId = allRecordTypesCache.get(rt.SObjectType);
                sObjectNameToRecordTypeId.put(rt.DeveloperName, rt.ID);
            }
            else
            {
                sObjectNameToRecordTypeId = new Map<String, Id>();
                sObjectNameToRecordTypeId.put(rt.DeveloperName, rt.ID);
            }

            allRecordTypesCache.put(rt.SObjectType, sObjectNameToRecordTypeId);
        }

    }

    public static Map<String, ID> mapOfSObjectRecordTypes(String sObjectName)
    {
        //lazy load all sObjects' RecordTypeId nested map:
        if (allRecordTypesCache == null)
        {
            populateAllRecordTypesCache();
        }

        Map<String, ID> developerNameToId = null;
        if (allRecordTypesCache.containsKey(sObjectName))
        {
            developerNameToId = allRecordTypesCache.get(sObjectName);
        }
        
        return developerNameToId;
    }

    public static Map<String, ID> mapOfAccountRecordTypes()
    {
        Map<String, Id> mapOfAccountRecordTypes = mapOfSObjectRecordTypes('Account');
        if (mapOfAccountRecordTypes == null)
        {
            mapOfAccountRecordTypes = new Map<String, ID>();
        }

        return mapOfAccountRecordTypes;
    }

    public static Map<String, ID> mapOfContactRecordTypes()
    {
        Map<String, Id> mapOfContactRecordTypes = mapOfSObjectRecordTypes('Contact');
        if (mapOfContactRecordTypes == null)
        {
            mapOfContactRecordTypes = new Map<String, ID>();
        }

        return mapOfContactRecordTypes;
    }

    public static Map<String, ID> mapOfOpportunityRecordTypes()
    {
        Map<String, Id> mapOfOpportunityRecordTypes = mapOfSObjectRecordTypes('Opportunity');
        if (mapOfOpportunityRecordTypes == null)
        {
            mapOfOpportunityRecordTypes = new Map<String, ID>();
        }

        return mapOfOpportunityRecordTypes;
    }
    /*****************************************************************************/
}