import React from "react";
import { Heading, Text, Box, Button, Divider, SimpleGrid, Center } from "@chakra-ui/react";
import { useContractReader } from "../hooks";

export default function Admin({
  props,
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
  const unapprovedTokens = useContractReader(readContracts, "BatchCollection", "tokenizationRequests");

  return (
    <div>
      <Center>
        <Box p="6" m="4" borderWidth="1px" rounded="lg" flexBasis={["auto", "45%"]}>
          <Heading as="h3" size="lg" mb="2">
            Tokenization requests
          </Heading>
          <div>
            {/* <List
              bordered
              dataSource={projectCreatedEvents}
              renderItem={item => {
                return <List.Item>{item}</List.Item>;
              }}
            /> */}
            <Text>
              There are <span style={{ color: "#00F6AA" }}>{unapprovedTokens ? unapprovedTokens.length : 0}</span>{" "}
              unapproved tokens waiting for approval.
            </Text>
            {unapprovedTokens && unapprovedTokens.length
              ? unapprovedTokens.map(token => (
                  <>
                    <br />
                    <br />
                    <SimpleGrid columns={2} spacing={10} mb={2} fontFamily="Cousine">
                      <Box align="right" fontWeight="bold">
                        Resource Identifier:
                      </Box>
                      <Box align="left">{token[0]}</Box>

                      <Box align="right" fontWeight="bold">
                        Status:
                      </Box>
                      {token[4] === false ? (
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
                      <Box align="left">{token[1]}</Box>

                      <Box align="right" fontWeight="bold">
                        Serial Number:
                      </Box>
                      <Box align="left">{token[2]}</Box>

                      <Box align="right" fontWeight="bold">
                        Quantity:
                      </Box>
                      <Box align="left">
                        {token[3] && typeof token[3] !== "undefined" ? parseInt(token[3]._hex, 16) : ""}
                      </Box>
                    </SimpleGrid>
                    <Button
                      mb={2}
                      // onClick={() => {
                      //   tx(writeContracts.BatchCollection.confirmRetirement(tokenId));
                      // }}
                    >
                      Approve
                    </Button>
                    <Divider />
                  </>
                ))
              : ""}
          </div>
        </Box>
        {/* </Flex> */}
      </Center>
    </div>
  );
}
