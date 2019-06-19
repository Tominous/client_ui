import React from 'react';
import { Route, IndexRoute } from 'react-router';
import App from './containers/App';
import Accounts from './containers/Accounts.js';
import Network from './containers/Network.js';
import NotFoundPage from './containers/NotFoundPage.js';

export default (
  <Route>
    <Route path="/" component={App}>
    <IndexRoute component={Accounts}/>
      <Route path="accounts" component={Accounts}/>
      <Route path="network" component={Network}/>
      <Route path="*" component={NotFoundPage}/>
    </Route>
  </Route>
);
