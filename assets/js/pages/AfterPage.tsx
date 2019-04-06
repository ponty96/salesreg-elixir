import * as React from 'react';


class AfterRegistration extends React.Component<any, any> {
  render() {


    return (
      <div className="panel-wrapper">
        {/* <a href="//www.yipcart.com" class="yipcart-logo">YipCart</a> */}
        <div className="feature-panel feature-panel--enterprise woman-picture1">
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

        <div className="main-panel">
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
export default (AfterRegistration);
