import React, { useState } from "react";
import { Text, Heading, Input, Divider, Stack, Switch, FormControl, FormLabel } from "@chakra-ui/react";
import { parseEther, formatEther } from "@ethersproject/units";
import { useHistory } from "react-router-dom";
import { useContractReader, useEventListener, useResolveName } from "../hooks";
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
  
  const history = useHistory();

  const [serialNo, setSerialNo] = useState("");
  const [proof, setProof] = useState("");
  const [email, setEmail] = useState("");
  const [projectName, setProjectName] = useState("");
  const [inputKind, setInputKind] = useState(true);

  const url = window.location.href.split("/");
  const path = url.pop();

  async function onChangeSerialNo(event) {
    await setSerialNo(event.target.value);
  }

  async function onChangeEmail(event) {
    await setEmail(event.target.value);
  }

  // async function onChangeProof(event) {
  //   await setProof(event.target.value);
  // }

  async function onChangeProjectName(event) {
    await setProjectName(event.target.value);
  }

  const handleChangeInputKind = () => setInputKind(!inputKind);

  function takeToProjectDetails() {
    if (inputKind) history.push("/tokenizer/" + path + "/" + serialNo);
    // eslint-disable-next-line no-alert
    else alert("Currently, we are unable to tokenize based on project name. Please enter Serial Number");
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
          <Stack direction={["column", "row"]} mt={4} mb={4}>
            <Text>Serial Number</Text>
            <Switch onChange={handleChangeInputKind} />
            <Text>Project Name</Text>
          </Stack>

          {inputKind ? (
            <>
              <FormControl id="proof-retirement" isRequired>
                <FormLabel fontWeight="700">Serial number</FormLabel>
                <Input fontFamily="Cousine" placeholder="Enter Serial Number" onChange={onChangeSerialNo} />
              </FormControl>

              <Text align="left" mb={3}>
                e.g: 9344-82392553-82392562-VCS-VCU-262-VER-BR-14-1686-01012017-31122017-1
              </Text>

              {/* <FormControl id="proof-retirement" isRequired>
                <FormLabel fontWeight="700">Proof of retirement</FormLabel>
                <Input fontFamily="Cousine" placeholder="Proof of retirement" onChange={onChangeProof} />
              </FormControl>

              <Text align="left" mb={3}>
                e.g: https://registry.verra.org/myModule/rpt/myrpt.asp?r=206&h=132788
              </Text> */}

              <FormControl id="proof-retirement">
                <FormLabel fontWeight="700">Enter your email</FormLabel>
                <Input
                  fontFamily="Cousine"
                  placeholder="Optionally be notified of retirement confirmation"
                  onChange={onChangeEmail}
                />
              </FormControl>

              <br />
            </>
          ) : (
            <FormControl id="proof-retirement" isRequired>
              <FormLabel fontWeight="700">Project Name</FormLabel>
              <Input fontFamily="Cousine" placeholder="Enter Project Name" onChange={onChangeProjectName} />
            </FormControl>
          )}

          <Button onClick={takeToProjectDetails}>Continue</Button>
        </AppContainer>
      </Container>
    </div>
  );
}
