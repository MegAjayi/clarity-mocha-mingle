import { Clarinet, Chain, Account, Tx, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure user can create a recipe",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    const recipe = {
      title: "Perfect Espresso",
      ingredients: "18g fine ground coffee, hot water",
      instructions: "Pull shot for 25-30 seconds"
    };
    
    const block = chain.mineBlock([
      Tx.contractCall("recipe", "create-recipe", [
        types.utf8(recipe.title),
        types.utf8(recipe.ingredients),
        types.utf8(recipe.instructions)
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    assertEquals(block.receipts[0].result.expectOk(), '0');
  },
});

Clarinet.test({
  name: "Ensure rating validation works correctly",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    // First create a recipe
    let block = chain.mineBlock([
      Tx.contractCall("recipe", "create-recipe", [
        types.utf8("Test Recipe"),
        types.utf8("Test Ingredients"),
        types.utf8("Test Instructions")
      ], deployer.address)
    ]);
    
    // Try invalid rating (0)
    block = chain.mineBlock([
      Tx.contractCall("recipe", "rate-recipe", [
        types.uint(0),
        types.uint(0)
      ], deployer.address)
    ]);
    block.receipts[0].result.expectErr();

    // Try valid rating
    block = chain.mineBlock([
      Tx.contractCall("recipe", "rate-recipe", [
        types.uint(0),
        types.uint(5)
      ], deployer.address)
    ]);
    block.receipts[0].result.expectOk();
  },
});
