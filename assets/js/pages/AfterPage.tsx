import * as React from 'react';
import { Link } from "react-router-dom";
import { withStyles, Theme } from '@material-ui/core/styles';
import Icon from '@material-ui/core/Icon';

const styles = (theme: Theme) => ({
  button: {
    marginTop: '1rem',
  },

});

class AfterRegistration extends React.Component<any, any> {
  render() {

    const { classes } = this.props;

    return (
      <div className="panel-wrapper">
        {/* <a href="//www.yipcart.com" class="yipcart-logo">YipCart</a> */}
        <div className="feature-panel feature-panel--enterprise woman-picture1" style={{ width: '50%' }}>
          <div className="enterprise-panel__content">
            <h2 className="enterprise-panel__header">
              <small className="enterprise-panel__subheader">
                <img src="/images/yp-white-logo.svg" className="enterprise-panel__logos" />
              </small>
              Management tool, built for African SME
						</h2>
            <p className="enterprise-panel__caption">
              Empower your business. Build customer relationship. Track business performance.
						</p>
          </div>
          <div className="enterprise-panel__footer">
            <p className="enterprise-panel__footer__lead">
              ...
						</p>
            {/* <img src="/" className="enterprise-panel__logos" /> */}
          </div>
        </div>

        <div className="main-panel registrationPage">
          <div className="main-panel__table">
            <div className="main-panel__table-cell">
              <div className="main-panel__content">
                <div className="main-panel__form">
                  <ul className="usageBlock usageBlockCorrect">
                    <li className="usageListItem">
                      {/* <Icon className="text-success">check_circle_outline</Icon> */}
                      <div className="usageListItemContent">
                        <div>
                          <h4>Account created!</h4>
                          <p>Your account has been created and a confirmation email has been sent to <span className="text-success">gbenga@badmos.com</span></p>
                        </div>
                      </div>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
export default withStyles(styles)(AfterRegistration);
