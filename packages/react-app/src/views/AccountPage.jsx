import React from "react";
import { Heading, Flex, Box, SimpleGrid } from "@chakra-ui/react";
import { useContractReader, useEventListener, useResolveName } from "../hooks";
import { AppContainer, Container } from "./styles/Tokenize";

export default function AccountPage({
  address,
  mainnetProvider,
  userProvider,
  localProvider,
  yourLocalBalance,
  price,
  tx,
  readContracts,
  writeContracts,
}) {
  const ownerBalanceOf = useContractReader(readContracts, "BatchCollection", "ownerBalanceOf", [address]);
  const userBatches = useContractReader(readContracts, "BatchCollection", "tokensOfOwner", [address]);
  console.log("userBatches are:", userBatches);

  return (
    <div>
      <Container>
        <AppContainer>
          <Heading>You have {ownerBalanceOf !== undefined ? parseInt(ownerBalanceOf._hex, 16) : 0} NFTs</Heading>
          <SimpleGrid>
            {userBatches && userBatches.length ? userBatches.map(batch => <Box>{JSON.stringify(batch)}</Box>) : null}
          </SimpleGrid>
        </AppContainer>
      </Container>
    </div>
  );
}
