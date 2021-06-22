import React from "react";
import { Heading, Flex, Box, SimpleGrid, Divider, Text } from "@chakra-ui/react";
import { useContractReader, useEventListener, useResolveName } from "../hooks";
import { AccountContainer, Container } from "./styles/Tokenize";

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
      <Heading marginTop="10%" fontFamily="Poppins" align="left" fontSize="14" fontWeight="400">View your minted NFTs</Heading>
        <AccountContainer>
          <Heading fontSize="26" fontWeight="400" mt={5} fontFamily="Poppins">You have <span style={{color:"#00F6AA"}}>{ownerBalanceOf !== undefined ? parseInt(ownerBalanceOf._hex, 16) : 0}</span> NFTs</Heading>
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
          
        </AccountContainer>
      </Container>
    </div>
  );
}
