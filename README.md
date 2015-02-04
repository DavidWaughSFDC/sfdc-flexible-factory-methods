#Flexible-Factory-Methods
A Salesforce flexible factory methods template for use with sObjects and a generic developer sandbox instance.  Several standard sObjects are included to demonstrate the template.  Implementing this template will require customizing the existing code to fit your org's configuration, and extending the template to apply to other sObjects as suits your needs.  

For another good guide to SFDC Factory implementation, see https://github.com/mbotos/SmartFactory-for-Force.com)  This repo has more detail on how to assign data types, and was published by our good friends at Mavens.

#Demo Setup
To configure this codeset in a live Salesforce environment, simply spin up a new SFDC developer's instance, add the below custom configuration settings, then deploy these classes using your favorite deployment method (e.g. an IDE like MavensMate + ST3 or copy/paste into Developer Console).

#Developer Sandbox Config Settings for Demo
1. Contact:  add recordtype with developername Standard_Contact
2. Product:  add these three values to the Family picklist (Widget, Service, Training)
3. Account: 
  1. add recordtypes with developernames Standard_Account, Channel_Partner
  2. add custom fields: Region__c (String) and Billing_Contact__c (Contact lookup)
4. Opportunity: 
  1. add recordtypes (and associated sales processes) with developernames One_Time_Opportunity and Renewing_Opportunity
  2. add custom fields: Subscription_Start_Date__c (Date) and End_User_Account (Account lookup)
5. Opportunity Product (LineItem): add custom field: Training_Date__c (Date)

#Validate After Deployment
To test the new apex classes, first run all Fact_sObjectTest classes in a test runner to verify that they all pass.  

The changes will be rolled back, preventing us from inspecting the result, so let's commit a factory-produced record to the database: open an Execute Anonymous window in the Dev Console and execute the following lines of code, then filter by debug statements and navigate to the provided opportunity id to the new factory-produced opportunity record

```java
//two different variants for the first factory method call, one a Boolean representing some desired initial state 
//it's up to you to extend these developer sandbox compatible factories to meet your org's sObject complexity level
Opportunity opp = Fact_Opportunity.insertOpportunity(Fact_Opportunity.ONE_TIME_RECORD_TYPE, false);

List<String> skus = new List<String> {Fact_Product.DEFAULT_SKU, Fact_Product.DEFAULT_TRAINING_SKU};
List<String> variants = new List<String> {Fact_OpportunityLineItem.STANDARD_LINEITEM, Fact_OpportunityLineItem.TRAINING_LINEITEM};

//Parameterize the generation of 2 distinctly decorated lineitems with parent opportunity (attachment is automatic), productcode, and the first of what could be several variants to switch internal factory logic on:
Fact_OpportunityLineItem.insertOpportunityLineItems(opp, skus, variants);

System.debug(opp.ID);
```

The Opportunity factory method automatically populates:
+ the opportunity based on the variants provided (Indirect + One-Time recordtype)
+ an associated end user account (customer) with related billing contact
+ channel partner account (customer's parent)

The OpportunityLineItem factory method automatically populates:
+ two different lineitems based on provided skus (Product) and lineitem variants
+ associated Products and PricebookEntries for above lineitems.  
 
These were all generated dynamically under SeeAllData=false test conditions, using 4 lines of apex.

By checking the debug logs, we can verify that this method consumed just 5 SOQL queries and 6 DML statements.

#Explanation
This repo contains several static Apex classes that contain Factory Methods that generate sObject records for well-known sObjects (Opportunity, OpportunityLineItem, Account, Contact, Product, PricebookEntry, and User) for use in their associated test classes (also useful for inserting persistent test data).  These factory methods would typically be used in Unit Testing to setup your tests with zero dependencies (no querying for records needed in pure test context: @isTest(SeeAllData=false)).  These initial objects demonstrate the template's design, and should be extendable to any sObject, whether standard or custom.

The purpose of the template is to be as flexible as possible in the injection of dependencies into the instantiation of a sObject in a potentially highly customized Salesforce instance with layers of declarative programming (validation rules, workflows, etc) that can be changed from beyond the codebase.  This factory method implementation should be easily updated by intermediate developers to keep pace with (and quickly fix broken tests in) a complex org with potentially distributed administration and development.

Example: if your instance's Opportunity object has important (and possibly required) fields that are also lookups, then these fields need to be populated within the factory method to produce a useful result that can be immediately used in testing without the need to further decorate the result with additional lines of code.  

Another need for flexibility is around required or 'recommended' fields that need to be populated within the factory to produce a useful record.   Additionally, these critical fields may have assignments based on sObject variants like record type or use cases dictated by business logic.  

The goal of this template is to bake as much of this dependency management and variant-routing logic into the factory method class as possible, such that the resulting class and its associated unit tests describe the cire use cases of the sObject within the instance quite broadly.  Due to the purposeful simplicity of the template (which may result in some code repetition), an intermediate developer should be able to read the factory method class and it's tests to gain an immediate understanding of the workings of the instance, as well modify and extend the implementation. 

Readability and extendibility is important when using this template.  Be kind to those that will come after you!

#Notes on Naming
Namespaces:  the code in this repo uses the namespaceless convention of a 3 or 4 character prefix for a grouping of code, followed by an underscore.  Factory method classes are all named Fact_sObject where sObject is the name of the sObject.  Tests are all grouped within the same prefix, suffixed with Test (Fact_sObjectTest).  UTIL_ acts as a utility prefix namespace to contain reusable code that shouldn't be limited only to the Fact_ prefix namespace.

#Trigger Behaviour: include in factory test!
This implementation assumes that sObject trigger behaviour will be completely covered (all critical lines of code exercised) by the associated factory method test class, not in its own trigger unit test class.  This is to centralize the core behaviour of the sObject in one place to allow for ease of understanding of the base configuration of an org for a new, intermediate developer.  

#Hunt Use Cases Beyond Code Coverage
In the factory method tests, it is important to go beyond the tests required to get critical lines of code covered, and determine all variants of records that could be produced, and the execution paths through their associated triggers.  This is a non-trivial exercise and requires deep understanding of the instance, which may be complex with many behavioural inter-relationships. 

My advice to achieve this is to start by getting all lines of code covered using the minimum number of variants (to get a handle on execution paths), then expand to all variants using the test names you've come up with to get good coverage (even if it appears the test is not necessary because another test exercises the code, the goal is to exercise each use case, and we can use variants to group for this.)  My experience has been that you will go back and forth between the factory method class and it's test class, adding variants and dependencies until, then checking code coverage, until you build up the knowledge to deem the variants-list complete.  You will also have to revisit the factory when you begin working to cover units that use these sObjects in new ways, and that's what they're designed for: flexibility! 
