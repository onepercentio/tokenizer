import styled from "styled-components";

export const Button = styled.button`
  background: #1c1c1c;
  color: #fff;
  padding: 8px 22px 8px 22px;
  width: fit-content;
  font-family: Cousine, monospace;
  box-shadow: 0px 4px 4px rgba(135, 124, 124, 0.44);
  border-radius: 30px;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: auto;
  margin-top: 12px;
  &:hover {
    color: #00f6aa;
  }
`;

export const Heading = styled.h1`
  font-family: Poppins, Sans-serif;
  font-style: normal;
  font-weight: 500;
  font-size: 56px;
  line-height: 96px;
  text-align: center;
  letter-spacing: -0.02em;
`;

export const SubHeading = styled.h1`
  font-family: Cousine, monospace;
  width: 50%;
  margin: auto;
  margin-bottom: 5%;
  font-size: 20px;
`;
