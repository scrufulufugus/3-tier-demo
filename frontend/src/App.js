import logo from './logo.svg';
import './App.css';
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import FrontPage from "./FrontPage";
import Login from "./Login";

const router = createBrowserRouter([
  { path: "/", element: <FrontPage/> },
  { path: "/login", element: <Login/> },
  { path: "/profile", element: <Login/> },
  { path: "/logout", element: <Login/> },
]);

function App() {
  return (<RouterProvider router={router} />);
}

export default App;
