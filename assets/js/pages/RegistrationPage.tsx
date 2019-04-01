import * as React from 'react';
import { Link } from "react-router-dom";
import { withStyles, Theme } from '@material-ui/core/styles';
import TextField from '@material-ui/core/TextField';
import Button from '@material-ui/core/Button';
import Divider from '@material-ui/core/Divider';

const styles = (theme: Theme) => ({
    button: {
        marginTop: '1rem',
    },

});

class RegistrationPage extends React.Component<any, any> {
    render() {

        const { classes } = this.props;

        return (
            <div className="panel-wrapper">
                <a href="//www.invisionapp.com" class="invision-logo">YipCart</a>
                <div className="feature-panel feature-panel--enterprise" style={{width: '50%'}}>
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

                <div className="main-panel registrationPage">

                    <div className="main-panel__table">
                        <div className="main-panel__table-cell">

                            <div className="main-panel__switch">
                                <span className="main-panel__switch__text">
                                    Already have an account?
								</span>
                                <Link to="/app/login">
                                    <Button color="primary" className="main-panel__switch__button">
                                        Sign In
                                    </Button>
                                </Link>
                            </div>

                            <div className="main-panel__content">

                                

                                <form className="main-panel__form" action="/login/authenticate" method="post" novalidate="">

                                    <h1 className="main-panel__heading"  style={{display: 'none'}}>
                                        Register today for free.
                                        <small className="main-panel__subheading">
                                            Start using YipCart today and bla bla bla.
                                        </small>
                                    </h1>

                                    <h1 className="main-panel__heading">
                                        Hi Adeola, tell us about your business
                                    </h1>

                                    <div className="step1of2Form" style={{display: 'none'}}>
                                        <TextField
                                            id="outlined-with-placeholder"
                                            label="Full name"
                                            placeholder="Segun Ayomide"
                                            margin="normal"
                                            variant="outlined"
                                            style={{ width: '100%' }}
                                        />

                                        <TextField
                                            id="outlined-with-placeholder"
                                            label="Email address"
                                            placeholder="gbenga@badmos.com"
                                            margin="normal"
                                            variant="outlined"
                                            style={{ width: '100%' }}
                                        />

                                        <TextField
                                            id="outlined-with-placeholder"
                                            label="Password"
                                            placeholder="type password"
                                            margin="normal"
                                            variant="outlined"
                                            style={{ width: '100%' }}
                                        />

                                        <Divider style={{marginTop: '1.5rem'}}/>

                                        <small className="main-panel__subheading">
                                            Are you male or female
                                        </small>
                                    </div>

                                    <div className="step2of2Form">
                                        <TextField
                                            id="outlined-with-placeholder"
                                            label="Business name"
                                            placeholder="Ajose shoes"
                                            margin="normal"
                                            variant="outlined"
                                            style={{ width: '100%' }}
                                        />

                                        <TextField
                                            id="outlined-with-placeholder"
                                            label="Business link"
                                            placeholder="ajostore"
                                            margin="normal"
                                            variant="outlined"
                                            style={{ width: '100%' }}
                                        />

                                        <TextField
                                            id="outlined-with-placeholder"
                                            label="Phone number"
                                            placeholder="type password"
                                            margin="normal"
                                            variant="outlined"
                                            style={{ width: '100%' }}
                                        />

                                        <TextField
                                            id="outlined-with-placeholder"
                                            label="Business email"
                                            placeholder="Email address"
                                            margin="normal"
                                            variant="outlined"
                                            style={{ width: '100%' }}
                                        />

                                        <TextField
                                            id="standard-multiline-flexible"
                                            label="Business description"
                                            placeholder="You can write short brief for now and edit later"
                                            margin="normal"
                                            variant="outlined"
                                            style={{ width: '100%' }}
                                            multiline
                                            rows="4"
                                        />

                                    </div>

                                    <div className="d-flex align-item-center flex-wrap">
                                        <Button variant="outlined" color="primary" className={classes.button} style={{marginRight: '2rem'}}>
                                            Back
										</Button>

                                        <Button variant="contained" color="primary" className={classes.button}>
                                            Create Account
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
export default withStyles(styles)(RegistrationPage);
