import React, { useState } from "react";
import { Text, Divider, Stack, Heading, SimpleGrid, Box } from "@chakra-ui/react";
import { useHistory } from "react-router-dom";
import { useContractReader, useEventListener } from "../hooks";
import { AppContainer, Container } from "./styles/Tokenize";
import { List } from "antd";
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
  const ownerBalanceOf = useContractReader(readContracts, "BatchCollection", "ownerBalanceOf", [address]);
  const userBatches = useContractReader(readContracts, "BatchCollection", "tokenIdsOfOwner", [address]);
  const setMintedEvent = useEventListener(readContracts, "BatchCollection", "BatchMinted", localProvider, 1);

  // let contractAddress = "";

  // if (readContracts) {
  //   contractAddress = readContracts.BatchCollection.address;
  //   console.log(contractAddress);
  // }

  const history = useHistory();
  const [isMinted, setIsMinted] = useState(false);

  async function onChangeIsMinted() {
    await setIsMinted(true);
  }

  // async function onChangeTokenId(event) {
  //   await setTokenId(event.target.value);
  // }

  function takeToTokenization(path) {
    history.push("/tokenize/" + path);
  }

  async function mintNFT() {
    await tx(writeContracts.BatchCollection.mintBatch(address));
    // eslint-disable-next-line no-alert
    alert("You will see a notification when your transcation has been processed. This may take a moment.");
    if (setMintedEvent) onChangeIsMinted();
  }

  return (
    <div>
      <Container>
        <AppContainer>
          <Stack direction={["column", "row"]} align="left">
            <Text fontSize="20px">Tokenize your</Text>
            <Text fontSize="20px" color="#00F6AA">
              Carbon Credits
            </Text>
          </Stack>
          <Divider />

          <Button
            mb={3}
            onClick={() => {
              mintNFT();
            }}
          >
            Click to generate a retirement claim
          </Button>

          {isMinted ? (
            <>
              <br />
              <Text colorScheme="green">Successfully generated a Batch Retirement Claim</Text>
              <Text>Please retire your credits with the registry with the message:</Text>
              <Text>&quot;Retired in the name of CO2ken claim ID NFT Hash &quot;</Text>
            </>
          ) : null}

          <Divider mt={3} />

          {/* <Heading mt={3} fontSize="16" fontWeight="400" fontFamily="Poppins">
            You currently have{" "}
            <span style={{ color: "#00F6AA" }}>
              {ownerBalanceOf !== undefined ? parseInt(ownerBalanceOf._hex, 16) : 0}
            </span>{" "}
            retirement claims in progress
          </Heading> */}

          <Heading mt={3} fontSize="16" fontWeight="400" fontFamily="Poppins">
            You currently have <span style={{ color: "#00F6AA" }}>{userBatches ? userBatches.length : 0}</span>{" "}
            retirement claims in progress
          </Heading>

          {userBatches && userBatches.length
            ? userBatches.map((batch, i) => (
                <>
                  <br />
                  <br />
                  <SimpleGrid columns={2} fontFamily="Cousine">
                    <Box fontWeight="bold">Claim {i + 1}:</Box>
                    <Box>{address + batch}</Box>

                    <Box>
                      <Button
                        onClick={() => {
                          takeToTokenization(address + batch);
                        }}
                      >
                        Continue
                      </Button>
                    </Box>
                    <Box>
                      <Button
                      // onClick={() => {
                      //   burnToken()
                      // }}
                      >
                        Cancel this retirement
                      </Button>
                    </Box>

                    <br />
                  </SimpleGrid>
                  <Divider />
                </>
              ))
            : null}
        </AppContainer>
      </Container>
    </div>
  );
}
