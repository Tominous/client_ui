import React from 'react';
import { Route, IndexRoute } from 'react-router';
import App from './containers/App';
import Accounts from './containers/Accounts.js';
import Network from './containers/Network.js';
import Contracts from './containers/Contracts.js';
import Docs from './containers/Docs.js';
import ExploreDag from './containers/ExploreDag.js';
import Query from './containers/Query.js';
import Settings from './containers/Settings.js';
import Landing from './containers/Landing.js';
import NotFoundPage from './containers/NotFoundPage.js';

export default (
  <Route>
    <Route path="/" component={App}>
    <IndexRoute component={Landing}/>
      <Route path="landing" component={Landing}/>
      <Route path="accounts" component={Accounts}/>
      <Route path="network" component={Network}/>
      <Route path="contracts" component={Contracts}/>
      <Route path="docs" component={Docs}/>
      <Route path="explore-dag" component={ExploreDag}/>
      <Route path="query" component={Query}/>
      <Route path="settings" component={Settings}/>
      <Route path="*" component={NotFoundPage}/>
    </Route>
  </Route>
);
