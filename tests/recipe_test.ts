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
