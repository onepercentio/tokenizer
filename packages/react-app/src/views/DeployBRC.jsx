import React, { useState } from "react";
import { Text, Divider, Stack } from "@chakra-ui/react";
import { useHistory } from "react-router-dom";
import { useContractReader, useEventListener } from "../hooks";
import { AppContainer, Container } from "./styles/Tokenize";
import { Button } from "./styles/Landing";

export default function Tokenize({
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

  const [isMinted, setIsMinted] = useState(false);

  async function onChangeIsMinted() {
    await setIsMinted(true);
  }

  return (
    <div>
      <Container>
        <AppContainer>
          <Stack direction={["column", "row"]} mb={2} align="left">
            <Text fontSize="20px">Tokenize your</Text>
            <Text fontSize="20px" color="#00F6AA">
              Carbon Credits
            </Text>
          </Stack>
          <Divider />
          
          <Button onClick={() => {
            tx(writeContracts.BatchCollection.mintBatch(address));
            alert("You will see a notification when your transcation has been processed. This may take a moment.");
            onChangeIsMinted();
          }}>
            Click to initiate tokenization
          </Button>

          {
            isMinted ?
            <>
            <br />
            <Text>Please retire your credits with the registry with the message:</Text>
            <Text>&quot;Retired in the name of CO2ken claim ID NFT Hash &quot;</Text>
            <Text>After you have retired the credits, click the button below</Text>
            <a href="/tokenize"><Button>Tokenize</Button></a>
            </>
            :
            null
          }

        </AppContainer>
      </Container>

      
    </div>
  );
}
