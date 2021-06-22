import React from "react";
import { Heading, Flex, Box, SimpleGrid } from "@chakra-ui/react";
import { useContractReader, useEventListener, useResolveName } from "../hooks";
import {AppContainer, Container} from "./styles/Tokenize"

export default function AccountPage({address, mainnetProvider, userProvider, localProvider, yourLocalBalance, price, tx, readContracts, writeContracts }) {
  
  const ownerBalanceOf = useContractReader(readContracts, "BatchCollection", "ownerBalanceOf", [address])
  const getNFTs = useContractReader(readContracts, "BatchCollection", "getNftData", [2])
  console.log("getNFTS are:", getNFTs)

return (
    <div>
      <Container>
        <AppContainer>
        <Heading>You have {ownerBalanceOf !== undefined ? parseInt(ownerBalanceOf._hex, 16) : 0} NFTs</Heading>
        <SimpleGrid>
          {/* {NFTarray.map((NFT) => (<Box>{NFT}</Box>))} */}
        </SimpleGrid>
        </AppContainer>
      </Container>
    </div>
  );
}
