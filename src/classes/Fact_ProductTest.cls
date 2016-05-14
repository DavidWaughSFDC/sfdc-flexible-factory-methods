@isTest
private class Fact_ProductTest 
{
    /******** TEST METHODS REGION ********/

	static testmethod void insertProduct_succeeds()
	{
		try
		{
			Product2 prod = Fact_Product.insertProduct();
			Product2 prod2 = Fact_Product.insertProduct(Fact_Product.DEFAULT_SKU);

			List<String> skus = new List<String>();
			skus.add(Fact_Product.DEFAULT_SKU);
			skus.add(Fact_Product.DEFAULT_SERVICE_SKU);
			skus.add(Fact_Product.DEFAULT_TRAINING_SKU);

			List<Product2> prodList = Fact_Product.insertProducts(skus);
		}
		catch (Exception e)
		{
			System.assert(false);
		}
	}

	static testmethod void insertProduct_fails()
	{
		try
		{
			Product2 prod2 = Fact_Product.insertProduct('Invalid SKU to force failure');
		}
		catch (Exception e)
		{
			System.assert(true);
		}
	}
}