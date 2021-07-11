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

  return (
    <div>
      <Container maxW="container.lg">
        <Heading marginTop="10%" fontFamily="Poppins" align="left" fontSize="14" fontWeight="400">
          Your tokenized retirement claims
        </Heading>
        <AccountContainer>
          <Heading fontSize="26" fontWeight="400" mt={5} fontFamily="Poppins">
            You have{" "}
            <span style={{ color: "#00F6AA" }}>
              {ownerBalanceOf !== undefined ? parseInt(ownerBalanceOf._hex, 16) : 0}
            </span>{" "}
            retirement claims
          </Heading>
          {userBatches && userBatches.length
            ? userBatches.map(batch => (
                <>
                  <br />
                  <br />
                  <SimpleGrid columns={2} spacing={10}>
                    <Box align="right" fontWeight="bold">
                      Resource Identifier:
                    </Box>
                    <Box align="left">{batch[0]}</Box>

                    <Box align="right" fontWeight="bold">
                      Status:
                    </Box>
                    {batch[4] === false ? (
                      <Box align="left" color="red">
                        unconfirmed
                      </Box>
                    ) : (
                      <Box align="left" color="green">
                        confirmed
                      </Box>
                    )}

                    <Box align="right" fontWeight="bold">
                      Vintage:
                    </Box>
                    <Box align="left">{batch[1]}</Box>

                    <Box align="right" fontWeight="bold">
                      Serial Number:
                    </Box>
                    <Box align="left">{batch[2]}</Box>

                    <Box align="right" fontWeight="bold">
                      Quantity:
                    </Box>
                    <Box align="left">
                      {batch[3] && typeof batch[3] !== "undefined" ? parseInt(batch[3]._hex, 16) : ""}
                    </Box>
                    <br />
                  </SimpleGrid>
                  <Divider />
                </>
              ))
            : null}
        </AccountContainer>
      </Container>
    </div>
  );
}
