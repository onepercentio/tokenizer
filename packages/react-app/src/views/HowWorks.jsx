import React from "react";
import { Text, Flex, Box } from "@chakra-ui/react";
import {Button, Heading, SubHeading} from "./styles/Landing"
import { ArrowForwardIcon } from '@chakra-ui/icons'

export default function HowWorks() {
  
return (
    <div>
      <Flex align="center" justify="center" height="80vh" direction="column">
        <Box>
          <Text fontFamily="Cousine"> - pre-alpha </Text>
        {/* title needs to change */}
          <Heading as="h3" size="lg" mb={4}>Bring carbon assets onchain</Heading>
          <SubHeading>How does tokenization work?</SubHeading>
          <Text>1. Initialise the process by minting your retirement claim NFT which is sent to your wallet - <a href="/accounts">view your retirment claims</a></Text>
          <Text>2. The DAO manually confirms that you have retired the credits on the off chain registry</Text>
          <Text>3. The "retirement confirmation status" of your NFT is updated</Text>
          <Text>4. You can now send your NFT to the "project vintage pool" which then mints ERC20 tokens, and send them back to your wallet.</Text>
        </Box>
      </Flex>
    </div>
  );
}
