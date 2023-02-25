<<<<<<< HEAD
import React from "react";
import { render, screen } from "@testing-library/react";
import { App } from "./common/App";

test("renders learn react link", () => {
=======
import React from 'react';
import { render, screen } from '@testing-library/react';
import { App } from './common/App';

test('renders learn react link', () => {
>>>>>>> e0784b5 (Change to type script and add performance)
  render(<App />);
  const linkElement = screen.getByText(/learn react/i);
  expect(linkElement).toBeInTheDocument();
});
