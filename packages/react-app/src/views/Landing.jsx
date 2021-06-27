import React from "react";
import { Text, Flex, Box } from "@chakra-ui/react";
import {Button, Heading, SubHeading} from "./styles/Landing"
import { ArrowForwardIcon } from '@chakra-ui/icons'

export default function Landing() {
  
return (
    <div>
      <Flex align="center" justify="center" height="80vh" direction="column">
        <Box>
          <Text fontFamily="Cousine"> - pre-alpha </Text>
        {/* title needs to change */}
          <Heading as="h3" size="lg" mb={4}>Tokenize your Carbon Credits</Heading>
          <SubHeading>Join us in creating a carbon neutral Web3 and beyond</SubHeading>
          <Button>Get Started <ArrowForwardIcon/></Button>
        </Box>
      </Flex>
    </div>
  );
}
