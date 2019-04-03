import 'phoenix_html';
import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { BrowserRouter as Router, Route } from 'react-router-dom';
import HomePage from '@/pages/HomePage';
import LoginPage from '@/pages/LoginPage';
import AfterPage from '@/pages/AfterPage';
import RegistrationPage from '@/pages/RegistrationPage';
import { ThemeProvider } from "@/ThemeProvider"

const App = () => (
	<Router>
		<ThemeProvider>
			<Route path="/app/success" component={AfterPage} />
			<Route path="/app/register" component={RegistrationPage} />
			<Route path="/app/login" component={LoginPage} />
			<Route path="/" exact component={HomePage} />
		</ThemeProvider>
	</Router>
)

ReactDOM.render(<App />, document.getElementById('body'));
