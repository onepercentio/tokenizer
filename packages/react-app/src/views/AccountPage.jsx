import React from "react";
import { Heading, Flex, Box, SimpleGrid, Divider, Text } from "@chakra-ui/react";
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
          
            {userBatches && userBatches.length ? userBatches.map(batch => 
            <>
            <SimpleGrid>
            <Box fontFamily="Cousine">
                <Text align="left">Resource Identifier: {batch[0]}</Text>
                <Text align="left">Vintage: {batch[1]}</Text>
                <Text align="left">Serial Number: {batch[2]}</Text>
                <Text align="left">Quantity: {parseInt(batch[3]._hex, 16)}</Text>
            </Box>
            </SimpleGrid>
            <Divider />
            </>) : null}
          
        </AppContainer>
      </Container>
    </div>
  );
}
