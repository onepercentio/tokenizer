import React, { useState } from "react";
import { List } from "antd";
import { Heading, Text, Flex, Box, Button, Input, Divider, Stack, Switch, Center } from "@chakra-ui/react";
import { parseEther, formatEther } from "@ethersproject/units";
import { useHistory } from "react-router-dom";
import { useContractReader, useEventListener, useResolveName } from "../hooks";

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
  // keep track of a variable from the contract in the local React state:
  const purpose = useContractReader(readContracts, "BatchCollection", "purpose");
  console.log("🤗 !! purpose:", purpose);

  // const ownerBalanceOf = useContractReader(readContracts,"ProjectContract", "ownerBalanceOf", ["0xD2CAc44B9d072A0D6bD39482147d894f13C5CF32"])
  // console.log("🤗 ownerBalanceOf:", ownerBalanceOf)

  // 📟 Listen for broadcast events
  const projectCreatedEvents = useEventListener(readContracts, "ProjectFactory", "ProjectCreated", localProvider, 1);
  console.log("📟 SetPurpose events:", projectCreatedEvents);

  const projectMintedEvents = useEventListener(readContracts, "ProjectContract", "ProjectMinted", localProvider, 1);
  console.log("📟 SetPurpose events:", projectMintedEvents);

  // const unapprovedTokens = readContracts.
  const unapprovedTokens = [];
  return (
    <div>
      <Center>
        {/* <Flex align="center" justify="center" height="50vh" direction="column"> */}
        {/* <Box p="6" m="4" borderWidth="1px" rounded="lg" flexBasis={['auto', '45%']} boxShadow="dark-lg">
          <Stack direction={["column", "row"]} mb={2} align="left">
            <Text>Tokenization requests</Text>
            <Text color="teal" fontWeight="700">Carbon Credits</Text>
          </Stack>
          <Divider />
          readContracts.YourContract
        </Box> */}
        <Box p="6" m="4" borderWidth="1px" rounded="lg" flexBasis={["auto", "45%"]}>
          <Heading as="h3" size="lg" mb="2">
            Tokenization requests
          </Heading>
          <div>
            <List
              bordered
              dataSource={projectCreatedEvents}
              renderItem={item => {
                return <List.Item>{item}</List.Item>;
              }}
            />
          </div>
        </Box>
        {/* </Flex> */}
      </Center>
    </div>
  );
}
