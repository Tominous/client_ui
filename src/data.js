import React from 'react';
import Assessment from 'material-ui/svg-icons/action/assessment';
import GridOn from 'material-ui/svg-icons/image/grid-on';
import PermIdentity from 'material-ui/svg-icons/action/perm-identity';
import Web from 'material-ui/svg-icons/av/web';
import {cyan600, pink600, purple600} from 'material-ui/styles/colors';
import ExpandLess from 'material-ui/svg-icons/navigation/expand-less';
import ExpandMore from 'material-ui/svg-icons/navigation/expand-more';
import ChevronRight from 'material-ui/svg-icons/navigation/chevron-right';

const data = {
  menus: [
    { text: 'accounts', icon: '', link: '/accounts' },
    { text: 'network', icon: '', link: '/network' },
    { text: 'contracts', icon: '', link: '/contracts' },
    { text: 'query', icon: '', link: '/query' },
    { text: 'contracts', icon: '', link: '/contracts' },
    { text: 'explore dag', icon: '', link: '/explore-dag' },
    { text: 'settings', icon: '', link: '/settings' },
    { text: 'docs', icon: '', link: '/docs' },
  ],
  accountPage: {
    items: [
      {id: 1, name: 'name 1', key: 'key', category: 'Category 1'},
      {id: 2, name: 'name 2', key: 'key', category: 'Category 2'},
      {id: 3, name: 'name 3', key: 'key', category: 'Category 3'},
      {id: 4, name: 'name 4', key: 'key', category: 'Category 4'},
      {id: 5, name: 'name 5', key: 'key', category: 'Category 5'},
      {id: 6, name: 'name 6', key: 'key', category: 'Category 6'},
      {id: 7, name: 'name 7', key: 'key', category: 'Category 7'},
      {id: 8, name: 'name 8', key: 'key', category: 'Category 8'}
    ]
  },
};

export default data;
