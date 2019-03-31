import 'phoenix_html';
import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { BrowserRouter as Router, Route } from 'react-router-dom';
import HomePage from '@/pages/HomePage';

class App extends React.Component {
	render() {
		return (
			<Router>
				<Route path="/" exact component={HomePage} />
			</Router>
		);
	}
}

ReactDOM.render(<App />, document.getElementById('body'));
