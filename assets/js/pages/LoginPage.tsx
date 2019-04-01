import * as React from 'react';
import { Link } from "react-router-dom";
import { withStyles, Theme } from '@material-ui/core/styles';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';

const styles = (theme: Theme) => ({
	button: {
	  marginTop: '1rem',
	},
	
  });

class LoginPage extends React.Component< any, any> {
	render() {

		const { classes } = this.props;

		return (
			<div className="panel-wrapper">
				<a href="//www.invisionapp.com" class="invision-logo">YipCart</a>
				<div className="feature-panel feature-panel--enterprise" >
					<div className="enterprise-panel__content">
						<h2 className="enterprise-panel__header">
							<small className="enterprise-panel__subheader">
								YipCart Lite
							</small>
							Management tool, built for African SME
						</h2>
						<p className="enterprise-panel__caption">
							Empower your business. Build customer relationship. Track business performance.
						</p>
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
								<Link to="/app/register">
								<Button color="primary" className="main-panel__switch__button">
									Get Started
								</Button>
							</Link>
							</div>

							<div className="main-panel__content">

								<h1 className="main-panel__heading">
									Sign in to YipCart.
									<small className="main-panel__subheading">
										Enter your details below.
									</small>
								</h1>
									
								<form className="main-panel__form" action="/login/authenticate" method="post" novalidate="">
								
									<div>
										<TextField
										id="outlined-with-placeholder"
										label="Email address"
										placeholder="gbenga@badmos.com"
										margin="normal"
										variant="outlined"
										style={{ width: '100%' }}
										/>
									</div>

									<div>
										<TextField
										id="outlined-with-placeholder"
										label="Password"
										placeholder="type password"
										margin="normal"
										variant="outlined"
										style={{ width: '100%' }}
										/>
									</div>

									<div className="d-flex align-item-center justify-content-between flex-wrap">

										<Button color="primary" className={classes.button}>
											Forgot Password
										</Button>

										<Button variant="contained" color="primary" className={classes.button}>
											Sign In
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
export default withStyles(styles)(LoginPage);
