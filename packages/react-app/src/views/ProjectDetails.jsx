import React from "react";
import { Heading, Text, Flex, Box, SimpleGrid, Stack, Divider, Center } from "@chakra-ui/react";
import { useContractReader, useEventListener, useResolveName } from "../hooks";
import projects from "../verra/projects.js";
import { AppContainer, Container } from "./styles/Tokenize";
import { Button } from "./styles/Landing";

export default function ProjectDetails({
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
  const url = window.location.href.split("/");
  const serialNo = url.pop().split("-");
  let project = "";

  const path = url.pop();
  const tokenId = path.replace(address, "");

  for (let i = 0; i < projects.length; i++) {
    if (projects[i].resourceIdentifier === serialNo[9]) {
      project = projects[i];
    }
  }

  console.log("project is ", project === "");

  function notifyDiscord(serialNum) {
    const request = new XMLHttpRequest();
    request.open("POST", process.env.REACT_APP_NOTIFY_TOKENIZATION);
    // replace the url in the "open" method with yours
    request.setRequestHeader("Content-type", "application/json");
    const params = {
      username: "Tokenization request",
      avatar_url:
        "https://uploads-ssl.webflow.com/5e59b1719e288f9894e1576f/5e5b0d8f2089e571d48b4cfa_logo_toucan_256.png",
      content: `Tokenization request for ${process.env.REACT_APP_SITE_URL}tokenizer/${serialNum}`,
    };
    request.send(JSON.stringify(params));
  }

  return (
    <div>
      <Container>
        <AppContainer>
          {project === "" || serialNo.length < 11 ? (
            <Heading>Invalid Serial Number</Heading>
          ) : (
            <>
              <Stack direction={["column", "row"]} mb={2}>
                <Text fontSize="20px">Tokenize your</Text>
                <Text fontSize="20px" color="#00F6AA">
                  Carbon Credits
                </Text>
              </Stack>
              <Divider />
              <Text fontSize="30" mt={4} mb={6}>
                Confirm project details
              </Text>
              <img
                src="https://verra.org/wp-content/uploads/2016/07/6289228289_7be6a5c962_b.jpg"
                alt="Project details"
              />
              <br />
              <br />
              <SimpleGrid fontFamily="Cousine" columns={2} spacing={10}>
                <Box align="right" fontWeight="bold">
                  Project Name:{" "}
                </Box>
                <Box align="left">{project.resourceName}</Box>
                <Box align="right" fontWeight="bold">
                  Location:{" "}
                </Box>
                <Box align="left">
                  {project.country}, {project.region}
                </Box>
                <Box align="right" fontWeight="bold">
                  Date:{" "}
                </Box>
                <Box align="left"> {project.createDate}</Box>
                <Box align="right" fontWeight="bold">
                  Program:{" "}
                </Box>
                <Box align="left"> {project.program}</Box>
                <Box align="right" fontWeight="bold">
                  Protocol:{" "}
                </Box>
                <Box align="left"> {project.protocols}</Box>
                <Box align="right" fontWeight="bold">
                  Number of Credits:
                </Box>
                <Box align="left"> {project.estAnnualEmissionReductions}</Box>
              </SimpleGrid>
              <br />

              <Button
                onClick={() => {
                  console.log("mint batch!!!");
                  console.log(`Notify discord at ${process.env.REACT_APP_NOTIFY_TOKENIZATION}`);
                  // eslint-disable-next-line no-alert
                  alert(
                    "You will see a notification when your transcation has been processed. This may take a moment.",
                  );
                  notifyDiscord(serialNo.join("-"));
                  tx(
                    writeContracts.BatchCollection.updateBatchWithData(
                      address,
                      tokenId,
                      project.resourceIdentifier,
                      serialNo[10] + "-" + serialNo[11],
                      serialNo.join("-"),
                      project.estAnnualEmissionReductions,
                    ),
                  );
                }}
              >
                Tokenize
              </Button>
            </>
          )}
        </AppContainer>
      </Container>
    </div>
  );
}
