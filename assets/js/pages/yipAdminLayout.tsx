import * as React from 'react';

class yipAdminLayout extends React.Component<any, any> {
    render() {

        return (
            <div className="ypAdminLayout">
                <header className="yipAppBar-fixed yipAppBar-primary yipAppBar-2">
                    <div className="yipAppBar-regular">
                        <button className="yipAppBar-toggle" tabIndex={0} aria-label="Open Drawer" type="button">
                            <span className="yipAppBar-toggle-icon">
                                <svg className="yipAppBar-toggle-icon-1"
                                     focusable="false"
                                     viewBox="0 0 24 24"
                                     aria-hidden="true"
                                     role="presentation">
                                    <path fill="none" d="M0 0h24v24H0z">
                                    </path>
                                    <path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z">
                                    </path>
                                </svg>
                            </span>
                        </button>

                        <img src={'/images/yp-logo-color.svg'} style={{ maxWidth: '7rem' }}/>

                        <div className="yipAppBar-search">
                            <div className="yipAdminLayout-searchIcon">
                                <svg className="yipAdminLayout-searchIcon-1"
                                     focusable="false"
                                     viewBox="0 0 24 24"
                                     aria-hidden="true"
                                     role="presentation">
                                    <path
                                        d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z">
                                    </path>
                                    <path fill="none" d="M0 0h24v24H0z">
                                    </path>
                                </svg>
                            </div>

                            <div className="yipAppBar-InputBase yipAppBar-InputBase-1">
                                <input className="yipAppBar-InputBase-input yipAppBar-InputBase-input-1"
                                       placeholder="Search…" type="text"
                                       value=""/>
                            </div>
                        </div>

                        <div className="AdminLayout-grow-5">
                        </div>

                        <div className="yipAppBarIcon-AdminLayout">
                            <button
                                className="yipAppBar-IconButton-62 yipAppBar-IconButton"
                                tabIndex={0}
                                type="button">
                        <span className="yipAppBar-IconButton-label">
                            <span className="yipAppBar-Badge">
                                <svg className="yipAppBar-Badge-1"
                                     focusable="false"
                                     viewBox="0 0 24 24"
                                     aria-hidden="true"
                                     role="presentation">
                                    <path
                                        d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z">
                                    </path>
                                </svg>
                                <span className="yipAppBar-Badge-colorSecondary-1 yipAppBar-Badge-colorSecondary">17</span>
                            </span>
                        </span>
                            </button>
                        </div>
                    </div>
                </header>

                <aside className="yipAdminLayout-sideNav-1 yipAdminLayout-sideNav">
                    <div className="yipAdminLayout-drawerPaper yipAdminLayout-drawerPaper">
                        <div className="yipAdminLayout-toolbar">
                        </div>
                        <ul className="yipAsideList-root">
                            <div className="yipAsideList-item yipAsideList-item-1"
                                 tabIndex={0}
                                 role="button">
                                <div className="yipAsideList-icon">
                                    <svg className="yipAsideList-icon-1"
                                         focusable="false"
                                         viewBox="0 0 24 24"
                                         aria-hidden="true"
                                         role="presentation">
                                        <path d="M19 3H4.99c-1.11 0-1.98.9-1.98 2L3 19c0 1.1.88 2 1.99 2H19c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 12h-4c0 1.66-1.35 3-3 3s-3-1.34-3-3H4.99V5H19v10zm-3-5h-2V7h-4v3H8l4 4 4-4z">
                                        </path>
                                        <path fill="none" d="M0 0h24v24H0V0z">
                                        </path>
                                    </svg>
                                </div>
                                <div className="yipAsideList-text">
                                    <span className="yipAsideList-text-1">Home</span>
                                </div>
                                <span className="MuiTouchRipple-root-174">
                                </span>
                            </div>

                            <div className="yipAsideList-item yipAsideList-item-1"
                                 tabIndex={0}
                                 role="button">
                                <div className="yipAsideList-icon">
                                    <svg className="yipAsideList-icon-1"
                                         focusable="false"
                                         viewBox="0 0 24 24"
                                         aria-hidden="true"
                                         role="presentation">
                                        <path d="M19 3H4.99c-1.11 0-1.98.9-1.98 2L3 19c0 1.1.88 2 1.99 2H19c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 12h-4c0 1.66-1.35 3-3 3s-3-1.34-3-3H4.99V5H19v10zm-3-5h-2V7h-4v3H8l4 4 4-4z">
                                        </path>
                                        <path fill="none" d="M0 0h24v24H0V0z">
                                        </path>
                                    </svg>
                                </div>
                                <div className="yipAsideList-text">
                                    <span className="yipAsideList-text-1">Orders</span>
                                </div>
                                <span className="MuiTouchRipple-root-174">
                                </span>
                            </div>

                            <div className="yipAsideList-item yipAsideList-item-1"
                                 tabIndex={0}
                                 role="button">
                                <div className="yipAsideList-icon">
                                    <svg className="yipAsideList-icon-1"
                                         focusable="false"
                                         viewBox="0 0 24 24"
                                         aria-hidden="true"
                                         role="presentation">
                                        <path d="M19 3H4.99c-1.11 0-1.98.9-1.98 2L3 19c0 1.1.88 2 1.99 2H19c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 12h-4c0 1.66-1.35 3-3 3s-3-1.34-3-3H4.99V5H19v10zm-3-5h-2V7h-4v3H8l4 4 4-4z">
                                        </path>
                                        <path fill="none" d="M0 0h24v24H0V0z">
                                        </path>
                                    </svg>
                                </div>
                                <div className="yipAsideList-text">
                                    <span className="yipAsideList-text-1">Inventory</span>
                                </div>
                                <span className="MuiTouchRipple-root-174">
                                </span>
                            </div>
                        </ul>
                    </div>
                </aside>

                <main className="yipAdminLayout-content yipAdminLayout-content-bg">
                    <div className="yipAdminLayout-toolbar">
                    </div>
                    <div className="container-fluid">
                        <div className="row">
                            <div className="col-12">
                                <div className="alert alert-info alert-dismissible fade show" role="alert" style={{color: '#454f5b'}}>
                                    <h4 className="alert-heading">Welcome to YipCart!</h4>
                                    <p>Aww yeah, you successfully read this important alert message. This example text is going to run a bit longer so that you can see how spacing within an alert works with this kind of content.</p>
                                    <hr />
                                    <p className="mb-0">Whenever you need to, be sure to use margin utilities to keep things nice and tidy.</p>
                                    <button type="button" className="close" data-dismiss="alert" aria-label="Close">
                                        <span aria-hidden="true">&times;</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
            </div>
        );
    }
}

export default (yipAdminLayout);
