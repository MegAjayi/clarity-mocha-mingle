import { Clarinet, Chain, Account, Tx, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure user can create profile",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    const block = chain.mineBlock([
      Tx.contractCall("profile", "set-profile", [
        types.utf8("coffee_lover"),
        types.utf8("Coffee enthusiast and home barista")
      ], deployer.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk();
  },
});
