import * as React from 'react';
import { withStyles, Theme } from '@material-ui/core/styles';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';

const styles = (theme: Theme) => ({
	button: {
	  margin: theme.spacing.unit,
	},
	input: {
	  display: 'none',
	},
  });

class HomePage extends React.Component< any, any> {
	render() {

		const { classes } = this.props;

		return (
			<div className="panel-wrapper">
				<a href="//www.invisionapp.com" class="invision-logo">InVision</a>
				<div className="feature-panel feature-panel--enterprise">
					<div className="enterprise-panel__content">
						<h2 className="enterprise-panel__header">
							<small className="enterprise-panel__subheader">
								YipCart
							</small>
							Your unified, scalable workflow—all in one place
						</h2>
						<p className="enterprise-panel__caption">
							Empower smarter design. Go to market faster. Spark design-driven innovation.
						</p>
						<a href="/" target="_blank" class="enterprise-panel__button">
							Learn More
						</a>
					</div>
					<div className="enterprise-panel__footer">
						<p className="enterprise-panel__footer__lead">
							TRUSTED BY THE WORLD'S SMARTEST COMPANIES
						</p>
						<img src="/images/phoenix.png" className="enterprise-panel__logos" />
					</div>
				</div>

				<div className="main-panel">

					<div className="main-panel__table">
						<div className="main-panel__table-cell">

							<div className="main-panel__switch">
								<span className="main-panel__switch__text">
									Don't have an account?
								</span>
								<a href="/d/signup?redir=" className="main-panel__switch__button">
									Get Started
								</a>
							</div>

							<div className="main-panel__content">

								<h1 className="main-panel__heading">
									Sign in to YipCart.
									<small className="main-panel__subheading">
										Enter your details below.
									</small>
								</h1>
									
								<form className="main-panel__form Bizible-Exclude" action="/d/login/authenticate" method="post" novalidate="">
								
								<div>
									<TextField
									id="outlined-with-placeholder"
									label="With placeholder"
									placeholder="Placeholder"
									margin="normal"
									variant="outlined"
									style={{ margin: 8, width: '100%' }}
									/>
								</div>

								<div>
									<TextField
									id="outlined-with-placeholder"
									label="With placeholder"
									placeholder="Placeholder"
									margin="normal"
									variant="outlined"
									style={{ margin: 8, width: '100%' }}
									/>
								</div>

							

									<div className="text--center">
									<Button variant="contained" color="primary" className={classes.button}>
										Primary
									</Button>
									</div>
								</form>

							</div>

						</div>
					</div>

				</div>
			</div>
		);
	}
}
export default withStyles(styles)(HomePage);
